import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/providers.dart';
import 'commerce_providers.dart';
import 'address_order_providers.dart';

final shippingMethodsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await ref.watch(apiClientProvider).get('/shipping-methods');
  final data = response['data'];
  if (data is! List) throw const FormatException('Invalid shipping methods response');
  return data.whereType<Map<String, dynamic>>().toList(growable: false);
});

class CheckoutService {
  const CheckoutService(this.ref);
  final Ref ref;

  /// Creates an order and PaymentIntent on Laravel. The returned client_secret
  /// must be passed to a Stripe-native payment SDK, never treated as paid.
  Future<Map<String, dynamic>> createPaymentIntent({
    required String addressUuid,
    required String shippingCode,
    String? coupon,
  }) async {
    final response = await ref.read(apiClientProvider).post('/checkout', data: {
      'address_uuid': addressUuid,
      'shipping_method': shippingCode,
      if (coupon != null && coupon.trim().isNotEmpty) 'coupon': coupon.trim(),
    });
    final data = response['data'];
    if (data is! Map<String, dynamic> || data['order_uuid'] is! String ||
        data['stripe'] is! Map || (data['stripe'] as Map)['client_secret'] is! String) {
      throw const FormatException('Invalid payment intent response');
    }
    ref.invalidate(cartProvider);
    ref.invalidate(ordersProvider);
    return data;
  }
}

final checkoutServiceProvider = Provider<CheckoutService>((ref) => CheckoutService(ref));
