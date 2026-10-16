import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../application/address_order_providers.dart';
import '../../../core/localization/app_localizations.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authControllerProvider).value == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Addresses')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: const Text('Sign in to manage addresses'),
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
        label: const Text('Add address'),
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
                ? const Center(child: Text('No addresses saved'))
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
                          tooltip: 'Remove address',
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialog) => AlertDialog(
                                title: const Text('Remove address?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialog, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(dialog, true),
                                    child: const Text('Remove'),
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
                              if (context.mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString())),
                                );
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
    appBar: AppBar(title: const Text('New shipping address')),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final entry in [
            (recipient, 'Recipient name'),
            (phone, 'Phone'),
            (city, 'City'),
            (street, 'Street address'),
          ]) ...[
            TextFormField(
              controller: entry.$1,
              decoration: InputDecoration(labelText: entry.$2),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
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
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  },
            child: Text(busy ? 'Saving…' : 'Save address'),
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
        appBar: AppBar(title: const Text('Orders')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: const Text('Sign in to view orders'),
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
                ? const Center(child: Text('No orders yet'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final order = items[i];
                      final uuid = order['uuid']?.toString() ?? '';
                      return ListTile(
                        title: Text('Order ${order['number']}'),
                        subtitle: Text(
                          'Order: ${order['status']} · Payment: ${order['payment_status']}',
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
    appBar: AppBar(title: const Text('Shipment tracking')),
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
                  title: Text('Order ${data['order_number']}'),
                  subtitle: Text('Status: ${data['order_status']}'),
                ),
                for (final shipment in shipments)
                  if (shipment is Map)
                    ListTile(
                      leading: const Icon(Icons.local_shipping_outlined),
                      title: Text(
                        shipment['carrier']?.toString() ?? 'Shipment',
                      ),
                      subtitle: Text(
                        'Status: ${shipment['status']} · Tracking: ${shipment['tracking_number'] ?? 'Not assigned'}',
                      ),
                    ),
              ],
            );
          },
        ),
  );
}
