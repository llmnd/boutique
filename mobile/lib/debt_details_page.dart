import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

import 'add_payment_page.dart';
import 'add_addition_page.dart';
import 'data/audio_service.dart';
import 'dart:async';

class DebtDetailsPage extends StatefulWidget {
  final String ownerPhone;
  final Map debt;

  const DebtDetailsPage({super.key, required this.ownerPhone, required this.debt});

  @override
  _DebtDetailsPageState createState() => _DebtDetailsPageState();
}

class _DebtDetailsPageState extends State<DebtDetailsPage> {
  List payments = [];
  List additions = [];
  bool _loading = false;
  bool _changed = false;
  late AudioService _audioService;
  late Map _debt; // Copie locale de la dette
  
  // États pour masquer/afficher les sections
  bool _showAllPayments = false;
  bool _showAllAdditions = false;
  
  // Pour le refresh automatique
  final int _autoRefreshInterval = 2000; // 2 secondes
  Timer? _refreshTimer;

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
    _debt = Map.from(widget.debt); // Copie locale
    _changed = false; // S'assurer que c'est false au démarrage
    _loadAllData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(milliseconds: _autoRefreshInterval), (timer) {
      if (mounted) {
        _loadAllData(silent: true);
      }
    });
  }

  // ✅ FONCTION DE TRI DÉCROISSANT
  List _sortByDateDescending(List items, String dateField) {
    items.sort((a, b) {
      final dateA = DateTime.parse(a[dateField] ?? '');
      final dateB = DateTime.parse(b[dateField] ?? '');
      return dateB.compareTo(dateA); // Ordre décroissant
    });
    return items;
  }

  Future<void> _loadAllData({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = true);
    }
    
    try {
      final headers = {
        'Content-Type': 'application/json', 
        if (widget.ownerPhone.isNotEmpty) 'x-owner': widget.ownerPhone
      };
      
      // Recharger aussi les infos principales de la dette
      final debtFuture = http.get(
        Uri.parse('$apiHost/debts/${_debt['id']}'), 
        headers: headers
      ).timeout(const Duration(seconds: 8));
      
      // Chargement en parallèle pour plus de rapidité
      final paymentsFuture = http.get(
        Uri.parse('$apiHost/debts/${_debt['id']}/payments'), 
        headers: headers
      ).timeout(const Duration(seconds: 8));
      
      final additionsFuture = http.get(
        Uri.parse('$apiHost/debts/${_debt['id']}/additions'), 
        headers: headers
      ).timeout(const Duration(seconds: 8));
      
      final responses = await Future.wait([debtFuture, paymentsFuture, additionsFuture]);
      
      if (mounted) {
        setState(() {
          if (responses[0].statusCode == 200) {
            // Mettre à jour les infos de la dette
            final updatedDebt = json.decode(responses[0].body) as Map;
            _debt.addAll(updatedDebt); // Utiliser la copie locale
          }
          if (responses[1].statusCode == 200) {
            // ✅ TRIER LES PAIEMENTS DU PLUS RÉCENT AU PLUS ANCIEN
            payments = _sortByDateDescending(json.decode(responses[1].body) as List, 'paid_at');
          }
          if (responses[2].statusCode == 200) {
            // ✅ TRIER LES ADDITIONS DU PLUS RÉCENT AU PLUS ANCIEN
            additions = _sortByDateDescending(json.decode(responses[2].body) as List, 'added_at');
          }
        });
      }
    } catch (e) {
      // Ignorer les erreurs silencieuses
    } finally {
      if (mounted && !silent) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addPayment() async {
    final res = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddPaymentPage(ownerPhone: widget.ownerPhone, debt: _debt))
    );
    if (res == true) {
      _changed = true;
      // Rechargement immédiat pour voir le résultat
      await _loadAllData();
    }
  }

  Future<void> _addAddition() async {
    final res = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddAdditionPage(ownerPhone: widget.ownerPhone, debt: _debt)),
    );
    if (res == true) {
      _changed = true;
      // Rechargement immédiat pour voir le résultat
      await _loadAllData();
    }
  }

  Future<void> _deleteDebt() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    
    final confirm = await showDialog<bool>(
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
                'SUPPRIMER LA DETTE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Êtes-vous sûr de vouloir supprimer cette dette ?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(
                      'ANNULER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                    ),
                    child: Text(
                      'SUPPRIMER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    if (confirm != true) return;
    try {
      final headers = {'Content-Type': 'application/json', if (widget.ownerPhone.isNotEmpty) 'x-owner': widget.ownerPhone};
      final res = await http.delete(Uri.parse('$apiHost/debts/${_debt['id']}'), headers: headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        _changed = true;
        Navigator.of(context).pop(true);
      } else {
        await _showMinimalDialog('Erreur', 'Échec suppression: ${res.statusCode}\n${res.body}');
      }
    } catch (e) {
      await _showMinimalDialog('Erreur réseau', '$e');
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

  // Nouvelle fonction pour formater la date d'échéance de manière intelligente
  Widget _buildDueDateWidget(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    final days = difference.inDays;
    
    Color color;
    String text;
    IconData icon;
    
    if (days < 0) {
      // En retard
      color = Colors.red;
      text = 'EN RETARD (${days.abs()}j)';
      icon = Icons.warning;
    } else if (days == 0) {
      // Aujourd'hui
      color = Colors.orange;
      text = 'AUJOURD\'HUI';
      icon = Icons.today;
    } else if (days <= 7) {
      // Cette semaine
      color = Colors.orange;
      text = 'DANS $days JOUR${days > 1 ? 'S' : ''}';
      icon = Icons.schedule;
    } else {
      // Plus d'une semaine
      color = Theme.of(context).colorScheme.primary;
      text = DateFormat('dd/MM/yyyy').format(dueDate);
      icon = Icons.calendar_today;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white24 : Colors.black26;

    double totalPaid = 0.0;
    try {
      totalPaid = payments.fold<double>(0.0, (s, p) => s + (double.tryParse(p['amount'].toString()) ?? 0.0));
    } catch (_) {}
    final amount = double.tryParse(_debt['amount'].toString()) ?? 0.0;
    final remaining = (amount - totalPaid);
    final progress = amount == 0 ? 0.0 : (totalPaid / amount).clamp(0.0, 1.0);
    
    // Parse due date for intelligent display
    final dueDate = _parseDate(_debt['due_date']);

    // ✅ PRENDRE LES PREMIERS ÉLÉMENTS DE LA LISTE DÉJÀ TRIÉE (les plus récents)
    final displayedPayments = _showAllPayments ? payments : payments.take(3).toList();
    final displayedAdditions = _showAllAdditions ? additions : additions.take(3).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(_changed),
        ),
        title: Text(
          'DÉTAILS DETTE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addAddition,
            icon: Icon(Icons.add, color: Colors.orange, size: 20),
            tooltip: 'Ajouter montant',
          ),
          IconButton(
            onPressed: _addPayment,
            icon: Icon(Icons.payment, color: textColor, size: 20),
            tooltip: 'Ajouter paiement',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec infos principales
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (_debt['client_name'] ?? '').toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (dueDate != null) _buildDueDateWidget(dueDate),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Montant principal
                  Text(
                    _fmtAmount(amount),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: textColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Progression rapide
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PAYÉ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: textColorSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fmtAmount(totalPaid),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'RESTE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: textColorSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fmtAmount(remaining),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: remaining <= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
                    color: remaining <= 0 ? Colors.green : Theme.of(context).colorScheme.primary,
                    minHeight: 6,
                  ),
                ],
              ),
            ),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Actions rapides
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _addPayment,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: BorderSide(color: borderColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: Icon(Icons.payment, size: 18),
                            label: Text(
                              'PAIEMENT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _addAddition,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: Icon(Icons.add, size: 18),
                            label: Text(
                              'AJOUTER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Notes (si existantes)
                    if (_debt['notes'] != null && _debt['notes'] != '') ...[
                      _buildSectionHeader('NOTES'),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 0.5),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _debt['notes'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Audio (si existant)
                    if (_debt['audio_path'] != null && _debt['audio_path'] != '') ...[
                      _buildSectionHeader('ENREGISTREMENT'),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 0.5),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.audio_file, color: textColorSecondary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Enregistrement audio',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _audioService.playAudio(_debt['audio_path']),
                              icon: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.primary),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Derniers paiements
                    _buildSectionHeader(
                      'DERNIERS PAIEMENTS',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${payments.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: textColorSecondary,
                            ),
                          ),
                          if (payments.length > 3) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showAllPayments = !_showAllPayments;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: borderColor),
                                ),
                                child: Text(
                                  _showAllPayments ? 'VOIR MOINS' : 'VOIR PLUS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_loading)
                      Center(child: CircularProgressIndicator())
                    else if (payments.isEmpty)
                      _buildEmptyState(
                        icon: Icons.payments_outlined,
                        title: 'AUCUN PAIEMENT',
                        subtitle: 'Aucun paiement enregistré',
                      )
                    else
                      // ✅ AFFICHER DIRECTEMENT SANS REVERSER
                      ...displayedPayments.map((p) => _buildPaymentItem(p, textColor, textColorSecondary)).toList(),

                    // Montants ajoutés
                    if (additions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        'MONTANTS AJOUTÉS',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${additions.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textColorSecondary,
                              ),
                            ),
                            if (additions.length > 3) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showAllAdditions = !_showAllAdditions;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Text(
                                    _showAllAdditions ? 'VOIR MOINS' : 'VOIR PLUS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...displayedAdditions.map((a) => _buildAdditionItem(a, textColor, textColorSecondary)).toList(),
                    ],

                    const SizedBox(height: 20),
                    
                    // Bouton suppression
                    Center(
                      child: TextButton(
                        onPressed: _deleteDebt,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text(
                          'SUPPRIMER LA DETTE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white24 : Colors.black26;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: textColorSecondary),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColorSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: textColorSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map payment, Color textColor, Color textColorSecondary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          child: Icon(
            Icons.monetization_on_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fmtAmount(payment['amount']),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (payment['notes'] != null && payment['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                payment['notes'].toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: textColorSecondary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _formatPaymentDate(payment['paid_at']),
            style: TextStyle(
              fontSize: 12,
              color: textColorSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionItem(Map addition, Color textColor, Color textColorSecondary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
          ),
          child: Icon(
            Icons.add_circle_outline,
            color: Colors.orange,
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fmtAmount(addition['amount']),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            if (addition['notes'] != null && addition['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                addition['notes'].toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: textColorSecondary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _fmtDate(addition['added_at']),
            style: TextStyle(
              fontSize: 12,
              color: textColorSecondary,
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date.toString());
    } catch (_) {
      return null;
    }
  }

  String _fmtAmount(dynamic v) {
    try {
      final n = double.tryParse(v?.toString() ?? '0') ?? 0.0;
      return '${NumberFormat('#,###', 'fr_FR').format(n)} F';
    } catch (_) { return v?.toString() ?? '-'; }
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    try { final dt = DateTime.tryParse(s); if (dt != null) return DateFormat('dd/MM/yyyy').format(dt); } catch (_) {}
    try { final parts = s.split(' ').first.split('-'); if (parts.length>=3) return '${parts[2]}/${parts[1]}/${parts[0]}'; } catch (_) {}
    return s;
  }

  String _formatPaymentDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return dateStr.toString();
    }
  }
}