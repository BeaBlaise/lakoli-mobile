import '../../core/utils/result.dart';
import '../entities/feed_result.dart';

abstract interface class FeedRepository {
  Future<Result<FeedResult>> getFeed({int page = 1});
}
