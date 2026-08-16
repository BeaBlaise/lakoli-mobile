import '../../core/utils/result.dart';
import '../entities/notification_entity.dart';
import '../entities/paginated_result.dart';

abstract interface class NotificationRepository {
  Future<Result<PaginatedResult<NotificationEntity>>> list({int page = 1});

  /// Renvoie le nouveau nombre de non-lus, tel que rapporté par le serveur — évite un second
  /// appel réseau juste pour rafraîchir le badge après une lecture.
  Future<Result<int>> markRead(String notificationId);

  Future<Result<int>> markAllRead();
}
