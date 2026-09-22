import 'package:flutter_test/flutter_test.dart';
import 'package:kabulfit_mobile/core/config/app_config.dart';

void main() {
  test('development uses the Android emulator API fallback', () {
    final config = AppConfig.fromEnvironment(AppFlavor.dev);
    expect(config.apiBaseUrl.toString(), 'http://10.0.2.2:8000/api/v1');
  });

  test('production refuses an absent API endpoint', () {
    expect(
      () => AppConfig.fromEnvironment(AppFlavor.production),
      throwsStateError,
    );
  });
}
