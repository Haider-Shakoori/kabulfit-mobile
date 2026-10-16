import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../../catalog/presentation/catalog_screen.dart';
import '../application/measurement_providers.dart';

class TailorProductScreen extends ConsumerStatefulWidget {
  const TailorProductScreen({required this.slug, super.key});
  final String slug;
  @override
  ConsumerState<TailorProductScreen> createState() =>
      _TailorProductScreenState();
}

class _TailorProductScreenState extends ConsumerState<TailorProductScreen> {
  String? profileUuid;
  String? variantSku;
  bool saving = false;
  final notes = TextEditingController();

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(authControllerProvider).value == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Custom tailoring')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: const Text('Sign in to customize your garment'),
          ),
        ),
      );
    }
    final product = ref.watch(productProvider(widget.slug));
    final profiles = ref.watch(measurementProfilesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Customize garment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          product.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => TextButton(
              onPressed: () => ref.invalidate(productProvider(widget.slug)),
              child: Text('Retry product: $e'),
            ),
            data: (item) {
              if (item['tailoring_enabled'] != true) {
                return const Text(
                  'Custom tailoring is not available for this product.',
                );
              }
              final tailoring = item['tailoring'];
              final garmentType = tailoring is Map
                  ? tailoring['garment_type']?.toString()
                  : null;
              final variants =
                  (item['variants'] as List?)
                      ?.whereType<Map<String, dynamic>>()
                      .where((v) => (v['stock'] as Map?)?['in_stock'] == true)
                      .toList() ??
                  [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item['name']?.toString() ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Measurement profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  profiles.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => TextButton(
                      onPressed: () =>
                          ref.invalidate(measurementProfilesProvider),
                      child: Text('Retry profiles: $e'),
                    ),
                    data: (items) {
                      final suitable = items
                          .where(
                            (p) =>
                                garmentType == null ||
                                p['garment_type'] == garmentType,
                          )
                          .toList();
                      if (suitable.isEmpty) {
                        return TextButton(
                          onPressed: () => context.push('/measurements/new'),
                          child: const Text(
                            'Create a measurement profile for this garment',
                          ),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        initialValue:
                            suitable.any((p) => p['uuid'] == profileUuid)
                            ? profileUuid
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Saved measurements',
                        ),
                        items: suitable
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p['uuid'].toString(),
                                child: Text(p['name']?.toString() ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: saving
                            ? null
                            : (v) => setState(() => profileUuid = v),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (variants.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: variants.any((v) => v['sku'] == variantSku)
                          ? variantSku
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Size / color',
                      ),
                      items: variants
                          .map(
                            (v) => DropdownMenuItem<String>(
                              value: v['sku'].toString(),
                              child: Text(
                                [
                                      v['size']?.toString() ?? '',
                                      (v['color'] as Map?)?['name']
                                              ?.toString() ??
                                          '',
                                    ]
                                    .where((value) => value.isNotEmpty)
                                    .join(' · '),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: saving
                          ? null
                          : (v) => setState(() => variantSku = v),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notes,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      labelText: 'Instructions for your tailor',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed:
                        saving ||
                            !profiles.hasValue ||
                            profileUuid == null ||
                            (variants.isNotEmpty && variantSku == null)
                        ? null
                        : () async {
                            setState(() => saving = true);
                            try {
                              await ref
                                  .read(measurementActionsProvider)
                                  .addTailoringToCart(
                                    productSlug: widget.slug,
                                    profileUuid: profileUuid!,
                                    variantSku: variantSku,
                                    notes: notes.text.trim(),
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Customized garment added to cart',
                                    ),
                                  ),
                                );
                                context.go('/cart');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => saving = false);
                            }
                          },
                    child: Text(
                      saving
                          ? 'Adding garment…'
                          : 'Add customized garment to cart',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
