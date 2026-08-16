import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/communaute_entity.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/states/empty_state_view.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/communautes_list_controller.dart';

class CommunautesListPage extends ConsumerWidget {
  const CommunautesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communautesListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Communautés')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: ErrorStateView(
            exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
            onRetry: () => ref.read(communautesListControllerProvider.notifier).refresh(),
          ),
        ),
        data: (communautes) {
          if (communautes.isEmpty) {
            return const EmptyStateView(
              icon: Icons.groups_outlined,
              title: 'Aucune communauté disponible',
              message: 'Revenez plus tard — de nouvelles communautés sont ajoutées régulièrement.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(communautesListControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: communautes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _CommunauteRow(communaute: communautes[index]),
            ),
          );
        },
      ),
    );
  }
}

class _CommunauteRow extends ConsumerWidget {
  const _CommunauteRow({required this.communaute});

  final CommunauteEntity communaute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final lastMessage = communaute.lastMessage;

    return ListTile(
      onTap: communaute.joined ? () => context.push('/communautes/${communaute.id}') : null,
      leading: AppAvatar(imageUrl: communaute.iconUrl, name: communaute.nom, size: AppAvatarSize.lg),
      title: Text(communaute.nom, style: textTheme.titleSmall),
      subtitle: Text(
        lastMessage != null ? '${lastMessage.userFullName} : ${lastMessage.contenu}' : 'Aucun message',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodySmall?.copyWith(color: colors.inkMuted),
      ),
      trailing: communaute.joined
          ? _JoinedTrailing(communaute: communaute, lastMessageDate: lastMessage?.createdAt)
          : AppButton(
              label: 'Rejoindre',
              variant: AppButtonVariant.secondary,
              onPressed: () async {
                final error = await ref.read(communautesListControllerProvider.notifier).join(communaute);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                }
              },
            ),
    );
  }
}

class _JoinedTrailing extends StatelessWidget {
  const _JoinedTrailing({required this.communaute, this.lastMessageDate});

  final CommunauteEntity communaute;
  final DateTime? lastMessageDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (lastMessageDate != null)
          Text(_relativeTime(lastMessageDate!), style: Theme.of(context).textTheme.labelSmall),
        if (communaute.unreadCount > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          AppCounterDot(count: communaute.unreadCount),
        ],
      ],
    );
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'maintenant';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }
}
