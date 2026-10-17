import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kabulfit_brand_logo.dart';
import '../../../core/widgets/kabulfit_bottom_navigation.dart';
import '../../auth/application/auth_controller.dart';
import '../application/measurement_providers.dart';
import 'original_measurement_guide_data.dart';

/// Public guide mirrors the original KabulFit men's/women's step images and
/// localized tutorial videos. Only saving a private profile requires a login.
class MeasurementGuideScreen extends ConsumerStatefulWidget {
  const MeasurementGuideScreen({super.key});

  @override
  ConsumerState<MeasurementGuideScreen> createState() =>
      _MeasurementGuideScreenState();
}

class _MeasurementGuideScreenState
    extends ConsumerState<MeasurementGuideScreen> {
  static const _draftKey = 'kabulfit.original_measurement_draft.v1';
  bool isMale = true;
  bool enteringValues = false;
  bool saving = false;
  int selectedIndex = 0;
  String unit = 'cm';
  final _name = TextEditingController();
  final _values = <String, TextEditingController>{};

  String _copy(String language, String en, String fa, String ps) =>
      switch (language) {
        'fa' => fa,
        'ps' => ps,
        _ => en,
      };

  String get _garmentType => isMale ? 'perahan_tunban' : 'dress';

  List<KabulFitGuideStep> get _steps => isMale
      ? OriginalKabulFitMeasurementGuide.male
      : OriginalKabulFitMeasurementGuide.female;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null || !mounted) return;
    try {
      final draft = jsonDecode(raw);
      if (draft is! Map) return;
      _name.text = draft['name']?.toString() ?? '';
      final measurements = draft['measurements'];
      if (measurements is Map) {
        for (final entry in measurements.entries) {
          _values
              .putIfAbsent(entry.key.toString(), TextEditingController.new)
              .text = entry.value
              .toString();
        }
      }
      setState(() {
        unit = draft['unit'] == 'in' ? 'in' : 'cm';
        isMale = draft['is_male'] != false;
        enteringValues = draft['entering'] == true;
      });
    } catch (_) {
      // Ignore corrupt local draft; never send a partially decoded profile.
    }
  }

  Future<void> _preserveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _draftKey,
      jsonEncode({
        'name': _name.text,
        'unit': unit,
        'is_male': isMale,
        'entering': true,
        'measurements': _values.map((key, value) => MapEntry(key, value.text)),
      }),
    );
  }

  void _changeUnit(String newUnit) {
    if (newUnit == unit) return;
    final fromCm = unit == 'cm';
    for (final controller in _values.values) {
      final number = double.tryParse(controller.text);
      if (number != null) {
        controller.text = (fromCm ? number / 2.54 : number * 2.54)
            .toStringAsFixed(2);
      }
    }
    setState(() => unit = newUnit);
  }

  Future<void> _saveProfile(List<Map<String, dynamic>> definitions) async {
    if (_name.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _copy(
              Localizations.localeOf(context).languageCode,
              'Enter a profile name.',
              'نام پروفایل را وارد کنید.',
              'د پروفایل نوم ولیکئ.',
            ),
          ),
        ),
      );
      return;
    }
    final measurements = <Map<String, dynamic>>[];
    for (final item in definitions) {
      final code = item['code']?.toString() ?? '';
      final raw = _values[_garmentType + '_' + code]?.text.trim() ?? '';
      final parsed = double.tryParse(raw);
      if (raw.isEmpty && item['required'] != true) continue;
      if (parsed == null || !parsed.isFinite || parsed <= 0) {
        _showInvalid(item['name']?.toString() ?? code);
        return;
      }
      final cm = unit == 'in' ? parsed * 2.54 : parsed;
      final minimum = (item['min'] as num?)?.toDouble() ?? 0;
      final maximum = (item['max'] as num?)?.toDouble() ?? double.infinity;
      if (cm < minimum || cm > maximum) {
        _showInvalid(item['name']?.toString() ?? code);
        return;
      }
      measurements.add({'code': code, 'value': cm});
    }
    await _preserveDraft();
    if (!mounted) return;
    if (ref.read(authControllerProvider).value == null) {
      await _promptForAccount();
      return;
    }
    setState(() => saving = true);
    try {
      await ref
          .read(measurementActionsProvider)
          .saveProfile(
            name: _name.text.trim(),
            garmentType: _garmentType,
            measurements: measurements,
          );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
      if (mounted) context.go('/measurements');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showInvalid(String field) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Check measurement: ' + field)));
  }

  Future<void> _promptForAccount() async {
    final language = Localizations.localeOf(context).languageCode;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _copy(
                  language,
                  'Save your measurements',
                  'ذخیره اندازه‌های شما',
                  'خپلې اندازې خوندي کړئ',
                ),
                style: Theme.of(sheet).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                _copy(
                  language,
                  'Your entries are kept on this device. Create an account or sign in to save a reusable measurement profile.',
                  'اندازه‌های شما در این دستگاه نگهداری می‌شود. برای ذخیره پروفایل حساب بسازید یا وارد شوید.',
                  'ستاسې اندازې پر همدې وسیله ساتل کېږي. د پروفایل خوندي کولو لپاره حساب جوړ کړئ یا ننوځئ.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  Navigator.pop(sheet);
                  context.push('/register?next=%2Fmeasurement-guide');
                },
                child: Text(AppLocalizations.of(context).text('createAccount')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(sheet);
                  context.push('/login?next=%2Fmeasurement-guide');
                },
                child: Text(AppLocalizations.of(context).text('signIn')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _watchVideo(String video) async {
    final uri = Uri.tryParse(video);
    if (uri == null ||
        uri.scheme != 'https' ||
        !({'www.youtube.com', 'youtube.com', 'youtu.be'}).contains(uri.host)) {
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open tutorial video.')),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final controller in _values.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final authenticated = ref.watch(authControllerProvider).value != null;
    final guideSteps = _steps;
    final safeIndex = selectedIndex.clamp(0, guideSteps.length - 1);
    final selected = guideSteps[safeIndex];
    final definitions = ref.watch(measurementDefinitionsProvider(_garmentType));
    return Scaffold(
      bottomNavigationBar: const KabulFitBottomNavigation(selectedIndex: 2),
      appBar: AppBar(
        title: const KabulFitBrandLogo(width: 140, height: 48),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).text('myMeasurements'),
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/measurements'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF881C27), Color(0xFF2A6867)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.straighten_outlined,
                  size: 36,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  _copy(
                    language,
                    'Get your perfect measurements',
                    'اندازه‌گیری دقیق',
                    'خپلې دقیقې اندازې واخلئ',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 9),
                Text(
                  _copy(
                    language,
                    'Follow the original KabulFit step-by-step photo and video guide.',
                    'رهنمای تصویری و ویدیویی گام‌به‌گام کابل‌فیت.',
                    'د کابل‌فټ اصلي انځوریز او ویډیويي لارښود.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: true,
                label: Text(_copy(language, 'Men', 'مردانه', 'نارینه')),
                icon: const Icon(Icons.man),
              ),
              ButtonSegment(
                value: false,
                label: Text(_copy(language, 'Women', 'زنانه', 'ښځینه')),
                icon: const Icon(Icons.woman),
              ),
            ],
            selected: {isMale},
            onSelectionChanged: (value) => setState(() {
              isMale = value.first;
              selectedIndex = 0;
            }),
          ),
          const SizedBox(height: 15),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(
                  _copy(
                    language,
                    'How to measure',
                    'چگونه اندازه بگیریم',
                    'څنګه اندازه وکړو',
                  ),
                ),
                icon: const Icon(Icons.menu_book_outlined),
              ),
              ButtonSegment(
                value: true,
                label: Text(
                  _copy(
                    language,
                    'Enter measurements',
                    'ثبت اندازه‌ها',
                    'اندازې ثبت کړئ',
                  ),
                ),
                icon: const Icon(Icons.edit_note),
              ),
            ],
            selected: {enteringValues},
            onSelectionChanged: (value) =>
                setState(() => enteringValues = value.first),
          ),
          const SizedBox(height: 18),
          if (!enteringValues) ...[
            Text(
              _copy(
                language,
                'Body measurements',
                'اندازه‌های بدن',
                'د بدن اندازې',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 13),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: guideSteps.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.6,
              ),
              itemBuilder: (context, index) {
                final active = index == safeIndex;
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    backgroundColor: active
                        ? const Color(0xFF881C27)
                        : Colors.white,
                    foregroundColor: active ? Colors.white : BrandColors.ink,
                  ),
                  onPressed: () => setState(() => selectedIndex = index),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: active
                            ? Colors.white24
                            : BrandColors.cream,
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            color: active ? Colors.white : BrandColors.burgundy,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          guideSteps[index].title(language),
                          style: const TextStyle(fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text(
                      selected.title(language),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          selected.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: BrandColors.cream,
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selected.video(language).isNotEmpty)
                      FilledButton.icon(
                        onPressed: () => _watchVideo(selected.video(language)),
                        icon: const Icon(Icons.play_circle_outline),
                        label: Text(
                          _copy(
                            language,
                            'Watch original tutorial',
                            'تماشای ویدیوی اصلی',
                            'اصلي ویډیو وګورئ',
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: safeIndex > 0
                              ? () => setState(() => selectedIndex--)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          label: Text(
                            _copy(language, 'Previous', 'قبلی', 'مخکې'),
                          ),
                        ),
                        Text(
                          (safeIndex + 1).toString() +
                              ' / ' +
                              guideSteps.length.toString(),
                        ),
                        TextButton.icon(
                          onPressed: safeIndex < guideSteps.length - 1
                              ? () => setState(() => selectedIndex++)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                          label: Text(_copy(language, 'Next', 'بعدی', 'بل')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _copy(
                language,
                'Use a flexible tape, ask someone for help and double-check each measurement.',
                'از متر انعطاف‌پذیر استفاده کنید، کمک بگیرید و هر اندازه را دوباره بررسی کنید.',
                'نرم متر و مرسته وکاروئ او هره اندازه دوه ځله وګورئ.',
              ),
            ),
            const SizedBox(height: 15),
            FilledButton.icon(
              onPressed: () => setState(() => enteringValues = true),
              icon: const Icon(Icons.edit_note),
              label: Text(
                _copy(
                  language,
                  'Enter your measurements',
                  'اندازه‌های خود را وارد کنید',
                  'خپلې اندازې ثبت کړئ',
                ),
              ),
            ),
          ] else ...[
            Text(
              _copy(
                language,
                'Enter your measurements',
                'اندازه‌های خود را وارد کنید',
                'خپلې اندازې ثبت کړئ',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 9),
            Text(
              _copy(
                language,
                'Enter your measurements below. You can browse the guide without an account; saving a profile requires an account.',
                'اندازه‌ها را وارد کنید. مشاهده رهنما بدون حساب ممکن است؛ ذخیره پروفایل نیاز به حساب دارد.',
                'اندازې ولیکئ. لارښود بې حسابه کتلای شئ؛ د پروفایل خوندي کولو لپاره حساب اړین دی.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).text('profileName'),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              key: ValueKey(unit),
              initialValue: unit,
              decoration: InputDecoration(
                labelText: _copy(
                  language,
                  'Measurement unit',
                  'واحد اندازه‌گیری',
                  'د اندازې واحد',
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'cm',
                  child: Text(
                    _copy(language, 'Centimeters', 'سانتی‌متر', 'سانتي متر'),
                  ),
                ),
                DropdownMenuItem(
                  value: 'in',
                  child: Text(_copy(language, 'Inches', 'اینچ', 'انچ')),
                ),
              ],
              onChanged: (v) {
                if (v != null) _changeUnit(v);
              },
            ),
            const SizedBox(height: 16),
            definitions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Column(
                children: [
                  Text(error.toString()),
                  TextButton(
                    onPressed: () => ref.invalidate(
                      measurementDefinitionsProvider(_garmentType),
                    ),
                    child: Text(AppLocalizations.of(context).text('retry')),
                  ),
                ],
              ),
              data: (items) => Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        key: ValueKey(
                          _garmentType + '_' + item['code'].toString(),
                        ),
                        controller: _values.putIfAbsent(
                          _garmentType + '_' + item['code'].toString(),
                          TextEditingController.new,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText:
                              (item['name'] ?? item['code']).toString() +
                              ' (' +
                              unit +
                              ')',
                          helperText: item['instructions']?.toString(),
                          suffixText: item['required'] == true ? '*' : null,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: saving ? null : () => _saveProfile(items),
                    child: Text(
                      saving
                          ? AppLocalizations.of(context).text('saving')
                          : authenticated
                          ? AppLocalizations.of(
                              context,
                            ).text('saveMeasurements')
                          : _copy(
                              language,
                              'Save measurements (sign in)',
                              'ذخیره اندازه‌ها (ورود)',
                              'اندازې خوندي کړئ (ننوتل)',
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!authenticated)
              OutlinedButton(
                onPressed: () async {
                  await _preserveDraft();
                  if (context.mounted) context.push('/register');
                },
                child: Text(AppLocalizations.of(context).text('createAccount')),
              ),
          ],
        ],
      ),
    );
  }
}
