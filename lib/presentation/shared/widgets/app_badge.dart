import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

enum AppBadgeTone { brand, accent, success, warning, error, neutral }

/// Étiquette courte — badge "Sponsorisé", "Admin", type d'établissement, statut de vidéo.
/// Le ton sémantique (succès/erreur/avertissement) reste toujours distinct de la couleur de
/// marque : un badge d'état ne doit jamais se confondre avec un badge de mise en avant.
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.tone = AppBadgeTone.neutral, this.icon});

  final String label;
  final AppBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color bg, Color fg) = switch (tone) {
      AppBadgeTone.brand => (colors.brand100, colors.brand600),
      AppBadgeTone.accent => (colors.accent100, colors.accent600),
      AppBadgeTone.success => (colors.successBg, colors.success),
      AppBadgeTone.warning => (colors.warningBg, colors.warning),
      AppBadgeTone.error => (colors.errorBg, colors.error),
      AppBadgeTone.neutral => (colors.border.withValues(alpha: 0.5), colors.inkMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: fg), const SizedBox(width: 3)],
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, letterSpacing: 0.2)),
        ],
      ),
    );
  }
}

/// Pastille numérique de non-lus — nav, icônes de communauté/messages (voir l'audit backend :
/// même sémantique que côté web, "nombre de conversations avec du non-lu", pas un total brut).
class AppCounterDot extends StatelessWidget {
  const AppCounterDot({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: colors.error, borderRadius: BorderRadius.circular(AppRadius.full)),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, height: 1),
      ),
    );
  }
}
