import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../application/commerce_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your cart')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: const Text('Sign in to view your cart'),
          ),
        ),
      );
    }
    final response = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: response.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString(), textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.invalidate(cartProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (cart) {
          final items = (cart['items'] as List?) ?? [];
          if (items.isEmpty) {
            return Center(
              child: TextButton(
                onPressed: () => context.go('/shop'),
                child: const Text('Your cart is empty — browse products'),
              ),
            );
          }
          final currency = cart['currency']?.toString() ?? '';
          final subtotal = cart['subtotal_minor'];
          final subtotalText = subtotal is num
              ? '${(subtotal / 100).toStringAsFixed(2)} $currency'
              : '—';
          return RefreshIndicator(
            onRefresh: () => ref.refresh(cartProvider.future).then((_) {}),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in items)
                  if (item is Map)
                    Card(
                      child: ListTile(
                        title: Text(item['name']?.toString() ?? ''),
                        subtitle: Text('Qty: ${item['quantity']}  ·  ${item['sku']}'),
                        trailing: Text(item['line_total_minor'] is num
                            ? ((item['line_total_minor'] as num) / 100)
                                .toStringAsFixed(2)
                            : '—'),
                      ),
                    ),
                const SizedBox(height: 16),
                Text('Subtotal: $subtotalText',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Shipping, discounts, and final charges are calculated by KabulFit at checkout.'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wishlist')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: const Text('Sign in to view wishlist'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: ref.watch(wishlistProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(wishlistProvider),
            child: Text('Unable to load wishlist. Try again: $error'),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No saved products yet'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final slug = item['slug']?.toString() ?? '';
                  return ListTile(
                    title: Text(item['name']?.toString() ?? ''),
                    subtitle: Text(item['sku']?.toString() ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: slug.isEmpty
                        ? null
                        : () => context.push('/products/${Uri.encodeComponent(slug)}'),
                  );
                },
              ),
      ),
    );
  }
}
