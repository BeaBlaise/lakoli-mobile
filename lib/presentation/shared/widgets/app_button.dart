import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outlined, text, destructive }

/// Bouton unique pour toute l'app — gère lui-même l'état de chargement (remplace le libellé
/// par un indicateur, désactive le tap) pour qu'aucun écran n'ait à réinventer ce comportement.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onPressed == null || loading;

    final (Color bg, Color fg, Color? borderColor) = switch (variant) {
      AppButtonVariant.primary => (colors.brand600, Colors.white, null),
      AppButtonVariant.secondary => (colors.brand100, colors.brand600, null),
      AppButtonVariant.outlined => (Colors.transparent, colors.ink, colors.border),
      AppButtonVariant.text => (Colors.transparent, colors.brand600, null),
      AppButtonVariant.destructive => (colors.errorBg, colors.error, null),
    };

    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: AppSpacing.sm)],
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg)),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: disabled ? bg.withValues(alpha: 0.5) : bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: borderColor != null ? Border.all(color: borderColor) : null,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
