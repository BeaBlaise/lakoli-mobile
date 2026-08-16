import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/commentaire_entity.dart';
import '../../domain/repositories/commentaire_repository.dart';
import '../datasources/commentaire_remote_datasource.dart';

class CommentaireRepositoryImpl implements CommentaireRepository {
  CommentaireRepositoryImpl(this._remote);

  final CommentaireRemoteDataSource _remote;

  @override
  Future<Result<List<CommentaireEntity>>> list(String publicationId) async {
    try {
      final models = await _remote.list(publicationId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<String>> create(String publicationId, String contenu, {String? parentId}) async {
    try {
      return Result.success(await _remote.create(publicationId, contenu, parentId: parentId));
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> delete(String commentaireId) async {
    try {
      await _remote.delete(commentaireId);
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
