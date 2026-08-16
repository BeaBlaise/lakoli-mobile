import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/ecole_entity.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/ecole_profile_controller.dart';

class EcoleProfilePage extends ConsumerWidget {
  const EcoleProfilePage({super.key, required this.ecoleId});

  final String ecoleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ecoleState = ref.watch(ecoleProfileControllerProvider(ecoleId));

    return Scaffold(
      body: ecoleState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: ErrorStateView(
              exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
              onRetry: () => ref.invalidate(ecoleProfileControllerProvider(ecoleId)),
            ),
          ),
        ),
        data: (ecole) => _EcoleProfileBody(ecole: ecole, ecoleId: ecoleId),
      ),
    );
  }
}

class _EcoleProfileBody extends ConsumerWidget {
  const _EcoleProfileBody({required this.ecole, required this.ecoleId});

  final EcoleEntity ecole;
  final String ecoleId;

  String? get _location {
    for (final part in [ecole.commune, ecole.prefecture, ecole.region]) {
      if (part != null) return part;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: ecole.coverPhotoUrl != null
                ? CachedNetworkImage(imageUrl: ecole.coverPhotoUrl!, fit: BoxFit.cover)
                : Container(color: colors.brand100),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -32),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
                        child: AppAvatar(imageUrl: ecole.photoUrl, name: ecole.nom, size: AppAvatarSize.xl),
                      ),
                    ),
                    const Spacer(),
                    if (!ecole.isOwner)
                      _FollowButton(
                        status: ecole.followStatus,
                        onTap: () => ref.read(ecoleProfileControllerProvider(ecoleId).notifier).toggleFollow(),
                      ),
                  ],
                ),
                Text(ecole.nom, style: textTheme.headlineSmall),
                if (_location != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: colors.inkMuted),
                      const SizedBox(width: 4),
                      Text(_location!, style: textTheme.bodyMedium?.copyWith(color: colors.inkMuted)),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                AppBadge(label: '${ecole.followersCount} abonnés', tone: AppBadgeTone.neutral),
                if (ecole.description != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(ecole.description!, style: textTheme.bodyLarge),
                ],
                if (ecole.phone != null || ecole.email != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('Contact', style: textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  if (ecole.phone != null)
                    _ContactRow(icon: Icons.call_outlined, label: ecole.phone!),
                  if (ecole.email != null)
                    _ContactRow(icon: Icons.mail_outline, label: ecole.email!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.inkMuted),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
