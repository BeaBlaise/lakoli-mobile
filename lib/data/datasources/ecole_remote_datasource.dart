import '../../core/network/api_client.dart';
import '../../domain/entities/paginated_result.dart';
import '../models/ecole_model.dart';

class EcoleRemoteDataSource {
  EcoleRemoteDataSource(this._client);

  final ApiClient _client;

  /// GET /api/v1/ecoles — Api\V1\EcoleController::index() côté Laravel. Ne renvoie que les
  /// écoles validées (`statut = Validee`), voir ce contrôleur : la recherche/découverte
  /// mobile n'a donc pas besoin de filtrer ça elle-même.
  Future<PaginatedResult<EcoleSummaryModel>> search({String? query, int page = 1}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/ecoles',
      queryParameters: {if (query != null && query.isNotEmpty) 'q': query, 'page': page},
    );
    return PaginatedResult<EcoleSummaryModel>.fromJson(response.data!, EcoleSummaryModel.fromJson);
  }

  Future<EcoleModel> show(String ecoleId) async {
    final response = await _client.get<Map<String, dynamic>>('/ecoles/$ecoleId');
    return EcoleModel.fromJson(response.data!['ecole'] as Map<String, dynamic>);
  }

  /// Renvoie le statut brut tel qu'exposé par Api\V1\FollowController::store() —
  /// 'ACCEPTEE'/'EN_ATTENTE' (les valeurs de App\Enums\FollowStatutEnum). Distinct, et non
  /// normalisé de la même façon que le `follow_status` ('accepted'/'pending'/'none') renvoyé
  /// par EcoleResource pour le profil complet — c'est au repository de faire cette conversion,
  /// pas à ce datasource, dont le rôle se limite à parler à l'API telle qu'elle répond
  /// réellement.
  Future<String> follow(String ecoleId) async {
    final response = await _client.post<Map<String, dynamic>>('/ecoles/$ecoleId/follow');
    return response.data!['statut'] as String;
  }

  Future<void> unfollow(String ecoleId) => _client.delete<void>('/ecoles/$ecoleId/unfollow');
}
