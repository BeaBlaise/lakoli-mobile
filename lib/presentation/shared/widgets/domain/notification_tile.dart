import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../app_avatar.dart';

/// Ligne de notification — l'icône encode le type d'événement (like/commentaire/abonnement…)
/// en plus du texte, pour rester scannable dans une longue liste (voir "Structure is
/// information" : l'icône n'est pas décorative, elle porte une vraie distinction).
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.icon,
    required this.iconTone,
    required this.title,
    this.subtitle,
    required this.timeLabel,
    this.avatarUrl,
    this.avatarName,
    this.unread = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconTone;
  final String title;
  final String? subtitle;
  final String timeLabel;
  final String? avatarUrl;
  final String? avatarName;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread ? colors.brand100.withValues(alpha: 0.4) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (avatarName != null)
                  AppAvatar(imageUrl: avatarUrl, name: avatarName!, size: AppAvatarSize.md)
                else
                  CircleAvatar(radius: 20, backgroundColor: iconTone.withValues(alpha: 0.12), child: Icon(icon, color: iconTone, size: 20)),
                if (avatarName != null)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
                      child: Icon(icon, size: 12, color: iconTone),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.bodyMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 4),
                  Text(timeLabel, style: textTheme.labelSmall),
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: colors.brand600, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
