import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../app_button.dart';

/// État d'erreur générique — le message vient toujours d'un [AppException] déjà traduit en
/// français par la couche réseau (voir core/network/api_client.dart), jamais du texte brut
/// d'une exception technique. "Réessayer" est optionnel : certaines erreurs (403) n'ont rien
/// à réessayer.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, required this.exception, this.onRetry});

  final AppException exception;
  final VoidCallback? onRetry;

  bool get _isOffline => exception is NetworkException;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
            size: 40,
            color: colors.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _isOffline ? 'Pas de connexion' : 'Une erreur est survenue',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            exception.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Réessayer', onPressed: onRetry, icon: Icons.refresh_rounded),
          ],
        ],
      ),
    );
  }
}
