import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/commerce/presentation/commerce_screens.dart';
import '../features/commerce/presentation/address_order_screens.dart';
import '../features/commerce/presentation/checkout_screen.dart';
import '../features/home/presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/shop', builder: (_, _) => const CatalogScreen()),
      GoRoute(
        path: '/products/:slug',
        builder: (_, state) => ProductScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(path: '/checkout', builder: (_, _) => const CheckoutScreen()),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(path: '/wishlist', builder: (_, _) => const WishlistScreen()),
      GoRoute(path: '/addresses', builder: (_, _) => const AddressesScreen()),
      GoRoute(path: '/addresses/new', builder: (_, _) => const NewAddressScreen()),
      GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen()),
      GoRoute(path: '/orders/:uuid/tracking', builder: (_, state) => TrackingScreen(uuid: state.pathParameters['uuid']!)),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    ],
  );
});
