import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/providers.dart';

/// These products are loaded from Laravel, never from hard-coded demo data.
final catalogProvider = FutureProvider<List<KabulProduct>>((ref) async {
  final response = await ref.watch(apiClientProvider).get('/catalog');
  final items = response['data'];
  if (items is! List) throw const FormatException('Invalid catalog response');
  return items
      .whereType<Map<String, dynamic>>()
      .map(KabulProduct.fromJson)
      .where((product) => product.slug.isNotEmpty)
      .toList(growable: false);
});

class KabulProduct {
  const KabulProduct({
    required this.slug,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.inStock,
    required this.description,
  });

  final String slug;
  final String name;
  final String price;
  final String? imageUrl;
  final String category;
  final bool inStock;
  final String description;

  factory KabulProduct.fromJson(Map<String, dynamic> json) {
    final price = json['price'];
    final media = json['primary_media'];
    final stock = json['stock'];
    final category = json['category'];
    return KabulProduct(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: price is Map ? price['formatted']?.toString() ?? '' : '',
      imageUrl: media is Map ? media['url']?.toString() : null,
      category: category is Map ? category['name']?.toString() ?? '' : '',
      inStock: stock is Map && stock['in_stock'] == true,
      description: json['short_description']?.toString() ?? '',
    );
  }
}

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final shop = switch (locale) {
      'fa' => 'فروشگاه',
      'ps' => 'پلورنځی',
      _ => 'Shop the collection',
    };
    final result = ref.watch(catalogProvider);
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
                  hintText: switch (locale) {
                    'fa' => 'جستجوی محصولات',
                    'ps' => 'محصولات ولټوئ',
                    _ => 'Search products',
                  },
                  onChanged: (value) => setState(() => query = value),
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
                      const Text('Unable to load products'),
                      TextButton(
                        onPressed: () => ref.invalidate(catalogProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (products) {
                final visible = products.where((product) =>
                    product.name.toLowerCase().contains(query.toLowerCase()) ||
                    product.category.toLowerCase().contains(query.toLowerCase())).toList();
                if (visible.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No matching products')),
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
                              onTap: () => context.push('/products/${Uri.encodeComponent(product.slug)}'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: product.imageUrl == null
                                          ? const Icon(Icons.checkroom, size: 48)
                                          : Image.network(
                                              product.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(Icons.broken_image_outlined),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.category,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.labelSmall),
                                        Text(product.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleSmall),
                                        Text(product.price,
                                            style: Theme.of(context).textTheme.labelLarge),
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

final productProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final response = await ref.watch(apiClientProvider).get('/products/${Uri.encodeComponent(slug)}');
  final data = response['data'];
  if (data is! Map<String, dynamic>) throw const FormatException('Invalid product response');
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
        error: (_, _) => Center(child: TextButton(
          onPressed: () => ref.invalidate(productProvider(slug)),
          child: const Text('Retry loading product'),
        )),
        data: (data) {
          final images = data['media'];
          final primary = data['primary_media'];
          final imageUrl = images is List && images.isNotEmpty && images.first is Map
              ? (images.first as Map)['url']?.toString()
              : primary is Map ? primary['url']?.toString() : null;
          final price = data['price'];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: imageUrl == null
                    ? const Icon(Icons.checkroom, size: 80)
                    : Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined)),
              ),
              const SizedBox(height: 24),
              Text(data['name']?.toString() ?? '',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(price is Map ? price['formatted']?.toString() ?? '' : '',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text(data['description']?.toString() ?? ''),
              const SizedBox(height: 24),
              if (data['tailoring_enabled'] == true)
                const Chip(label: Text('Custom tailoring available')),
              const SizedBox(height: 12),
              const Text('Choose your options and sign in to order.'),
              FilledButton(
                onPressed: () => context.push('/login'),
                child: const Text('Sign in to shop'),
              ),
            ],
          );
        },
      ),
    );
  }
}
