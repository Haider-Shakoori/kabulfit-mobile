import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kabulfit_brand_logo.dart';
import '../../catalog/presentation/catalog_screen.dart';
import 'home_screen.dart';

/// First-install introduction; afterwards opens the real commerce storefront.
class KabulFitLaunchScreen extends StatefulWidget {
  const KabulFitLaunchScreen({super.key});

  @override
  State<KabulFitLaunchScreen> createState() => _KabulFitLaunchScreenState();
}

class _KabulFitLaunchScreenState extends State<KabulFitLaunchScreen> {
  static const completedKey = 'kabulfit_luxury_onboarding_completed_v1';
  bool? completed;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    // Keep the branded startup visible briefly, without blocking longer
    // than necessary for onboarding preferences to load.
    var wasCompleted = false;
    try {
      await Future.wait<void>([
        () async {
          final prefs = await SharedPreferences.getInstance();
          wasCompleted = prefs.getBool(completedKey) ?? false;
        }(),
        Future<void>.delayed(const Duration(milliseconds: 1500)),
      ]);
    } catch (error) {
      debugPrint('Unable to restore KabulFit onboarding state: $error');
    }
    if (mounted) {
      setState(() => completed = wasCompleted);
    }
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(completedKey, true);
    if (mounted) setState(() => completed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (completed == null) {
      return const KabulFitPreloader();
    }
    return completed!
        ? const HomeScreen()
        : _LuxuryOnboarding(onContinue: _complete);
  }
}

/// A lightweight, offline-safe branded startup screen. This is not the
/// first-install onboarding flow, which still appears only on first launch.
class KabulFitPreloader extends StatelessWidget {
  const KabulFitPreloader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.warmWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.86, end: 1.0),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(scale: value, child: child),
                ),
                child: const KabulFitBrandLogo(width: 260, height: 110),
              ),
              const SizedBox(height: 22),
              const Text(
                'TIMELESS ELEGANCE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: BrandColors.burgundy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(
                width: 84,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: BrandColors.gold,
                  backgroundColor: BrandColors.champagne,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onboarding photography comes from original Base44 products via Laravel.
class _LuxuryOnboarding extends ConsumerStatefulWidget {
  const _LuxuryOnboarding({required this.onContinue});
  final Future<void> Function() onContinue;

  @override
  ConsumerState<_LuxuryOnboarding> createState() => _LuxuryOnboardingState();
}

class _LuxuryOnboardingState extends ConsumerState<_LuxuryOnboarding> {
  final controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String _copy(String language, String en, String fa, String ps) =>
      switch (language) {
        'fa' => fa,
        'ps' => ps,
        _ => en,
      };

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(catalogProvider).value ?? const <KabulProduct>[];
    final photos = products
        .where((p) => p.imageUrl != null && p.imageUrl!.isNotEmpty)
        .take(3)
        .map((p) => p.imageUrl!)
        .toList(growable: false);
    final locale = Localizations.localeOf(context).languageCode;
    final headlines = [
      _copy(
        locale,
        'Tradition woven\nfor your story',
        'اصالت و زیبایی\nبرای داستان شما',
        'ستاسو د کیسې لپاره\nدودیزه ښکلا',
      ),
      _copy(
        locale,
        'Discover Afghan\nelegance',
        'زیبایی اصیل\nافغانی',
        'اصیله افغاني\nښکلا',
      ),
      _copy(
        locale,
        'Perfectly fitted\nfor you',
        'دوخت ویژه\nبرای شما',
        'ستاسو لپاره\nځانګړې ګنډنه',
      ),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller,
            itemCount: headlines.length,
            onPageChanged: (page) => setState(() => currentPage = page),
            itemBuilder: (context, index) => Stack(
              fit: StackFit.expand,
              children: [
                if (photos.isNotEmpty)
                  Image.network(
                    photos[index % photos.length],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: BrandColors.deepBurgundy),
                  )
                else
                  const ColoredBox(color: BrandColors.deepBurgundy),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x404B1528),
                        Color(0x8050182A),
                        Color(0xE94B1528),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 25),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  const KabulFitBrandLogo(white: true, width: 260, height: 110),
                  const SizedBox(height: 12),
                  Text(
                    _copy(
                      locale,
                      'TRADITIONAL ELEGANCE · MODERN STYLE',
                      'زیبایی سنتی · سبک مدرن',
                      'دودیزه ښکلا · عصري بڼه',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: BrandColors.champagne,
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(flex: 4),
                  Text(
                    headlines[currentPage],
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 25,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < headlines.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 5,
                          width: currentPage == i ? 23 : 7,
                          decoration: BoxDecoration(
                            color: currentPage == i
                                ? Colors.white
                                : BrandColors.champagne.withValues(alpha: .5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: BrandColors.warmWhite,
                        foregroundColor: BrandColors.deepBurgundy,
                      ),
                      onPressed: currentPage == headlines.length - 1
                          ? widget.onContinue
                          : () => controller.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOut,
                            ),
                      label: Text(
                        currentPage == headlines.length - 1
                            ? _copy(
                                locale,
                                'Get started',
                                'شروع کنید',
                                'پیل کړئ',
                              )
                            : _copy(locale, 'Continue', 'ادامه', 'دوام'),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.onContinue,
                    child: Text(
                      AppLocalizations.of(context).text('shop'),
                      style: const TextStyle(color: BrandColors.champagne),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
