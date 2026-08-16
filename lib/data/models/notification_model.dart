import '../../domain/entities/notification_entity.dart';

/// Parse App\Http\Resources\NotificationResource — {id, type, data, read_at, created_at,
/// follow_statut}. `data` est le contenu réel de la notification (voir
/// App\Notifications\*::toArray(), toutes de la même forme {type, message, lien, follow_id?}) ;
/// `type` au premier niveau est la classe Laravel complète (ex.
/// "App\\Notifications\\NewLikeNotification"), pas la même chose que `data.type` — seul ce
/// dernier est utilisé ici.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.kind,
    required this.message,
    required this.createdAt,
    this.lien,
    this.readAt,
  });

  final String id;
  final String kind;
  final String message;
  final DateTime createdAt;
  final String? lien;
  final DateTime? readAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};

    return NotificationModel(
      id: json['id'] as String,
      kind: data['type'] as String? ?? '',
      message: data['message'] as String? ?? '',
      lien: data['lien'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      kind: notificationKindFromString(kind),
      message: message,
      lien: lien,
      createdAt: createdAt,
      readAt: readAt,
    );
  }
}
