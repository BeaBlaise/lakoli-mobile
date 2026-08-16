import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/communaute_entity.dart';
import '../../domain/entities/communaute_post_entity.dart';
import '../../domain/repositories/communaute_repository.dart';
import '../datasources/communaute_remote_datasource.dart';

class CommunauteRepositoryImpl implements CommunauteRepository {
  CommunauteRepositoryImpl(this._remote);

  final CommunauteRemoteDataSource _remote;

  @override
  Future<Result<List<CommunauteEntity>>> list() async {
    try {
      final models = await _remote.list();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<List<CommunautePostEntity>>> messages(String communauteId) async {
    try {
      final models = await _remote.messages(communauteId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<CommunautePostEntity>> postMessage(
    String communauteId,
    String contenu, {
    String? imagePath,
    String? replyToId,
  }) async {
    try {
      final model = await _remote.postMessage(communauteId, contenu, imagePath: imagePath, replyToId: replyToId);
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> deleteMessage(String postId) async {
    try {
      await _remote.deleteMessage(postId);
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<(int, bool)>> like(String postId) => _likeRun(() => _remote.like(postId));

  @override
  Future<Result<(int, bool)>> unlike(String postId) => _likeRun(() => _remote.unlike(postId));

  Future<Result<(int, bool)>> _likeRun(Future<(int, bool)> Function() call) async {
    try {
      return Result.success(await call());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> join(String communauteId) => _run(() => _remote.join(communauteId));

  @override
  Future<Result<void>> leave(String communauteId) => _run(() => _remote.leave(communauteId));

  Future<Result<void>> _run(Future<void> Function() call) async {
    try {
      await call();
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
