import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'data/audio_service.dart';

class AddDebtPage extends StatefulWidget {
  final String ownerPhone;
  final List clients;
  final int? preselectedClientId;

  const AddDebtPage({super.key, required this.ownerPhone, required this.clients, this.preselectedClientId});

  @override
  _AddDebtPageState createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int? _clientId;
  final TextEditingController _amountCtl = TextEditingController();
  final TextEditingController _notesCtl = TextEditingController();
  DateTime? _due;
  bool _saving = false;
  late AudioService _audioService;
  String? _audioPath;
  bool _isRecording = false;
  late AnimationController _pulseController;

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
    _audioService = AudioService();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    int? validClientId;
    if (widget.preselectedClientId != null && widget.clients.isNotEmpty) {
      final exists = widget.clients.any((c) => c['id'] == widget.preselectedClientId);
      if (exists) {
        validClientId = widget.preselectedClientId;
      }
    }
    
    _clientId = validClientId ?? (widget.clients.isNotEmpty ? widget.clients.first['id'] : null);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioService.dispose();
    _amountCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  Future<void> _createClientInline() async {
    final numberCtl = TextEditingController();
    final nameCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (c) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NOUVEAU CLIENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtl,
                autofocus: true,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.2, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 0.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26, width: 0.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, width: 1)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: numberCtl,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.2, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Numéro (optionnel)',
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 0.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26, width: 0.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, width: 1)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(c).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                    ),
                    child: Text('ANNULER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(c).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('AJOUTER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true && nameCtl.text.trim().isNotEmpty) {
      try {
        final body = {'client_number': numberCtl.text.trim(), 'name': nameCtl.text.trim()};
        final headers = {'Content-Type': 'application/json', if (widget.ownerPhone.isNotEmpty) 'x-owner': widget.ownerPhone};
        setState(() => _saving = true);
        final res = await http.post(Uri.parse('$apiHost/clients'), headers: headers, body: json.encode(body)).timeout(const Duration(seconds: 8));
        if (res.statusCode == 201) {
          try {
            final created = json.decode(res.body);
            setState(() {
              if (created is Map && created['id'] != null) {
                final createdId = created['id'].toString();
                final exists = widget.clients.indexWhere((c) => c['id']?.toString() == createdId);
                if (exists == -1) {
                  widget.clients.insert(0, created);
                } else {
                  widget.clients[exists] = created;
                }
                _clientId = created['id'];
              }
            });
            _showMinimalSnackbar('Client ajouté', isSuccess: true);
          } catch (_) {
            _showMinimalSnackbar('Client ajouté', isSuccess: true);
          }
        } else {
          final bodyText = res.body;
          final lower = bodyText.toLowerCase();
          final isDuplicate = res.statusCode == 409 || lower.contains('duplicate') || lower.contains('already exists') || lower.contains('unique');
          if (numberCtl.text.trim().isNotEmpty) {
            try {
              final headersGet = {'Content-Type': 'application/json', if (widget.ownerPhone.isNotEmpty) 'x-owner': widget.ownerPhone};
              final getRes = await http.get(Uri.parse('$apiHost/clients'), headers: headersGet).timeout(const Duration(seconds: 8));
              if (getRes.statusCode == 200) {
                final list = json.decode(getRes.body) as List;
                final found = list.firstWhere((c) => (c['client_number'] ?? '').toString() == numberCtl.text.trim(), orElse: () => null);
                if (found != null) {
                  final choose = await _showExistingClientDialog(found);
                  if (choose == true) {
                    setState(() {
                      final foundId = found['id']?.toString();
                      final existsIndex = widget.clients.indexWhere((c) => c['id']?.toString() == foundId);
                      if (existsIndex == -1) {
                        widget.clients.insert(0, found);
                      } else {
                        widget.clients[existsIndex] = found;
                      }
                      _clientId = found['id'];
                    });
                    _showMinimalSnackbar('Client sélectionné', isSuccess: true);
                    return;
                  } else if (isDuplicate) {
                    await _showMinimalDialog('Ce client existe déjà');
                    return;
                  }
                }
              }
            } catch (_) {}
          }
          await _showMinimalDialog('Erreur lors de la création');
        }
      } catch (e) {
        await _showMinimalDialog('Erreur réseau');
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }
  }

  Future<bool?> _showExistingClientDialog(Map found) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CLIENT EXISTANT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            const SizedBox(height: 16),
            Text('Un client existe avec ce numéro : ${found['name']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, letterSpacing: -0.2, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('NON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('SÉLECTIONNER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMinimalDialog(String message) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, letterSpacing: -0.2, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('OK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMinimalSnackbar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1, color: Colors.white)),
        backgroundColor: isSuccess ? Colors.green : Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickDue() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _due ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) setState(() => _due = d);
  }

  Future<void> _startRecording() async {
    final ok = await _audioService.startRecording();
    if (ok) {
      setState(() => _isRecording = true);
      _showMinimalSnackbar('Enregistrement démarré');
    } else {
      _showMinimalSnackbar('Erreur d\'enregistrement');
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioService.stopRecording();
    if (path != null) {
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
      _showMinimalSnackbar('Enregistrement sauvegardé', isSuccess: true);
    } else {
      setState(() => _isRecording = false);
      _showMinimalSnackbar('Erreur d\'enregistrement');
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath != null) {
      await _audioService.playAudio(_audioPath!);
    }
  }

  Future<void> _deleteAudio() async {
    if (_audioPath != null) {
      await _audioService.deleteAudio(_audioPath!);
      setState(() => _audioPath = null);
      _showMinimalSnackbar('Enregistrement supprimé');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clientId == null) {
      _showMinimalSnackbar('Veuillez choisir un client');
      return;
    }
    setState(() => _saving = true);
    try {
      final body = {
        'client_id': _clientId,
        'amount': double.tryParse(_amountCtl.text.replaceAll(',', '')) ?? 0.0,
        'due_date': _due == null ? null : DateFormat('yyyy-MM-dd').format(_due!),
        'notes': _notesCtl.text,
        if (_audioPath != null) 'audio_path': _audioPath,
      };
      final headers = {'Content-Type': 'application/json', if (widget.ownerPhone.isNotEmpty) 'x-owner': widget.ownerPhone};
      final res = await http.post(Uri.parse('$apiHost/debts'), headers: headers, body: json.encode(body)).timeout(const Duration(seconds: 8));
      if (res.statusCode == 201) {
        _showMinimalSnackbar('Dette créée', isSuccess: true);
        Navigator.of(context).pop(true);
      } else {
        await _showMinimalDialog('Erreur lors de la création');
      }
    } catch (e) {
      await _showMinimalDialog('Erreur réseau');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    bool isOptional = false,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: textColorSecondary),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: textColorSecondary,
                    ),
                  ),
                  if (isOptional) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Optionnel',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final textColorTertiary = isDark ? Colors.white38 : Colors.black38;
    final textColorHint = isDark ? Colors.white12 : Colors.black12;
    final borderColor = isDark ? Colors.white24 : Colors.black26;
    final subtleBackground = isDark ? Colors.white10 : Colors.black.withOpacity(0.03);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'NOUVELLE DETTE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount Section - avec bordure visible
                          _buildSection(
                            title: 'MONTANT',
                            icon: Icons.attach_money_outlined,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor, width: 1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _amountCtl,
                                          keyboardType: TextInputType.number,
                                          autofocus: true,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w200,
                                            letterSpacing: -0.3,
                                            color: textColor,
                                            height: 1,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.w200, color: textColorHint),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                                        ),
                                      ),
                                      Text(' FCFA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, letterSpacing: -0.2, color: textColorSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Client Section - bouton simplifié
                          _buildSection(
                            title: 'CLIENT',
                            icon: Icons.person_outline,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: subtleBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonFormField<int>(
                                    value: _clientId,
                                    isExpanded: true,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.2, color: textColor),
                                    items: widget.clients.map<DropdownMenuItem<int>>((cl) {
                                      final clientNumber = (cl['client_number'] ?? '').toString().isNotEmpty 
                                          ? ' · ${cl['client_number']}' 
                                          : '';
                                      return DropdownMenuItem(
                                        value: cl['id'],
                                        child: Text('${cl['name'] ?? 'Client'}$clientNumber', style: TextStyle(color: textColor, letterSpacing: -0.2)),
                                      );
                                    }).toList(),
                                    onChanged: (v) => setState(() => _clientId = v),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Bouton simplifié et moins visible
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: _saving ? null : _createClientInline,
                                    icon: Icon(Icons.person_add_outlined, size: 16, color: textColorSecondary),
                                    label: Text('Ajouter un client', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textColorSecondary)),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      foregroundColor: textColorSecondary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Notes Section - AVANT la date d'échéance
                          _buildSection(
                            title: 'NOTES',
                            icon: Icons.note_outlined,
                            isOptional: true,
                            child: Container(
                              decoration: BoxDecoration(
                                color: subtleBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: 0.5),
                              ),
                              child: TextFormField(
                                controller: _notesCtl,
                                maxLines: 3,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.2, color: textColor),
                                decoration: InputDecoration(
                                  hintText: 'Ex: 1 kg de sucre, 2 pains...',
                                  hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, letterSpacing: -0.2, color: borderColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Due Date Section - APRÈS les notes
                          _buildSection(
                            title: 'DATE D\'ÉCHÉANCE',
                            icon: Icons.calendar_today_outlined,
                            child: InkWell(
                              onTap: _pickDue,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: subtleBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor, width: 0.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _due == null ? 'Aucune échéance' : DateFormat('dd/MM/yyyy').format(_due!),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.2,
                                        color: _due == null ? textColorTertiary : textColor,
                                      ),
                                    ),
                                    Icon(Icons.calendar_today_outlined, size: 18, color: textColorSecondary),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Audio Section
                          _buildSection(
                            title: 'NOTE VOCALE',
                            icon: Icons.mic_outlined,
                            isOptional: true,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: subtleBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _isRecording ? Colors.red.withOpacity(0.3) : borderColor, width: 0.5),
                              ),
                              child: _audioPath == null
                                  ? Column(
                                      children: [
                                        if (_isRecording)
                                          FadeTransition(
                                            opacity: _pulseController,
                                            child: Row(
                                              children: [
                                                Icon(Icons.fiber_manual_record, size: 12, color: Colors.red),
                                                const SizedBox(width: 12),
                                                Text('ENREGISTREMENT EN COURS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1, color: Colors.red)),
                                              ],
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              Icon(Icons.mic_none_outlined, size: 18, color: textColorHint),
                                              const SizedBox(width: 12),
                                              Text('Aucun enregistrement', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, letterSpacing: -0.2, color: textColorTertiary)),
                                            ],
                                          ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: _saving ? null : (_isRecording ? _stopRecording : _startRecording),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _isRecording ? Colors.red : (isDark ? Colors.white10 : Colors.black.withOpacity(0.1)),
                                              foregroundColor: _isRecording ? Colors.white : textColor,
                                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              elevation: 0,
                                            ),
                                            icon: Icon(_isRecording ? Icons.stop : Icons.mic, size: 18),
                                            label: Text(
                                              _isRecording ? 'ARRÊTER' : 'DÉMARRER',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                                            const SizedBox(width: 12),
                                            Text('Enregistrement sauvegardé', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: -0.2, color: textColor)),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: _saving ? null : _playAudio,
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                  side: BorderSide(color: borderColor, width: 0.5),
                                                  foregroundColor: textColor,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                icon: Icon(Icons.play_arrow_outlined, size: 18),
                                                label: Text('ÉCOUTER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: textColor)),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            OutlinedButton(
                                              onPressed: _saving ? null : _deleteAudio,
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                side: const BorderSide(color: Colors.red, width: 0.5),
                                                foregroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              child: const Icon(Icons.delete_outline, size: 18),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Fixed Bottom Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(top: BorderSide(color: borderColor, width: 0.5)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          disabledBackgroundColor: isDark ? Colors.white24 : Colors.black26,
                          disabledForegroundColor: isDark ? Colors.black38 : Colors.white54,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _saving 
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Icon(Icons.add_chart_outlined, size: 18),
                        label: _saving
                            ? const Text(
                                'CRÉATION...',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                              )
                            : const Text(
                                'ENREGISTRER LA DETTE',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}