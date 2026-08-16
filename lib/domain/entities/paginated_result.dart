/// Reflète la forme standard d'un JsonResource::collection(...)->response() paginé de
/// Laravel : {"data": [...], "links": {"next": ...}, "meta": {"current_page", "last_page"}}.
/// Utilisé pour tout flux à chargement progressif (fil, recherche d'écoles, vidéos) — voir
/// la contrainte produit "ne jamais charger toutes les publications en une seule requête".
class PaginatedResult<T> {
  const PaginatedResult({required this.items, required this.nextPageUrl});

  final List<T> items;
  final String? nextPageUrl;

  bool get hasMore => nextPageUrl != null;

  factory PaginatedResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final data = (json['data'] as List).cast<Map<String, dynamic>>();
    final links = json['links'] as Map<String, dynamic>?;

    return PaginatedResult<T>(
      items: data.map(fromJsonT).toList(),
      nextPageUrl: links?['next'] as String?,
    );
  }
}
