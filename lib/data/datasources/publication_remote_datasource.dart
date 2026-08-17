import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../domain/entities/paginated_result.dart';
import '../models/publication_model.dart';

class PublicationRemoteDataSource {
  PublicationRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResult<PublicationModel>> listForEcole(String ecoleId, {int page = 1}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/ecoles/$ecoleId/publications',
      queryParameters: {'page': page},
    );
    return PaginatedResult<PublicationModel>.fromJson(response.data!, PublicationModel.fromJson);
  }

  Future<void> delete(String publicationId) => _client.delete<void>('/publications/$publicationId');

  Future<void> like(String publicationId) => _client.post<void>('/publications/$publicationId/like');

  Future<void> unlike(String publicationId) => _client.delete<void>('/publications/$publicationId/like');

  Future<void> create(String contenu, List<String> imagePaths) async {
    // A Dart Map literal can't hold repeated 'images[]' keys (only the last would survive) —
    // FormData.fromMap() instead expands a single key mapped to a List into repeated
    // multipart fields itself (ListFormat.multi, the default), which is what
    // StorePublicationRequest's `images.*` validation rule on the Laravel side expects.
    final images = await Future.wait(imagePaths.map(MultipartFile.fromFile));
    final data = FormData.fromMap({'contenu': contenu, 'images[]': images});
    await _client.postMultipart<void>('/publications', data);
  }
}
