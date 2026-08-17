import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/user_entity.dart';
import '../../auth/application/auth_controller.dart';
import '../../shared/widgets/app_button.dart';

/// Mobile de App\Http\Controllers\HomeController — un compte école dont l'active_role est
/// "ecole" mais dont l'école n'est pas encore Validee atterrit ici plutôt que sur le fil
/// normal ou le tableau de bord (voir HomePage, qui choisit entre ce widget/EcoleDashboardPage/
/// FeedPage selon activeRole + ecole.statut).
class EcoleEnAttentePage extends ConsumerWidget {
  const EcoleEnAttentePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final refusee = user?.ecole?.statut == EcoleStatut.refusee;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Lakoli')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                refusee ? Icons.error_outline_rounded : Icons.hourglass_empty_rounded,
                size: 56,
                color: refusee ? colors.error : colors.warning,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                refusee ? 'Inscription refusée' : 'École en attente de validation',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                refusee
                    ? "La validation de « ${user?.ecole?.nom ?? 'votre école'} » a été refusée par un administrateur. Contactez l'équipe Lakoli pour plus d'informations."
                    : 'Merci d\'avoir inscrit « ${user?.ecole?.nom ?? 'votre école'} » sur Lakoli. Un administrateur doit valider votre établissement avant que vous puissiez publier des actualités et vidéos. Cela peut prendre quelques jours.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Se déconnecter',
                variant: AppButtonVariant.outlined,
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
