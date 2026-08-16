import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/ecole_entity.dart';
import '../app_avatar.dart';
import '../app_badge.dart';
import '../app_button.dart';
import '../app_card.dart';

/// Carte école — utilisée dans Découvrir (Phase 6) et les listes de résultats de recherche.
/// Paramètres simples plutôt qu'une entité unique : la recherche (EcoleSearchResource) et le
/// profil complet (EcoleResource) n'exposent pas les mêmes champs côté API (voir l'audit
/// backend, Phase 1) — à l'appelant de ne passer que ce qu'il a réellement.
class EcoleCardView extends StatelessWidget {
  const EcoleCardView({
    super.key,
    required this.nom,
    this.photoUrl,
    this.location,
    this.followersCount,
    this.followStatus = FollowStatus.none,
    this.onTap,
    this.onFollowToggle,
  });

  final String nom;
  final String? photoUrl;
  final String? location;
  final int? followersCount;
  final FollowStatus followStatus;
  final VoidCallback? onTap;
  final VoidCallback? onFollowToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(imageUrl: photoUrl, name: nom, size: AppAvatarSize.lg),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nom, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (location != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: colors.inkMuted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(location!, style: textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
                if (followersCount != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppBadge(label: '$followersCount abonnés', tone: AppBadgeTone.neutral),
                ],
              ],
            ),
          ),
          if (onFollowToggle != null) ...[
            const SizedBox(width: AppSpacing.sm),
            _FollowButton(status: followStatus, onTap: onFollowToggle),
          ],
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.status, this.onTap});

  final FollowStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (label, variant) = switch (status) {
      FollowStatus.none => ('Suivre', AppButtonVariant.primary),
      FollowStatus.pending => ('Envoyée', AppButtonVariant.outlined),
      FollowStatus.accepted => ('Abonné', AppButtonVariant.secondary),
    };
    return AppButton(label: label, onPressed: onTap, variant: variant);
  }
}
