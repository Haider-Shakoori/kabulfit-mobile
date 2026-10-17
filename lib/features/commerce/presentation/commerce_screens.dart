import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kabulfit_bottom_navigation.dart';
import '../../auth/application/auth_controller.dart';
import '../../catalog/presentation/catalog_screen.dart';
import '../application/commerce_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).text('cart'))),
        bottomNavigationBar: const KabulFitBottomNavigation(selectedIndex: 3),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: Text(AppLocalizations.of(context).text('signInCart')),
          ),
        ),
      );
    }
    final response = ref.watch(cartProvider);
    final liveCatalog =
        ref.watch(catalogProvider).value ?? const <KabulProduct>[];
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).text('cart'))),
      bottomNavigationBar: const KabulFitBottomNavigation(selectedIndex: 3),
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
                    _LuxuryCartLine(
                      item: item,
                      product: _findCatalogProduct(
                        liveCatalog,
                        item['product_slug']?.toString(),
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
                              AppLocalizations.of(
                                context,
                              ).text('checkoutSubtotal'),
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
    final liveCatalog =
        ref.watch(catalogProvider).value ?? const <KabulProduct>[];
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
                      final product = _findCatalogProduct(liveCatalog, slug);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LiveProductPhoto(
                                url: product?.imageUrl,
                                width: 92,
                                height: 112,
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name']?.toString() ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    if (product != null)
                                      Text(
                                        product.price,
                                        style: const TextStyle(
                                          color: BrandColors.burgundy,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    OutlinedButton(
                                      onPressed: slug.isEmpty
                                          ? null
                                          : () => context.push(
                                              '/products/${Uri.encodeComponent(slug)}',
                                            ),
                                      child: Text(
                                        switch (Localizations.localeOf(
                                          context,
                                        ).languageCode) {
                                          'fa' => 'انتخاب گزینه‌ها',
                                          'ps' => 'انتخابونه وټاکئ',
                                          _ => 'Choose options',
                                        },
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: AppLocalizations.of(
                                  context,
                                ).text('delete'),
                                onPressed: slug.isEmpty
                                    ? null
                                    : () => _mutate(
                                        context,
                                        ref,
                                        () => ref
                                            .read(commerceActionsProvider)
                                            .removeFromWishlist(slug),
                                      ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: BrandColors.burgundy,
                                ),
                              ),
                            ],
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

KabulProduct? _findCatalogProduct(List<KabulProduct> products, String? slug) {
  if (slug == null || slug.isEmpty) return null;
  for (final product in products) {
    if (product.slug == slug) return product;
  }
  return null;
}

class _LiveProductPhoto extends StatelessWidget {
  const _LiveProductPhoto({
    required this.url,
    required this.width,
    required this.height,
  });

  final String? url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(13),
    child: SizedBox(
      width: width,
      height: height,
      child: url == null
          ? const ColoredBox(
              color: BrandColors.cream,
              child: Icon(Icons.checkroom_outlined),
            )
          : Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: BrandColors.cream,
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
    ),
  );
}

class _LuxuryCartLine extends ConsumerWidget {
  const _LuxuryCartLine({required this.item, required this.product});

  final Map item;
  final KabulProduct? product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qty = item['quantity'] is num ? (item['quantity'] as num).toInt() : 0;
    final lineTotal = item['line_total_minor'];
    final totalText = lineTotal is num
        ? '\$${(lineTotal / 100).toStringAsFixed(2)}'
        : '—';
    final size = item['size_code']?.toString();
    final uuid = item['uuid']?.toString() ?? '';
    final locale = Localizations.localeOf(context).languageCode;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LiveProductPhoto(url: product?.imageUrl, width: 86, height: 110),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (size != null && size.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context).text('selectOriginalSize')}: $size',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 7),
                  Text(
                    totalText,
                    style: const TextStyle(
                      color: BrandColors.burgundy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: switch (locale) {
                          'fa' => 'کم کردن تعداد',
                          'ps' => 'شمېر کم کړئ',
                          _ => 'Decrease quantity',
                        },
                        visualDensity: VisualDensity.compact,
                        onPressed: qty > 1 && uuid.isNotEmpty
                            ? () => _mutate(
                                context,
                                ref,
                                () => ref
                                    .read(commerceActionsProvider)
                                    .changeQuantity(uuid, qty - 1),
                              )
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$qty',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      IconButton(
                        tooltip: switch (locale) {
                          'fa' => 'زیاد کردن تعداد',
                          'ps' => 'شمېر زیات کړئ',
                          _ => 'Increase quantity',
                        },
                        visualDensity: VisualDensity.compact,
                        onPressed: qty < 99 && uuid.isNotEmpty
                            ? () => _mutate(
                                context,
                                ref,
                                () => ref
                                    .read(commerceActionsProvider)
                                    .changeQuantity(uuid, qty + 1),
                              )
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      IconButton(
                        tooltip: AppLocalizations.of(context).text('delete'),
                        visualDensity: VisualDensity.compact,
                        onPressed: uuid.isEmpty
                            ? null
                            : () => _mutate(
                                context,
                                ref,
                                () => ref
                                    .read(commerceActionsProvider)
                                    .removeItem(uuid),
                              ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: BrandColors.burgundy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
