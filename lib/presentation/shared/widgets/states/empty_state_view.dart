import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../app_button.dart';

/// État "rien à afficher" — jamais un écran blanc silencieux (voir la contrainte produit :
/// chaque écran doit expliquer clairement pourquoi il est vide).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: colors.inkMuted.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: actionLabel!, onPressed: onAction, variant: AppButtonVariant.secondary),
          ],
        ],
      ),
    );
  }
}
