import 'package:flutter/material.dart' show Color, Colors;

/// 🎨 Utilitaires pour formatage de texte et strings
class HelperStrings {
  /// Obtient le terme "Client" ou "Contact" selon le mode boutique
  static String getTermClient(bool isBoutiqueMode) =>
      isBoutiqueMode ? 'client' : 'contact';

  /// Obtient le terme "Client" ou "Contact" en majuscule
  static String getTermClientUp(bool isBoutiqueMode) =>
      isBoutiqueMode ? 'CLIENTS' : 'CONTACTS';

  /// Obtient le nom d'un client avec fallback
  static String getClientName(
    dynamic client, {
    required bool isBoutiqueMode,
  }) {
    if (client == null) {
      return isBoutiqueMode ? 'Client inconnu' : 'Contact inconnu';
    }

    final name = (client['name'] ?? '').toString().trim();
    if (name.isNotEmpty) {
      return name;
    }

    final phone = (client['phone'] ?? '').toString().trim();
    if (phone.isNotEmpty) {
      return phone;
    }

    return isBoutiqueMode ? 'Client' : 'Contact';
  }

  /// Extrait les initiales d'un nom
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    final first = parts[0].substring(0, 1).toUpperCase();
    final last = parts.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }

  /// Obtient la couleur d'avatar basée sur le client
  static Color getAvatarColor(dynamic client) {
    if (client == null) return Colors.grey;

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    try {
      final id = client['id'] ?? 0;
      final idInt = id is int ? id : int.tryParse(id.toString()) ?? 0;
      return colors[idInt % colors.length];
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Formate une date au format dd/MM/yyyy
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Obtient le statut textuel d'une dette
  static String getDebtStatus(Map debt, bool isLoan) {
    if (debt['paid'] == true) return 'Payée';
    
    try {
      if (debt['due_date'] != null) {
        final dueDate = DateTime.parse(debt['due_date'].toString());
        if (dueDate.isBefore(DateTime.now())) {
          return 'En retard';
        }
      }
    } catch (_) {}
    
    return isLoan ? 'En cours' : 'Impayée';
  }
}
