import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/communaute_model.dart';
import '../models/communaute_post_model.dart';

class CommunauteRemoteDataSource {
  CommunauteRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<CommunauteModel>> list() async {
    final response = await _client.get<Map<String, dynamic>>('/communautes');
    final list = response.data!['communautes'] as List;
    return list.map((e) => CommunauteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CommunautePostModel>> messages(String communauteId) async {
    final response = await _client.get<Map<String, dynamic>>('/communautes/$communauteId/messages');
    final list = response.data!['messages'] as List;
    return list.map((e) => CommunautePostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CommunautePostModel> postMessage(String communauteId, String contenu, {String? imagePath, String? replyToId}) async {
    final data = FormData.fromMap({
      'contenu': contenu,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath),
    });
    final response = await _client.postMultipart<Map<String, dynamic>>('/communautes/$communauteId/messages', data);
    return CommunautePostModel.fromJson(response.data!);
  }

  Future<void> deleteMessage(String postId) => _client.delete<void>('/communaute-posts/$postId');

  Future<(int, bool)> like(String postId) async {
    final response = await _client.post<Map<String, dynamic>>('/communaute-posts/$postId/like');
    return (response.data!['likes_count'] as int, response.data!['user_liked'] as bool);
  }

  Future<(int, bool)> unlike(String postId) async {
    final response = await _client.delete<Map<String, dynamic>>('/communaute-posts/$postId/like');
    return (response.data!['likes_count'] as int, response.data!['user_liked'] as bool);
  }

  Future<void> join(String communauteId) => _client.post<void>('/communautes/$communauteId/rejoindre');

  Future<void> leave(String communauteId) => _client.delete<void>('/communautes/$communauteId/quitter');
}
