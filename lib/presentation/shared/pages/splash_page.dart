import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Écran affiché le temps que l'état d'authentification initial se résolve (lecture du
/// stockage sécurisé, éventuel appel /auth/me — voir AuthController.build()). Sans cet écran,
/// `initialLocation: '/'` du routeur (voir core/router/app_router.dart) laissait le fil
/// d'accueil se construire brièvement pendant ce chargement, déclenchant un appel réseau sans
/// token pour tout utilisateur non encore connecté — observé en conditions réelles comme une
/// erreur "Unauthenticated" affichée juste après une inscription réussie.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lakoli', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: colors.brand600)),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: colors.brand600),
          ],
        ),
      ),
    );
  }
}
