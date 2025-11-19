import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

class AddPaymentPage extends StatefulWidget {
  final String ownerPhone;
  final Map debt;

  const AddPaymentPage({super.key, required this.ownerPhone, required this.debt});

  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final TextEditingController _amountCtl = TextEditingController();
  final DateTime _paidAt = DateTime.now();
  bool _loading = false;

  double get _remaining {
    try {
      final amt = double.tryParse(widget.debt['amount']?.toString() ?? '0') ?? 0.0;
      if (widget.debt['remaining'] != null) return double.tryParse(widget.debt['remaining'].toString()) ?? amt;
      if (widget.debt['total_paid'] != null) return (amt - (double.tryParse(widget.debt['total_paid'].toString()) ?? 0.0)).clamp(0.0, amt);
      return amt;
    } catch (_) {
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    final r = _remaining;
    if (r > 0) _amountCtl.text = r.toStringAsFixed(0);
  }

  Future<void> _submit() async {
    final text = _amountCtl.text.trim();
    if (text.isEmpty) return;
    final val = double.tryParse(text) ?? 0.0;
    if (val <= 0) return;
    setState(() => _loading = true);
    try {
      final headers = {'Content-Type': 'application/json', if (widget.ownerPhone.isNotEmpty) 'x-owner': widget.ownerPhone};
      final body = {'amount': val, 'paid_at': _paidAt.toIso8601String()};
      final res = await http.post(Uri.parse('$apiHost/debts/${widget.debt['id']}/pay'), headers: headers, body: json.encode(body)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        final msg = res.body;
        await _showMinimalDialog('Erreur', 'Échec ajout paiement: ${res.statusCode}\n$msg');
      }
    } catch (e) {
      await _showMinimalDialog('Erreur réseau', '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showMinimalDialog(String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: isDark ? Colors.black : Colors.white,
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

  String get apiHost {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white24 : Colors.black26;
    final remaining = _remaining;

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
          'NOUVEAU PAIEMENT',
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Client Info
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor, width: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CLIENT',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: textColorSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    (widget.debt['client_name'] ?? '').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'RESTE À PAYER',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: textColorSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${NumberFormat('#,###', 'fr_FR').format(remaining)} FCFA',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                      color: textColor,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Amount Input
                          Text(
                            'MONTANT DU PAIEMENT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: textColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _amountCtl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: textColor,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(20),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'FCFA',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : Colors.black,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                disabledBackgroundColor: isDark ? Colors.white24 : Colors.black26,
                                disabledForegroundColor: isDark ? Colors.black38 : Colors.white54,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      'ENREGISTRER LE PAIEMENT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5,
                                        color: isDark ? Colors.black : Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Quick Amount Buttons
                          if (remaining > 0) ...[
                            Text(
                              'MONTANTS RAPIDES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: textColorSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _quickAmountButton('MOITIÉ', (remaining / 2).roundToDouble()),
                                const SizedBox(width: 12),
                                _quickAmountButton('TOUT', remaining.roundToDouble()),
                              ],

                            ),
                          ],

                          const SizedBox(height: 80),
                        ],
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

  Widget _quickAmountButton(String label, double amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
        ),
        child: TextButton(
          onPressed: () {
            _amountCtl.text = amount.toStringAsFixed(0);
          },
          style: TextButton.styleFrom(
            foregroundColor: textColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${NumberFormat('#,###', 'fr_FR').format(amount)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}