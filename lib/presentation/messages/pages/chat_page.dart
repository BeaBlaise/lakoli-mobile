import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/message_entity.dart';
import '../../auth/application/auth_controller.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/chat_controller.dart';
import '../application/conversations_controller.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.conversationId, this.otherUserName, this.otherUserId});

  final String conversationId;
  final String? otherUserName;
  final String? otherUserId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  XFile? _pendingImage;
  bool _sending = false;
  bool _blocked = false;

  @override
  void initState() {
    super.initState();
    ref.read(conversationsControllerProvider.notifier).markRead(widget.conversationId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _pendingImage == null) || _sending) return;

    setState(() => _sending = true);
    await ref.read(chatControllerProvider(widget.conversationId).notifier).send(text, imagePath: _pendingImage?.path);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _controller.clear();
      _pendingImage = null;
    });
    _scrollToBottom();
  }

  Future<void> _toggleBlock() async {
    if (widget.otherUserId == null) return;
    final repo = ref.read(messageRepositoryProvider);
    final result = _blocked ? await repo.unblock(widget.otherUserId!) : await repo.block(widget.otherUserId!);
    if (!mounted) return;
    result.when(
      success: (_) {
        setState(() => _blocked = !_blocked);
        ref.invalidate(chatControllerProvider(widget.conversationId));
      },
      failure: (exception) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider(widget.conversationId));
    final myId = ref.watch(authControllerProvider).valueOrNull?.id;
    final colors = context.colors;

    ref.listen(chatControllerProvider(widget.conversationId), (previous, next) {
      if ((previous?.valueOrNull?.messages.length ?? 0) < (next.valueOrNull?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName ?? 'Conversation'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'block') _toggleBlock();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'block', child: Text(_blocked ? 'Débloquer' : 'Bloquer')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: ErrorStateView(
                  exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
                  onRetry: () => ref.invalidate(chatControllerProvider(widget.conversationId)),
                ),
              ),
              data: (chat) {
                if (chat.messages.isEmpty) {
                  return Center(child: Text('Dites bonjour !', style: TextStyle(color: colors.inkMuted)));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients && _scrollController.position.pixels == 0) _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    final message = chat.messages[index];
                    final isMine = myId != null && myId == message.userId;
                    return _MessageBubble(message: message, isMine: isMine);
                  },
                );
              },
            ),
          ),
          if (state.valueOrNull?.canReply == false)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              color: colors.errorBg,
              child: Text(
                'Vous ne pouvez plus échanger de messages avec cette personne.',
                style: TextStyle(color: colors.error),
                textAlign: TextAlign.center,
              ),
            )
          else
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_pendingImage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            Text('1 image jointe', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(width: AppSpacing.sm),
                            InkWell(
                              onTap: () => setState(() => _pendingImage = null),
                              child: Icon(Icons.close_rounded, size: 16, color: colors.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _sending
                              ? null
                              : () async {
                                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if (picked != null) setState(() => _pendingImage = picked);
                                },
                          icon: Icon(Icons.image_outlined, color: colors.inkMuted),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: !_sending,
                            decoration: const InputDecoration(hintText: 'Écrire un message…'),
                            minLines: 1,
                            maxLines: 4,
                          ),
                        ),
                        IconButton(
                          onPressed: _sending ? null : _send,
                          icon: _sending
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(Icons.send_rounded, color: colors.brand600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final MessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isMine ? colors.brand600 : colors.surface,
                border: isMine ? null : Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: CachedNetworkImage(imageUrl: message.imageUrl!, width: 200, fit: BoxFit.cover),
                    ),
                  if (message.contenu.isNotEmpty)
                    Text(
                      message.contenu,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isMine ? Colors.white : colors.ink),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(DateFormat('HH:mm').format(message.createdAt), style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
