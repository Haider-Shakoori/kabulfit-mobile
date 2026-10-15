import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../application/address_order_providers.dart';
import '../application/checkout_providers.dart';
import '../application/commerce_providers.dart';

/// Preflight only: payment is deliberately not initiated until the native
/// Stripe PaymentSheet integration is available and tested.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? addressUuid;
  String? shippingCode;
  final coupon = TextEditingController();

  @override
  void dispose() {
    coupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(authControllerProvider).value == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(child: FilledButton(
          onPressed: () => context.push('/login'),
          child: const Text('Sign in to checkout'),
        )),
      );
    }

    final addresses = ref.watch(addressesProvider);
    final methods = ref.watch(shippingMethodsProvider);
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Delivery address', style: Theme.of(context).textTheme.titleLarge),
          addresses.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => TextButton(
              onPressed: () => ref.invalidate(addressesProvider),
              child: Text('Could not load addresses. Retry: $error'),
            ),
            data: (items) => items.isEmpty
                ? TextButton(
                    onPressed: () => context.push('/addresses/new'),
                    child: const Text('Add a shipping address'),
                  )
                : DropdownButtonFormField<String>(
                    value: items.any((e) => e['uuid'] == addressUuid) ? addressUuid : null,
                    decoration: const InputDecoration(labelText: 'Ship to'),
                    items: items.map((item) => DropdownMenuItem(
                      value: item['uuid']?.toString(),
                      child: Text('${item['recipient_name']} · ${item['city']}'),
                    )).toList(),
                    onChanged: (v) => setState(() => addressUuid = v),
                  ),
          ),
          const SizedBox(height: 20),
          Text('Shipping method', style: Theme.of(context).textTheme.titleLarge),
          methods.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => TextButton(
              onPressed: () => ref.invalidate(shippingMethodsProvider),
              child: Text('Could not load shipping. Retry: $error'),
            ),
            data: (items) => items.isEmpty
                ? const Text('No shipping methods available for this cart.')
                : DropdownButtonFormField<String>(
                    value: items.any((e) => e['code'] == shippingCode) ? shippingCode : null,
                    decoration: const InputDecoration(labelText: 'Shipping'),
                    items: items.map((item) => DropdownMenuItem(
                      value: item['code']?.toString(),
                      child: Text(item['name']?.toString() ?? ''),
                    )).toList(),
                    onChanged: (v) => setState(() => shippingCode = v),
                  ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: coupon,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Coupon (optional)'),
          ),
          const SizedBox(height: 20),
          cart.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Cart unavailable: $error'),
            data: (data) => Text(
              'Cart subtotal (before shipping/discounts): ${data['subtotal_minor']} minor units · ${data['currency']}',
            ),
          ),
          const SizedBox(height: 20),
          const Text('Checkout payment is not yet enabled. Order creation is '
              'disabled until secure Stripe PaymentSheet integration is verified. '
              'Your cart will remain unchanged on this screen.'),
          const SizedBox(height: 16),
          const FilledButton(
            onPressed: null,
            child: Text('Payment integration pending'),
          ),
        ],
      ),
    );
  }
}
