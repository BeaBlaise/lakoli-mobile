import 'paginated_result.dart';
import 'publication_entity.dart';

/// Résultat de GET /api/v1/feed — un [PaginatedResult] classique plus `has_follows`, un champ
/// que le fil personnel est seul à renvoyer (voir Api\V1\FeedController côté Laravel). Le web
/// n'a pas cet équivalent : /dashboard redirige carrément vers un écran d'onboarding dédié
/// quand l'utilisateur ne suit personne (un concept Inertia sans équivalent API) — le mobile
/// utilise plutôt ce booléen pour décider d'afficher sa propre UI de découverte au-dessus d'un
/// fil qui, sinon, resterait presque vide sans aucune explication.
class FeedResult {
  const FeedResult({required this.page, required this.hasFollows});

  final PaginatedResult<PublicationEntity> page;
  final bool hasFollows;
}
