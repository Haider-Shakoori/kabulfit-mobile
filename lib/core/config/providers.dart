import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../device/device_identity.dart';
import '../localization/locale_controller.dart';
import '../network/api_client.dart';
import '../security/token_store.dart';
import 'app_config.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw StateError('AppConfig was not provided at bootstrap.'),
);

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());
final deviceIdentityProvider = Provider<DeviceIdentity>(
  (ref) => DeviceIdentity(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  // Recreate the API client when the selected language changes so dependent
  // product/catalog providers re-fetch in the new locale.
  ref.watch(appLocaleProvider);
  return ApiClient(
    config: ref.watch(appConfigProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});
