import 'package:equatable/equatable.dart';

/// Un commentaire n'a qu'un seul niveau de réponses côté backend (parent_id direct, pas de
/// chaîne infinie) — Api\V1\CommentaireController::index() organise déjà les réponses sous
/// leur parent avant l'envoi, donc [replies] est toujours plat, jamais récursif.
class CommentaireEntity extends Equatable {
  const CommentaireEntity({
    required this.id,
    required this.contenu,
    required this.createdAt,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.parentId,
    this.replies = const [],
  });

  final String id;
  final String contenu;
  final DateTime createdAt;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String? parentId;
  final List<CommentaireEntity> replies;

  @override
  List<Object?> get props => [id, contenu, createdAt, userId, userName, userAvatarUrl, parentId, replies];
}
