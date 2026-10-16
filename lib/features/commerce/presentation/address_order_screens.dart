import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../application/address_order_providers.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authControllerProvider).value == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).text('addresses'))),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: Text(AppLocalizations.of(context).text('signInAddresses')),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).text('shippingAddress')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/addresses/new'),
        label: Text(AppLocalizations.of(context).text('addAddress')),
        icon: const Icon(Icons.add),
      ),
      body: ref
          .watch(addressesProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(addressesProvider),
                child: Text('Retry: $error'),
              ),
            ),
            data: (items) => items.isEmpty
                ? Center(child: Text(AppLocalizations.of(context).text('noAddresses')))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final address = items[i];
                      return ListTile(
                        title: Text(
                          address['recipient_name']?.toString() ?? '',
                        ),
                        subtitle: Text(
                          [
                            address['address_line1'],
                            address['city'],
                            address['country_code'],
                          ].whereType<String>().join(', '),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: AppLocalizations.of(context).text('removeAddress'),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialog) => AlertDialog(
                                title: Text(AppLocalizations.of(context).text('removeAddressConfirm')),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialog, false),
                                    child: Text(AppLocalizations.of(context).text('cancel')),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(dialog, true),
                                    child: Text(AppLocalizations.of(context).text('removeAddress')),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true) return;
                            try {
                              await ref
                                  .read(addressActionsProvider)
                                  .remove(address['uuid'].toString());
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString())),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
    );
  }
}

class NewAddressScreen extends ConsumerStatefulWidget {
  const NewAddressScreen({super.key});
  @override
  ConsumerState<NewAddressScreen> createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends ConsumerState<NewAddressScreen> {
  final form = GlobalKey<FormState>();
  final recipient = TextEditingController();
  final phone = TextEditingController();
  final city = TextEditingController();
  final street = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    recipient.dispose();
    phone.dispose();
    city.dispose();
    street.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).text('newAddress'))),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final entry in [
            (recipient, AppLocalizations.of(context).text('recipientName')),
            (phone, AppLocalizations.of(context).text('phone')),
            (city, AppLocalizations.of(context).text('city')),
            (street, AppLocalizations.of(context).text('street')),
          ]) ...[
            TextFormField(
              controller: entry.$1,
              decoration: InputDecoration(labelText: entry.$2),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? AppLocalizations.of(context).text('required') : null,
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: busy
                ? null
                : () async {
                    if (!form.currentState!.validate()) return;
                    setState(() => busy = true);
                    try {
                      await ref
                          .read(addressActionsProvider)
                          .add(
                            recipient: recipient.text.trim(),
                            phone: phone.text.trim(),
                            city: city.text.trim(),
                            street: street.text.trim(),
                          );
                      if (context.mounted) context.pop();
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  },
            child: Text(busy ? AppLocalizations.of(context).text('saving') : AppLocalizations.of(context).text('saveAddress')),
          ),
        ],
      ),
    ),
  );
}

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authControllerProvider).value == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).text('orders'))),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: Text(AppLocalizations.of(context).text('signInOrders')),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).text('myOrders')),
      ),
      body: ref
          .watch(ordersProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(ordersProvider),
                child: Text('Retry: $error'),
              ),
            ),
            data: (items) => items.isEmpty
                ? Center(child: Text(AppLocalizations.of(context).text('noOrders')))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final order = items[i];
                      final uuid = order['uuid']?.toString() ?? '';
                      return ListTile(
                        title: Text("${AppLocalizations.of(context).text('orderLabel')} ${order['number']}"),
                        subtitle: Text(
                          "${AppLocalizations.of(context).text('statusLabel')}: ${order['status']} · ${AppLocalizations.of(context).text('paymentLabel')}: ${order['payment_status']}",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: uuid.isEmpty
                            ? null
                            : () => context.push(
                                '/orders/${Uri.encodeComponent(uuid)}/tracking',
                              ),
                      );
                    },
                  ),
          ),
    );
  }
}

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({required this.uuid, super.key});
  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).text('shipmentTracking'))),
    body: ref
        .watch(orderTrackingProvider(uuid))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(orderTrackingProvider(uuid)),
              child: Text('Retry: $error'),
            ),
          ),
          data: (data) {
            final shipments = (data['shipments'] as List?) ?? [];
            return ListView(
              children: [
                ListTile(
                  title: Text("${AppLocalizations.of(context).text('orderLabel')} ${data['order_number']}"),
                  subtitle: Text("${AppLocalizations.of(context).text('statusLabel')}: ${data['order_status']}"),
                ),
                for (final shipment in shipments)
                  if (shipment is Map)
                    ListTile(
                      leading: const Icon(Icons.local_shipping_outlined),
                      title: Text(
                        shipment['carrier']?.toString() ?? AppLocalizations.of(context).text('shipmentLabel'),
                      ),
                      subtitle: Text(
                        "${AppLocalizations.of(context).text('statusLabel')}: ${shipment['status']} · ${AppLocalizations.of(context).text('trackingLabel')}: ${shipment['tracking_number'] ?? AppLocalizations.of(context).text('notAssigned')}",
                      ),
                    ),
              ],
            );
          },
        ),
  );
}
