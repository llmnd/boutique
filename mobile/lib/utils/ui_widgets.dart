import 'package:flutter/material.dart';

/// 📋 Widget pour afficher une carte de header de section avec stats
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const SectionHeader({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor ?? textColorSecondary),
              const SizedBox(width: 8),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: textColorSecondary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 8,
                      color: textColorSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 🏷️ Widget pour afficher un badge avec montant
class AmountBadge extends StatelessWidget {
  final double amount;
  final String Function(double)? formatter;
  final Color? color;
  final bool isHighlight;

  const AmountBadge({
    required this.amount,
    this.formatter,
    this.color,
    this.isHighlight = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final displayAmount = formatter?.call(amount) ?? amount.toString();
    final displayColor = color ?? (amount > 0 ? Colors.orange : Colors.green);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(isHighlight ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(4),
        border: isHighlight
            ? Border.all(color: displayColor.withOpacity(0.3), width: 0.5)
            : null,
      ),
      child: Text(
        displayAmount,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: displayColor,
        ),
      ),
    );
  }
}

/// 🔍 Widget pour la barre de recherche
class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchBar({
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onClear,
    super.key,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.08),
          border: Border.all(
            color: Colors.orange.withOpacity(0.2),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          focusNode: widget.focusNode,
          controller: widget.controller,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: 'Rechercher un client...',
            hintStyle: TextStyle(
              color: textColorSecondary,
              fontSize: 12,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 0,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 18,
              color: Colors.orange.withOpacity(0.6),
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 16,
                      color: textColorSecondary,
                    ),
                    onPressed: widget.onClear,
                  )
                : null,
          ),
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }
}
