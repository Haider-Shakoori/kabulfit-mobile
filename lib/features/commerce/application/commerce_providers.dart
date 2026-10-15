import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';

final cartProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.watch(apiClientProvider).get('/cart');
  final data = result['data'];
  if (data is! Map<String, dynamic>) {
    throw const FormatException('Invalid cart payload');
  }
  return data;
});

final wishlistProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.watch(apiClientProvider).get('/wishlist');
  final data = result['data'];
  if (data is! List) throw const FormatException('Invalid wishlist payload');
  return data.whereType<Map<String, dynamic>>().toList();
});

class CommerceActions {
  const CommerceActions(this.ref);
  final Ref ref;

  Future<void> addToCart(String slug, {String? variantSku, int quantity = 1}) async {
    await ref.read(apiClientProvider).post('/cart/items', data: {
      'product_slug': slug,
      'quantity': quantity,
      if (variantSku != null) 'variant_sku': variantSku,
    });
    ref.invalidate(cartProvider);
  }

  Future<void> addToWishlist(String slug) async {
    await ref.read(apiClientProvider).post('/wishlist', data: {'product_slug': slug});
    ref.invalidate(wishlistProvider);
  }
}

final commerceActionsProvider = Provider<CommerceActions>((ref) => CommerceActions(ref));
