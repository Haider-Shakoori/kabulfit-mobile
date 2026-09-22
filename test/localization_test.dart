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

  test('Dari and Pashto are resolved as RTL by Flutter', () {
    expect(Bidi.isRtlLanguage('fa'), isTrue);
    expect(Bidi.isRtlLanguage('ps'), isTrue);
  });
}
