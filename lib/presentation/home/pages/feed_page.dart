import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/widgets/domain/publication_card_view.dart';
import '../../shared/widgets/states/empty_state_view.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../../shared/widgets/states/skeleton_box.dart';
import '../application/feed_controller.dart';
import '../widgets/comments_sheet.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lakoli'),
        actions: [
          IconButton(
            onPressed: () => context.push('/videos'),
            icon: const Icon(Icons.videocam_outlined),
            tooltip: 'Vidéos',
          ),
          IconButton(
            onPressed: () => context.push('/messages'),
            icon: const Icon(Icons.mail_outline_rounded),
            tooltip: 'Messages',
          ),
          IconButton(
            onPressed: () => context.push('/communautes'),
            icon: const Icon(Icons.groups_outlined),
            tooltip: 'Communautés',
          ),
        ],
      ),
      body: feedState.when(
        loading: () => const _FeedSkeleton(),
        error: (error, _) => Center(
          child: ErrorStateView(
            exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
            onRetry: () => ref.read(feedControllerProvider.notifier).refresh(),
          ),
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
              child: ListView(
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  EmptyStateView(
                    icon: Icons.explore_outlined,
                    title: state.hasFollows ? 'Rien de nouveau pour le moment' : 'Découvrez des écoles',
                    message: state.hasFollows
                        ? 'Les publications des écoles que vous suivez apparaîtront ici.'
                        : "Suivez des écoles depuis l'onglet Découvrir pour personnaliser votre fil.",
                    actionLabel: state.hasFollows ? null : 'Découvrir des écoles',
                    onAction: state.hasFollows ? null : () => context.push('/decouvrir'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 400) {
                  ref.read(feedControllerProvider.notifier).loadMore();
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: state.items.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
                    );
                  }

                  final publication = state.items[index];
                  return PublicationCardView(
                    publication: publication,
                    onLike: () => ref.read(feedControllerProvider.notifier).toggleLike(publication),
                    onComment: () => showCommentsSheet(context, publication.id),
                    onOpenEcole: () => context.push('/ecoles/${publication.ecoleId}'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.colors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 40, height: 40, radius: 20),
                SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonBox(height: 14)),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 12),
            SizedBox(height: AppSpacing.xs),
            SkeletonBox(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}
