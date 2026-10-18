/// Stripe checkout is intentionally unavailable in the initial TestFlight beta.
/// The native Stripe SDK will be restored after iOS compatibility is resolved.
/// Never create an order or PaymentIntent while payments are disabled.
class StripePaymentGateway {
  const StripePaymentGateway();

  static bool get isConfigured => false;

  static Future<void> initialize() async {}

  Future<void> present(String clientSecret) async {
    throw StateError(
      'Payments are temporarily unavailable in this TestFlight build.',
    );
  }
}
