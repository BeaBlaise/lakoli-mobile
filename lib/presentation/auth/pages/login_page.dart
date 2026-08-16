import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Écran provisoire — la vraie interface de connexion est construite en Phase 4
/// (Authentification), une fois le design system de la Phase 3 disponible. Ce placeholder
/// existe pour que le routeur et la garde d'authentification soient vérifiables dès
/// maintenant, sans attendre les phases suivantes.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Connexion — écran à construire en Phase 4'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/design-system'),
              child: const Text('Voir le design system (Phase 3)'),
            ),
          ],
        ),
      ),
    );
  }
}
