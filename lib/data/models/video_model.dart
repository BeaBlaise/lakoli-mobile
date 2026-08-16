import '../../domain/entities/video_entity.dart';

class VideoModel {
  const VideoModel({
    required this.id,
    required this.statut,
    required this.vues,
    required this.createdAt,
    required this.ecoleId,
    required this.ecoleNom,
    this.ecolePhotoUrl,
    this.contenu,
    this.videoUrl,
    this.thumbnailUrl,
    this.dureeSecondes,
    this.erreurMessage,
  });

  final String id;
  final String? contenu;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String statut;
  final int? dureeSecondes;
  final String? erreurMessage;
  final int vues;
  final DateTime createdAt;
  final String ecoleId;
  final String ecoleNom;
  final String? ecolePhotoUrl;

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final ecole = json['ecole'] as Map<String, dynamic>;

    return VideoModel(
      id: json['id'] as String,
      contenu: json['contenu'] as String?,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      statut: json['statut'] as String,
      dureeSecondes: json['duree_secondes'] as int?,
      erreurMessage: json['erreur_message'] as String?,
      vues: json['vues'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      ecoleId: ecole['id'] as String,
      ecoleNom: ecole['nom'] as String,
      ecolePhotoUrl: ecole['photo_url'] as String?,
    );
  }

  VideoEntity toEntity() {
    return VideoEntity(
      id: id,
      contenu: contenu,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      statut: videoStatutFromString(statut),
      dureeSecondes: dureeSecondes,
      erreurMessage: erreurMessage,
      vues: vues,
      createdAt: createdAt,
      ecole: VideoEcoleEntity(id: ecoleId, nom: ecoleNom, photoUrl: ecolePhotoUrl),
    );
  }
}
