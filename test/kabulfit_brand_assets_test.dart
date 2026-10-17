import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundles the exact original KabulFit logo art for offline use', () async {
    final dark = await rootBundle.load(
      'assets/brand/kabulfit-original-logo.png',
    );
    final white = await rootBundle.load(
      'assets/brand/kabulfit-original-logo-white.png',
    );
    expect(dark.lengthInBytes, 192694);
    expect(white.lengthInBytes, 73682);
  });
}
