/// Référentiel géographique (région → préfecture → commune) — donnée statique, pas de
/// mutation, pas besoin de la séparation domain/data/repository complète utilisée ailleurs
/// dans l'app pour ça (voir presentation/auth/application/geographie_provider.dart).
class PrefectureGeo {
  const PrefectureGeo({required this.nom, required this.communes});

  final String nom;
  final List<String> communes;

  factory PrefectureGeo.fromJson(Map<String, dynamic> json) {
    return PrefectureGeo(
      nom: json['nom'] as String,
      communes: (json['communes'] as List).cast<String>(),
    );
  }
}

class RegionGeo {
  const RegionGeo({required this.nom, required this.prefectures});

  final String nom;
  final List<PrefectureGeo> prefectures;

  factory RegionGeo.fromJson(Map<String, dynamic> json) {
    return RegionGeo(
      nom: json['nom'] as String,
      prefectures: (json['prefectures'] as List)
          .map((e) => PrefectureGeo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
