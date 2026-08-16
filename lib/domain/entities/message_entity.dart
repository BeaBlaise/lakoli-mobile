import 'package:equatable/equatable.dart';

/// Résultat de recherche d'utilisateurs (GET /api/v1/messages/utilisateurs) — un sous-ensemble
/// minimal distinct de UserEntity, qui porte des champs (phone/email/rôles) que cet endpoint
/// n'expose jamais.
class UserSearchResult extends Equatable {
  const UserSearchResult({required this.id, required this.fullName, this.avatarUrl});

  final String id;
  final String fullName;
  final String? avatarUrl;

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, fullName, avatarUrl];
}

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.contenu,
    required this.createdAt,
    required this.userId,
    required this.userFullName,
    this.imageUrl,
  });

  final String id;
  final String conversationId;
  final String contenu;
  final DateTime createdAt;
  final String userId;
  final String userFullName;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, conversationId, contenu, createdAt, userId, userFullName, imageUrl];
}

class ConversationLastMessage extends Equatable {
  const ConversationLastMessage({required this.contenu, required this.createdAt, required this.userId});

  final String contenu;
  final DateTime createdAt;
  final String userId;

  @override
  List<Object?> get props => [contenu, createdAt, userId];
}

/// Correspond à Api\V1\MessageController::index() — un tableau construit à la main (pas un
/// JsonResource), voir ce contrôleur.
class ConversationEntity extends Equatable {
  const ConversationEntity({
    required this.id,
    required this.otherUserId,
    required this.otherUserFullName,
    required this.unread,
    this.otherUserAvatarUrl,
    this.lastMessage,
  });

  final String id;
  final String otherUserId;
  final String otherUserFullName;
  final String? otherUserAvatarUrl;
  final bool unread;
  final ConversationLastMessage? lastMessage;

  ConversationEntity copyWith({bool? unread}) {
    return ConversationEntity(
      id: id,
      otherUserId: otherUserId,
      otherUserFullName: otherUserFullName,
      otherUserAvatarUrl: otherUserAvatarUrl,
      unread: unread ?? this.unread,
      lastMessage: lastMessage,
    );
  }

  @override
  List<Object?> get props => [id, otherUserId, otherUserFullName, otherUserAvatarUrl, unread, lastMessage];
}
