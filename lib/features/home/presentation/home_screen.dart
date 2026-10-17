import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kabulfit_bottom_navigation.dart';
import '../../auth/application/auth_controller.dart';
import '../../catalog/presentation/catalog_screen.dart';

/// Editorial home screen of the approved KabulFit luxury-fashion showcase.
/// Every image and category is fetched from Laravel, never hardcoded stock.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _copy(String language, String en, String fa, String ps) =>
      switch (language) {
        'fa' => fa,
        'ps' => ps,
        _ => en,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final session = ref.watch(authControllerProvider).value;
    final catalog = ref.watch(catalogProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KABULFIT'),
        leading: IconButton(
          tooltip: strings.text('shop'),
          icon: const Icon(Icons.grid_view_rounded),
          onPressed: () => context.go('/shop'),
        ),
        actions: [
          IconButton(
            tooltip: strings.text('wishlist'),
            onPressed: () => context.push('/wishlist'),
            icon: const Icon(Icons.favorite_border_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: strings.text('language'),
            icon: const Icon(Icons.language_rounded),
            onSelected: (language) =>
                ref.read(appLocaleProvider.notifier).change(language),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'fa', child: Text('دری')),
              PopupMenuItem(value: 'ps', child: Text('پښتو')),
            ],
          ),
          PopupMenuButton<String>(
            tooltip: strings.text('account'),
            icon: const Icon(Icons.person_outline_rounded),
            onSelected: (route) {
              if (route == 'signOut') {
                ref.read(authControllerProvider.notifier).signOut();
              } else {
                context.push(route);
              }
            },
            itemBuilder: (_) => [
              if (session == null)
                PopupMenuItem(
                  value: '/login',
                  child: Text(strings.text('signIn')),
                ),
              PopupMenuItem(
                value: '/orders',
                child: Text(strings.text('orders')),
              ),
              PopupMenuItem(
                value: '/addresses',
                child: Text(strings.text('addresses')),
              ),
              PopupMenuItem(
                value: '/measurements',
                child: Text(strings.text('measurements')),
              ),
              PopupMenuItem(
                value: '/tailoring',
                child: Text(strings.text('tailoring')),
              ),
              if (session != null)
                const PopupMenuItem(value: 'signOut', child: Text('Sign out')),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          await ref.refresh(catalogProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
              color: BrandColors.cream,
              child: Center(
                child: Text(
                  _copy(
                    locale,
                    'TIMELESS AFGHAN ELEGANCE',
                    'زیبایی ماندگار افغانی',
                    'تلپاتې افغاني ښکلا',
                  ),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.burgundy,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () => context.go('/shop'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: BrandColors.cream,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: BrandColors.mutedInk,
                        size: 21,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        strings.text('searchProducts'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: catalog.when(
                loading: () => const SizedBox(
                  height: 238,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => SizedBox(
                  height: 240,
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => ref.invalidate(catalogProvider),
                      icon: const Icon(Icons.refresh),
                      label: Text(strings.text('retry')),
                    ),
                  ),
                ),
                data: (products) => _EditorialHero(
                  imageUrl: products.isEmpty ? null : products.first.imageUrl,
                  eyebrow: _copy(
                    locale,
                    'THE KABULFIT COLLECTION',
                    'مجموعه کابل‌فیت',
                    'د کابل فټ ټولګه',
                  ),
                  headline: _copy(
                    locale,
                    'Elegance rooted\nin tradition',
                    'زیبایی ریشه‌دار\nدر اصالت',
                    'ښکلا چې له\nدودونو راټوکېږي',
                  ),
                  caption: _copy(
                    locale,
                    'Discover authentic style, thoughtfully made.',
                    'پوشاک اصیل را با ظرافت کشف کنید.',
                    'اصیل لباسونه او ځانګړی هنر ومومئ.',
                  ),
                  onExplore: () => context.go('/shop'),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _SectionHeading(
              eyebrow: _copy(
                locale,
                'FIND YOUR STYLE',
                'سبک خود را بیابید',
                'خپل سټایل ومومئ',
              ),
              title: _copy(
                locale,
                'Shop by category',
                'خرید بر اساس دسته‌بندی',
                'د کټګورۍ له مخې پیرود',
              ),
              onAll: () => context.go('/shop'),
              allLabel: strings.text('shop'),
            ),
            const SizedBox(height: 14),
            categories.when(
              loading: () => const SizedBox(height: 120),
              error: (_, _) => const SizedBox.shrink(),
              data: (items) => items.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 118,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final category = items[index];
                          final name = category['name']?.toString() ?? '';
                          final slug = category['slug']?.toString() ?? '';
                          final photos =
                              catalog.value ?? const <KabulProduct>[];
                          KabulProduct? sample;
                          for (final product in photos) {
                            if (product.categorySlug == slug &&
                                product.imageUrl != null) {
                              sample = product;
                              break;
                            }
                          }
                          return SizedBox(
                            width: 75,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(13),
                              onTap: () => context.go('/shop?category=${Uri.encodeQueryComponent(slug)}'),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: BrandColors.champagne,
                                    backgroundImage: sample?.imageUrl == null
                                        ? null
                                        : NetworkImage(sample!.imageUrl!),
                                    child: sample?.imageUrl == null
                                        ? const Icon(
                                            Icons.checkroom_outlined,
                                            color: BrandColors.burgundy,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: BrandColors.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            _SectionHeading(
              eyebrow: _copy(
                locale,
                'DISCOVER MORE',
                'بیشتر کشف کنید',
                'نور ومومئ',
              ),
              title: _copy(
                locale,
                'The collection',
                'مجموعه لباس‌ها',
                'د جامو ټولګه',
              ),
              onAll: () => context.go('/shop'),
              allLabel: strings.text('shop'),
            ),
            const SizedBox(height: 16),
            catalog.when(
              loading: () => const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (products) => products.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 306,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length > 8 ? 8 : products.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) =>
                            _EditorialProductCard(product: products[index]),
                      ),
                    ),
            ),
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: BrandColors.cream,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: BrandColors.champagne),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.straighten_rounded,
                        color: BrandColors.burgundy,
                        size: 30,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _copy(
                          locale,
                          'Tailored for you',
                          'دوخت ویژه برای شما',
                          'ستاسو لپاره ځانګړې ګنډنه',
                        ),
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _copy(
                          locale,
                          'Save your measurements for a personalized fit.',
                          'اندازه‌های خود را برای دوخت اختصاصی ثبت کنید.',
                          'خپلې اندازې د ځانګړې ګنډنې لپاره ثبت کړئ.',
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/measurements'),
                        icon: const Icon(Icons.straighten),
                        label: Text(strings.text('measurements')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const KabulFitBottomNavigation(selectedIndex: 0),
    );
  }
}

class _EditorialHero extends StatelessWidget {
  const _EditorialHero({
    required this.imageUrl,
    required this.eyebrow,
    required this.headline,
    required this.caption,
    required this.onExplore,
  });
  final String? imageUrl;
  final String eyebrow;
  final String headline;
  final String caption;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        height: 238,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: BrandColors.deepBurgundy),
              )
            else
              const ColoredBox(color: BrandColors.deepBurgundy),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x2B1B0810),
                    Color(0xC64B1528),
                    Color(0xF24B1528),
                  ],
                  stops: [0, .48, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: const TextStyle(
                      color: BrandColors.champagne,
                      fontSize: 10,
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    headline,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.08,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    caption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 145,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: BrandColors.warmWhite,
                        foregroundColor: BrandColors.deepBurgundy,
                      ),
                      onPressed: onExplore,
                      label: Text(AppLocalizations.of(context).text('shop')),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    ),
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.onAll,
    required this.allLabel,
  });
  final String eyebrow;
  final String title;
  final VoidCallback onAll;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.gold,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          TextButton(
            onPressed: onAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(allLabel),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialProductCard extends StatelessWidget {
  const _EditorialProductCard({required this.product});
  final KabulProduct product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 188,
      child: Card(
        child: InkWell(
          onTap: () =>
              context.push('/products/${Uri.encodeComponent(product.slug)}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: product.imageUrl == null
                      ? const ColoredBox(
                          color: BrandColors.cream,
                          child: Icon(Icons.checkroom_outlined),
                        )
                      : Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: BrandColors.cream,
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BrandColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: BrandColors.burgundy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
