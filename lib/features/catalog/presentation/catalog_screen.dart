import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kabulfit_bottom_navigation.dart';
import '../../auth/application/auth_controller.dart';
import '../../commerce/application/commerce_providers.dart';
import '../application/catalog_pagination.dart';
import '../application/demo_catalog.dart';

/// Live products are loaded from Laravel; optional preview data is read-only.
final catalogProvider = FutureProvider<List<KabulProduct>>((ref) async {
  try {
    final api = ref.watch(apiClientProvider);
    final items = await loadAllCatalogPages(
      (page) => api.get('/catalog?page=$page'),
    );
    final products = items
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
  const CatalogScreen({this.initialCategory, super.key});

  final String? initialCategory;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String query = '';
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

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
      appBar: AppBar(
        title: Text(shop),
        actions: [
          IconButton(
            tooltip: strings.text('cart'),
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.go('/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: const KabulFitBottomNavigation(selectedIndex: 1),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(catalogProvider.future),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(BrandColors.cream),
                  leading: const Icon(
                    Icons.search,
                    color: BrandColors.burgundy,
                  ),
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
                              label: Text(switch (locale) {
                                'fa' => 'همه',
                                'ps' => 'ټول',
                                _ => 'All',
                              }),
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
                            child: InkWell(
                              onTap: () => context.push(
                                '/products/${Uri.encodeComponent(product.slug)}',
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        product.imageUrl == null
                                            ? const ColoredBox(
                                                color: BrandColors.cream,
                                                child: Icon(
                                                  Icons.checkroom_outlined,
                                                ),
                                              )
                                            : Image.network(
                                                product.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) =>
                                                    const ColoredBox(
                                                      color: BrandColors.cream,
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported_outlined,
                                                      ),
                                                    ),
                                              ),
                                        if (!product.inStock)
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Chip(
                                                label: Text(switch (locale) {
                                                  'fa' => 'ناموجود',
                                                  'ps' => 'نشته',
                                                  _ => 'Sold out',
                                                }),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      11,
                                      11,
                                      11,
                                      14,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.category.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            letterSpacing: .8,
                                            fontWeight: FontWeight.w700,
                                            color: BrandColors.gold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          product.price,
                                          style: const TextStyle(
                                            color: BrandColors.burgundy,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
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

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({required this.slug, super.key});
  final String slug;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final PageController _photos = PageController();
  int _selectedPhoto = 0;

  @override
  void didUpdateWidget(covariant ProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _selectedPhoto = 0;
      if (_photos.hasClients) _photos.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _photos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
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
          final gallery = images is List
              ? images
                    .whereType<Map>()
                    .map((entry) => entry['url']?.toString())
                    .whereType<String>()
                    .where((url) => url.isNotEmpty)
                    .toList(growable: false)
              : <String>[];
          final photoUrls = gallery.isNotEmpty
              ? gallery
              : imageUrl == null
              ? <String>[]
              : <String>[imageUrl];
          final originalSizes =
              (data['size_options'] as List?)?.whereType<String>().toList() ??
              const <String>[];
          final stock = data['stock'];
          final inStock = stock is Map && stock['in_stock'] == true;
          final currency = price is Map ? price['currency']?.toString() : null;
          final minor = price is Map ? price['minor'] : null;
          final displayedPrice = currency == 'USD' && minor is num
              ? '\$${(minor / 100).toStringAsFixed(2)}'
              : '—';
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 34),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 4 / 4.4,
                  child: photoUrls.isEmpty
                      ? const ColoredBox(
                          color: BrandColors.cream,
                          child: Icon(Icons.checkroom_outlined, size: 72),
                        )
                      : PageView.builder(
                          controller: _photos,
                          onPageChanged: (index) {
                            if (mounted) setState(() => _selectedPhoto = index);
                          },
                          itemCount: photoUrls.length,
                          itemBuilder: (context, index) => Image.network(
                            photoUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: BrandColors.cream,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                ),
              ),
              if (photoUrls.length > 1) ...[
                const SizedBox(height: 11),
                SizedBox(
                  height: 74,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photoUrls.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 9),
                    itemBuilder: (context, index) {
                      final selected = _selectedPhoto == index;
                      return Semantics(
                        label: 'Photo ${index + 1} of ${photoUrls.length}',
                        selected: selected,
                        button: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _photos.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 64,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selected
                                    ? BrandColors.burgundy
                                    : BrandColors.champagne,
                                width: selected ? 2.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                photoUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const ColoredBox(
                                  color: BrandColors.cream,
                                  child: Icon(Icons.image_not_supported_outlined),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedPhoto + 1} / ${photoUrls.length}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 22),
              Text(
                data['category'] is Map
                    ? ((data['category'] as Map)['name']?.toString() ?? '')
                          .toUpperCase()
                    : 'KABULFIT',
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.gold,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                data['name']?.toString() ?? '',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayedPrice,
                      style: const TextStyle(
                        color: BrandColors.burgundy,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!inStock) const Chip(label: Text('Sold out')),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(),
              if (originalSizes.isNotEmpty) ...[
                const SizedBox(height: 9),
                Text(
                  'Available sizes: ${originalSizes.join(' · ')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 18),
              Text(
                data['description']?.toString() ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (data['tailoring_enabled'] == true) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BrandColors.cream,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.straighten,
                        size: 30,
                        color: BrandColors.burgundy,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Custom tailoring available',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          '/products/${Uri.encodeComponent(slug)}/tailor',
                        ),
                        icon: const Icon(Icons.straighten),
                        label: Text(
                          AppLocalizations.of(context).text('customize'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
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
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    final variants =
        (widget.product['variants'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];
    final originalSizes =
        (widget.product['size_options'] as List?)?.whereType<String>().toList(
          growable: false,
        ) ??
        const <String>[];
    final requiresOriginalSize = variants.isEmpty && originalSizes.isNotEmpty;
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
        if (requiresOriginalSize)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).text('selectOriginalSize'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  for (final size in originalSizes)
                    ChoiceChip(
                      label: Text(size),
                      selected: selectedSize == size,
                      onSelected: busy
                          ? null
                          : (selected) => setState(
                              () => selectedSize = selected ? size : null,
                            ),
                    ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed:
              busy ||
                  (variants.isNotEmpty && selectedVariant == null) ||
                  (requiresOriginalSize && selectedSize == null) ||
                  (variants.isEmpty &&
                      widget.product['stock'] is Map &&
                      (widget.product['stock'] as Map)['in_stock'] != true)
              ? null
              : () async {
                  setState(() => busy = true);
                  try {
                    await ref
                        .read(commerceActionsProvider)
                        .addToCart(
                          widget.slug,
                          variantSku: selectedVariant,
                          sizeCode: requiresOriginalSize ? selectedSize : null,
                        );
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
