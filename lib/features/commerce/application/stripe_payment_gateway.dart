import 'package:flutter_stripe/flutter_stripe.dart';

/// Stripe publishable keys are client-side identifiers, not secret keys.
/// The server is authoritative for order, inventory, and payment state.
class StripePaymentGateway {
  const StripePaymentGateway();

  static const publishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static bool get isConfigured =>
      publishableKey.startsWith('pk_test_') ||
      publishableKey.startsWith('pk_live_');

  static Future<void> initialize() async {
    if (!isConfigured) return;
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  /// A successful sheet dismissal is NOT authoritative proof of payment.
  /// The order remains pending until Laravel processes Stripe webhooks.
  Future<void> present(String clientSecret) async {
    if (!isConfigured) {
      throw StateError('Stripe publishable key is not configured.');
    }
    if (!clientSecret.startsWith('pi_') ||
        !clientSecret.contains('_secret_')) {
      throw const FormatException('Invalid Stripe PaymentIntent client secret');
    }
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'KabulFit',
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }
}
