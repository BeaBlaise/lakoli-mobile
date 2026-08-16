import 'package:equatable/equatable.dart';

class CommunauteLastMessage extends Equatable {
  const CommunauteLastMessage({required this.contenu, required this.createdAt, required this.userFullName});

  final String contenu;
  final DateTime createdAt;
  final String userFullName;

  @override
  List<Object?> get props => [contenu, createdAt, userFullName];
}

/// Correspond à Api\V1\CommunauteController::index() — pas un JsonResource côté Laravel (un
/// tableau construit à la main), voir ce contrôleur pour le détail des champs calculés
/// (unread_count, last_message).
class CommunauteEntity extends Equatable {
  const CommunauteEntity({
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

  CommunauteEntity copyWith({bool? joined, int? membresCount, int? unreadCount}) {
    return CommunauteEntity(
      id: id,
      nom: nom,
      description: description,
      iconUrl: iconUrl,
      membresCount: membresCount ?? this.membresCount,
      joined: joined ?? this.joined,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage,
    );
  }

  @override
  List<Object?> get props => [id, nom, description, iconUrl, membresCount, joined, unreadCount, lastMessage];
}
