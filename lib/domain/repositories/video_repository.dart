import '../../core/utils/result.dart';
import '../entities/paginated_result.dart';
import '../entities/video_entity.dart';

abstract interface class VideoRepository {
  Future<Result<PaginatedResult<VideoEntity>>> feed({int page = 1});

  Future<Result<void>> incrementView(String videoId);

  Future<Result<List<VideoEntity>>> myVideos();

  Future<Result<VideoEntity>> upload(String videoPath, {String? contenu});

  Future<Result<void>> delete(String videoId);
}
