import 'package:flutter/material.dart';

/// 🎨 Extensions pour la typographie premium
extension PremiumTextStyles on TextStyle {
  static TextStyle displayXL(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -1,
      color: isDark ? Colors.white : Colors.black,
      height: 1.2,
    );
  }

  static TextStyle displayL(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: isDark ? Colors.white : Colors.black,
      height: 1.3,
    );
  }

  static TextStyle headingL(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: isDark ? Colors.white : Colors.black,
      height: 1.3,
    );
  }

  static TextStyle headingM(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: isDark ? Colors.white : Colors.black,
      height: 1.4,
    );
  }

  static TextStyle headingS(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: isDark ? Colors.white : Colors.black,
      height: 1.4,
    );
  }

  static TextStyle bodyL(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
      color: isDark ? Colors.white : Colors.black,
      height: 1.5,
    );
  }

  static TextStyle bodyM(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      color: isDark ? Colors.white : Colors.black,
      height: 1.5,
    );
  }

  static TextStyle bodyS(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: isDark ? Colors.white70 : Colors.black54,
      height: 1.4,
    );
  }

  static TextStyle captionL(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: isDark ? Colors.white54 : Colors.black45,
      height: 1.3,
    );
  }

  static TextStyle captionS(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 1,
      color: isDark ? Colors.white54 : Colors.black45,
      height: 1.2,
    );
  }

  // Variantes avec couleur spécifique
  static TextStyle bold(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: color ?? (isDark ? Colors.white : Colors.black),
      height: 1.5,
    );
  }

  static TextStyle muted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: isDark ? Colors.white54 : Colors.black54,
      height: 1.5,
    );
  }

  static TextStyle success(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2DB89A),
      letterSpacing: 0.2,
      height: 1.5,
    );
  }

  static TextStyle danger(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFE63946),
      letterSpacing: 0.2,
      height: 1.5,
    );
  }

  static TextStyle warning(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF77F00),
      letterSpacing: 0.2,
      height: 1.5,
    );
  }
}

/// Extensions pour les espaces
extension PremiumSpacing on num {
  SizedBox get vspace => SizedBox(height: toDouble());
  SizedBox get hspace => SizedBox(width: toDouble());
}

/// 🎨 Classe pour les constantes de design
class PremiumDesign {
  // Couleurs
  static const Color accentPrimary = Color(0xFF7C3AED);
  static const Color accentSecondary = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF2DB89A);
  static const Color danger = Color(0xFFE63946);
  static const Color warning = Color(0xFFF77F00);
  static const Color info = Color(0xFF0066CC);

  // Espacement
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Border radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 9999;

  // Animations
  static const Duration transitionFast = Duration(milliseconds: 150);
  static const Duration transitionNormal = Duration(milliseconds: 300);
  static const Duration transitionSlow = Duration(milliseconds: 500);
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
}
