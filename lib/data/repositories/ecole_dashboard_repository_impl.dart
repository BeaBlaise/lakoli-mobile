import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/ecole_dashboard_entity.dart';
import '../../domain/repositories/ecole_dashboard_repository.dart';
import '../datasources/ecole_dashboard_remote_datasource.dart';

class EcoleDashboardRepositoryImpl implements EcoleDashboardRepository {
  EcoleDashboardRepositoryImpl(this._remote);

  final EcoleDashboardRemoteDataSource _remote;

  @override
  Future<Result<EcoleDashboardEntity>> fetch() async {
    try {
      return Result.success((await _remote.fetch()).toEntity());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> acceptFollowRequest(String followId) => _run(() => _remote.acceptFollowRequest(followId));

  @override
  Future<Result<void>> refuseFollowRequest(String followId) => _run(() => _remote.refuseFollowRequest(followId));

  Future<Result<void>> _run(Future<void> Function() call) async {
    try {
      await call();
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
