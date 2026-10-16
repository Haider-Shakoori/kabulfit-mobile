/// Illustrative, read-only product previews inspired by KabulFit's public
/// Afghan fashion categories. These are NOT real website inventory or prices.
/// Enabled only with --dart-define=DEMO_CATALOG=true.
const demoCatalogEnabled = bool.fromEnvironment('DEMO_CATALOG');

const demoCatalog = <Map<String, dynamic>>[
  {
    'slug': 'demo-perahan-tunban',
    'name': 'Traditional Perahan Tunban (Demo)',
    'category': {'name': 'Men'},
    'price': {'formatted': 'Demo — no price'},
    'primary_media': null,
    'stock': {'in_stock': false},
    'short_description': 'Classic Afghan traditional outfit, shown for preview only.',
    'description': 'Illustrative KabulFit catalog preview. Not a real listed product.',
    'tailoring_enabled': false,
    'is_demo': true,
  },
  {
    'slug': 'demo-embroidered-dress',
    'name': 'Hand-Embroidered Afghan Dress (Demo)',
    'category': {'name': 'Women'},
    'price': {'formatted': 'Demo — no price'},
    'primary_media': null,
    'stock': {'in_stock': false},
    'short_description': 'Traditional embroidery and craftsmanship preview.',
    'description': 'Illustrative KabulFit catalog preview. Not a real listed product.',
    'tailoring_enabled': false,
    'is_demo': true,
  },
  {
    'slug': 'demo-waistcoat',
    'name': 'Traditional Afghan Waistcoat (Demo)',
    'category': {'name': 'Men'},
    'price': {'formatted': 'Demo — no price'},
    'primary_media': null,
    'stock': {'in_stock': false},
    'short_description': 'A traditional waistcoat style for storefront demonstration.',
    'description': 'Illustrative KabulFit catalog preview. Not a real listed product.',
    'tailoring_enabled': false,
    'is_demo': true,
  },
  {
    'slug': 'demo-child-outfit',
    'name': 'Children’s Afghan Outfit (Demo)',
    'category': {'name': 'Kids'},
    'price': {'formatted': 'Demo — no price'},
    'primary_media': null,
    'stock': {'in_stock': false},
    'short_description': 'Traditional clothing concept for children.',
    'description': 'Illustrative KabulFit catalog preview. Not a real listed product.',
    'tailoring_enabled': false,
    'is_demo': true,
  },
];

Map<String, dynamic>? demoProductBySlug(String slug) {
  for (final item in demoCatalog) {
    if (item['slug'] == slug) return item;
  }
  return null;
}
