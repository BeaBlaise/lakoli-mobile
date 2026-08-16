import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/communaute_post_entity.dart';
import '../../auth/application/auth_controller.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/communaute_chat_controller.dart';

class CommunauteChatPage extends ConsumerStatefulWidget {
  const CommunauteChatPage({super.key, required this.communauteId, this.communauteNom});

  final String communauteId;
  final String? communauteNom;

  @override
  ConsumerState<CommunauteChatPage> createState() => _CommunauteChatPageState();
}

class _CommunauteChatPageState extends ConsumerState<CommunauteChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  CommunautePostEntity? _replyTo;
  XFile? _pendingImage;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _pendingImage == null) || _sending) return;

    setState(() => _sending = true);
    await ref.read(communauteChatControllerProvider(widget.communauteId).notifier).sendMessage(
          text,
          imagePath: _pendingImage?.path,
          replyToId: _replyTo?.id,
        );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _controller.clear();
      _pendingImage = null;
      _replyTo = null;
    });
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communauteChatControllerProvider(widget.communauteId));
    final myId = ref.watch(authControllerProvider).valueOrNull?.id;
    final colors = context.colors;

    ref.listen(communauteChatControllerProvider(widget.communauteId), (previous, next) {
      if ((previous?.valueOrNull?.length ?? 0) < (next.valueOrNull?.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.communauteNom ?? 'Communauté')),
      body: Column(
        children: [
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: ErrorStateView(
                  exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
                  onRetry: () => ref.invalidate(communauteChatControllerProvider(widget.communauteId)),
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text('Aucun message pour le moment', style: TextStyle(color: colors.inkMuted)),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients && _scrollController.position.pixels == 0) _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => _MessageBubble(
                    message: messages[index],
                    isMine: myId != null && myId == messages[index].userId,
                    onLike: () => ref.read(communauteChatControllerProvider(widget.communauteId).notifier).toggleLike(messages[index]),
                    onReply: () => setState(() => _replyTo = messages[index]),
                    onDelete: () =>
                        ref.read(communauteChatControllerProvider(widget.communauteId).notifier).deleteMessage(messages[index].id),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_replyTo != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Réponse à ${_replyTo!.userFullName}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                            ),
                          ),
                          InkWell(onTap: () => setState(() => _replyTo = null), child: Icon(Icons.close_rounded, size: 16, color: colors.inkMuted)),
                        ],
                      ),
                    ),
                  if (_pendingImage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Text('1 image jointe', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(width: AppSpacing.sm),
                          InkWell(onTap: () => setState(() => _pendingImage = null), child: Icon(Icons.close_rounded, size: 16, color: colors.inkMuted)),
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
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.onLike,
    required this.onReply,
    required this.onDelete,
  });

  final CommunautePostEntity message;
  final bool isMine;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message.userFullName, style: textTheme.labelSmall),
              if (message.isAdmin) ...[
                const SizedBox(width: 4),
                Icon(Icons.verified_rounded, size: 12, color: colors.brand600),
              ],
            ],
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onLongPress: () => _showActions(context),
            child: Container(
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
                  if (message.replyTo != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: (isMine ? Colors.white : colors.brand600).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        '${message.replyTo!.userFullName} : ${message.replyTo!.contenu}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: isMine ? Colors.white70 : colors.inkMuted),
                      ),
                    ),
                  if (message.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: CachedNetworkImage(imageUrl: message.imageUrl!, width: 200, fit: BoxFit.cover),
                    ),
                  if (message.contenu.isNotEmpty)
                    Text(message.contenu, style: textTheme.bodyMedium?.copyWith(color: isMine ? Colors.white : colors.ink)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat('HH:mm').format(message.createdAt), style: textTheme.labelSmall),
              const SizedBox(width: AppSpacing.sm),
              InkWell(
                onTap: onLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      message.userLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 14,
                      color: message.userLiked ? colors.error : colors.inkMuted,
                    ),
                    if (message.likesCount > 0) ...[
                      const SizedBox(width: 2),
                      Text('${message.likesCount}', style: textTheme.labelSmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              InkWell(onTap: onReply, child: Text('Répondre', style: textTheme.labelSmall?.copyWith(color: colors.brand600))),
            ],
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context) {
    if (!isMine) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline_rounded),
          title: const Text('Supprimer ce message'),
          onTap: () {
            Navigator.of(context).pop();
            onDelete();
          },
        ),
      ),
    );
  }
}
