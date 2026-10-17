import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/kabulfit_bottom_navigation.dart';
import '../../../core/theme/app_theme.dart';
import 'measurement_figure.dart';
import '../../auth/application/auth_controller.dart';
import '../application/measurement_providers.dart';

class MeasurementProfilesScreen extends ConsumerWidget {
  const MeasurementProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authControllerProvider).value == null) {
      return Scaffold(
        bottomNavigationBar: const KabulFitBottomNavigation(selectedIndex: 2),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).text('measurements')),
        ),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: Text(
              AppLocalizations.of(context).text('signInMeasurements'),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      bottomNavigationBar: const KabulFitBottomNavigation(selectedIndex: 2),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).text('myMeasurements')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/measurements/new'),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).text('newProfile')),
      ),
      body: ref
          .watch(measurementProfilesProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(measurementProfilesProvider),
                child: Text('Retry: $error'),
              ),
            ),
            data: (profiles) => profiles.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).text('emptyProfiles'),
                    ),
                  )
                : ListView.builder(
                    itemCount: profiles.length,
                    itemBuilder: (context, i) {
                      final profile = profiles[i];
                      return _MeasurementProfileCard(
                        profile: profile,
                        menu: PopupMenuButton<String>(
                          onSelected: (choice) async {
                            final uuid = profile['uuid']?.toString();
                            if (uuid == null) return;
                            if (choice == 'edit') {
                              context.push(
                                '/measurements/edit',
                                extra: profile,
                              );
                            } else if (choice == 'delete') {
                              final yes = await showDialog<bool>(
                                context: context,
                                builder: (dialog) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).text('deleteProfileConfirm'),
                                  ),
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).text('cannotUndo'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialog, false),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).text('cancel'),
                                      ),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(dialog, true),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).text('delete'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (yes != true) return;
                              try {
                                await ref
                                    .read(measurementActionsProvider)
                                    .deleteProfile(uuid);
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                AppLocalizations.of(context).text('edit'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                AppLocalizations.of(context).text('delete'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
    );
  }
}

class NewMeasurementProfileScreen extends ConsumerStatefulWidget {
  const NewMeasurementProfileScreen({this.existing, super.key});
  final Map<String, dynamic>? existing;
  @override
  ConsumerState<NewMeasurementProfileScreen> createState() =>
      _NewMeasurementProfileScreenState();
}

class _NewMeasurementProfileScreenState
    extends ConsumerState<NewMeasurementProfileScreen> {
  static String _existingCm(Object? value, Object? unit) {
    final numeric = double.tryParse(value?.toString() ?? '');
    if (numeric == null) return '';
    return (unit == 'in' ? numeric * 2.54 : numeric).toStringAsFixed(2);
  }

  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final values = <String, TextEditingController>{};
  String garmentType = garmentTypes.first;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      name.text = existing['name']?.toString() ?? '';
      final type = existing['garment_type']?.toString();
      if (type != null && garmentTypes.contains(type)) garmentType = type;
      for (final m in (existing['measurements'] as List? ?? [])) {
        if (m is! Map) continue;
        final code = m['code']?.toString();
        if (code == null) continue;
        values['${garmentType}_$code'] = TextEditingController(
          text: _existingCm(m['value'], existing['display_unit']),
        );
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    for (final controller in values.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final definitions = ref.watch(measurementDefinitionsProvider(garmentType));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null
              ? AppLocalizations.of(context).text('newMeasurement')
              : AppLocalizations.of(context).text('editMeasurement'),
        ),
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: name,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).text('profileName'),
              ),
              validator: (s) => (s == null || s.trim().isEmpty)
                  ? AppLocalizations.of(context).text('required')
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: garmentType,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).text('garmentType'),
              ),
              items: garmentTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.replaceAll('_', ' ')),
                    ),
                  )
                  .toList(),
              onChanged: saving
                  ? null
                  : (v) {
                      if (v != null) setState(() => garmentType = v);
                    },
            ),
            const SizedBox(height: 20),
            definitions.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => TextButton(
                onPressed: () =>
                    ref.invalidate(measurementDefinitionsProvider(garmentType)),
                child: Text('Retry definitions: $error'),
              ),
              data: (items) => Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        key: ValueKey('${garmentType}_${item['code']}'),
                        controller: values.putIfAbsent(
                          '${garmentType}_${item['code']}',
                          TextEditingController.new,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: '${item['name'] ?? item['code']} (cm)',
                          helperText: item['instructions']?.toString(),
                        ),
                        validator: (raw) {
                          if ((raw == null || raw.trim().isEmpty) &&
                              item['required'] != true) {
                            return null;
                          }
                          final number = double.tryParse(raw?.trim() ?? '');
                          final min = (item['min'] as num?)?.toDouble() ?? 0;
                          final max =
                              (item['max'] as num?)?.toDouble() ??
                              double.infinity;
                          return number == null || number < min || number > max
                              ? 'Enter a value between $min and $max cm'
                              : null;
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving || !definitions.hasValue
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      final measurements = <Map<String, dynamic>>[];
                      for (final item in definitions.value!) {
                        final code = item['code'].toString();
                        final raw = values['${garmentType}_$code']?.text.trim();
                        if (raw == null || raw.isEmpty) continue;
                        measurements.add({
                          'code': code,
                          'value': double.parse(raw),
                        });
                      }
                      setState(() => saving = true);
                      try {
                        await ref
                            .read(measurementActionsProvider)
                            .saveProfile(
                              name: name.text.trim(),
                              garmentType: garmentType,
                              measurements: measurements,
                              profileUuid: widget.existing?['uuid']?.toString(),
                              isDefault: widget.existing?['is_default'] == true,
                            );
                        if (context.mounted) context.pop();
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => saving = false);
                      }
                    },
              child: Text(
                saving
                    ? AppLocalizations.of(context).text('saving')
                    : AppLocalizations.of(context).text('saveMeasurements'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TailoringRequestsScreen extends ConsumerWidget {
  const TailoringRequestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context).text('myTailoring')),
    ),
    body: ref
        .watch(tailoringRequestsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(tailoringRequestsProvider),
              child: Text('Retry: $e'),
            ),
          ),
          data: (requests) => requests.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context).text('emptyTailoring'),
                  ),
                )
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, i) {
                    final item = requests[i];
                    final product = item['product'];
                    final order = item['order'];
                    return ListTile(
                      title: Text(
                        product is Map ? product['name']?.toString() ?? '' : '',
                      ),
                      subtitle: Text(
                        'Status: ${item['status']} · Profile: ${(item['measurement_profile'] as Map?)?['name'] ?? ''}',
                      ),
                      trailing: order is Map
                          ? Text(order['number']?.toString() ?? '')
                          : null,
                    );
                  },
                ),
        ),
  );
}

class _MeasurementProfileCard extends StatelessWidget {
  const _MeasurementProfileCard({
    required this.profile,
    required this.menu,
  });

  final Map<String, dynamic> profile;
  final Widget menu;

  @override
  Widget build(BuildContext context) {
    final list = (profile['measurements'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];
    final unit = profile['display_unit'] == 'in' ? 'in' : 'cm';
    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      child: ExpansionTile(
        initiallyExpanded: profile['is_default'] == true,
        leading: const CircleAvatar(
          backgroundColor: BrandColors.cream,
          child: Icon(Icons.accessibility_new_outlined, color: BrandColors.burgundy),
        ),
        title: Text(
          profile['name']?.toString() ?? '',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          (profile['garment_type']?.toString() ?? '').replaceAll('_', ' '),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: menu,
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          if (list.isEmpty)
            Text(AppLocalizations.of(context).text('emptyProfiles'))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MeasurementFigure(height: 210),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      for (final value in list)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  value['name']?.toString() ??
                                      value['code']?.toString() ?? '',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${value['value'] ?? '—'} $unit',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: BrandColors.deepBurgundy,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () => context.push(
              '/measurements/edit',
              extra: profile,
            ),
            icon: const Icon(Icons.edit_outlined),
            label: Text(AppLocalizations.of(context).text('editMeasurement')),
          ),
        ],
      ),
    );
  }
}
