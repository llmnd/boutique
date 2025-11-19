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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NOUVEAU CLIENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
              const SizedBox(height: 32),
              TextField(
                controller: nameCtl,
                autofocus: true,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.5),
                  border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26, width: 0.5)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, width: 1)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: numberCtl,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Numéro (optionnel)',
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.5),
                  border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26, width: 0.5)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, width: 1)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
            _showMinimalSnackbar('Client ajouté');
          } catch (_) {
            _showMinimalSnackbar('Client ajouté');
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
                    _showMinimalSnackbar('Client sélectionné');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CLIENT EXISTANT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            const SizedBox(height: 20),
            Text('Un client existe avec ce numéro : ${found['name']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54),
                  child: Text('NON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                ),
                child: Text('OK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMinimalSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1, color: Colors.white)),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
      _showMinimalSnackbar('Enregistrement sauvegardé');
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
        _showMinimalSnackbar('Dette créée');
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final textColorTertiary = isDark ? Colors.white38 : Colors.black38;
    final textColorHint = isDark ? Colors.white12 : Colors.black12;
    final borderColor = isDark ? Colors.white24 : Colors.black26;
    
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount Section
                          Text('MONTANT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: textColorSecondary)),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _amountCtl,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w200,
                              color: textColor,
                              height: 1,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.w200, color: textColorHint),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              suffix: Text(' FCFA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: textColorSecondary)),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                          ),
                          const SizedBox(height: 8),
                          Container(height: 0.5, color: textColorHint),
                          
                          const SizedBox(height: 48),

                          // Client Section
                          Text('CLIENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: textColorSecondary)),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _clientId,
                            isExpanded: true,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textColor),
                            items: widget.clients.map<DropdownMenuItem<int>>((cl) {
                              final clientNumber = (cl['client_number'] ?? '').toString().isNotEmpty 
                                  ? ' · ${cl['client_number']}' 
                                  : '';
                              return DropdownMenuItem(
                                value: cl['id'],
                                child: Text('${cl['name'] ?? 'Client'}$clientNumber', style: TextStyle(color: textColor)),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _clientId = v),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor, width: 0.5)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textColor, width: 1)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _saving ? null : _createClientInline,
                              icon: Icon(Icons.person_add_outlined, size: 18, color: textColor),
                              label: Text('AJOUTER UN CLIENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: textColor)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: borderColor, width: 0.5),
                                foregroundColor: textColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Due Date Section
                          Text('DATE D\'ÉCHÉANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: textColorSecondary)),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _pickDue,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
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
                                      color: _due == null ? textColorTertiary : textColor,
                                    ),
                                  ),
                                  Icon(Icons.calendar_today_outlined, size: 18, color: textColorSecondary),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Notes Section
                          Text('NOTES (OPTIONNEL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: textColorSecondary)),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesCtl,
                            maxLines: 4,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Ex: 1 kg de sucre, 2 pains',
                              hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: borderColor),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor, width: 0.5)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textColor, width: 1)),
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Audio Section
                          Text('NOTE VOCALE (OPTIONNEL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: textColorSecondary)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: textColorHint, width: 0.5),
                            ),
                            child: _audioPath == null
                                ? Column(
                                    children: [
                                      if (_isRecording)
                                        FadeTransition(
                                          opacity: _pulseController,
                                          child: const Row(
                                            children: [
                                              Icon(Icons.fiber_manual_record, size: 12, color: Colors.red),
                                              SizedBox(width: 12),
                                              Text('ENREGISTREMENT EN COURS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1)),
                                            ],
                                          ),
                                        )
                                      else
                                        Row(
                                          children: [
                                            Icon(Icons.mic_none_outlined, size: 18, color: textColorHint),
                                            const SizedBox(width: 12),
                                            Text('Aucun enregistrement', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: textColorTertiary)),
                                          ],
                                        ),
                                      const SizedBox(height: 16),
                                        SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: _saving ? null : (_isRecording ? _stopRecording : _startRecording),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            side: BorderSide(color: _isRecording ? Colors.red : borderColor, width: 0.5),
                                            foregroundColor: _isRecording ? Colors.red : textColor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                          ),
                                          child: Text(
                                            _isRecording ? 'ARRÊTER' : 'DÉMARRER',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                    : Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.check_circle_outline, size: 18, color: textColor),
                                          const SizedBox(width: 12),
                                          Text('Enregistrement sauvegardé', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textColor)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _saving ? null : _playAudio,
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                side: BorderSide(color: borderColor, width: 0.5),
                                                foregroundColor: textColor,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                              ),
                                              child: Text('ÉCOUTER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: textColor)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          OutlinedButton(
                                            onPressed: _saving ? null : _deleteAudio,
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                              side: const BorderSide(color: Colors.red, width: 0.5),
                                              foregroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                            ),
                                            child: const Icon(Icons.delete_outline, size: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),

                          const SizedBox(height: 80),
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
                  border: const Border(top: BorderSide(color: Colors.black12, width: 0.5)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          disabledBackgroundColor: isDark ? Colors.white24 : Colors.black26,
                          disabledForegroundColor: isDark ? Colors.black38 : Colors.white54,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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