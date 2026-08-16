import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../domain/entities/message_entity.dart';
import '../models/message_model.dart';

class MessageRemoteDataSource {
  MessageRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ConversationModel>> conversations() async {
    final response = await _client.get<Map<String, dynamic>>('/messages');
    final list = response.data!['conversations'] as List;
    return list.map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<UserSearchResult>> searchUsers(String query) async {
    final response = await _client.get<Map<String, dynamic>>('/messages/utilisateurs', queryParameters: {'q': query});
    final list = response.data!['users'] as List;
    return list.map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> startConversation(String userId) async {
    final response = await _client.post<Map<String, dynamic>>('/messages/utilisateurs/$userId/demarrer');
    return response.data!['conversation_id'] as String;
  }

  Future<(List<MessageModel>, bool)> messages(String conversationId) async {
    final response = await _client.get<Map<String, dynamic>>('/messages/$conversationId/messages');
    final list = response.data!['messages'] as List;
    final messages = list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
    return (messages, response.data!['can_reply'] as bool);
  }

  Future<MessageModel> sendMessage(String conversationId, String contenu, {String? imagePath}) async {
    final data = FormData.fromMap({
      'contenu': contenu,
      if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath),
    });
    final response = await _client.postMultipart<Map<String, dynamic>>('/messages/$conversationId/messages', data);
    return MessageModel.fromJson(response.data!);
  }

  Future<void> block(String userId) => _client.post<void>('/users/$userId/bloquer');

  Future<void> unblock(String userId) => _client.delete<void>('/users/$userId/bloquer');
}
