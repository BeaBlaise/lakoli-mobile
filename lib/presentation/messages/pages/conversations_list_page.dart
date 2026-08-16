import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/message_entity.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/states/empty_state_view.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/conversations_controller.dart';

class ConversationsListPage extends ConsumerWidget {
  const ConversationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            onPressed: () => _openNewConversationSearch(context, ref),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Nouveau message',
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: ErrorStateView(
            exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
            onRetry: () => ref.read(conversationsControllerProvider.notifier).refresh(),
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return EmptyStateView(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Aucune conversation',
              message: 'Envoyez un message à quelqu\'un pour démarrer une conversation.',
              actionLabel: 'Nouveau message',
              onAction: () => _openNewConversationSearch(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(conversationsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ListTile(
                  leading: AppAvatar(
                    imageUrl: conversation.otherUserAvatarUrl,
                    name: conversation.otherUserFullName,
                    size: AppAvatarSize.lg,
                  ),
                  title: Text(conversation.otherUserFullName, style: Theme.of(context).textTheme.titleSmall),
                  subtitle: conversation.lastMessage != null
                      ? Text(
                          conversation.lastMessage!.contenu,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.inkMuted),
                        )
                      : null,
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (conversation.lastMessage != null)
                        Text(
                          DateFormat('d MMM', 'fr_FR').format(conversation.lastMessage!.createdAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      if (conversation.unread) ...[
                        const SizedBox(height: AppSpacing.xs),
                        const AppCounterDot(count: 1),
                      ],
                    ],
                  ),
                  onTap: () {
                    ref.read(conversationsControllerProvider.notifier).markRead(conversation.id);
                    context.push(
                      '/messages/${conversation.id}',
                      extra: {'name': conversation.otherUserFullName, 'userId': conversation.otherUserId},
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openNewConversationSearch(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _NewConversationSheet(),
    );
  }
}

class _NewConversationSheet extends ConsumerStatefulWidget {
  const _NewConversationSheet();

  @override
  ConsumerState<_NewConversationSheet> createState() => _NewConversationSheetState();
}

class _NewConversationSheetState extends ConsumerState<_NewConversationSheet> {
  List<UserSearchResult> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _loading = true);
    final result = await ref.read(messageRepositoryProvider).searchUsers(query);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _results = result.when(success: (list) => list, failure: (_) => []);
    });
  }

  Future<void> _startConversation(UserSearchResult user) async {
    final result = await ref.read(messageRepositoryProvider).startConversation(user.id);
    if (!mounted) return;

    result.when(
      success: (conversationId) {
        Navigator.of(context).pop();
        context.push('/messages/$conversationId', extra: {'name': user.fullName, 'userId': user.id});
      },
      failure: (exception) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nouveau message', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              AppTextField(hint: 'Rechercher une personne', onChanged: _search),
              const SizedBox(height: AppSpacing.md),
              if (_loading) const Center(child: CircularProgressIndicator()),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final user = _results[index];
                    return ListTile(
                      leading: AppAvatar(imageUrl: user.avatarUrl, name: user.fullName, size: AppAvatarSize.md),
                      title: Text(user.fullName),
                      onTap: () => _startConversation(user),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
