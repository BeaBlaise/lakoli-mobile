import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/publication_entity.dart';
import '../../domain/repositories/publication_repository.dart';
import '../datasources/publication_remote_datasource.dart';

class PublicationRepositoryImpl implements PublicationRepository {
  PublicationRepositoryImpl(this._remote);

  final PublicationRemoteDataSource _remote;

  @override
  Future<Result<void>> like(String publicationId) => _run(() => _remote.like(publicationId));

  @override
  Future<Result<void>> unlike(String publicationId) => _run(() => _remote.unlike(publicationId));

  @override
  Future<Result<void>> create(String contenu, List<String> imagePaths) =>
      _run(() => _remote.create(contenu, imagePaths));

  @override
  Future<Result<PaginatedResult<PublicationEntity>>> listForEcole(String ecoleId, {int page = 1}) async {
    try {
      final page0 = await _remote.listForEcole(ecoleId, page: page);
      return Result.success(
        PaginatedResult(items: page0.items.map((m) => m.toEntity()).toList(), nextPageUrl: page0.nextPageUrl),
      );
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> delete(String publicationId) => _run(() => _remote.delete(publicationId));

  Future<Result<void>> _run(Future<void> Function() call) async {
    try {
      await call();
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
