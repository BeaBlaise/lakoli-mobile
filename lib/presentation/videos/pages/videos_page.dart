import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/video_entity.dart';
import '../../auth/application/auth_controller.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/domain/video_thumbnail_card.dart';
import '../../shared/widgets/states/empty_state_view.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/my_videos_controller.dart';
import '../application/videos_feed_controller.dart';

class VideosPage extends ConsumerWidget {
  const VideosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final isEcole = user?.activeRole == UserRole.ecole;
    // VideoPolicy::create() côté Laravel exige ecole.statut === Validee, même règle que
    // PublicationPolicy — voir CreatePublicationPage pour le même contrôle.
    final canUpload = isEcole && user?.ecole?.statut == EcoleStatut.validee;
    final feedState = ref.watch(videosFeedControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vidéos'),
        actions: [
          if (canUpload)
            IconButton(
              onPressed: () => _pickAndUpload(context, ref),
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: 'Publier une vidéo',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(videosFeedControllerProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            if (isEcole)
              SliverToBoxAdapter(
                child: canUpload
                    ? const _MyVideosSection()
                    : Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Un administrateur doit valider votre école avant que vous puissiez publier des vidéos.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
              ),
            feedState.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: ErrorStateView(
                    exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
                    onRetry: () => ref.read(videosFeedControllerProvider.notifier).refresh(),
                  ),
                ),
              ),
              data: (state) {
                if (state.items.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyStateView(
                      icon: Icons.videocam_outlined,
                      title: 'Aucune vidéo pour le moment',
                      message: 'Les vidéos publiées par les écoles apparaîtront ici.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final video = state.items[index];
                        return VideoThumbnailCard(
                          thumbnailUrl: video.thumbnailUrl,
                          ecoleName: video.ecole.nom,
                          durationLabel: video.dureeSecondes != null ? _formatDuration(video.dureeSecondes!) : null,
                          onTap: () {
                            ref.read(videosFeedControllerProvider.notifier).registerView(video.id);
                            if (video.videoUrl != null) {
                              context.push('/videos/lecteur', extra: {'url': video.videoUrl!, 'title': video.ecole.nom});
                            }
                          },
                        );
                      },
                      childCount: state.items.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 10));
    if (picked == null) return;
    if (!context.mounted) return;

    final error = await ref.read(myVideosControllerProvider.notifier).upload(picked.path);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Vidéo envoyée — traitement en cours.')),
    );
  }
}

class _MyVideosSection extends ConsumerWidget {
  const _MyVideosSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myVideosControllerProvider);

    return state.when(
      loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: LinearProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (videos) {
        if (videos.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mes vidéos', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return SizedBox(
                      width: 100,
                      child: Stack(
                        children: [
                          VideoThumbnailCard(
                            thumbnailUrl: video.thumbnailUrl,
                            ecoleName: _statutLabel(video.statut),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: InkWell(
                              onTap: () => ref.read(myVideosControllerProvider.notifier).delete(video.id),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                          if (video.statut != VideoStatut.prete)
                            Positioned(
                              left: 4,
                              top: 4,
                              child: AppBadge(
                                label: video.statut == VideoStatut.enTraitement ? 'En cours' : 'Échec',
                                tone: video.statut == VideoStatut.enTraitement ? AppBadgeTone.warning : AppBadgeTone.error,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }

  String _statutLabel(VideoStatut statut) => switch (statut) {
        VideoStatut.enTraitement => 'En traitement',
        VideoStatut.prete => 'Prête',
        VideoStatut.echouee => 'Échec',
      };
}
