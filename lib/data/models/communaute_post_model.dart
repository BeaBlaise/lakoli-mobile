import '../../domain/entities/communaute_post_entity.dart';

class CommunautePostModel {
  const CommunautePostModel({
    required this.id,
    required this.communauteId,
    required this.contenu,
    required this.createdAt,
    required this.userId,
    required this.userFullName,
    required this.isAdmin,
    required this.likesCount,
    required this.userLiked,
    this.imageUrl,
    this.replyTo,
  });

  final String id;
  final String communauteId;
  final String contenu;
  final DateTime createdAt;
  final String userId;
  final String userFullName;
  final bool isAdmin;
  final int likesCount;
  final bool userLiked;
  final String? imageUrl;
  final CommunauteReplyToEntity? replyTo;

  factory CommunautePostModel.fromJson(Map<String, dynamic> json) {
    final replyToJson = json['reply_to'] as Map<String, dynamic>?;

    return CommunautePostModel(
      id: json['id'] as String,
      communauteId: json['communaute_id'] as String,
      contenu: json['contenu'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      userFullName: (json['user'] as Map<String, dynamic>)['full_name'] as String,
      isAdmin: json['is_admin'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      userLiked: json['user_liked'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      replyTo: replyToJson != null
          ? CommunauteReplyToEntity(
              id: replyToJson['id'] as String,
              contenu: replyToJson['contenu'] as String,
              userFullName: (replyToJson['user'] as Map<String, dynamic>)['full_name'] as String,
            )
          : null,
    );
  }

  CommunautePostEntity toEntity() {
    return CommunautePostEntity(
      id: id,
      communauteId: communauteId,
      contenu: contenu,
      createdAt: createdAt,
      userId: userId,
      userFullName: userFullName,
      isAdmin: isAdmin,
      likesCount: likesCount,
      userLiked: userLiked,
      imageUrl: imageUrl,
      replyTo: replyTo,
    );
  }
}
