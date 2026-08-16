import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_remote_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl(this._remote);

  final VideoRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<VideoEntity>>> feed({int page = 1}) async {
    try {
      final page0 = await _remote.feed(page: page);
      return Result.success(
        PaginatedResult(items: page0.items.map((m) => m.toEntity()).toList(), nextPageUrl: page0.nextPageUrl),
      );
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> incrementView(String videoId) => _run(() => _remote.incrementView(videoId));

  @override
  Future<Result<List<VideoEntity>>> myVideos() async {
    try {
      final models = await _remote.myVideos();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<VideoEntity>> upload(String videoPath, {String? contenu}) async {
    try {
      final model = await _remote.upload(videoPath, contenu: contenu);
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> delete(String videoId) => _run(() => _remote.delete(videoId));

  Future<Result<void>> _run(Future<void> Function() call) async {
    try {
      await call();
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
