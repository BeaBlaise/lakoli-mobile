import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../auth/application/auth_controller.dart';

class NotificationListState {
  const NotificationListState({
    this.items = const [],
    this.nextPageUrl,
    this.isLoadingMore = false,
  });

  final List<NotificationEntity> items;
  final String? nextPageUrl;
  final bool isLoadingMore;

  bool get hasMore => nextPageUrl != null;

  NotificationListState copyWith({
    List<NotificationEntity>? items,
    String? nextPageUrl,
    bool clearNextPageUrl = false,
    bool? isLoadingMore,
  }) {
    return NotificationListState(
      items: items ?? this.items,
      nextPageUrl: clearNextPageUrl ? null : (nextPageUrl ?? this.nextPageUrl),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, NotificationListState>(NotificationController.new);

/// Même correction que feed_controller.dart : ref.watch(authControllerProvider) évite qu'une
/// erreur "Unauthenticated" survenue avant que la session ne soit résolue reste en cache après
/// une connexion réussie. Cet écran n'est atteignable que via l'onglet Notifications, déjà
/// derrière la garde d'authentification du routeur — donc moins exposé à la race du démarrage
/// que le fil (branche `/`) — mais garder la même protection ici évite de réintroduire le même
/// bug si la navigation évolue.
class NotificationController extends AsyncNotifier<NotificationListState> {
  @override
  Future<NotificationListState> build() async {
    ref.watch(authControllerProvider);

    final result = await ref.read(notificationRepositoryProvider).list(page: 1);
    return result.when(
      success: (page) => NotificationListState(items: page.items, nextPageUrl: page.nextPageUrl),
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<NotificationListState>();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final page = _pageFromUrl(current.nextPageUrl!);
    final result = await ref.read(notificationRepositoryProvider).list(page: page);

    result.when(
      success: (next) => state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          nextPageUrl: next.nextPageUrl,
          clearNextPageUrl: next.nextPageUrl == null,
          isLoadingMore: false,
        ),
      ),
      failure: (_) => state = AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }

  Future<void> markRead(NotificationEntity notification) async {
    if (!notification.isUnread) return;

    final current = state.valueOrNull;
    if (current == null) return;

    final updated = notification.copyWith(readAt: DateTime.now());
    state = AsyncData(current.copyWith(items: current.items.map((n) => n.id == updated.id ? updated : n).toList()));

    await ref.read(notificationRepositoryProvider).markRead(notification.id);
    // Échec silencieux volontaire : au pire la notification réapparaît comme non lue après un
    // prochain rafraîchissement, jamais bloquante pour l'utilisateur.
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final now = DateTime.now();
    state = AsyncData(current.copyWith(items: current.items.map((n) => n.copyWith(readAt: n.readAt ?? now)).toList()));

    await ref.read(notificationRepositoryProvider).markAllRead();
  }

  int _pageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.tryParse(uri.queryParameters['page'] ?? '') ?? 1;
  }
}
