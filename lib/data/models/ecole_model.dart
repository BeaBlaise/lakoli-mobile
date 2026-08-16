import '../../domain/entities/ecole_entity.dart';

/// Parse App\Http\Resources\EcoleResource (profil complet — GET /api/v1/ecoles/{ecole}).
class EcoleModel {
  const EcoleModel({
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
    this.followStatus = 'none',
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
  final String followStatus;
  final int followersCount;

  factory EcoleModel.fromJson(Map<String, dynamic> json) {
    return EcoleModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      region: json['region'] as String?,
      prefecture: json['prefecture'] as String?,
      commune: json['commune'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      typeEtablissement: json['type_etablissement'] as String?,
      isOwner: json['is_owner'] as bool? ?? false,
      followStatus: json['follow_status'] as String? ?? 'none',
      followersCount: json['followers_count'] as int? ?? 0,
    );
  }

  EcoleEntity toEntity() {
    return EcoleEntity(
      id: id,
      nom: nom,
      region: region,
      prefecture: prefecture,
      commune: commune,
      description: description,
      phone: phone,
      email: email,
      photoUrl: photoUrl,
      coverPhotoUrl: coverPhotoUrl,
      typeEtablissement: typeEtablissement,
      isOwner: isOwner,
      followStatus: followStatusFromString(followStatus),
      followersCount: followersCount,
    );
  }
}

/// Parse App\Http\Resources\EcoleSearchResource (liste de recherche/découverte —
/// GET /api/v1/ecoles). Volontairement un type distinct d'[EcoleModel] : le backend renvoie
/// moins de champs ici, un modèle unique masquerait cette différence réelle.
class EcoleSummaryModel {
  const EcoleSummaryModel({
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

  factory EcoleSummaryModel.fromJson(Map<String, dynamic> json) {
    return EcoleSummaryModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      region: json['region'] as String?,
      prefecture: json['prefecture'] as String?,
      commune: json['commune'] as String?,
      description: json['description'] as String?,
    );
  }

  EcoleSummaryEntity toEntity() {
    return EcoleSummaryEntity(id: id, nom: nom, region: region, prefecture: prefecture, commune: commune, description: description);
  }
}
