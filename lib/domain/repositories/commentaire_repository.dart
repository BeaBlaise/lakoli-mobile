import '../../core/utils/result.dart';
import '../entities/commentaire_entity.dart';

abstract interface class CommentaireRepository {
  Future<Result<List<CommentaireEntity>>> list(String publicationId);

  /// Renvoie seulement le nouvel id (voir Api\V1\CommentaireController::store(), qui ne
  /// renvoie pas le commentaire complet) — à l'appelant de construire l'entité optimiste avec
  /// les données déjà connues côté client (utilisateur courant, contenu saisi, horodatage).
  Future<Result<String>> create(String publicationId, String contenu, {String? parentId});

  Future<Result<void>> delete(String commentaireId);
}
