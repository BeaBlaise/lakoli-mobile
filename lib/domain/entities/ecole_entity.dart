import 'package:equatable/equatable.dart';

enum FollowStatus { none, pending, accepted }

FollowStatus followStatusFromString(String? value) => switch (value) {
      'accepted' => FollowStatus.accepted,
      'pending' => FollowStatus.pending,
      _ => FollowStatus.none,
    };

/// Correspond à App\Http\Resources\EcoleResource côté Laravel (profil complet). La liste de
/// recherche/découverte utilise un sous-ensemble plus léger — voir [EcoleSummaryEntity].
class EcoleEntity extends Equatable {
  const EcoleEntity({
    required this.id,
    required this.nom,
    this.region,
    this.prefecture,
    this.commune,
    this.description,
    this.phone,
    this.email,
    this.photoUrl,
    this.coverPhotoUrl,
    this.typeEtablissement,
    this.isOwner = false,
    this.followStatus = FollowStatus.none,
    this.followersCount = 0,
  });

  final String id;
  final String nom;
  final String? region;
  final String? prefecture;
  final String? commune;
  final String? description;
  final String? phone;
  final String? email;
  final String? photoUrl;
  final String? coverPhotoUrl;
  final String? typeEtablissement;
  final bool isOwner;
  final FollowStatus followStatus;
  final int followersCount;

  @override
  List<Object?> get props => [
        id,
        nom,
        region,
        prefecture,
        commune,
        description,
        phone,
        email,
        photoUrl,
        coverPhotoUrl,
        typeEtablissement,
        isOwner,
        followStatus,
        followersCount,
      ];
}

/// Version allégée utilisée par la recherche/découverte (GET /api/v1/ecoles) — correspond à
/// App\Http\Resources\EcoleSearchResource, qui n'expose ni contact ni statut de suivi.
class EcoleSummaryEntity extends Equatable {
  const EcoleSummaryEntity({
    required this.id,
    required this.nom,
    this.region,
    this.prefecture,
    this.commune,
    this.description,
  });

  final String id;
  final String nom;
  final String? region;
  final String? prefecture;
  final String? commune;
  final String? description;

  @override
  List<Object?> get props => [id, nom, region, prefecture, commune, description];
}
