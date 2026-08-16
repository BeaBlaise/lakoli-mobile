import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../domain/entities/paginated_result.dart';
import '../models/video_model.dart';

class VideoRemoteDataSource {
  VideoRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResult<VideoModel>> feed({int page = 1}) async {
    final response = await _client.get<Map<String, dynamic>>('/videos', queryParameters: {'page': page});
    return PaginatedResult<VideoModel>.fromJson(response.data!, VideoModel.fromJson);
  }

  Future<void> incrementView(String videoId) => _client.post<void>('/videos/$videoId/vue');

  /// GET /api/v1/ecole/videos — Ecole\VideoController::index() renvoie un tableau JSON brut
  /// (pas paginé, pas la forme resource-collection habituelle), contrairement à tous les
  /// autres endpoints de liste de cette API.
  Future<List<VideoModel>> myVideos() async {
    final response = await _client.get<List<dynamic>>('/ecole/videos');
    return response.data!.map((e) => VideoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VideoModel> upload(String videoPath, {String? contenu}) async {
    final data = FormData.fromMap({
      if (contenu != null) 'contenu': contenu,
      'video': await MultipartFile.fromFile(videoPath),
    });
    final response = await _client.postMultipart<Map<String, dynamic>>('/ecole/videos', data);
    return VideoModel.fromJson(response.data!);
  }

  Future<void> delete(String videoId) => _client.delete<void>('/ecole/videos/$videoId');
}
