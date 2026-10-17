import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/account_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/commerce/presentation/address_order_screens.dart';
import '../features/commerce/presentation/checkout_screen.dart';
import '../features/commerce/presentation/commerce_screens.dart';
import '../features/home/presentation/onboarding_screen.dart';
import '../features/tailoring/presentation/measurement_screens.dart';
import '../features/tailoring/presentation/measurement_guide_screen.dart';
import '../features/tailoring/presentation/tailor_product_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const KabulFitLaunchScreen()),
      GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
      GoRoute(path: '/shop', builder: (_, state) => CatalogScreen(initialCategory: state.uri.queryParameters['category'])),
      GoRoute(
        path: '/products/:slug',
        builder: (_, state) =>
            ProductScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(path: '/measurement-guide', builder: (_, _) => const MeasurementGuideScreen()),
      GoRoute(
        path: '/measurements',
        builder: (_, _) => const MeasurementProfilesScreen(),
      ),
      GoRoute(
        path: '/measurements/new',
        builder: (_, _) => const NewMeasurementProfileScreen(),
      ),
      GoRoute(
        path: '/measurements/edit',
        builder: (_, state) => NewMeasurementProfileScreen(
          existing: state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null,
        ),
      ),
      GoRoute(
        path: '/products/:slug/tailor',
        builder: (_, state) =>
            TailorProductScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/tailoring',
        builder: (_, _) => const TailoringRequestsScreen(),
      ),
      GoRoute(path: '/checkout', builder: (_, _) => const CheckoutScreen()),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(path: '/wishlist', builder: (_, _) => const WishlistScreen()),
      GoRoute(path: '/addresses', builder: (_, _) => const AddressesScreen()),
      GoRoute(
        path: '/addresses/new',
        builder: (_, _) => const NewAddressScreen(),
      ),
      GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen()),
      GoRoute(
        path: '/orders/:uuid/tracking',
        builder: (_, state) =>
            TrackingScreen(uuid: state.pathParameters['uuid']!),
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    ],
  );
});
