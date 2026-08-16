import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Coquille de navigation à 5 onglets (bottom navigation) — tous réels depuis l'audit du
/// 2026-08-16 (fil, découverte, création de publication, notifications, profil).
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
