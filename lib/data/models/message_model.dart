import '../../domain/entities/message_entity.dart';

/// Parse à la fois la forme REST (Api\V1\MessageController::messages()/store(), avec un objet
/// `user: {id, full_name}` imbriqué) et la forme diffusée en temps réel (App\Events\MessageSent
/// ::broadcastWith(), qui n'a que `user.full_name`, l'id étant déjà porté par `user_id` au
/// premier niveau) — les deux se valent ici puisque seul `user_id` est réellement utilisé comme
/// identifiant.
class MessageModel {
  const MessageModel({
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

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      contenu: json['contenu'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      userFullName: (json['user'] as Map<String, dynamic>)['full_name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      contenu: contenu,
      createdAt: createdAt,
      userId: userId,
      userFullName: userFullName,
      imageUrl: imageUrl,
    );
  }
}

class ConversationModel {
  const ConversationModel({
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

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final otherUser = json['other_user'] as Map<String, dynamic>;
    final lastMessageJson = json['last_message'] as Map<String, dynamic>?;

    return ConversationModel(
      id: json['id'] as String,
      otherUserId: otherUser['id'] as String,
      otherUserFullName: otherUser['full_name'] as String,
      otherUserAvatarUrl: otherUser['avatar_url'] as String?,
      unread: json['unread'] as bool? ?? false,
      lastMessage: lastMessageJson != null
          ? ConversationLastMessage(
              contenu: lastMessageJson['contenu'] as String,
              createdAt: DateTime.parse(lastMessageJson['created_at'] as String),
              userId: lastMessageJson['user_id'] as String,
            )
          : null,
    );
  }

  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      otherUserId: otherUserId,
      otherUserFullName: otherUserFullName,
      otherUserAvatarUrl: otherUserAvatarUrl,
      unread: unread,
      lastMessage: lastMessage,
    );
  }
}
