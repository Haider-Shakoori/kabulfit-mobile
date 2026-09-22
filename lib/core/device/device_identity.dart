import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentity {
  static const _uuidKey = 'device_uuid';

  Future<Map<String, String>> payload() async {
    final preferences = await SharedPreferences.getInstance();
    var deviceUuid = preferences.getString(_uuidKey);
    if (deviceUuid == null) {
      deviceUuid = const Uuid().v4();
      await preferences.setString(_uuidKey, deviceUuid);
    }
    final package = await PackageInfo.fromPlatform();
    return {
      'device_uuid': deviceUuid,
      'device_name': 'KabulFit Mobile',
      'platform': Platform.isIOS ? 'ios' : 'android',
      'app_version': package.version,
    };
  }
}
