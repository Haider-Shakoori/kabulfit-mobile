import 'package:flutter_test/flutter_test.dart';
import 'package:kabulfit_mobile/features/catalog/application/catalog_pagination.dart';

void main() {
  Map<String, dynamic> page(
    int current,
    int last,
    int total,
    List<String> skus,
  ) {
    return {
      'data': [
        for (final sku in skus) {'sku': sku, 'slug': sku.toLowerCase()},
      ],
      'meta': {
        'current_page': current,
        'last_page': last,
        'total': total,
      },
    };
  }

  test('loads all products across pages in source order', () async {
    final requested = <int>[];
    final result = await loadAllCatalogPages((number) async {
      requested.add(number);
      return switch (number) {
        1 => page(1, 3, 5, ['A', 'B']),
        2 => page(2, 3, 5, ['C', 'D']),
        _ => page(3, 3, 5, ['E']),
      };
    });

    expect(requested, [1, 2, 3]);
    expect(result.map((item) => item['sku']), ['A', 'B', 'C', 'D', 'E']);
  });

  test('accepts empty catalog when server reports zero products', () async {
    final items = await loadAllCatalogPages(
      (number) async => page(1, 1, 0, []),
    );
    expect(items, isEmpty);
  });

  test('does not silently accept first page as complete catalog', () async {
    await expectLater(
      loadAllCatalogPages((number) async => page(1, 1, 130, ['A'])),
      throwsFormatException,
    );
  });

  test('rejects duplicated products across pages', () async {
    await expectLater(
      loadAllCatalogPages(
        (number) async => number == 1
            ? page(1, 2, 2, ['A'])
            : page(2, 2, 2, ['A']),
      ),
      throwsFormatException,
    );
  });

  test('rejects incomplete or inconsistent catalog responses', () async {
    await expectLater(
      loadAllCatalogPages(
        (number) async => number == 1
            ? page(1, 2, 3, ['A'])
            : page(2, 2, 2, ['B']),
      ),
      throwsFormatException,
    );
  });
}
