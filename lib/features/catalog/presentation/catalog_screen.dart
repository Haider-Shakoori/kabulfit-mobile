import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/providers.dart';
import '../application/demo_catalog.dart';
import '../../../core/localization/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../commerce/application/commerce_providers.dart';

/// Live products are loaded from Laravel; optional preview data is read-only.
final catalogProvider = FutureProvider<List<KabulProduct>>((ref) async {
  try {
    final response = await ref.watch(apiClientProvider).get('/catalog');
    final items = response['data'];
    if (items is! List) throw const FormatException('Invalid catalog response');
    final products = items
        .whereType<Map<String, dynamic>>()
        .map(KabulProduct.fromJson)
        .where((product) => product.slug.isNotEmpty)
        .toList(growable: false);
    if (products.isNotEmpty || !demoCatalogEnabled) return products;
  } catch (_) {
    if (!demoCatalogEnabled) rethrow;
  }
  return demoCatalog.map(KabulProduct.fromJson).toList(growable: false);
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final response = await ref.watch(apiClientProvider).get('/categories');
  final data = response['data'];
  if (data is! List) throw const FormatException('Invalid categories response');
  return data
      .whereType<Map<String, dynamic>>()
      .where((entry) => entry['slug'] is String && entry['name'] is String)
      .toList(growable: false);
});

class KabulProduct {
  factory KabulProduct.fromJson(Map<String, dynamic> json) {
    final price = json['price'];
    final media = json['primary_media'];
    final stock = json['stock'];
    final category = json['category'];
    return KabulProduct(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: price is Map && price['currency'] == 'USD' && price['minor'] is num
          ? String.fromCharCode(36) +
                ((price['minor'] as num) / 100).toStringAsFixed(2)
          : price is Map
          ? price['formatted']?.toString() ?? ''
          : '',
      imageUrl: media is Map ? media['url']?.toString() : null,
      category: category is Map ? category['name']?.toString() ?? '' : '',
      categorySlug: category is Map ? category['slug']?.toString() : null,
      inStock: stock is Map && stock['in_stock'] == true,
      description: json['short_description']?.toString() ?? '',
    );
  }
  const KabulProduct({
    required this.slug,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.categorySlug,
    required this.inStock,
    required this.description,
  });

  final String slug;
  final String name;
  final String price;
  final String? imageUrl;
  final String category;
  final String? categorySlug;
  final bool inStock;
  final String description;
}

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String query = '';
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final shop = switch (locale) {
      'fa' => 'فروشگاه',
      'ps' => 'پلورنځی',
      _ => 'Shop the collection',
    };
    final strings = AppLocalizations.of(context);
    final result = ref.watch(catalogProvider);
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(shop)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(catalogProvider.future),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  leading: const Icon(Icons.search),
                  hintText: strings.text('searchProducts'),
                  onChanged: (value) => setState(() => query = value),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: categories.when(
                loading: () => const SizedBox(height: 8),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) => items.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        height: 52,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          children: [
                            ChoiceChip(
                              label: const Text('All'),
                              selected: selectedCategory == null,
                              onSelected: (_) =>
                                  setState(() => selectedCategory = null),
                            ),
                            for (final category in items) ...[
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: Text(category['name'].toString()),
                                selected: selectedCategory == category['slug'],
                                onSelected: (_) => setState(
                                  () => selectedCategory = category['slug']
                                      .toString(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
            result.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(strings.text('loadFailed')),
                      TextButton(
                        onPressed: () => ref.invalidate(catalogProvider),
                        child: Text(strings.text('retry')),
                      ),
                    ],
                  ),
                ),
              ),
              data: (products) {
                final visible = products
                    .where(
                      (product) =>
                          (selectedCategory == null ||
                              product.categorySlug == selectedCategory) &&
                          (product.name.toLowerCase().contains(
                                query.toLowerCase(),
                              ) ||
                              product.category.toLowerCase().contains(
                                query.toLowerCase(),
                              )),
                    )
                    .toList();
                if (visible.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(strings.text('noProducts'))),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.crossAxisExtent > 740 ? 4 : 2;
                      return SliverGrid.builder(
                        itemCount: visible.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: .60,
                        ),
                        itemBuilder: (context, index) {
                          final product = visible[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.push(
                                '/products/${Uri.encodeComponent(product.slug)}',
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: product.imageUrl == null
                                          ? const Icon(
                                              Icons.checkroom,
                                              size: 48,
                                            )
                                          : Image.network(
                                              product.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                    Icons.broken_image_outlined,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.category,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        Text(
                                          product.price,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final productProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  slug,
) async {
  if (demoCatalogEnabled) {
    final demo = demoProductBySlug(slug);
    if (demo != null) return demo;
  }
  final response = await ref
      .watch(apiClientProvider)
      .get('/products/${Uri.encodeComponent(slug)}');
  final data = response['data'];
  if (data is! Map<String, dynamic>) {
    throw const FormatException('Invalid product response');
  }
  return data;
});

class ProductScreen extends ConsumerWidget {
  const ProductScreen({required this.slug, super.key});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(productProvider(slug));
    return Scaffold(
      appBar: AppBar(title: const Text('KabulFit')),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(productProvider(slug)),
            child: const Text('Retry loading product'),
          ),
        ),
        data: (data) {
          final images = data['media'];
          final primary = data['primary_media'];
          final imageUrl =
              images is List && images.isNotEmpty && images.first is Map
              ? (images.first as Map)['url']?.toString()
              : primary is Map
              ? primary['url']?.toString()
              : null;
          final price = data['price'];
          return ListView(
            padding: const EdgeInsets.all(20),

            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: imageUrl == null
                    ? const Icon(Icons.checkroom, size: 80)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                data['name']?.toString() ?? '',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                price is Map ? price['formatted']?.toString() ?? '' : '',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(data['description']?.toString() ?? ''),
              const SizedBox(height: 24),
              if (data['tailoring_enabled'] == true) ...[
                const Chip(label: Text('Custom tailoring available')),
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/products/${Uri.encodeComponent(slug)}/tailor',
                  ),
                  icon: const Icon(Icons.straighten),
                  label: Text(AppLocalizations.of(context).text('customize')),
                ),
              ],
              const SizedBox(height: 12),
              if (data['is_demo'] == true)
                const Text('DEMO PREVIEW — not available to purchase')
              else
                _ProductActions(slug: slug, product: data),
            ],
          );
        },
      ),
    );
  }
}

class _ProductActions extends ConsumerStatefulWidget {
  const _ProductActions({required this.slug, required this.product});

  final String slug;
  final Map<String, dynamic> product;

  @override
  ConsumerState<_ProductActions> createState() => _ProductActionsState();
}

class _ProductActionsState extends ConsumerState<_ProductActions> {
  bool busy = false;
  String? selectedVariant;

  @override
  Widget build(BuildContext context) {
    final variants =
        (widget.product['variants'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];
    final available = variants.where((variant) {
      final stock = variant['stock'];
      return stock is Map && stock['in_stock'] == true;
    }).toList();
    final signedIn = ref.watch(authControllerProvider).value != null;

    if (!signedIn) {
      return FilledButton(
        onPressed: () => context.push('/login'),
        child: Text(AppLocalizations.of(context).text('signInShop')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (variants.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: selectedVariant,
            decoration: const InputDecoration(labelText: 'Choose size / color'),
            items: available.map((variant) {
              final color = variant['color'];
              final label = [
                variant['size']?.toString() ?? '',
                if (color is Map) color['name']?.toString() ?? '',
              ].where((part) => part.isNotEmpty).join(' · ');
              return DropdownMenuItem(
                value: variant['sku']?.toString(),
                child: Text(label.isEmpty ? variant['sku'].toString() : label),
              );
            }).toList(),
            onChanged: busy
                ? null
                : (value) => setState(() => selectedVariant = value),
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed:
              busy ||
                  (variants.isNotEmpty && selectedVariant == null) ||
                  (variants.isEmpty &&
                      widget.product['stock'] is Map &&
                      (widget.product['stock'] as Map)['in_stock'] != true)
              ? null
              : () async {
                  setState(() => busy = true);
                  try {
                    await ref
                        .read(commerceActionsProvider)
                        .addToCart(widget.slug, variantSku: selectedVariant);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
          icon: const Icon(Icons.shopping_bag_outlined),
          label: Text(
            busy ? 'Adding…' : AppLocalizations.of(context).text('addToCart'),
          ),
        ),
        TextButton.icon(
          onPressed: busy
              ? null
              : () async {
                  setState(() => busy = true);
                  try {
                    await ref
                        .read(commerceActionsProvider)
                        .addToWishlist(widget.slug);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to wishlist')),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
          icon: const Icon(Icons.favorite_border),
          label: Text(AppLocalizations.of(context).text('addWishlist')),
        ),
        TextButton(
          onPressed: () => context.push('/cart'),
          child: Text(AppLocalizations.of(context).text('viewCart')),
        ),
      ],
    );
  }
}
