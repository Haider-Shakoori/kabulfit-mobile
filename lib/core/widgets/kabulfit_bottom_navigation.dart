import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_localizations.dart';

/// Shared five-destination navigation of the approved KabulFit showcase.
/// Account and measurements use real screens, not inert placeholders.
class KabulFitBottomNavigation extends StatelessWidget {
  const KabulFitBottomNavigation({required this.selectedIndex, super.key});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/');
          case 1:
            context.go('/shop');
          case 2:
            context.go('/measurements');
          case 3:
            context.go('/cart');
          case 4:
            context.go('/account');
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: strings.text('home'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.shopping_bag_outlined),
          selectedIcon: const Icon(Icons.shopping_bag_rounded),
          label: strings.text('shop'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.straighten_outlined),
          selectedIcon: const Icon(Icons.straighten_rounded),
          label: strings.text('measurements'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.shopping_cart_outlined),
          selectedIcon: const Icon(Icons.shopping_cart_rounded),
          label: strings.text('cart'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: strings.text('account'),
        ),
      ],
    );
  }
}
