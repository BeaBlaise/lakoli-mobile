import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<NotificationEntity>>> list({int page = 1}) async {
    try {
      final page0 = await _remote.list(page: page);
      return Result.success(
        PaginatedResult(items: page0.items.map((m) => m.toEntity()).toList(), nextPageUrl: page0.nextPageUrl),
      );
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<int>> markRead(String notificationId) => _run(() => _remote.markRead(notificationId));

  @override
  Future<Result<int>> markAllRead() => _run(() => _remote.markAllRead());

  Future<Result<int>> _run(Future<int> Function() call) async {
    try {
      return Result.success(await call());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
