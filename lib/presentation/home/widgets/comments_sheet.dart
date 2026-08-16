import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/commentaire_entity.dart';
import '../../auth/application/auth_controller.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/states/empty_state_view.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/comments_controller.dart';

/// Ouvert en tiroir modal depuis PublicationCardView.onComment (voir FeedPage) — pas un écran
/// à part entière, pour rester dans le flux du fil comme sur les apps sociales classiques
/// (Instagram/Facebook) plutôt que de naviguer hors du contexte de la publication.
Future<void> showCommentsSheet(BuildContext context, String publicationId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _CommentsSheet(publicationId: publicationId),
  );
}

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.publicationId});

  final String publicationId;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  CommentaireEntity? _replyTo;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    await ref.read(commentsControllerProvider(widget.publicationId).notifier).post(text, parentId: _replyTo?.id);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _controller.clear();
      _replyTo = null;
    });
  }

  void _reply(CommentaireEntity comment) {
    setState(() => _replyTo = comment);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(commentsControllerProvider(widget.publicationId));
    final myId = ref.watch(authControllerProvider).valueOrNull?.id;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
            ),
            Text('Commentaires', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: AppSpacing.lg),
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: ErrorStateView(
                    exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
                    onRetry: () => ref.invalidate(commentsControllerProvider(widget.publicationId)),
                  ),
                ),
                data: (comments) {
                  if (comments.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.mode_comment_outlined,
                      title: 'Aucun commentaire',
                      message: 'Soyez le premier à réagir à cette publication.',
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: comments.length,
                    itemBuilder: (context, index) => _CommentThread(
                      comment: comments[index],
                      myId: myId,
                      onReply: _reply,
                      onDelete: (c) => ref.read(commentsControllerProvider(widget.publicationId).notifier).delete(c.id),
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
                                'Réponse à ${_replyTo!.userName}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() => _replyTo = null),
                              child: Icon(Icons.close_rounded, size: 16, color: colors.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            enabled: !_sending,
                            decoration: const InputDecoration(hintText: 'Ajouter un commentaire…'),
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
        );
      },
    );
  }
}

class _CommentThread extends StatelessWidget {
  const _CommentThread({required this.comment, required this.myId, required this.onReply, required this.onDelete});

  final CommentaireEntity comment;
  final String? myId;
  final void Function(CommentaireEntity comment) onReply;
  final void Function(CommentaireEntity comment) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentRow(comment: comment, myId: myId, onReply: onReply, onDelete: onDelete),
        for (final reply in comment.replies)
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: _CommentRow(comment: reply, myId: myId, onReply: onReply, onDelete: onDelete),
          ),
      ],
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment, required this.myId, required this.onReply, required this.onDelete});

  final CommentaireEntity comment;
  final String? myId;
  final void Function(CommentaireEntity comment) onReply;
  final void Function(CommentaireEntity comment) onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isMine = myId != null && myId == comment.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(imageUrl: comment.userAvatarUrl, name: comment.userName, size: AppAvatarSize.sm),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.userName, style: textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(comment.contenu, style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(_relativeTime(comment.createdAt), style: textTheme.labelSmall),
                    const SizedBox(width: AppSpacing.md),
                    InkWell(
                      onTap: () => onReply(comment),
                      child: Text('Répondre', style: textTheme.labelSmall?.copyWith(color: colors.brand600)),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: AppSpacing.md),
                      InkWell(
                        onTap: () => onDelete(comment),
                        child: Text('Supprimer', style: textTheme.labelSmall?.copyWith(color: colors.error)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "à l'instant";
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    if (diff.inDays < 7) return '${diff.inDays} j';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }
}
