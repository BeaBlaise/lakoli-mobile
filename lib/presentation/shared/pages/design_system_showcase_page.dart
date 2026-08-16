import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/ecole_entity.dart';
import '../../../domain/entities/publication_entity.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/domain/ecole_card_view.dart';
import '../widgets/domain/notification_tile.dart';
import '../widgets/domain/publication_card_view.dart';
import '../widgets/domain/video_thumbnail_card.dart';
import '../widgets/states/empty_state_view.dart';
import '../widgets/states/error_state_view.dart';
import '../widgets/states/skeleton_box.dart';
import '../../../core/errors/app_exception.dart';

/// Vitrine du design system — pas un écran produit, un outil de vérification visuelle pour
/// la Phase 3. À retirer du routeur une fois les vrais écrans en place (Phase 4+).
class DesignSystemShowcasePage extends StatelessWidget {
  const DesignSystemShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final samplePublication = PublicationEntity(
      id: '1',
      contenu: "Portes ouvertes ce samedi de 9h à 16h ! Venez découvrir nos filières scientifiques et rencontrer l'équipe pédagogique.",
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ecoleId: 'e1',
      author: const PublicationAuthorEntity(id: 'e1', nom: 'Lycée Donka', region: 'Conakry'),
      likesCount: 24,
      commentsCount: 6,
      userLiked: true,
      sponsorActif: true,
      sponsorNiveau: 'NATIONAL',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Design System — Lakoli')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionLabel('Couleurs'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ColorSwatch('brand600', colors.brand600),
              _ColorSwatch('accent600', colors.accent600),
              _ColorSwatch('success', colors.success),
              _ColorSwatch('warning', colors.warning),
              _ColorSwatch('error', colors.error),
              _ColorSwatch('ink', colors.ink),
              _ColorSwatch('inkMuted', colors.inkMuted),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('Typographie'),
          Text('Display', style: Theme.of(context).textTheme.displayLarge),
          Text('Headline', style: Theme.of(context).textTheme.headlineLarge),
          Text('Title', style: Theme.of(context).textTheme.titleLarge),
          Text('Body — texte courant en français, lisible sur un paragraphe long.', style: Theme.of(context).textTheme.bodyLarge),
          Text('Body small / méta', style: Theme.of(context).textTheme.bodySmall),
          Text('LABEL / EYEBROW', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('Boutons'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              AppButton(label: 'Primaire', onPressed: null),
              AppButton(label: 'Secondaire', variant: AppButtonVariant.secondary, onPressed: null),
              AppButton(label: 'Contour', variant: AppButtonVariant.outlined, onPressed: null),
              AppButton(label: 'Texte', variant: AppButtonVariant.text, onPressed: null),
              AppButton(label: 'Destructeur', variant: AppButtonVariant.destructive, onPressed: null),
              AppButton(label: 'Chargement', loading: true, onPressed: null),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('Badges'),
          Wrap(
            spacing: AppSpacing.sm,
            children: const [
              AppBadge(label: 'Sponsorisé', tone: AppBadgeTone.accent, icon: Icons.trending_up_rounded),
              AppBadge(label: 'Admin', tone: AppBadgeTone.brand, icon: Icons.verified_rounded),
              AppBadge(label: 'Publiée', tone: AppBadgeTone.success),
              AppBadge(label: 'En traitement', tone: AppBadgeTone.warning),
              AppBadge(label: 'Échec', tone: AppBadgeTone.error),
              AppCounterDot(count: 4),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('Avatars'),
          const Row(
            children: [
              AppAvatar(name: 'Mariam Diallo', size: AppAvatarSize.sm),
              SizedBox(width: AppSpacing.sm),
              AppAvatar(name: 'Lycée Donka', size: AppAvatarSize.md),
              SizedBox(width: AppSpacing.sm),
              AppAvatar(name: 'École Kaloum', size: AppAvatarSize.lg),
              SizedBox(width: AppSpacing.sm),
              AppAvatar(name: 'X', size: AppAvatarSize.xl),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('Champ de saisie'),
          const AppTextField(label: 'Téléphone', hint: '+224 6XX XX XX XX'),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(label: 'Mot de passe', obscureText: true, errorText: 'Mot de passe incorrect.'),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('Carte de publication'),
          PublicationCardView(publication: samplePublication, onLike: () {}, onComment: () {}, onShare: () {}),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('Carte école'),
          const EcoleCardView(
            nom: 'Groupe Scolaire Les Palmiers',
            location: 'Kaloum, Conakry',
            followersCount: 342,
            followStatus: FollowStatus.none,
          ),
          const SizedBox(height: AppSpacing.sm),
          const EcoleCardView(
            nom: 'Institut Sainte-Marie',
            location: 'Dixinn, Conakry',
            followStatus: FollowStatus.pending,
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('Vignette vidéo'),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(child: VideoThumbnailCard(ecoleName: 'Lycée Donka', durationLabel: '1:24')),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: VideoThumbnailCard(ecoleName: 'École Kaloum', durationLabel: '0:48')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('Notification'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                NotificationTile(
                  icon: Icons.favorite_rounded,
                  iconTone: colors.error,
                  title: 'Mariam Diallo a aimé votre publication',
                  timeLabel: 'il y a 12 min',
                  avatarName: 'Mariam Diallo',
                  unread: true,
                ),
                Divider(height: 1, color: colors.border),
                NotificationTile(
                  icon: Icons.person_add_alt_1_rounded,
                  iconTone: colors.brand600,
                  title: 'Nouvelle demande d\'abonnement',
                  subtitle: 'Ibrahima Camara souhaite suivre votre école',
                  timeLabel: 'il y a 2 h',
                  avatarName: 'Ibrahima Camara',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('États — chargement'),
          const AppCard(
            child: Row(
              children: [
                SkeletonBox(width: 40, height: 40, radius: 20),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140),
                      SizedBox(height: 6),
                      SkeletonBox(width: 90, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('États — vide'),
          AppCard(
            child: EmptyStateView(
              icon: Icons.school_outlined,
              title: 'Aucune école suivie',
              message: 'Découvrez des écoles pour remplir votre fil.',
              actionLabel: 'Découvrir',
              onAction: () {},
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          _SectionLabel('États — erreur'),
          AppCard(
            child: ErrorStateView(exception: const NetworkException(), onRetry: () {}),
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 13)),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
