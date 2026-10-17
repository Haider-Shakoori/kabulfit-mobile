/// Formats validated USD minor units (cents) for the KabulFit storefront.
/// A missing or non-USD value is never represented as a valid price.
String formatUsdMinor(Object? minor, {String currency = 'USD'}) {
  if (currency != 'USD' || minor is! num || !minor.isFinite) return '—';
  return String.fromCharCode(36) + (minor / 100).toStringAsFixed(2);
}
