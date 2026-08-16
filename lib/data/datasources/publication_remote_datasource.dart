import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

class PublicationRemoteDataSource {
  PublicationRemoteDataSource(this._client);

  final ApiClient _client;

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
