/// Noms de routes centralisés — jamais de chemin en dur ailleurs dans le code, pour garder
/// un seul endroit à modifier si une structure de navigation change.
abstract final class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';

  static const home = 'home';
  static const discover = 'discover';
  static const create = 'create';
  static const notifications = 'notifications';
  static const profile = 'profile';

  static const ecoleProfile = 'ecole-profile';
  static const publicationDetail = 'publication-detail';

  /// Outil de vérification visuelle, pas un écran produit — voir
  /// presentation/shared/pages/design_system_showcase_page.dart.
  static const designSystem = 'design-system';
}
