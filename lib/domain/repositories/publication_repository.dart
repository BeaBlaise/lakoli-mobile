import '../../core/utils/result.dart';

abstract interface class PublicationRepository {
  Future<Result<void>> like(String publicationId);
  Future<Result<void>> unlike(String publicationId);

  /// Réservé aux comptes école (POST /api/v1/publications exige role:ecole côté serveur — le
  /// backend reste l'autorité finale, cette restriction n'est vérifiée client-side que pour
  /// l'UX, voir CreatePublicationPage). [imagePaths] : jusqu'à 10, voir StorePublicationRequest.
  Future<Result<void>> create(String contenu, List<String> imagePaths);
}
