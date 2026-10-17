import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabulfit_mobile/core/widgets/kabulfit_brand_logo.dart';
import 'package:kabulfit_mobile/features/home/presentation/onboarding_screen.dart';

void main() {
  testWidgets('shows original brand artwork during startup', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: KabulFitPreloader()));
    expect(find.byType(KabulFitBrandLogo), findsOneWidget);
    expect(find.text('TIMELESS ELEGANCE'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
