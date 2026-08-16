import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../shared/widgets/domain/notification_tile.dart';
import '../../shared/widgets/states/empty_state_view.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/notification_controller.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.valueOrNull?.items.any((n) => n.isUnread) ?? false)
            TextButton(
              onPressed: () => ref.read(notificationControllerProvider.notifier).markAllRead(),
              child: const Text('Tout marquer lu'),
            ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: ErrorStateView(
            exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
            onRetry: () => ref.read(notificationControllerProvider.notifier).refresh(),
          ),
        ),
        data: (data) {
          if (data.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.read(notificationControllerProvider.notifier).refresh(),
              child: ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyStateView(
                    icon: Icons.notifications_none_rounded,
                    title: 'Aucune notification',
                    message: "Vous serez prévenu ici des nouveaux j'aime, commentaires et abonnements.",
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationControllerProvider.notifier).refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 400) {
                  ref.read(notificationControllerProvider.notifier).loadMore();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: data.items.length + (data.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= data.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
                    );
                  }

                  final notification = data.items[index];
                  final (icon, tone) = _iconAndTone(notification.kind, context);

                  return NotificationTile(
                    icon: icon,
                    iconTone: tone,
                    title: notification.message,
                    timeLabel: _relativeTime(notification.createdAt),
                    unread: notification.isUnread,
                    onTap: () => _handleTap(context, ref, notification),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, NotificationEntity notification) {
    ref.read(notificationControllerProvider.notifier).markRead(notification);

    // Seul /ecoles/{id} a un équivalent mobile aujourd'hui (voir core/router/app_router.dart) —
    // /ecole/dashboard (le tableau de bord école) n'a pas encore d'écran mobile, donc ces
    // notifications restent marquées lues sans navigation plutôt que d'échouer silencieusement
    // sur une route inexistante.
    final lien = notification.lien;
    if (lien != null && lien.startsWith('/ecoles/')) {
      context.push(lien);
    }
  }

  (IconData, Color) _iconAndTone(NotificationKind kind, BuildContext context) {
    final colors = context.colors;
    return switch (kind) {
      NotificationKind.nouveauLike => (Icons.favorite_rounded, colors.error),
      NotificationKind.nouveauCommentaire => (Icons.mode_comment_rounded, colors.brand600),
      NotificationKind.nouvelleReponse => (Icons.reply_rounded, colors.brand600),
      NotificationKind.abonnementAccepte => (Icons.check_circle_rounded, colors.success),
      NotificationKind.demandeAbonnement => (Icons.person_add_rounded, colors.accent600),
      NotificationKind.ecoleValidee => (Icons.verified_rounded, colors.success),
      NotificationKind.ecoleRefusee => (Icons.error_rounded, colors.error),
      NotificationKind.inconnu => (Icons.notifications_rounded, colors.inkMuted),
    };
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
