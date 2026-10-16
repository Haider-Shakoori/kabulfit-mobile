import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../../../core/localization/app_localizations.dart';
import '../application/commerce_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).text('cart'))),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: Text(AppLocalizations.of(context).text('signInCart')),
          ),
        ),
      );
    }
    final response = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).text('cart'))),
      body: response.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString(), textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.invalidate(cartProvider),
                child: Text(AppLocalizations.of(context).text('retry')),
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
                child: Text(AppLocalizations.of(context).text('emptyCart')),
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
                        subtitle: Text(
                          'Qty: ${item['quantity']}  ·  ${item['sku']}',
                        ),
                        trailing: SizedBox(
                          width: 144,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 36,
                                ),
                                tooltip: 'Decrease quantity',
                                onPressed:
                                    (item['quantity'] is num &&
                                        (item['quantity'] as num) > 1)
                                    ? () => _mutate(
                                        context,
                                        ref,
                                        () => ref
                                            .read(commerceActionsProvider)
                                            .changeQuantity(
                                              item['uuid'].toString(),
                                              (item['quantity'] as num)
                                                      .toInt() -
                                                  1,
                                            ),
                                      )
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(item['quantity']?.toString() ?? '0'),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 36,
                                ),
                                tooltip: 'Increase quantity',
                                onPressed:
                                    (item['quantity'] is num &&
                                        (item['quantity'] as num) < 99)
                                    ? () => _mutate(
                                        context,
                                        ref,
                                        () => ref
                                            .read(commerceActionsProvider)
                                            .changeQuantity(
                                              item['uuid'].toString(),
                                              (item['quantity'] as num)
                                                      .toInt() +
                                                  1,
                                            ),
                                      )
                                    : null,
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 36,
                                ),
                                tooltip: 'Remove item',
                                onPressed: () => _mutate(
                                  context,
                                  ref,
                                  () => ref
                                      .read(commerceActionsProvider)
                                      .removeItem(item['uuid'].toString()),
                                ),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                Text(
                  'Subtotal: $subtotalText',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Shipping, discounts, and final charges are calculated by KabulFit at checkout.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.push('/checkout'),
                  icon: const Icon(Icons.lock_outline),
                  label: Text(AppLocalizations.of(context).text('checkout')),
                ),
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
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).text('wishlist')),
        ),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: Text(AppLocalizations.of(context).text('signInWishlist')),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).text('wishlist')),
      ),
      body: ref
          .watch(wishlistProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(wishlistProvider),
                child: Text('Unable to load wishlist. Try again: $error'),
              ),
            ),
            data: (items) => items.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).text('emptyWishlist'),
                    ),
                  )
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
                            : () => context.push(
                                '/products/${Uri.encodeComponent(slug)}',
                              ),
                      );
                    },
                  ),
          ),
    );
  }
}

Future<void> _mutate(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() request,
) async {
  try {
    await request();
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
