import '../../core/network/api_client.dart';
import '../models/ecole_dashboard_model.dart';

class EcoleDashboardRemoteDataSource {
  EcoleDashboardRemoteDataSource(this._client);

  final ApiClient _client;

  Future<EcoleDashboardModel> fetch() async {
    final response = await _client.get<Map<String, dynamic>>('/ecole/tableau-de-bord');
    return EcoleDashboardModel.fromJson(response.data!);
  }

  Future<void> acceptFollowRequest(String followId) => _client.patch<void>('/abonnements/$followId/accepter');

  Future<void> refuseFollowRequest(String followId) => _client.delete<void>('/abonnements/$followId/refuser');
}
