import 'package:equatable/equatable.dart';

class CommunauteReplyToEntity extends Equatable {
  const CommunauteReplyToEntity({required this.id, required this.contenu, required this.userFullName});

  final String id;
  final String contenu;
  final String userFullName;

  @override
  List<Object?> get props => [id, contenu, userFullName];
}

/// Correspond au CommunautePost renvoyé par Api\V1\CommunauteController::messages()/
/// CommunautePostController::store(), et à App\Events\CommunautePostCreated::broadcastWith()
/// pour les messages reçus en temps réel — les trois call sites sont maintenus à la main côté
/// Laravel (pas de Resource partagée, voir CLAUDE.md du dépôt lakoli), donc les trois formes
/// JSON sont vérifiées comme identiques ici plutôt que supposées.
class CommunautePostEntity extends Equatable {
  const CommunautePostEntity({
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

  CommunautePostEntity copyWith({int? likesCount, bool? userLiked}) {
    return CommunautePostEntity(
      id: id,
      communauteId: communauteId,
      contenu: contenu,
      createdAt: createdAt,
      userId: userId,
      userFullName: userFullName,
      isAdmin: isAdmin,
      likesCount: likesCount ?? this.likesCount,
      userLiked: userLiked ?? this.userLiked,
      imageUrl: imageUrl,
      replyTo: replyTo,
    );
  }

  @override
  List<Object?> get props =>
      [id, communauteId, contenu, createdAt, userId, userFullName, isAdmin, likesCount, userLiked, imageUrl, replyTo];
}
