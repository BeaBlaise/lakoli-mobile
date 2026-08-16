import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/ecole_entity.dart';
import '../../domain/repositories/ecole_repository.dart';
import '../datasources/ecole_remote_datasource.dart';

class EcoleRepositoryImpl implements EcoleRepository {
  EcoleRepositoryImpl(this._remote);

  final EcoleRemoteDataSource _remote;

  @override
  Future<Result<EcoleEntity>> show(String ecoleId) async {
    try {
      return Result.success((await _remote.show(ecoleId)).toEntity());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<FollowStatus>> follow(String ecoleId) async {
    try {
      final statut = await _remote.follow(ecoleId);
      // SendFollowRequestAction always creates a fresh request as EN_ATTENTE (no auto-accept
      // for public-type écoles) — ACCEPTEE here only happens if firstOrCreate() matched an
      // already-accepted row from a prior follow. Never REFUSEE at this point either way.
      return Result.success(statut == 'ACCEPTEE' ? FollowStatus.accepted : FollowStatus.pending);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> unfollow(String ecoleId) async {
    try {
      await _remote.unfollow(ecoleId);
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
