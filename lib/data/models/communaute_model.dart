import '../../domain/entities/communaute_entity.dart';

class CommunauteModel {
  const CommunauteModel({
    required this.id,
    required this.nom,
    required this.membresCount,
    required this.joined,
    required this.unreadCount,
    this.description,
    this.iconUrl,
    this.lastMessage,
  });

  final String id;
  final String nom;
  final String? description;
  final String? iconUrl;
  final int membresCount;
  final bool joined;
  final int unreadCount;
  final CommunauteLastMessage? lastMessage;

  factory CommunauteModel.fromJson(Map<String, dynamic> json) {
    final lastMessageJson = json['last_message'] as Map<String, dynamic>?;

    return CommunauteModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      membresCount: json['membres_count'] as int? ?? 0,
      joined: json['joined'] as bool? ?? false,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessage: lastMessageJson != null
          ? CommunauteLastMessage(
              contenu: lastMessageJson['contenu'] as String,
              createdAt: DateTime.parse(lastMessageJson['created_at'] as String),
              userFullName: (lastMessageJson['user'] as Map<String, dynamic>)['full_name'] as String,
            )
          : null,
    );
  }

  CommunauteEntity toEntity() {
    return CommunauteEntity(
      id: id,
      nom: nom,
      description: description,
      iconUrl: iconUrl,
      membresCount: membresCount,
      joined: joined,
      unreadCount: unreadCount,
      lastMessage: lastMessage,
    );
  }
}
