import 'package:flutter_test/flutter_test.dart';
import 'package:kabulfit_mobile/core/formatting/usd_money.dart';

void main() {
  group('KabulFit USD price formatting', () {
    test('renders amounts from minor units rather than interpolation syntax', () {
      expect(formatUsdMinor(280000), '\u00242,800.00');
      expect(formatUsdMinor(420000), '\u00244,200.00');
      expect(formatUsdMinor(12345), '\u0024123.45');
      expect(formatUsdMinor(0), '\u00240.00');
    });

    test('fails closed for non-USD or missing price', () {
      expect(formatUsdMinor(280000, currency: 'AFN'), '—');
      expect(formatUsdMinor(null), '—');
      expect(formatUsdMinor('280000'), '—');
      expect(formatUsdMinor(double.nan), '—');
    });
  });
}
