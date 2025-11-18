import 'package:flutter/material.dart';
import 'app_settings.dart';

// Palette Dark Theme Premium
const Color kBackground = Color(0xFF0F1113);       // Noir très foncé - background principal
const Color kSurface = Color(0xFF1A1E23);          // Gris très foncé - cards/surfaces
const Color kCard = Color(0xFF252A31);             // Gris foncé - card background
const Color kAccent = Color(0xFF2DB89A);           // Teal vibrant - accent principal
const Color kAccentAlt = Color(0xFF00D4AA);        // Teal clair - accent secondaire
const Color kMuted = Color(0xFF888888);            // Gris moyen
const Color kBorder = Color(0xFF3A3F47);           // Bordure gris foncé
const Color kSuccess = Color(0xFF2DB89A);          // Teal pour confirmations
const Color kDanger = Color(0xFFE63946);           // Rouge pour alertes
const Color kWarning = Color(0xFFF77F00);          // Orange pour avertissements
const Color kTextPrimary = Color(0xFFFFFFFF);      // Texte blanc pur
const Color kTextSecondary = Color(0xFFA0A0A0);    // Texte gris clair

// Typography - Style épuré
const double kFontSizeXS = 12.0;
const double kFontSizeS = 14.0;
const double kFontSizeM = 16.0;
const double kFontSizeL = 18.0;
const double kFontSizeXL = 24.0;
const double kFontSize2XL = 32.0;

String fmtFCFA(dynamic v) {
  try {
    return AppSettings().formatCurrency(v);
  } catch (_) {
    if (v == null) return '-';
    if (v is num) return '${v.toStringAsFixed(0)} FCFA';
    final parsed = num.tryParse(v.toString());
    if (parsed == null) return '${v.toString()} FCFA';
    return '${parsed.toStringAsFixed(0)} FCFA';
  }
}

// Theme ThemeData Dark Premium
ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: kSurface,
      foregroundColor: kTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kTextPrimary,
        fontSize: kFontSizeL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: kCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: kBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kAccent,
      foregroundColor: Color(0xFF0F1113),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: Color(0xFF0F1113),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        textStyle: TextStyle(
          fontSize: kFontSizeM,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kAccent,
        side: BorderSide(color: kBorder, width: 1),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(
          fontSize: kFontSizeM,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kAccent, width: 2),
      ),
      labelStyle: TextStyle(
        color: kMuted,
        fontSize: kFontSizeM,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: TextStyle(
        color: kMuted,
        fontSize: kFontSizeM,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: kTextPrimary,
        fontSize: kFontSize2XL,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: kTextPrimary,
        fontSize: kFontSizeXL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        color: kTextPrimary,
        fontSize: kFontSizeL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      titleMedium: TextStyle(
        color: kTextPrimary,
        fontSize: kFontSizeM,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      bodyLarge: TextStyle(
        color: kTextPrimary,
        fontSize: kFontSizeM,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        color: kTextSecondary,
        fontSize: kFontSizeS,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      labelSmall: TextStyle(
        color: kMuted,
        fontSize: kFontSizeXS,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ),
    dividerColor: kBorder,
    dialogTheme: DialogThemeData(
      backgroundColor: kSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kBorder, width: 1),
      ),
    ),
  );
}
