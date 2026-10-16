import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabulfit_mobile/core/localization/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores saved Dari and persists a change to Pashto', () async {
    SharedPreferences.setMockInitialValues({'kabulfit.locale': 'fa'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = await container.read(appLocaleProvider.future);
    expect(initial.languageCode, 'fa');

    await container.read(appLocaleProvider.notifier).change('ps');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('kabulfit.locale'), 'ps');
    expect(container.read(appLocaleProvider).value?.languageCode, 'ps');
  });

  test('rejects unsupported language codes', () async {
    SharedPreferences.setMockInitialValues({'kabulfit.locale': 'en'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(appLocaleProvider.future);
    await expectLater(
      container.read(appLocaleProvider.notifier).change('fr'),
      throwsArgumentError,
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('kabulfit.locale'), 'en');
  });
}
