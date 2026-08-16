import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/ecole_entity.dart';

class DiscoverState {
  const DiscoverState({this.items = const [], this.nextPageUrl, this.isLoadingMore = false});

  final List<EcoleSummaryEntity> items;
  final String? nextPageUrl;
  final bool isLoadingMore;

  bool get hasMore => nextPageUrl != null;

  DiscoverState copyWith({List<EcoleSummaryEntity>? items, String? nextPageUrl, bool clearNextPageUrl = false, bool? isLoadingMore}) {
    return DiscoverState(
      items: items ?? this.items,
      nextPageUrl: clearNextPageUrl ? null : (nextPageUrl ?? this.nextPageUrl),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final discoverControllerProvider = AsyncNotifierProvider<DiscoverController, DiscoverState>(DiscoverController.new);

/// Recherche/découverte d'écoles — GET /api/v1/ecoles (Api\V1\EcoleController::index()), déjà
/// couvert par l'API avant même l'audit du 2026-08-16 (contrairement au fil personnel ou à la
/// bascule de profil). `EcoleSearchResource` n'expose ni statut de suivi ni nombre d'abonnés
/// (voir domain/entities/ecole_entity.dart) — cet écran ne peut donc pas afficher de bouton
/// "Suivre" directement sur les résultats, seulement ouvrir le profil complet.
class DiscoverController extends AsyncNotifier<DiscoverState> {
  String _query = '';
  Timer? _debounce;

  @override
  Future<DiscoverState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    return _fetch(query: _query, page: 1);
  }

  Future<DiscoverState> _fetch({required String query, required int page}) async {
    final result = await ref.read(ecoleRepositoryProvider).search(query: query, page: page);
    return result.when(
      success: (page0) => DiscoverState(items: page0.items, nextPageUrl: page0.nextPageUrl),
      failure: (exception) => throw exception,
    );
  }

  /// Débounce de 400ms — évite un appel réseau à chaque caractère tapé (voir la contrainte
  /// produit "réseau mobile faible" déjà présente ailleurs, ApiClient/env.dart).
  void search(String query) {
    _query = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      state = const AsyncLoading<DiscoverState>();
      state = await AsyncValue.guard(() => _fetch(query: _query, page: 1));
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final uri = Uri.parse(current.nextPageUrl!);
    final page = int.tryParse(uri.queryParameters['page'] ?? '') ?? 1;
    final result = await ref.read(ecoleRepositoryProvider).search(query: _query, page: page);

    result.when(
      success: (page0) => state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page0.items],
          nextPageUrl: page0.nextPageUrl,
          clearNextPageUrl: page0.nextPageUrl == null,
          isLoadingMore: false,
        ),
      ),
      failure: (_) => state = AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }
}
