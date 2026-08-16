import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Coquille de navigation provisoire (bottom navigation à 5 onglets) — les écrans réels du
/// fil, de la découverte, etc. arrivent en Phase 5 et suivantes. Ce placeholder valide que
/// la structure de navigation principale fonctionne dès la Phase 2.
class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _labels = ['Accueil', 'Découvrir', 'Créer', 'Notifications', 'Profil'];
  static const _icons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.add_box_outlined,
    Icons.notifications_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (var i = 0; i < _labels.length; i++)
            NavigationDestination(icon: Icon(_icons[i]), label: _labels[i]),
        ],
      ),
    );
  }
}

/// Un seul écran placeholder réutilisé pour les 5 onglets tant que les vraies pages
/// n'existent pas — évite cinq fichiers identiques pour rien à ce stade.
class PlaceholderTabPage extends StatelessWidget {
  const PlaceholderTabPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — écran à construire dans une phase suivante')),
    );
  }
}
