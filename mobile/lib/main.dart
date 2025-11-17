import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// google_fonts removed - using default text theme
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.light();
    return MaterialApp(
      title: 'Boutique - Gestion de dettes',
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme,
        colorScheme: baseTheme.colorScheme.copyWith(primary: Colors.black87, secondary: Colors.grey[600]),
        appBarTheme: AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0; // 0: Debts, 1: Clients

  List debts = [];
  List clients = [];
  String boutiqueName = '';

  String get apiHost {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  @override
  void initState() {
    super.initState();
    _loadBoutique();
    fetchClients();
    fetchDebts();
  }

  Future _loadBoutique() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('boutique_name');
    if (name == null || name.isEmpty) {
      await Future.delayed(Duration(milliseconds: 200));
      _askBoutiqueName();
    } else {
      setState(() => boutiqueName = name);
    }
  }

  Future _askBoutiqueName() async {
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: Text('Créer votre boutique'),
        content: TextField(controller: ctl, decoration: InputDecoration(labelText: 'Nom de la boutique')),
        actions: [
          ElevatedButton(onPressed: () => Navigator.of(c).pop(false), child: Text('Ignorer')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text('OK')),
        ],
      ),
    );
    if (ok == true && ctl.text.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('boutique_name', ctl.text.trim());
      setState(() => boutiqueName = ctl.text.trim());
    }
  }

  Future fetchClients() async {
    try {
      final res = await http.get(Uri.parse('$apiHost/clients')).timeout(Duration(seconds: 8));
      if (res.statusCode == 200) {
        setState(() => clients = json.decode(res.body) as List);
      }
    } on TimeoutException {
      print('Timeout fetching clients');
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  Future fetchDebts({String? query}) async {
    try {
      final res = await http.get(Uri.parse('$apiHost/debts')).timeout(Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List;
        if (query != null && query.isNotEmpty) {
          setState(() => debts = list.where((d) {
                final clientName = _clientNameForDebt(d)?.toLowerCase() ?? '';
                return clientName.contains(query.toLowerCase());
              }).toList());
        } else {
          setState(() => debts = list);
        }
      }
    } on TimeoutException {
      print('Timeout fetching debts');
    } catch (e) {
      print('Error fetching debts: $e');
    }
  }

  String? _clientNameForDebt(dynamic d) {
    if (d == null) return null;
    final cid = d['client_id'];
    if (cid == null) return null;
    final c = clients.firstWhere((x) => x['id'] == cid, orElse: () => null);
    return c != null ? c['name'] : null;
  }

  Future<int?> createClient() async {
    final numberCtl = TextEditingController();
    final nameCtl = TextEditingController();
    final avatarCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Ajouter un client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: numberCtl, decoration: InputDecoration(labelText: 'Numéro (optionnel)')),
            TextField(controller: nameCtl, decoration: InputDecoration(labelText: 'Nom')),
            TextField(controller: avatarCtl, decoration: InputDecoration(labelText: 'URL Avatar (optionnel)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: Text('Ajouter')),
        ],
      ),
    );
    if (ok == true && nameCtl.text.trim().isNotEmpty) {
      try {
        final body = {'client_number': numberCtl.text.trim(), 'name': nameCtl.text.trim(), 'avatar_url': avatarCtl.text.trim()};
        final res = await http.post(Uri.parse('$apiHost/clients'), headers: {'Content-Type': 'application/json'}, body: json.encode(body)).timeout(Duration(seconds: 8));
        if (res.statusCode == 201) {
          // try to parse created object (expecting backend returns created client)
          try {
            final created = json.decode(res.body);
            await fetchClients();
            if (created is Map && created['id'] != null) return created['id'] as int?;
          } catch (_) {
            await fetchClients();
            return clients.isNotEmpty ? clients.last['id'] as int? : null;
          }
        }
      } on TimeoutException {
        print('Timeout creating client');
      } catch (e) {
        print('Error creating client: $e');
      }
    }
    return null;
  }

  Future createDebt() async {
    if (clients.isEmpty) {
      final add = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text('Aucun client'), content: Text('Aucun client trouvé. Voulez-vous en ajouter un maintenant ?'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text('Annuler')), ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: Text('Ajouter client'))]));
      if (add == true) {
        final newId = await createClient();
        if (newId != null) {
          await fetchClients();
          // reopen createDebt flow now that a client exists
          await createDebt();
        }
      }
      return;
    }
    final amountCtl = TextEditingController();
    final notesCtl = TextEditingController();
    int? selectedClientId = clients.first['id'];
    DateTime? dueDate;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Ajouter dette'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedClientId,
                items: clients.map<DropdownMenuItem<int>>((cl) => DropdownMenuItem(value: cl['id'], child: Text(cl['name']))).toList(),
                onChanged: (v) => selectedClientId = v,
                decoration: InputDecoration(labelText: 'Client'),
              ),
              TextField(controller: amountCtl, decoration: InputDecoration(labelText: 'Montant'), keyboardType: TextInputType.number),
              SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text(dueDate == null ? 'Échéance: -' : 'Échéance: ${DateFormat.yMd().format(dueDate!)}')),
                TextButton(onPressed: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d!=null) setState((){ dueDate=d; }); }, child: Text('Choisir'))
              ]),
              TextField(controller: notesCtl, decoration: InputDecoration(labelText: 'Notes')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: Text('Ajouter')),
        ],
      ),
    );
    if (ok == true && selectedClientId != null && amountCtl.text.trim().isNotEmpty) {
      try {
        final body = {'client_id': selectedClientId, 'amount': double.tryParse(amountCtl.text) ?? 0.0, 'due_date': dueDate == null ? null : DateFormat('yyyy-MM-dd').format(dueDate!), 'notes': notesCtl.text};
        final res = await http.post(Uri.parse('$apiHost/debts'), headers: {'Content-Type': 'application/json'}, body: json.encode(body)).timeout(Duration(seconds: 8));
        if (res.statusCode == 201) {
          await fetchDebts();
        }
      } on TimeoutException {
        print('Timeout creating debt');
      } catch (e) {
        print('Error creating debt: $e');
      }
    }
  }

  Future showDebtDetails(Map d) async {
    // fetch payments
    List payments = [];
    try {
      final pres = await http.get(Uri.parse('$apiHost/debts/${d['id']}/payments')).timeout(Duration(seconds: 6));
      if (pres.statusCode == 200) payments = json.decode(pres.body) as List;
    } catch (e) {
      print('Error fetching payments: $e');
    }
    final totalPaid = payments.fold<double>(0.0, (s, p) => s + (double.tryParse(p['amount'].toString()) ?? 0.0));
    final remaining = (double.tryParse(d['amount'].toString()) ?? 0.0) - totalPaid;

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Détail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${_clientNameForDebt(d) ?? '-'}', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Montant: €${d['amount']}'),
            Text('Payé: €${totalPaid.toStringAsFixed(2)}'),
            Text('Reste: €${remaining.toStringAsFixed(2)}', style: TextStyle(color: remaining <= 0 ? Colors.green : Colors.red)),
            SizedBox(height: 8),
            Text('Échéance: ${d['due_date'] ?? '-'}'),
            SizedBox(height: 8),
            Text('Notes: ${d['notes'] ?? '-'}'),
            SizedBox(height: 12),
            Text('Paiements récents:', style: TextStyle(fontWeight: FontWeight.w600)),
            ...payments.map<Widget>((p) => ListTile(title: Text('€${p['amount']}'), subtitle: Text('${DateFormat.yMd().add_jm().format(DateTime.parse(p['paid_at']))}'))).take(5),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Fermer')),
          ElevatedButton(onPressed: () async { Navigator.of(ctx).pop(); await _addPayment(d); }, child: Text('Ajouter paiement')),
        ],
      ),
    );
  }

  Future _addPayment(Map d) async {
    final amountCtl = TextEditingController();
    DateTime paidAt = DateTime.now();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Ajouter paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountCtl, decoration: InputDecoration(labelText: 'Montant payé'), keyboardType: TextInputType.number),
            SizedBox(height: 8),
            Row(children: [Expanded(child: Text('Date: ${DateFormat.yMd().format(paidAt)}')), TextButton(onPressed: () async { final d = await showDatePicker(context: context, initialDate: paidAt, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d!=null) paidAt = d; setState((){}); }, child: Text('Choisir'))])
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text('Annuler')), ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: Text('Ajouter'))],
      ),
    );
    if (ok == true && amountCtl.text.trim().isNotEmpty) {
      try {
        final body = {'amount': double.tryParse(amountCtl.text) ?? 0.0, 'paid_at': paidAt.toIso8601String()};
        final res = await http.post(Uri.parse('$apiHost/debts/${d['id']}/pay'), headers: {'Content-Type': 'application/json'}, body: json.encode(body)).timeout(Duration(seconds: 8));
        if (res.statusCode == 201 || res.statusCode == 200) {
          await fetchDebts();
        }
      } catch (e) {
        print('Error adding payment: $e');
      }
    }
  }

  Widget _buildDebtsTab() {
    return RefreshIndicator(
      onRefresh: () async => await fetchDebts(),
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: debts.length,
        itemBuilder: (ctx, i) {
          final d = debts[i];
          final clientName = _clientNameForDebt(d) ?? 'Client inconnu';
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              title: Text(clientName, style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('€${d['amount']}'), SizedBox(height: 6), Text(d['notes'] ?? '')]),
              trailing: d['paid'] == true ? Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.chevron_right),
              onTap: () => showDebtDetails(d),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientsTab() {
    return RefreshIndicator(
      onRefresh: () async => await fetchClients(),
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: clients.length,
        itemBuilder: (ctx, i) {
          final c = clients[i];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.grey[200], child: c['avatar_url'] != null && c['avatar_url'] != '' ? CachedNetworkImage(imageUrl: c['avatar_url'], width: 40, height: 40, fit: BoxFit.cover) : Icon(Icons.person, color: Colors.grey)),
              title: Text(c['name'], style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(c['client_number'] ?? ''),
              onTap: () async {
                // show debts for client
                final res = await http.get(Uri.parse('$apiHost/debts/client/${c['id']}')).timeout(Duration(seconds: 8));
                if (res.statusCode == 200) {
                  final clientDebts = json.decode(res.body) as List;
                  await showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Dettes de ${c['name']}'), content: Container(width: 400, child: ListView(children: clientDebts.map<Widget>((d) => ListTile(title: Text('€${d['amount']}'), subtitle: Text('Reste: €${d['remaining'].toStringAsFixed(2)}'), onTap: () { Navigator.of(ctx).pop(); showDebtDetails(d); })).toList())), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Fermer'))]));
                }
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(boutiqueName.isEmpty ? 'Gestion de dettes' : boutiqueName, style: TextStyle(color: Colors.black87)),
        actions: [IconButton(onPressed: () { setState((){}); }, icon: Icon(Icons.sync, color: Colors.black54))],
      ),
      body: _tabIndex == 0 ? _buildDebtsTab() : _buildClientsTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) { setState(() => _tabIndex = i); },
        items: [BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Dettes'), BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients')],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { if (_tabIndex==0) await createDebt(); else await createClient(); },
        child: Icon(_tabIndex==0?Icons.add:Icons.person_add),
      ),
    );
  }
}
