/// 📊 Utilitaires de calcul pour les dettes et emprunts
class DebtCalculations {
  /// Parse une valeur en double
  static double parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Récupère le timestamp d'une dette
  static double tsForDebt(dynamic debt) {
    try {
      if (debt == null || debt['created_at'] == null) return 0.0;
      final dt = DateTime.parse(debt['created_at'].toString());
      return dt.millisecondsSinceEpoch.toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  /// Calcule le montant restant après paiements
  static double calculateRemainingFromPayments(Map debt, List paymentList) {
    try {
      double totalDebt = parseDouble(debt['total_debt']);
      double totalPaid = 0.0;
      
      for (final p in paymentList) {
        if (p is Map) {
          final amount = parseDouble(p['amount']);
          totalPaid += amount;
        }
      }
      
      return totalDebt - totalPaid;
    } catch (e) {
      return 0.0;
    }
  }

  /// Calcule le solde net (positif = dû par les clients, négatif = dû au propriétaire)
  static double calculateNetBalance(List debts) {
    double netBalance = 0.0;
    
    for (final d in debts) {
      if (d == null) continue;
      
      final remaining = parseDouble(d['remaining']);
      final txType = (d['type'] ?? 'debt').toString();
      
      if (txType == 'loan') {
        netBalance -= remaining; // Emprunt = dû au propriétaire (négatif)
      } else {
        netBalance += remaining; // Prêt = dû par les clients (positif)
      }
    }
    
    return netBalance;
  }

  /// Calcule le total des prêts (dettes)
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

  /// Calcule le total des emprunts
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

  /// Calcule le montant total restant pour un client
  static double clientTotalRemaining(dynamic clientId, List debts) {
    double total = 0.0;
    
    for (final d in debts) {
      if (d == null) continue;
      if (d['client_id'] != clientId) continue;
      
      final remaining = parseDouble(d['remaining']);
      total += remaining;
    }
    
    return total;
  }

  /// Vérifie si une dette est payée
  static bool isDebtPaid(Map debt) {
    final remaining = parseDouble(debt['remaining']);
    return debt['paid'] == true || remaining <= 0;
  }

  /// Vérifie si une dette est en retard
  static bool isDebtOverdue(Map debt) {
    try {
      final dueDate = debt['due_date'];
      if (dueDate == null) return false;
      
      final dueDateTime = DateTime.parse(dueDate.toString());
      final isPaid = isDebtPaid(debt);
      
      return dueDateTime.isBefore(DateTime.now()) && !isPaid;
    } catch (e) {
      return false;
    }
  }
}
