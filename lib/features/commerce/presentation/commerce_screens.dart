import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
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
          final subtotalText = subtotal is num && currency == 'USD'
              ? '\${(subtotal / 100).toStringAsFixed(2)}'
              : '—';
          return RefreshIndicator(
            onRefresh: () => ref.refresh(cartProvider.future).then((_) {}),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 17),
                  child: Text(
                    switch (Localizations.localeOf(context).languageCode) {
                      'fa' => 'محصولات انتخاب‌شده',
                      'ps' => 'غوره شوي توکي',
                      _ => 'YOUR SELECTION',
                    },
                    style: const TextStyle(
                      color: BrandColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
                for (final item in items)
                  if (item is Map)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: BrandColors.cream,
                          child: Icon(
                            Icons.checkroom_outlined,
                            color: BrandColors.burgundy,
                          ),
                        ),
                        title: Text(
                          item['name']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Qty: ${item['quantity']}  ·  '
                          '${item['size_code'] == null ? '' : 'Size: ${item['size_code']}  ·  '}'
                          '${item['sku']}',
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
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: BrandColors.cream,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: BrandColors.champagne),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).text('checkoutSubtotal'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            subtotalText,
                            style: const TextStyle(
                              fontSize: 22,
                              color: BrandColors.burgundy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 9),
                      const Text(
                        'Shipping, discounts and final charges are calculated at checkout.',
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandColors.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: currency == 'USD'
                      ? () => context.push('/checkout')
                      : null,
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
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final slug = item['slug']?.toString() ?? '';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const CircleAvatar(
                            backgroundColor: BrandColors.cream,
                            child: Icon(
                              Icons.favorite,
                              color: BrandColors.burgundy,
                            ),
                          ),
                          title: Text(
                            item['name']?.toString() ?? '',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(item['sku']?.toString() ?? ''),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: BrandColors.burgundy,
                          ),
                          onTap: slug.isEmpty
                              ? null
                              : () => context.push(
                                  '/products/${Uri.encodeComponent(slug)}',
                                ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
