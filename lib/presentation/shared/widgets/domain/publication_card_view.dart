import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/publication_entity.dart';
import '../app_avatar.dart';
import '../app_badge.dart';
import '../app_card.dart';

/// Carte de publication — le composant le plus vu de l'app (moteur du fil, voir Phase 5).
/// Purement présentationnel : reçoit une [PublicationEntity] déjà chargée et des callbacks,
/// ne fait aucun appel réseau lui-même. Le badge sponsorisé ne s'affiche que si
/// `publication.sponsorActif` est vrai côté serveur — jamais déduit côté client.
class PublicationCardView extends StatelessWidget {
  const PublicationCardView({
    super.key,
    required this.publication,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onOpenEcole,
  });

  final PublicationEntity publication;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onOpenEcole;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpenEcole,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Row(
              children: [
                AppAvatar(imageUrl: publication.author.photoUrl, name: publication.author.nom, size: AppAvatarSize.md),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(publication.author.nom, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
                          if (publication.sponsorActif) ...[
                            const SizedBox(width: AppSpacing.sm),
                            const AppBadge(label: 'Sponsorisé', tone: AppBadgeTone.accent, icon: Icons.trending_up_rounded),
                          ],
                        ],
                      ),
                      Text(
                        [
                          if (publication.author.region != null) publication.author.region!,
                          _relativeTime(publication.createdAt),
                        ].join(' · '),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(publication.contenu, style: textTheme.bodyLarge),
          if (publication.imageUrl != null) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(publication.imageUrl!, fit: BoxFit.cover),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _ActionChip(
                icon: publication.userLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: publication.likesCount > 0 ? '${publication.likesCount}' : "J'aime",
                active: publication.userLiked,
                activeColor: colors.error,
                onTap: onLike,
              ),
              const SizedBox(width: AppSpacing.lg),
              _ActionChip(
                icon: Icons.mode_comment_outlined,
                label: publication.commentsCount > 0 ? '${publication.commentsCount}' : 'Commenter',
                onTap: onComment,
              ),
              const Spacer(),
              IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, size: 20),
                color: colors.inkMuted,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "à l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, this.active = false, this.activeColor, this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final Color? activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? (activeColor ?? colors.brand600) : colors.inkMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
