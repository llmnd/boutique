import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

class AddDebtPage extends StatefulWidget {
  final String ownerPhone;
  final List clients;
  final int? preselectedClientId;

  AddDebtPage({required this.ownerPhone, required this.clients, this.preselectedClientId});

  @override
  _AddDebtPageState createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> {
  final _formKey = GlobalKey<FormState>();
  int? _clientId;
  final TextEditingController _amountCtl = TextEditingController();
  final TextEditingController _notesCtl = TextEditingController();
  DateTime? _due;
  bool _saving = false;

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
    _clientId = widget.preselectedClientId ?? (widget.clients.isNotEmpty ? widget.clients.first['id'] : null);
  }

  Future<void> _pickDue() async {
    final d = await showDatePicker(context: context, initialDate: _due ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null) setState(() => _due = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez choisir un client')));
      return;
    }
    setState(() => _saving = true);
    try {
      final body = {
        'client_id': _clientId,
        'amount': double.tryParse(_amountCtl.text.replaceAll(',', '')) ?? 0.0,
        'due_date': _due == null ? null : DateFormat('yyyy-MM-dd').format(_due!),
        'notes': _notesCtl.text
      };
      final headers = {'Content-Type': 'application/json', if (widget.ownerPhone.isNotEmpty) 'x-owner': widget.ownerPhone};
      final res = await http.post(Uri.parse('$apiHost/debts'), headers: headers, body: json.encode(body)).timeout(Duration(seconds: 8));
      if (res.statusCode == 201) {
        Navigator.of(context).pop(true);
      } else {
        await showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Erreur'), content: Text('Échec création dette: ${res.statusCode}\n${res.body}'), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('OK'))]));
      }
    } catch (e) {
      await showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Erreur'), content: Text('Erreur création dette: $e'), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('OK'))]));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('Ajouter une dette', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 640),
              child: Card(
                color: cardColor,
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client selector
                      Text('Client', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _clientId,
                        isExpanded: true,
                        items: widget.clients.map<DropdownMenuItem<int>>((cl) => DropdownMenuItem(value: cl['id'], child: Text(cl['name'] ?? 'Client'))).toList(),
                        onChanged: (v) => setState(() => _clientId = v),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor == Colors.white ? Colors.grey[50] : Colors.grey[900],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Amount field (large)
                      Text('Montant', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _amountCtl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.white24, fontSize: 28),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor == Colors.white ? Colors.grey[50] : Colors.grey[900],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Entrez un montant' : null,
                        autofocus: true,
                      ),
                      SizedBox(height: 14),

                      // Due date & quick info
                      Row(
                        children: [
                          Expanded(child: Text(_due == null ? 'Échéance : Aucune' : 'Échéance : ${DateFormat('dd/MM/yyyy').format(_due!)}', style: TextStyle(color: Colors.white70))),
                          TextButton(onPressed: _pickDue, child: Text('Choisir', style: TextStyle(color: accent)))
                        ],
                      ),
                      SizedBox(height: 12),

                      // Notes
                      Text('Notes (optionnel)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _notesCtl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Ex : A payé partiellement',
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor == Colors.white ? Colors.grey[50] : Colors.grey[900],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),

                      SizedBox(height: 20),
                      Divider(color: Colors.white10),

                      // Actions
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saving ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: _saving
                                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                          child: Text('Annuler', style: TextStyle(color: Colors.white70)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
