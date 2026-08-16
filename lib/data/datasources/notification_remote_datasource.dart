import '../../core/network/api_client.dart';
import '../../domain/entities/paginated_result.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResult<NotificationModel>> list({int page = 1}) async {
    final response = await _client.get<Map<String, dynamic>>('/notifications', queryParameters: {'page': page});
    return PaginatedResult<NotificationModel>.fromJson(response.data!, NotificationModel.fromJson);
  }

  Future<int> markRead(String notificationId) async {
    final response = await _client.patch<Map<String, dynamic>>('/notifications/$notificationId/lu');
    return response.data!['unread_count'] as int;
  }

  Future<int> markAllRead() async {
    final response = await _client.post<Map<String, dynamic>>('/notifications/tout-lire');
    return response.data!['unread_count'] as int;
  }
}
