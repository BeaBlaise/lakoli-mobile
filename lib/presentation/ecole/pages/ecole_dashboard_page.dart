import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/ecole_dashboard_entity.dart';
import '../../auth/application/auth_controller.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/domain/publication_card_view.dart';
import '../../shared/widgets/states/empty_state_view.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/ecole_dashboard_controller.dart';
import '../application/ecole_publications_controller.dart';

/// Mobile de Ecole/Dashboard.tsx — sans les pourcentages de croissance sur 30 jours ni le
/// graphe d'engagement sur 7 jours (voir Api\V1\Ecole\DashboardController côté Laravel, qui
/// ne les calcule pas non plus pour cette première version mobile).
class EcoleDashboardPage extends ConsumerWidget {
  const EcoleDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final dashboardState = ref.watch(ecoleDashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.ecole?.nom ?? 'Lakoli'),
        actions: [
          IconButton(
            onPressed: () => context.push('/creer'),
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Nouvelle publication',
          ),
        ],
      ),
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: ErrorStateView(
            exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
            onRetry: () => ref.read(ecoleDashboardControllerProvider.notifier).refresh(),
          ),
        ),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () => ref.read(ecoleDashboardControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _StatsRow(stats: dashboard.stats),
              if (dashboard.demandesAbonnement.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text('Demandes d\'abonnement', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                for (final request in dashboard.demandesAbonnement)
                  _FollowRequestRow(request: request),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text('Vos publications', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              const _MyPublicationsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final EcoleDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatTile(label: 'Abonnés', value: stats.followersCount)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatTile(label: 'Publications', value: stats.publicationsCount)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatTile(label: "J'aime", value: stats.likesCount)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatTile(label: 'Commentaires', value: stats.commentairesCount)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text('$value', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _FollowRequestRow extends ConsumerWidget {
  const _FollowRequestRow({required this.request});

  final FollowRequestEntity request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          AppAvatar(imageUrl: request.userAvatarUrl, name: request.userFullName, size: AppAvatarSize.md),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(request.userFullName)),
          IconButton(
            onPressed: () => ref.read(ecoleDashboardControllerProvider.notifier).acceptFollowRequest(request),
            icon: Icon(Icons.check_circle_outline_rounded, color: context.colors.success),
          ),
          IconButton(
            onPressed: () => ref.read(ecoleDashboardControllerProvider.notifier).refuseFollowRequest(request),
            icon: Icon(Icons.cancel_outlined, color: context.colors.error),
          ),
        ],
      ),
    );
  }
}

class _MyPublicationsList extends ConsumerWidget {
  const _MyPublicationsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ecolePublicationsControllerProvider);

    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ErrorStateView(
        exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
        onRetry: () => ref.invalidate(ecolePublicationsControllerProvider),
      ),
      data: (publications) {
        if (publications.isEmpty) {
          return const EmptyStateView(
            icon: Icons.article_outlined,
            title: 'Aucune publication',
            message: 'Utilisez le bouton "+" pour partager votre première actualité.',
          );
        }

        return Column(
          children: [
            for (final publication in publications)
              Dismissible(
                key: ValueKey(publication.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: context.colors.errorBg,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Icon(Icons.delete_outline_rounded, color: context.colors.error),
                ),
                confirmDismiss: (_) => _confirmDelete(context),
                onDismissed: (_) => ref.read(ecolePublicationsControllerProvider.notifier).delete(publication.id),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: PublicationCardView(publication: publication),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette publication ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          AppButton(
            label: 'Supprimer',
            variant: AppButtonVariant.destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
