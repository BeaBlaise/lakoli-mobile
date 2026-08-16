import 'package:flutter/material.dart';

/// Palette Lakoli — un bleu institutionnel profond (confiance, éducation) porte l'identité de
/// marque, une terre cuite chaude sert d'accent ponctuel (jamais dominant), et les neutres ont
/// un léger biais chaud plutôt qu'un gris pur, pour éviter l'aspect "générique". Chaque teinte a
/// une variante claire et sombre — voir [AppColors.light] / [AppColors.dark].
class AppColors {
  const AppColors({
    required this.brand900,
    required this.brand600,
    required this.brand400,
    required this.brand100,
    required this.accent600,
    required this.accent100,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.error,
    required this.errorBg,
    required this.ink,
    required this.inkMuted,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
  });

  final Color brand900;
  final Color brand600;
  final Color brand400;
  final Color brand100;

  final Color accent600;
  final Color accent100;

  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color error;
  final Color errorBg;

  final Color ink;
  final Color inkMuted;
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color border;

  static const light = AppColors(
    brand900: Color(0xFF10233D),
    brand600: Color(0xFF1B3A63),
    brand400: Color(0xFF5C82AD),
    brand100: Color(0xFFE7EDF4),
    accent600: Color(0xFFB8582F),
    accent100: Color(0xFFF7E7DC),
    success: Color(0xFF2F6B4F),
    successBg: Color(0xFFE5F0EA),
    warning: Color(0xFFA66A1E),
    warningBg: Color(0xFFF5EADA),
    error: Color(0xFFA83B32),
    errorBg: Color(0xFFF5E4E1),
    ink: Color(0xFF201E1A),
    inkMuted: Color(0xFF6B6659),
    background: Color(0xFFF6F4EE),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    border: Color(0xFFE1DCCE),
  );

  static const dark = AppColors(
    brand900: Color(0xFFDCE7F5),
    brand600: Color(0xFF7FA8D9),
    brand400: Color(0xFF4A6FA0),
    brand100: Color(0xFF202B3A),
    accent600: Color(0xFFE0A07C),
    accent100: Color(0xFF3A2A20),
    success: Color(0xFF7FBE9C),
    successBg: Color(0xFF1B2B22),
    warning: Color(0xFFE0AC5C),
    warningBg: Color(0xFF2E2416),
    error: Color(0xFFE08B7D),
    errorBg: Color(0xFF331F1B),
    ink: Color(0xFFEDEAE2),
    inkMuted: Color(0xFFA7A398),
    background: Color(0xFF16171A),
    surface: Color(0xFF1D1F23),
    surfaceRaised: Color(0xFF23262B),
    border: Color(0xFF33342F),
  );
}

/// Accès rapide aux couleurs depuis n'importe quel widget : `context.colors.brand600`.
/// Résolu dynamiquement selon le thème actif (clair/sombre), jamais codé en dur.
extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).brightness == Brightness.dark ? AppColors.dark : AppColors.light;
}
