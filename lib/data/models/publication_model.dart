import '../../domain/entities/publication_entity.dart';

/// Parse App\Http\Resources\PublicationResource.
class PublicationModel {
  const PublicationModel({
    required this.id,
    required this.contenu,
    required this.createdAt,
    required this.ecoleId,
    required this.ecole,
    this.imageUrl,
    this.images = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.userLiked = false,
    this.sponsorActif = false,
    this.sponsorNiveau,
    this.sponsorVues,
  });

  final String id;
  final String contenu;
  final DateTime createdAt;
  final String ecoleId;
  final PublicationEcoleModel ecole;
  final String? imageUrl;
  final List<String> images;
  final int likesCount;
  final int commentsCount;
  final bool userLiked;
  final bool sponsorActif;
  final String? sponsorNiveau;
  final int? sponsorVues;

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    return PublicationModel(
      id: json['id'] as String,
      contenu: json['contenu'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      ecoleId: json['ecole_id'] as String,
      ecole: PublicationEcoleModel.fromJson(json['ecole'] as Map<String, dynamic>),
      imageUrl: json['image_url'] as String?,
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      userLiked: json['user_liked'] as bool? ?? false,
      sponsorActif: json['sponsor_actif'] as bool? ?? false,
      sponsorNiveau: json['sponsor_niveau'] as String?,
      sponsorVues: json['sponsor_vues'] as int?,
    );
  }

  PublicationEntity toEntity() {
    return PublicationEntity(
      id: id,
      contenu: contenu,
      createdAt: createdAt,
      ecoleId: ecoleId,
      author: PublicationAuthorEntity(id: ecole.id, nom: ecole.nom, region: ecole.region, photoUrl: ecole.photoUrl),
      imageUrl: imageUrl,
      images: images,
      likesCount: likesCount,
      commentsCount: commentsCount,
      userLiked: userLiked,
      sponsorActif: sponsorActif,
      sponsorNiveau: sponsorNiveau,
      sponsorVues: sponsorVues,
    );
  }
}

class PublicationEcoleModel {
  const PublicationEcoleModel({required this.id, required this.nom, this.region, this.photoUrl});

  final String id;
  final String nom;
  final String? region;
  final String? photoUrl;

  factory PublicationEcoleModel.fromJson(Map<String, dynamic> json) {
    return PublicationEcoleModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      region: json['region'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}
