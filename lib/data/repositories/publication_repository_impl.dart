import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/publication_repository.dart';
import '../datasources/publication_remote_datasource.dart';

class PublicationRepositoryImpl implements PublicationRepository {
  PublicationRepositoryImpl(this._remote);

  final PublicationRemoteDataSource _remote;

  @override
  Future<Result<void>> like(String publicationId) => _run(() => _remote.like(publicationId));

  @override
  Future<Result<void>> unlike(String publicationId) => _run(() => _remote.unlike(publicationId));

  Future<Result<void>> _run(Future<void> Function() call) async {
    try {
      await call();
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
