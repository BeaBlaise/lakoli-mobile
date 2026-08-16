import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/application/auth_controller.dart';
import '../../presentation/auth/pages/login_page.dart';
import '../../presentation/auth/pages/register_page.dart';
import '../../presentation/ecole/pages/ecole_profile_page.dart';
import '../../presentation/home/pages/feed_page.dart';
import '../../presentation/home/pages/home_shell_page.dart';
import '../../presentation/profile/pages/profile_page.dart';
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
      final isLoggingIn = state.matchedLocation == '/connexion' || state.matchedLocation == '/inscription';
      final isPublicTool = state.matchedLocation == '/design-system';

      if (isPublicTool) return null;
      if (!isAuthenticated && !isLoggingIn) return '/connexion';
      if (isAuthenticated && isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/connexion', name: RouteNames.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: '/inscription', name: RouteNames.register, builder: (context, state) => const RegisterPage()),
      GoRoute(
        path: '/design-system',
        name: RouteNames.designSystem,
        builder: (context, state) => const DesignSystemShowcasePage(),
      ),
      GoRoute(
        path: '/ecoles/:id',
        name: RouteNames.ecoleProfile,
        builder: (context, state) => EcoleProfilePage(ecoleId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', name: RouteNames.home, builder: (context, state) => const FeedPage())],
          ),
          _placeholderBranch('/decouvrir', RouteNames.discover, 'Découvrir'),
          _placeholderBranch('/creer', RouteNames.create, 'Créer'),
          _placeholderBranch('/notifications', RouteNames.notifications, 'Notifications'),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profil', name: RouteNames.profile, builder: (context, state) => const ProfilePage())],
          ),
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
