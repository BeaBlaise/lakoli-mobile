import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/application/auth_controller.dart';
import '../../presentation/auth/pages/login_page.dart';
import '../../presentation/home/pages/home_shell_page.dart';
import '../../presentation/shared/pages/design_system_showcase_page.dart';
import 'route_names.dart';

/// Reconstruit l'arbre de routes à chaque changement d'état d'auth — volontairement simple
/// pour cette phase d'architecture (perd la pile de navigation au moment précis de la
/// connexion/déconnexion, ce qui est acceptable puisque l'app redirige de toute façon vers
/// un écran racine à cet instant). À reconsidérer avec un refreshListenable dédié si des
/// parcours plus profonds en Phase 5+ rendent cette perte de pile gênante en pratique.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Tant que la session initiale n'a pas été résolue (lecture du stockage sécurisé +
      // éventuel appel /auth/me), ne redirige nulle part — évite un flash vers l'écran de
      // connexion pour un utilisateur déjà connecté.
      if (authState.isLoading) return null;

      final isAuthenticated = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/connexion';
      final isPublicTool = state.matchedLocation == '/design-system';

      if (isPublicTool) return null;
      if (!isAuthenticated && !isLoggingIn) return '/connexion';
      if (isAuthenticated && isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/connexion', name: RouteNames.login, builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/design-system',
        name: RouteNames.designSystem,
        builder: (context, state) => const DesignSystemShowcasePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShellPage(navigationShell: navigationShell),
        branches: [
          _placeholderBranch('/', RouteNames.home, 'Accueil'),
          _placeholderBranch('/decouvrir', RouteNames.discover, 'Découvrir'),
          _placeholderBranch('/creer', RouteNames.create, 'Créer'),
          _placeholderBranch('/notifications', RouteNames.notifications, 'Notifications'),
          _placeholderBranch('/profil', RouteNames.profile, 'Profil'),
        ],
      ),
    ],
  );
});

StatefulShellBranch _placeholderBranch(String path, String name, String title) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        name: name,
        builder: (context, state) => PlaceholderTabPage(title: title),
      ),
    ],
  );
}
