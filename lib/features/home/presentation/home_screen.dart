import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../catalog/presentation/catalog_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('appName')),
        actions: [
          if (session == null)
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(strings.text('signIn')),
            )
          else
            IconButton(
              tooltip: strings.text('account'),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.checkroom, size: 72),
                const SizedBox(height: 24),
                Text(
                  strings.text('welcome'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.go('/shop'),
                  icon: const Icon(Icons.storefront_outlined),
                  label: Text(strings.text('shop')),
                ),
                const SizedBox(height: 24),
                const Expanded(child: _FeaturedPreview()),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.go('/shop');
          if (index == 2) context.go('/login');
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: strings.text('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            label: strings.text('shop'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: strings.text('account'),
          ),
        ],
      ),
    );
  }
}


class _FeaturedPreview extends ConsumerWidget {
  const _FeaturedPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(catalogProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => TextButton(
        onPressed: () => ref.invalidate(catalogProvider),
        child: Text(AppLocalizations.of(context).text('retry')),
      ),
      data: (products) => products.isEmpty
          ? const SizedBox.shrink()
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length > 6 ? 6 : products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return SizedBox(
                  width: 180,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push('/products/${Uri.encodeComponent(product.slug)}'),
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox.expand(
                              child: product.imageUrl == null
                                  ? const Icon(Icons.checkroom)
                                  : Image.network(product.imageUrl!, fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(product.name, maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
