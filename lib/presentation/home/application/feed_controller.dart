import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/publication_entity.dart';
import '../../auth/application/auth_controller.dart';

class FeedState {
  const FeedState({
    this.items = const [],
    this.hasFollows = true,
    this.nextPageUrl,
    this.isLoadingMore = false,
  });

  final List<PublicationEntity> items;
  final bool hasFollows;
  final String? nextPageUrl;
  final bool isLoadingMore;

  bool get hasMore => nextPageUrl != null;

  FeedState copyWith({
    List<PublicationEntity>? items,
    bool? hasFollows,
    String? nextPageUrl,
    bool clearNextPageUrl = false,
    bool? isLoadingMore,
  }) {
    return FeedState(
      items: items ?? this.items,
      hasFollows: hasFollows ?? this.hasFollows,
      nextPageUrl: clearNextPageUrl ? null : (nextPageUrl ?? this.nextPageUrl),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final feedControllerProvider = AsyncNotifierProvider<FeedController, FeedState>(FeedController.new);

/// Fil personnel — GET /api/v1/feed (voir App\Http\Controllers\Api\V1\FeedController côté
/// Laravel, ajouté le 2026-08-16 : jusque-là ce endpoint n'existait tout simplement pas, seul
/// le web (DashboardController, Inertia) avait un fil personnalisé). `hasFollows` piloté par le
/// même booléen que renvoie l'API — permet d'afficher une invitation à découvrir des écoles
/// sans avoir à répliquer l'écran d'onboarding web (un redirect Inertia sans équivalent API).
///
/// La pagination ne lit que le numéro de page suivant depuis l'URL renvoyée par l'API
/// (`?page=N`, forme standard Laravel) plutôt que de le suivre nous-mêmes — cohérent avec
/// PaginatedResult, déjà pensé pour ça.
class FeedController extends AsyncNotifier<FeedState> {
  @override
  Future<FeedState> build() async {
    // `/` est initialLocation (voir core/router/app_router.dart) : tant que l'état d'auth
    // initial n'a pas fini de se résoudre (lecture du stockage sécurisé, éventuel appel
    // /auth/me), le redirect du routeur laisse passer et cette page se construit une première
    // fois — sans token, pour un utilisateur qui n'a encore jamais de session, ou pendant la
    // fraction de seconde avant que le token fraîchement enregistré ne soit pris en compte à
    // l'inscription. Un `AsyncNotifierProvider` classique (pas autoDispose) mettrait cette
    // erreur "Unauthenticated" en cache indéfiniment, y compris après une connexion réussie
    // qui redirige vers ce même écran — observé en conditions réelles (émulateur Android,
    // création de compte). ref.watch() ici force ce build() à se relancer à chaque changement
    // d'état d'authentification (chargement → non connecté → connecté), pas seulement au tout
    // premier appel.
    ref.watch(authControllerProvider);

    final result = await ref.read(feedRepositoryProvider).getFeed(page: 1);
    return result.when(
      success: (feed) => FeedState(
        items: feed.page.items,
        hasFollows: feed.hasFollows,
        nextPageUrl: feed.page.nextPageUrl,
      ),
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<FeedState>();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final page = _pageFromUrl(current.nextPageUrl!);
    final result = await ref.read(feedRepositoryProvider).getFeed(page: page);

    result.when(
      success: (feed) {
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...feed.page.items],
            nextPageUrl: feed.page.nextPageUrl,
            clearNextPageUrl: feed.page.nextPageUrl == null,
            isLoadingMore: false,
          ),
        );
      },
      failure: (_) {
        // Échec silencieux pour "charger plus" (l'utilisateur a déjà du contenu à l'écran) —
        // repasse juste isLoadingMore à false pour réactiver le bouton, sans écran d'erreur
        // plein-écran qui remplacerait le fil déjà chargé.
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
    );
  }

  Future<void> toggleLike(PublicationEntity publication) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final optimistic = publication.copyWith(
      userLiked: !publication.userLiked,
      likesCount: publication.userLiked ? publication.likesCount - 1 : publication.likesCount + 1,
    );
    state = AsyncData(current.copyWith(items: _replace(current.items, optimistic)));

    final repo = ref.read(publicationRepositoryProvider);
    final result = optimistic.userLiked ? await repo.like(publication.id) : await repo.unlike(publication.id);

    result.when(
      success: (_) {},
      failure: (AppException exception) {
        // Revert optimiste en cas d'échec réseau — ne jamais laisser l'UI mentir sur un état
        // que le serveur a refusé.
        final reverted = state.valueOrNull;
        if (reverted == null) return;
        state = AsyncData(reverted.copyWith(items: _replace(reverted.items, publication)));
      },
    );
  }

  List<PublicationEntity> _replace(List<PublicationEntity> items, PublicationEntity updated) {
    return items.map((p) => p.id == updated.id ? updated : p).toList();
  }

  int _pageFromUrl(String url) {
    final uri = Uri.parse(url);
    return int.tryParse(uri.queryParameters['page'] ?? '') ?? 1;
  }
}
