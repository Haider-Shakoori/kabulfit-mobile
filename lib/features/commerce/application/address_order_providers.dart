import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';

final addressesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final result = await ref.watch(apiClientProvider).get('/account/addresses');
  final items = result['data'];
  if (items is! List) throw const FormatException('Invalid addresses response');
  return items.whereType<Map<String, dynamic>>().toList();
});

final ordersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.watch(apiClientProvider).get('/orders');
  final items = result['data'];
  if (items is! List) throw const FormatException('Invalid orders response');
  return items.whereType<Map<String, dynamic>>().toList();
});

final orderTrackingProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, uuid) async {
      final result = await ref
          .watch(apiClientProvider)
          .get('/orders/${Uri.encodeComponent(uuid)}/tracking');
      final data = result['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid tracking response');
      }
      return data;
    });

class AddressActions {
  const AddressActions(this.ref);
  final Ref ref;

  Future<void> add({
    required String recipient,
    required String phone,
    required String city,
    required String street,
    String country = 'AF',
  }) async {
    await ref
        .read(apiClientProvider)
        .post(
          '/account/addresses',
          data: {
            'recipient_name': recipient,
            'phone': phone,
            'country_code': country,
            'city': city,
            'address_line1': street,
          },
        );
    ref.invalidate(addressesProvider);
  }

  Future<void> remove(String uuid) async {
    await ref
        .read(apiClientProvider)
        .delete('/account/addresses/${Uri.encodeComponent(uuid)}');
    ref.invalidate(addressesProvider);
  }
}

final addressActionsProvider = Provider<AddressActions>(
  (ref) => AddressActions(ref),
);
