import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabulfit_mobile/core/localization/app_localizations.dart';

void main() {
  test('checkout and tailoring vocabulary exists in every language', () {
    const keys = [
      'checkoutSignIn',
      'checkoutAddAddress',
      'checkoutShipTo',
      'checkoutNoShipping',
      'checkoutShipping',
      'checkoutSubtotal',
      'checkoutNotice',
      'checkoutPending',
      'checkoutReview',
      'checkoutPreparing',
      'checkoutPay',
      'checkoutUnconfigured',
      'checkoutConfirm',
      'checkoutConfirmBody',
      'checkoutNotNow',
      'checkoutContinue',
      'checkoutSubmitted',
      'checkoutFailed',
      'tailorCustom',
      'tailorSignIn',
      'tailorCustomize',
      'tailorUnavailable',
      'tailorNewProfile',
      'tailorSaved',
      'tailorSizeColor',
      'tailorInstructions',
      'tailorAdded',
      'tailorAdding',
      'tailorAdd',
      'signInAddresses',
      'addAddress',
      'noAddresses',
      'removeAddress',
      'removeAddressConfirm',
      'newAddress',
      'recipientName',
      'phone',
      'city',
      'street',
      'saveAddress',
      'saving',
      'signInOrders',
      'noOrders',
      'orderLabel',
      'statusLabel',
      'paymentLabel',
      'shipmentTracking',
      'shipmentLabel',
      'trackingLabel',
      'notAssigned',
      'signInMeasurements',
      'deleteProfileConfirm',
      'cannotUndo',
      'newMeasurement',
      'editMeasurement',
    ];

    for (final locale in AppLocalizations.supportedLocales) {
      final strings = AppLocalizations(locale);
      for (final key in keys) {
        final value = strings.text(key);
        expect(value, isNotEmpty, reason: '${locale.languageCode}: $key');
        expect(value, isNot(key), reason: '${locale.languageCode}: $key');
      }
    }

    expect(
      AppLocalizations(const Locale('fa')).text('checkoutPay'),
      isNot(AppLocalizations(const Locale('en')).text('checkoutPay')),
    );
    expect(
      AppLocalizations(const Locale('ps')).text('tailorAdd'),
      isNot(AppLocalizations(const Locale('en')).text('tailorAdd')),
    );
  });
}
