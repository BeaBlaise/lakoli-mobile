import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/user_entity.dart';
import '../../auth/application/auth_controller.dart';
import '../../ecole/pages/ecole_dashboard_page.dart';
import '../../ecole/pages/ecole_en_attente_page.dart';
import 'feed_page.dart';

/// Mobile de App\Http\Controllers\HomeController — l'onglet "Accueil" n'est pas toujours le
/// fil personnel : un compte dont l'active_role est "ecole" voit son tableau de bord (une fois
/// son école validée) ou un écran d'attente (tant qu'elle ne l'est pas), jamais le fil normal.
/// Web fait ce choix via une redirection serveur (HomeController::index()) ; mobile le fait ici
/// pour rester dans la même coquille de navigation à onglets plutôt que de sortir vers une
/// route hors StatefulShellRoute (voir core/router/app_router.dart).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    if (user?.activeRole == UserRole.ecole) {
      return user?.ecole?.statut == EcoleStatut.validee ? const EcoleDashboardPage() : const EcoleEnAttentePage();
    }

    return const FeedPage();
  }
}
