import 'package:equatable/equatable.dart';

enum VideoStatut { enTraitement, prete, echouee }

VideoStatut videoStatutFromString(String value) => switch (value) {
      'PRETE' => VideoStatut.prete,
      'ECHOUEE' => VideoStatut.echouee,
      _ => VideoStatut.enTraitement,
    };

class VideoEcoleEntity extends Equatable {
  const VideoEcoleEntity({required this.id, required this.nom, this.photoUrl});

  final String id;
  final String nom;
  final String? photoUrl;

  @override
  List<Object?> get props => [id, nom, photoUrl];
}

/// Correspond à App\Http\Resources\VideoResource.
class VideoEntity extends Equatable {
  const VideoEntity({
    required this.id,
    required this.statut,
    required this.vues,
    required this.createdAt,
    required this.ecole,
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
  final VideoStatut statut;
  final int? dureeSecondes;
  final String? erreurMessage;
  final int vues;
  final DateTime createdAt;
  final VideoEcoleEntity ecole;

  @override
  List<Object?> get props =>
      [id, contenu, videoUrl, thumbnailUrl, statut, dureeSecondes, erreurMessage, vues, createdAt, ecole];
}
