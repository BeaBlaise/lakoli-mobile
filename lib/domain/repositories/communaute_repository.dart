import '../../core/utils/result.dart';
import '../entities/communaute_entity.dart';
import '../entities/communaute_post_entity.dart';

abstract interface class CommunauteRepository {
  Future<Result<List<CommunauteEntity>>> list();

  Future<Result<List<CommunautePostEntity>>> messages(String communauteId);

  Future<Result<CommunautePostEntity>> postMessage(
    String communauteId,
    String contenu, {
    String? imagePath,
    String? replyToId,
  });

  Future<Result<void>> deleteMessage(String postId);

  /// Renvoie (nombre de likes, l'utilisateur courant aime-t-il maintenant) tel que rapporté
  /// par le serveur — voir Api\V1\CommunautePostController::likeResponse().
  Future<Result<(int, bool)>> like(String postId);
  Future<Result<(int, bool)>> unlike(String postId);

  Future<Result<void>> join(String communauteId);
  Future<Result<void>> leave(String communauteId);
}
