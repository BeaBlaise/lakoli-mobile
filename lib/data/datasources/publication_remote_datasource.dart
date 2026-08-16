import '../../core/network/api_client.dart';

class PublicationRemoteDataSource {
  PublicationRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> like(String publicationId) => _client.post<void>('/publications/$publicationId/like');

  Future<void> unlike(String publicationId) => _client.delete<void>('/publications/$publicationId/like');
}
