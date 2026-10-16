import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kabulfit_mobile/core/localization/app_localizations.dart';

void main() {
  test('all supported locales include essential authentication copy', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final strings = AppLocalizations(locale);
      expect(strings.text('signIn'), isNotEmpty);
      expect(strings.text('email'), isNotEmpty);
      expect(strings.text('password'), isNotEmpty);
    }
  });

  test('checkout labels exist for every supported locale', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final strings = AppLocalizations(locale);
      for (final key in ['checkout', 'shippingMethod', 'deliveryAddress']) {
        expect(strings.text(key), isNot(key), reason: '${locale.languageCode}: $key');
      }
    }
  });

  test('Dari and Pashto are resolved as RTL by Flutter', () {
    expect(Bidi.isRtlLanguage('fa'), isTrue);
    expect(Bidi.isRtlLanguage('ps'), isTrue);
  });
}
