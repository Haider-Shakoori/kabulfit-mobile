import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('fa'), Locale('ps')];
  static const delegate = _AppLocalizationsDelegate();

  final Locale locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const _values = <String, Map<String, String>>{
    'en': {
      'appName': 'KabulFit',
      'welcome': 'Authentic Afghan elegance',
      'signIn': 'Sign in',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot password?',
      'createAccount': 'Create account',
      'continueAsGuest': 'Continue as guest',
      'home': 'Home',
      'shop': 'Shop',
      'account': 'Account',
      'retry': 'Try again',
      'required': 'This field is required.',
      'invalidEmail': 'Enter a valid email address.',
      'comingSoon': 'Your shopping experience is coming in Batch 13.',
    },
    'fa': {
      'appName': 'کابل فِت',
      'welcome': 'زیبایی اصیل افغانی',
      'signIn': 'ورود',
      'email': 'ایمیل',
      'password': 'رمز عبور',
      'forgotPassword': 'رمز عبور را فراموش کرده‌اید؟',
      'createAccount': 'ایجاد حساب',
      'continueAsGuest': 'ادامه به‌عنوان مهمان',
      'home': 'خانه',
      'shop': 'فروشگاه',
      'account': 'حساب',
      'retry': 'دوباره تلاش کنید',
      'required': 'این بخش الزامی است.',
      'invalidEmail': 'یک ایمیل معتبر وارد کنید.',
      'comingSoon': 'تجربه خرید شما در مرحله ۱۳ تکمیل می‌شود.',
    },
    'ps': {
      'appName': 'کابل فټ',
      'welcome': 'اصلي افغاني ښکلا',
      'signIn': 'ننوتل',
      'email': 'برېښنالیک',
      'password': 'پټنوم',
      'forgotPassword': 'پټنوم مو هېر شوی؟',
      'createAccount': 'حساب جوړ کړئ',
      'continueAsGuest': 'د مېلمه په توګه دوام',
      'home': 'کور',
      'shop': 'پلورنځی',
      'account': 'حساب',
      'retry': 'بیا هڅه وکړئ',
      'required': 'دا برخه اړینه ده.',
      'invalidEmail': 'یو سم برېښنالیک ولیکئ.',
      'comingSoon': 'ستاسو د پیرود تجربه په ۱۳ پړاو کې بشپړېږي.',
    },
  };

  String text(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (item) => item.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
