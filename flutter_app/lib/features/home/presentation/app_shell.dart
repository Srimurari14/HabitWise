import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_toggle_off_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.face_retouching_natural_outlined),
            selectedIcon: Icon(Icons.face_retouching_natural_rounded),
            label: 'Avatar',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            selectedIcon: Icon(Icons.auto_graph_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
