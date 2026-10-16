import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLocaleProvider = AsyncNotifierProvider<AppLocaleController, Locale>(
  AppLocaleController.new,
);

class AppLocaleController extends AsyncNotifier<Locale> {
  static const _key = 'kabulfit.locale';

  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString(_key);
    if (const {'en', 'fa', 'ps'}.contains(language)) return Locale(language!);
    final system =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return Locale(const {'en', 'fa', 'ps'}.contains(system) ? system : 'en');
  }

  Future<void> change(String language) async {
    if (!const {'en', 'fa', 'ps'}.contains(language)) {
      throw ArgumentError.value(language, 'language');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language);
    state = AsyncData(Locale(language));
  }
}
