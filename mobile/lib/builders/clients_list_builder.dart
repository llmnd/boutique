import 'package:flutter/material.dart';

/// 👥 Builder pour la liste des clients
class ClientListBuilder {
  /// Construit une carte de client
  static Widget buildClientCard({
    required BuildContext context,
    required String clientName,
    required String? phone,
    required double totalRemaining,
    required Widget avatar,
    required Widget amountDisplay,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
    required Widget actionMenu,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.black26;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.3)),
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: avatar,
        title: Text(clientName),
        subtitle: phone != null ? Text(phone) : null,
        trailing: amountDisplay,
      ),
    );
  }
}
