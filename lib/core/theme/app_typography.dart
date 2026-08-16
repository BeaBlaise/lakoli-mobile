import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sora (titres) + police système par défaut (texte courant) — un choix délibéré, pas un
/// compromis : Lakoli doit rester utilisable sur un réseau mobile faible (voir la contrainte
/// produit dédiée), donc aucune police n'est chargée à l'exécution depuis un service distant
/// (type google_fonts). Sora est embarquée une fois pour toutes comme asset ; le corps de texte
/// utilise la police système (Roboto/San Francisco) — zéro coût réseau, lisibilité maximale en
/// français sur de longs paragraphes.
class AppTypography {
  const AppTypography._();

  static const _display = 'Sora';

  static TextTheme textTheme(AppColors colors) {
    final base = TextTheme(
      displayLarge: TextStyle(fontFamily: _display, fontWeight: FontWeight.w700, fontSize: 32, height: 1.15, color: colors.ink, letterSpacing: -0.3),
      headlineLarge: TextStyle(fontFamily: _display, fontWeight: FontWeight.w600, fontSize: 24, height: 1.2, color: colors.ink),
      headlineMedium: TextStyle(fontFamily: _display, fontWeight: FontWeight.w600, fontSize: 20, height: 1.25, color: colors.ink),
      titleLarge: TextStyle(fontFamily: _display, fontWeight: FontWeight.w600, fontSize: 18, height: 1.3, color: colors.ink),
      titleMedium: TextStyle(fontFamily: _display, fontWeight: FontWeight.w500, fontSize: 16, height: 1.35, color: colors.ink),
      titleSmall: TextStyle(fontFamily: _display, fontWeight: FontWeight.w500, fontSize: 14, height: 1.35, color: colors.ink),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, height: 1.5, color: colors.ink),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, height: 1.5, color: colors.ink),
      bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.5, height: 1.45, color: colors.inkMuted),
      labelLarge: TextStyle(fontFamily: _display, fontWeight: FontWeight.w600, fontSize: 14, height: 1.2, color: colors.ink, letterSpacing: 0.1),
      labelMedium: TextStyle(fontFamily: _display, fontWeight: FontWeight.w600, fontSize: 12.5, height: 1.2, color: colors.inkMuted, letterSpacing: 0.2),
      labelSmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 10.5, height: 1.3, color: colors.inkMuted, letterSpacing: 0.6),
    );
    return base;
  }
}
