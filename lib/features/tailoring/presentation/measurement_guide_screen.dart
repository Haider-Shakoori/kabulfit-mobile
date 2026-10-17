import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../catalog/presentation/catalog_screen.dart';

/// Step-by-step measurement education inspired by the approved visual guide.
/// Shows honest written directions until KabulFit has verified tutorial videos.
class MeasurementGuideScreen extends ConsumerWidget {
  const MeasurementGuideScreen({super.key});

  String _copy(String language, String en, String fa, String ps) =>
      switch (language) {
        'fa' => fa,
        'ps' => ps,
        _ => en,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final products = ref.watch(catalogProvider).value ?? const <KabulProduct>[];
    final photo = products
        .where((p) => p.imageUrl != null)
        .firstOrNull
        ?.imageUrl;
    final sections = [
      (
        icon: Icons.face_outlined,
        title: _copy(locale, 'Neck', 'گردن', 'غاړه'),
        detail: _copy(
          locale,
          'Measure gently around the base of your neck. Keep the tape level and allow comfortable breathing.',
          'دور پایه گردن را اندازه بگیرید. متر را صاف و بدون فشار نگه دارید.',
          'د غاړې د بېخ چاپېره اندازه واخلئ. متر نېغ او لږ نرم وساتئ.',
        ),
      ),
      (
        icon: Icons.accessibility_new_outlined,
        title: _copy(locale, 'Shoulder', 'شانه', 'اوږه'),
        detail: _copy(
          locale,
          'Measure from one shoulder tip to the other across your back.',
          'از سر یک شانه تا سر شانه دیگر از پشت اندازه بگیرید.',
          'له یوې اوږې تر بلې اوږې پورې د شا له لوري اندازه واخلئ.',
        ),
      ),
      (
        icon: Icons.straighten_outlined,
        title: _copy(locale, 'Chest / Bust', 'سینه', 'سینه'),
        detail: _copy(
          locale,
          'Wrap the tape around the fullest part of your chest, parallel to the floor.',
          'متر را دور پهن‌ترین قسمت سینه، موازی با زمین بپیچید.',
          'متر د سینې تر ټولو پلنې برخې چاپېره نېغ تاو کړئ.',
        ),
      ),
      (
        icon: Icons.checkroom_outlined,
        title: _copy(locale, 'Waist', 'کمر', 'ملا'),
        detail: _copy(
          locale,
          'Measure your natural waistline without pulling the tape tight.',
          'دور باریک‌ترین بخش کمر را بدون کشیدن متر اندازه بگیرید.',
          'د ملا طبیعي نرۍ برخه په نرم متر اندازه کړئ.',
        ),
      ),
      (
        icon: Icons.accessibility_outlined,
        title: _copy(locale, 'Hip', 'باسن', 'کوناټي'),
        detail: _copy(
          locale,
          'Measure around the fullest part of your hips while standing straight.',
          'ایستاده دور پهن‌ترین قسمت باسن را اندازه بگیرید.',
          'په نېغه ولاړه د کوناټو تر ټولو پلنه برخه اندازه کړئ.',
        ),
      ),
      (
        icon: Icons.pan_tool_alt_outlined,
        title: _copy(locale, 'Sleeve length', 'طول آستین', 'د لستوڼي اوږدوالی'),
        detail: _copy(
          locale,
          'Bend your arm slightly; measure from shoulder tip to wrist along your arm.',
          'دست را کمی خم کنید و از شانه تا مچ اندازه بگیرید.',
          'لاس لږ کوږ کړئ او له اوږې تر مړوند اندازه واخلئ.',
        ),
      ),
      (
        icon: Icons.height_rounded,
        title: _copy(locale, 'Garment length', 'طول لباس', 'د جامو اوږدوالی'),
        detail: _copy(
          locale,
          'Measure vertically from the high shoulder point to your preferred garment hem.',
          'از بالای شانه تا قد دلخواه لباس به صورت عمودی اندازه بگیرید.',
          'له اوږې څخه د جامو تر خوښې اوږدوالي پورې اندازه واخلئ.',
        ),
      ),
    ];
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _copy(
              locale,
              'Measurement guide',
              'رهنمای اندازه‌گیری',
              'د اندازې لارښود',
            ),
          ),
          bottom: TabBar(
            indicatorColor: BrandColors.burgundy,
            labelColor: BrandColors.burgundy,
            tabs: [
              Tab(text: _copy(locale, 'Women', 'زنانه', 'ښځې')),
              Tab(text: _copy(locale, 'Men', 'مردانه', 'نارینه')),
              Tab(text: _copy(locale, 'Kids', 'اطفال', 'ماشومان')),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 25),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (photo == null)
                      const ColoredBox(color: BrandColors.deepBurgundy)
                    else
                      Image.network(
                        photo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: BrandColors.deepBurgundy),
                      ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xF04B1528), Color(0x554B1528)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _copy(
                            locale,
                            'Get the\nperfect fit',
                            'اندازه‌گیری\nدقیق',
                            'سمه\nاندازه',
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'serif',
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 19),
            Text(
              _copy(
                locale,
                'Follow each step and keep the tape comfortably snug.',
                'هر مرحله را دنبال کنید و متر را مناسب نگه دارید.',
                'هر ګام تعقیب کړئ او متر په ارام ډول ونیسئ.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 13),
            for (final step in sections)
              Card(
                margin: const EdgeInsets.only(bottom: 11),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: BrandColors.cream,
                    child: Icon(step.icon, color: BrandColors.burgundy),
                  ),
                  title: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    _copy(
                      locale,
                      'View instructions',
                      'مشاهده رهنما',
                      'لارښوونې وګورئ',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(19, 0, 19, 18),
                  children: [
                    Text(
                      step.detail,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push('/measurements'),
              icon: const Icon(Icons.straighten),
              label: Text(AppLocalizations.of(context).text('myMeasurements')),
            ),
          ],
        ),
      ),
    );
  }
}
