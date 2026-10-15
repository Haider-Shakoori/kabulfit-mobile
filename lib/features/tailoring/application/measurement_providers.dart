import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/providers.dart';
import '../../commerce/application/commerce_providers.dart';

const garmentTypes = ['perahan_tunban', 'dress', 'waistcoat'];

final measurementProfilesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await ref.watch(apiClientProvider).get('/measurement-profiles');
  final data = response['data'];
  if (data is! List) throw const FormatException('Invalid profiles response');
  return data.whereType<Map<String, dynamic>>().toList();
});

final measurementDefinitionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, garmentType) async {
  if (!garmentTypes.contains(garmentType)) throw ArgumentError.value(garmentType);
  final response = await ref.watch(apiClientProvider)
      .get('/measurements/definitions?garment_type=$garmentType&unit=cm');
  final data = response['data'];
  if (data is! List) throw const FormatException('Invalid definitions response');
  return data.whereType<Map<String, dynamic>>().toList();
});

final tailoringRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await ref.watch(apiClientProvider).get('/tailoring');
  final data = response['data'];
  if (data is! List) throw const FormatException('Invalid tailoring response');
  return data.whereType<Map<String, dynamic>>().toList();
});

class MeasurementActions {
  const MeasurementActions(this.ref);
  final Ref ref;

  Future<void> saveProfile({
    required String name,
    required String garmentType,
    required List<Map<String, dynamic>> measurements,
    bool isDefault = false,
  }) async {
    if (!garmentTypes.contains(garmentType)) throw ArgumentError.value(garmentType);
    await ref.read(apiClientProvider).post('/measurement-profiles', data: {
      'name': name,
      'garment_type': garmentType,
      'display_unit': 'cm',
      'is_default': isDefault,
      'measurements': measurements,
    });
    ref.invalidate(measurementProfilesProvider);
  }

  Future<void> addTailoringToCart({
    required String productSlug,
    required String profileUuid,
    String? variantSku,
    String? notes,
  }) async {
    await ref.read(apiClientProvider).post('/tailoring', data: {
      'product_slug': productSlug,
      'measurement_profile_uuid': profileUuid,
      if (variantSku != null) 'variant_sku': variantSku,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    ref.invalidate(tailoringRequestsProvider);
    ref.invalidate(cartProvider);
  }
}
final measurementActionsProvider =
    Provider<MeasurementActions>((ref) => MeasurementActions(ref));
