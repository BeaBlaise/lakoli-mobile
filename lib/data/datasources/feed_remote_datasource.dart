import '../../core/network/api_client.dart';
import '../../domain/entities/feed_result.dart';
import '../../domain/entities/paginated_result.dart';
import '../models/publication_model.dart';

/// Appels HTTP bruts pour GET /api/v1/feed. Pas de datasource générique "paginée" partagée
/// (une seule route consomme ce endpoint pour l'instant) — voir PublicationRemoteDataSource
/// pour /ecoles/{ecole}/publications, une forme de pagination différente (pas de has_follows).
class FeedRemoteDataSource {
  FeedRemoteDataSource(this._client);

  final ApiClient _client;

  Future<FeedResult> getFeed({int page = 1}) async {
    final response = await _client.get<Map<String, dynamic>>('/feed', queryParameters: {'page': page});
    final body = response.data!;

    final modelPage = PaginatedResult<PublicationModel>.fromJson(body, PublicationModel.fromJson);

    return FeedResult(
      page: PaginatedResult(
        items: modelPage.items.map((m) => m.toEntity()).toList(),
        nextPageUrl: modelPage.nextPageUrl,
      ),
      hasFollows: body['has_follows'] as bool? ?? false,
    );
  }
}
