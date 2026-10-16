import 'package:flutter_test/flutter_test.dart';
import 'package:kabulfit_mobile/features/catalog/application/demo_catalog.dart';

void main() {
  test('demo items are marked read-only and out of stock', () {
    expect(demoCatalog, isNotEmpty);
    for (final item in demoCatalog) {
      expect(item['is_demo'], isTrue);
      expect(item['tailoring_enabled'], isFalse);
      expect((item['stock'] as Map)['in_stock'], isFalse);
      expect(demoProductBySlug(item['slug'] as String), isNotNull);
    }
  });
}
