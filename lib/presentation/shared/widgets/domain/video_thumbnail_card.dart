import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Vignette vidéo pour la grille du fil vidéo (Phase 8) — n'intègre jamais de lecteur ni ne
/// télécharge la vidéo elle-même ; affiche la miniature et délègue l'ouverture réelle au
/// parent (voir la contrainte produit : ne jamais charger une vidéo en mémoire sans y être
/// invité par un geste explicite de l'utilisateur).
class VideoThumbnailCard extends StatelessWidget {
  const VideoThumbnailCard({
    super.key,
    this.thumbnailUrl,
    required this.ecoleName,
    this.durationLabel,
    this.onTap,
  });

  final String? thumbnailUrl;
  final String ecoleName;
  final String? durationLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: colors.ink.withValues(alpha: 0.08)),
              if (thumbnailUrl != null) Image.network(thumbnailUrl!, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              const Center(
                child: Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 40),
              ),
              Positioned(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ecoleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (durationLabel != null)
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(durationLabel!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
