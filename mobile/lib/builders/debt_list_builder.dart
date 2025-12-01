import 'package:flutter/material.dart';

/// 💎 Builder pour la liste des dettes (version UI uniquement, logique en main.dart)
class DebtListBuilder {
  /// Construit la vue d'une carte de dette avec expansions
  static Widget buildDebtCard({
    required BuildContext context,
    required String clientName,
    required String? clientPhone,
    required double totalRemaining,
    required String txType,
    required bool isOpen,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
    required Widget avatar,
    required Widget amountDisplay,
    required Widget actionMenu,
    required Widget? expandedContent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.black26;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.3)),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              child: Row(
                children: [
                  // Avatar
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: avatar,
                  ),
                  const SizedBox(width: 12),
                  // Client info
                  Expanded(child: _buildClientInfo(context, clientName, clientPhone)),
                  // Amount
                  amountDisplay,
                  const SizedBox(width: 12),
                  // Menu
                  actionMenu,
                ],
              ),
            ),
          ),
          if (isOpen && expandedContent != null) ...[
            Container(
              height: 0.5,
              color: borderColor,
            ),
            expandedContent,
          ],
        ],
      ),
    );
  }

  /// Construit les informations du client
  static Widget _buildClientInfo(
    BuildContext context,
    String clientName,
    String? clientPhone,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          clientName.toString(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
        if (clientPhone != null && clientPhone.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Text(
                clientPhone,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Construit un article de dette déploYé (montant + échéance)
  static Widget buildDebtItem({
    required BuildContext context,
    required double totalDebt,
    required double remaining,
    required bool isPaid,
    required bool isOverdue,
    required String dueText,
    required String Function(double) formatter,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white24 : Colors.black26;
    final statusColor = isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.3),
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatter(totalDebt),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Échéance: $dueText',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : textColorSecondary,
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RESTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter(remaining),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: remaining <= 0 ? Colors.green : (isOverdue ? Colors.red : textColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Icon(
                isPaid ? Icons.check_circle : (isOverdue ? Icons.error : Icons.circle),
                color: statusColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
