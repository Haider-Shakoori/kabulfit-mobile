import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../application/address_order_providers.dart';
import '../application/checkout_providers.dart';
import '../application/commerce_providers.dart';
import '../application/stripe_payment_gateway.dart';
import '../../../core/localization/app_localizations.dart';

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
  bool processing = false;
  String? pendingOrderUuid;
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
        appBar: AppBar(title: Text(AppLocalizations.of(context).text('checkout'))),
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
      appBar: AppBar(title: Text(AppLocalizations.of(context).text('checkout'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(AppLocalizations.of(context).text('deliveryAddress'), style: Theme.of(context).textTheme.titleLarge),
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
          Text(AppLocalizations.of(context).text('shippingMethod'), style: Theme.of(context).textTheme.titleLarge),
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
            decoration: InputDecoration(labelText: AppLocalizations.of(context).text('coupon')),
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
          const Text('The final amount, including shipping and any coupon, '
              'will be calculated by KabulFit. Placing an order reserves stock '
              'and clears the cart even if you cancel the payment sheet.'),
          const SizedBox(height: 16),
          if (pendingOrderUuid != null) ...[
            Text('Payment has not been confirmed for order $pendingOrderUuid.'),
            TextButton(
              onPressed: () => context.push('/orders'),
              child: const Text('Review order status'),
            ),
          ] else
            FilledButton(
              onPressed: processing ||
                      !StripePaymentGateway.isConfigured ||
                      addressUuid == null ||
                      shippingCode == null ||
                      !cart.hasValue ||
                      ((cart.value?['items'] as List?)?.isEmpty ?? true)
                  ? null
                  : () => _pay(context),
              child: Text(processing ? 'Preparing payment…' : 'Continue to secure payment'),
            ),
          if (!StripePaymentGateway.isConfigured)
            const Text('Stripe is not configured in this build. Checkout is disabled.'),
        ],
      ),
    );
  }
  Future<void> _pay(BuildContext context) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Place your order?'),
        content: const Text('KabulFit will create a pending order and reserve '
            'stock before Stripe opens. Canceling the payment sheet does not '
            'automatically restore the cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true),
              child: const Text('Continue')),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    setState(() => processing = true);
    try {
      final order = await ref.read(checkoutServiceProvider).createPaymentIntent(
        addressUuid: addressUuid!,
        shippingCode: shippingCode!,
        coupon: coupon.text,
      );
      final uuid = order['order_uuid'].toString();
      if (mounted) setState(() => pendingOrderUuid = uuid);
      final stripe = order['stripe'] as Map;
      await const StripePaymentGateway().present(stripe['client_secret'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment submitted. Confirm status in your orders.')),
      );
      context.push('/orders');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout not confirmed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

}
