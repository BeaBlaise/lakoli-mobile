import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/feed_result.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._remote);

  final FeedRemoteDataSource _remote;

  @override
  Future<Result<FeedResult>> getFeed({int page = 1}) async {
    try {
      return Result.success(await _remote.getFeed(page: page));
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
