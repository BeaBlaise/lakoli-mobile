import 'package:equatable/equatable.dart';

/// École minimale embarquée dans une publication (voir PublicationResource côté Laravel :
/// 'ecole' => ['id', 'nom', 'region', 'photo_url']) — pas les mêmes champs qu'[EcoleEntity],
/// volontairement, pour ne pas laisser croire que le fil renvoie le profil complet.
class PublicationAuthorEntity extends Equatable {
  const PublicationAuthorEntity({required this.id, required this.nom, this.region, this.photoUrl});

  final String id;
  final String nom;
  final String? region;
  final String? photoUrl;

  @override
  List<Object?> get props => [id, nom, region, photoUrl];
}

/// Correspond à App\Http\Resources\PublicationResource. Les champs `sponsor*` ne sont
/// affichés à l'écran que pour distinguer clairement le contenu sponsorisé de l'organique
/// (voir la contrainte produit "respecter les données renvoyées par l'API" — jamais de badge
/// sponsorisé inventé côté client).
class PublicationEntity extends Equatable {
  const PublicationEntity({
    required this.id,
    required this.contenu,
    required this.createdAt,
    required this.ecoleId,
    required this.author,
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
  final PublicationAuthorEntity author;
  final String? imageUrl;
  final List<String> images;
  final int likesCount;
  final int commentsCount;
  final bool userLiked;
  final bool sponsorActif;
  final String? sponsorNiveau;
  final int? sponsorVues;

  PublicationEntity copyWith({int? likesCount, bool? userLiked, int? commentsCount}) {
    return PublicationEntity(
      id: id,
      contenu: contenu,
      createdAt: createdAt,
      ecoleId: ecoleId,
      author: author,
      imageUrl: imageUrl,
      images: images,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      userLiked: userLiked ?? this.userLiked,
      sponsorActif: sponsorActif,
      sponsorNiveau: sponsorNiveau,
      sponsorVues: sponsorVues,
    );
  }

  @override
  List<Object?> get props => [
        id,
        contenu,
        createdAt,
        ecoleId,
        author,
        imageUrl,
        images,
        likesCount,
        commentsCount,
        userLiked,
        sponsorActif,
        sponsorNiveau,
        sponsorVues,
      ];
}
