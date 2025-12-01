import 'package:flutter/material.dart';
import '../app_settings.dart';

/// 🔧 Extraction des méthodes simples du HomePage
class HomePageMethods {
  // ===== HELPER STRING METHODS =====
  
  static String getTermClient() =>
      AppSettings().boutiqueModeEnabled ? 'client' : 'contact';

  static String getTermClientUp() =>
      AppSettings().boutiqueModeEnabled ? 'CLIENT' : 'CONTACT';

  static String getClientName(dynamic client) {
    if (client == null) {
      return AppSettings().boutiqueModeEnabled ? 'Client' : 'Contact';
    }
    final name = client['name'];
    if (name != null && name is String && name.isNotEmpty && name != 'null') {
      return name;
    }
    return AppSettings().boutiqueModeEnabled ? 'Client' : 'Contact';
  }

  static String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  static Color getAvatarColor(dynamic client) {
    if (client == null) return Colors.grey;

    const colors = [
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
      final id = client['id'];
      if (id is int) return colors[id % colors.length];
      if (id is String) return colors[int.parse(id) % colors.length];
    } catch (_) {}

    return Colors.grey;
  }

  // ===== PARSING & CONVERSION =====

  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(' ', '')) ?? 0.0;
    }
    return 0.0;
  }

  static double tsForDebt(dynamic debt) {
    if (debt == null) return 0.0;
    final List<String> tsFields = [
      'updated_at',
      'added_at',
      'created_at',
      'createdAt',
      'date'
    ];
    for (final f in tsFields) {
      final v = debt[f];
      if (v == null) continue;
      if (v is String) {
        final dt = DateTime.tryParse(v);
        if (dt != null) return dt.millisecondsSinceEpoch.toDouble();
      } else if (v is int) {
        return v.toDouble();
      } else if (v is double) {
        return v;
      }
    }

    final idv = debt['id'];
    if (idv is int) return idv.toDouble();
    if (idv is String) return double.tryParse(idv) ?? 0.0;
    return 0.0;
  }

  // ===== CALCULATION METHODS =====

  static double calculateRemainingFromPayments(Map debt, List paymentList) {
    try {
      final baseAmount = parseDouble(debt['amount']);
      final totalAdditions = parseDouble(debt['total_additions'] ?? 0.0);
      final totalDebtAmount = baseAmount + totalAdditions;

      double totalPaid = 0.0;
      for (final payment in paymentList) {
        totalPaid += parseDouble(payment['amount']);
      }
      return (totalDebtAmount - totalPaid).clamp(0.0, double.infinity);
    } catch (_) {
      return 0.0;
    }
  }

  static double clientTotalRemaining(dynamic clientId, List<dynamic> debts) {
    final clientDebts =
        debts.where((d) => d != null && d['client_id'] == clientId).toList();
    if (clientDebts.isEmpty) return 0.0;

    dynamic latest = clientDebts[0];
    double latestTs = tsForDebt(latest);

    for (int i = 1; i < clientDebts.length; i++) {
      final current = clientDebts[i];
      final currentTs = tsForDebt(current);
      if (currentTs >= latestTs) {
        latest = current;
        latestTs = currentTs;
      }
    }

    return ((latest['remaining'] as num?)?.toDouble() ?? 0.0);
  }

  static double calculateNetBalance(List debts) {
    double totalToCollect = 0.0;
    double totalToPay = 0.0;

    for (final d in debts) {
      if (d == null) continue;

      double balance = 0.0;
      final balanceValue = d['balance'] ?? d['remaining'];

      if (balanceValue is String) {
        balance =
            double.tryParse(balanceValue.toString().replaceAll(' ', '')) ?? 0.0;
      } else if (balanceValue is double) {
        balance = balanceValue;
      } else if (balanceValue is int) {
        balance = balanceValue.toDouble();
      }

      if (balance > 0) {
        totalToCollect += balance;
      } else if (balance < 0) {
        totalToPay += balance.abs();
      }
    }

    return totalToCollect - totalToPay;
  }

  static double calculateTotalPrets(List debts) {
    double total = 0.0;

    for (final d in debts) {
      if (d == null) continue;
      if ((d['type'] ?? 'debt') != 'debt') continue;

      final remaining = parseDouble(d['remaining']);
      if (remaining > 0) {
        total += remaining;
      }
    }

    return total;
  }

  static double calculateTotalEmprunts(List debts) {
    double total = 0.0;

    for (final d in debts) {
      if (d == null) continue;
      if ((d['type'] ?? 'debt') != 'loan') continue;

      final remaining = parseDouble(d['remaining']);
      if (remaining > 0) {
        total += remaining;
      }
    }

    return total;
  }
}
