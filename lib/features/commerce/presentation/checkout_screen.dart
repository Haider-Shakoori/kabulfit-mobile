import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../application/address_order_providers.dart';
import '../application/checkout_providers.dart';
import '../application/commerce_providers.dart';
import '../application/stripe_payment_gateway.dart';

/// Checkout creates a pending order. Only the backend webhook confirms payment.
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
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).text('checkout')),
        ),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: Text(AppLocalizations.of(context).text('checkoutSignIn')),
          ),
        ),
      );
    }

    final addresses = ref.watch(addressesProvider);
    final methods = ref.watch(shippingMethodsProvider);
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).text('checkout')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            AppLocalizations.of(context).text('deliveryAddress'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          addresses.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => TextButton(
              onPressed: () => ref.invalidate(addressesProvider),
              child: Text('Could not load addresses. Retry: $error'),
            ),
            data: (items) => items.isEmpty
                ? TextButton(
                    onPressed: () => context.push('/addresses/new'),
                    child: Text(AppLocalizations.of(context).text('checkoutAddAddress')),
                  )
                : DropdownButtonFormField<String>(
                    initialValue: items.any((e) => e['uuid'] == addressUuid)
                        ? addressUuid
                        : null,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).text('checkoutShipTo')),
                    items: items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item['uuid']?.toString(),
                            child: Text(
                              '${item['recipient_name']} · ${item['city']}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => addressUuid = v),
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).text('shippingMethod'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          methods.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => TextButton(
              onPressed: () => ref.invalidate(shippingMethodsProvider),
              child: Text('Could not load shipping. Retry: $error'),
            ),
            data: (items) => items.isEmpty
                ? Text(AppLocalizations.of(context).text('checkoutNoShipping'))
                : DropdownButtonFormField<String>(
                    initialValue: items.any((e) => e['code'] == shippingCode)
                        ? shippingCode
                        : null,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).text('checkoutShipping')),
                    items: items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item['code']?.toString(),
                            child: Text(item['name']?.toString() ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => shippingCode = v),
                  ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: coupon,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).text('coupon'),
            ),
          ),
          const SizedBox(height: 20),
          cart.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Cart unavailable: $error'),
            data: (data) => Text(
              "${AppLocalizations.of(context).text('checkoutSubtotal')}: ${data['subtotal_minor'] is num ? ((data['subtotal_minor'] as num) / 100).toStringAsFixed(2) : '—'} ${data['currency'] ?? ''}",
            ),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).text('checkoutNotice')),
          const SizedBox(height: 16),
          if (pendingOrderUuid != null) ...[
            Text("${AppLocalizations.of(context).text('checkoutPending')}: $pendingOrderUuid."),
            TextButton(
              onPressed: () => context.push('/orders'),
              child: Text(AppLocalizations.of(context).text('checkoutReview')),
            ),
          ] else
            FilledButton(
              onPressed:
                  processing ||
                      !StripePaymentGateway.isConfigured ||
                      addressUuid == null ||
                      shippingCode == null ||
                      !cart.hasValue ||
                      ((cart.value?['items'] as List?)?.isEmpty ?? true)
                  ? null
                  : _pay,
              child: Text(
                processing
                    ? AppLocalizations.of(context).text('checkoutPreparing')
                    : AppLocalizations.of(context).text('checkoutPay'),
              ),
            ),
          if (!StripePaymentGateway.isConfigured)
            Text(AppLocalizations.of(context).text('checkoutUnconfigured')),
        ],
      ),
    );
  }

  Future<void> _pay() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(AppLocalizations.of(context).text('checkoutConfirm')),
        content: Text(AppLocalizations.of(context).text('checkoutConfirmBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(AppLocalizations.of(context).text('checkoutNotNow')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(AppLocalizations.of(context).text('checkoutContinue')),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    setState(() => processing = true);
    try {
      final order = await ref
          .read(checkoutServiceProvider)
          .createPaymentIntent(
            addressUuid: addressUuid!,
            shippingCode: shippingCode!,
            coupon: coupon.text,
          );
      final uuid = order['order_uuid'].toString();
      if (mounted) setState(() => pendingOrderUuid = uuid);
      final stripe = order['stripe'] as Map;
      await const StripePaymentGateway().present(
        stripe['client_secret'].toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).text('checkoutSubmitted'))),
      );
      context.push('/orders');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context).text('checkoutFailed')}: $error")),
        );
      }
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }
}
