import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appPreferencesProvider = Provider<AppPreferences>(
  (ref) => AppPreferences(),
);

class AppPreferences {
  static const localeKey = 'preferred_locale';
  static const analyticsConsentKey = 'analytics_consent';

  Future<bool?> analyticsConsent() async =>
      (await SharedPreferences.getInstance()).getBool(analyticsConsentKey);

  Future<String?> locale() async =>
      (await SharedPreferences.getInstance()).getString(localeKey);

  Future<void> setAnalyticsConsent(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(
        analyticsConsentKey,
        value,
      );

  Future<void> setLocale(String value) async =>
      (await SharedPreferences.getInstance()).setString(localeKey, value);
}
