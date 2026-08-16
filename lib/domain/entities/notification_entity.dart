import 'package:equatable/equatable.dart';

/// Toutes les classes App\Notifications\* de ce projet renvoient la même forme dans leur
/// toArray() — {type, message, lien, follow_id?} — donc un seul modèle suffit ici, pas un type
/// par catégorie de notification (contrairement à [PublicationEntity]/[EcoleEntity], dont les
/// formes JSON diffèrent réellement selon le contexte).
enum NotificationKind {
  nouveauLike,
  nouveauCommentaire,
  nouvelleReponse,
  abonnementAccepte,
  demandeAbonnement,
  ecoleValidee,
  ecoleRefusee,
  inconnu,
}

NotificationKind notificationKindFromString(String value) => switch (value) {
      'nouveau_like' => NotificationKind.nouveauLike,
      'nouveau_commentaire' => NotificationKind.nouveauCommentaire,
      'nouvelle_reponse' => NotificationKind.nouvelleReponse,
      'abonnement_accepte' => NotificationKind.abonnementAccepte,
      'demande_abonnement' => NotificationKind.demandeAbonnement,
      'ecole_validee' => NotificationKind.ecoleValidee,
      'ecole_refusee' => NotificationKind.ecoleRefusee,
      _ => NotificationKind.inconnu,
    };

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.kind,
    required this.message,
    required this.createdAt,
    this.lien,
    this.readAt,
  });

  final String id;
  final NotificationKind kind;
  final String message;
  final DateTime createdAt;
  final String? lien;
  final DateTime? readAt;

  bool get isUnread => readAt == null;

  NotificationEntity copyWith({DateTime? readAt}) {
    return NotificationEntity(
      id: id,
      kind: kind,
      message: message,
      createdAt: createdAt,
      lien: lien,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [id, kind, message, createdAt, lien, readAt];
}
