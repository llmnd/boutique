import 'package:flutter/material.dart';

/// 🎭 Utilitaires pour construction d'avatars
class AvatarBuilder {
  /// Construit un avatar avec initiales
  static Widget buildInitialsAvatar(String initials, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.blue.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Construit un avatar pour un client (avec photo ou initiales)
  static Widget buildClientAvatarWidget(
    dynamic client,
    double size, {
    String Function(String)? getInitials,
    Color Function(dynamic)? getAvatarColor,
  }) {
    final initials = getInitials?.call(client?['name'] ?? '') ?? '?';
    final color = getAvatarColor?.call(client) ?? Colors.grey;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
