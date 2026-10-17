import 'package:intl/intl.dart';

/// Formats validated USD minor units (cents) for the KabulFit storefront.
/// A missing or non-USD value is never represented as a valid price.
String formatUsdMinor(Object? minor, {String currency = 'USD'}) {
  if (currency != 'USD' || minor is! num || !minor.isFinite) return '—';
  final amount = NumberFormat('#,##0.00', 'en_US').format(minor / 100);
  return String.fromCharCode(36) + amount;
}
