/// Loads the complete paginated Laravel product catalog, not just page one.
///
/// Errors are intentional: returning only the first page can silently hide
/// products that have already been imported into the website.
Future<List<Map<String, dynamic>>> loadAllCatalogPages(
  Future<Map<String, dynamic>> Function(int page) fetchPage,
) async {
  const maxPages = 100;
  final results = <Map<String, dynamic>>[];
  final seen = <String>{};
  int? expectedTotal;

  for (var page = 1; page <= maxPages; page++) {
    final response = await fetchPage(page);
    final data = response['data'];
    final meta = response['meta'];

    if (data is! List || meta is! Map) {
      throw const FormatException('Invalid paginated catalog response');
    }

    final currentPage = meta['current_page'];
    final lastPage = meta['last_page'];
    final total = meta['total'];
    if (currentPage is! int ||
        currentPage != page ||
        lastPage is! int ||
        lastPage < page ||
        lastPage > maxPages ||
        total is! int ||
        total < 0) {
      throw const FormatException('Invalid Laravel catalog pagination');
    }

    expectedTotal ??= total;
    if (expectedTotal != total) {
      throw const FormatException('Catalog changed while loading pages');
    }

    for (final entry in data) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Invalid catalog product');
      }
      final sku = entry['sku'];
      if (sku is! String || sku.isEmpty || !seen.add(sku)) {
        throw const FormatException('Missing or duplicate catalog SKU');
      }
      results.add(entry);
    }

    if (page == lastPage) {
      if (results.length != total) {
        throw const FormatException('Incomplete catalog data');
      }
      return results;
    }
  }

  throw const FormatException('Catalog pagination limit exceeded');
}
