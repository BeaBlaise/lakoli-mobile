import '../../domain/entities/commentaire_entity.dart';

/// Parse la forme renvoyée par Api\V1\CommentaireController::index() — un tableau construit
/// à la main côté Laravel (pas un JsonResource), avec les réponses déjà groupées sous
/// `replies` pour chaque commentaire racine.
class CommentaireModel {
  const CommentaireModel({
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
  final List<CommentaireModel> replies;

  factory CommentaireModel.fromJson(Map<String, dynamic> json) {
    return CommentaireModel(
      id: json['id'] as String,
      contenu: json['contenu'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
      parentId: json['parent_id'] as String?,
      replies: (json['replies'] as List? ?? const [])
          .map((e) => CommentaireModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CommentaireEntity toEntity() {
    return CommentaireEntity(
      id: id,
      contenu: contenu,
      createdAt: createdAt,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      parentId: parentId,
      replies: replies.map((r) => r.toEntity()).toList(),
    );
  }
}
