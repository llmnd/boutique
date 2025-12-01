import 'package:flutter/material.dart';

/// 🎯 Bâtisseur des onglets (Dettes et Clients)
class TabsBuilder {
  /// Construit l'onglet des dettes
  static Widget buildDebtsTabHeader(
    BuildContext context, {
    required double totalPrets,
    required double totalEmprunts,
    required int unpaidCount,
    required String Function(double) formatter,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRÊTS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter(totalPrets),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EMPRUNTS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter(totalEmprunts),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(231, 141, 47, 219),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construit les sous-onglets (Prêts/Emprunts)
  static Widget buildDebtSubTabs(
    BuildContext context, {
    required String activeSubTab,
    required ValueChanged<String> onTabChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged('prets'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: activeSubTab == 'prets'
                          ? Colors.orange
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'PRÊTS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activeSubTab == 'prets' ? Colors.orange : textColorSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged('emprunts'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: activeSubTab == 'emprunts'
                          ? const Color.fromARGB(231, 141, 47, 219)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'EMPRUNTS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activeSubTab == 'emprunts'
                        ? const Color.fromARGB(231, 141, 47, 219)
                        : textColorSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
