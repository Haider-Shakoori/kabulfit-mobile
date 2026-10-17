import 'package:flutter_test/flutter_test.dart';
import 'package:kabulfit_mobile/features/tailoring/presentation/original_measurement_guide_data.dart';

void main() {
  test('the public guide mirrors the original KabulFit gender steps', () {
    final men = OriginalKabulFitMeasurementGuide.male;
    final women = OriginalKabulFitMeasurementGuide.female;
    expect(men.length, 11);
    expect(women.length, 17);
    for (final steps in [men, women]) {
      expect(steps.map((item) => item.id).toSet().length, steps.length);
      for (final step in steps) {
        expect(step.title('en'), isNotEmpty);
        expect(step.title('fa'), isNotEmpty);
        expect(step.title('ps'), isNotEmpty);
        expect(
          step.imageUrl.startsWith(
            'https://kabulfit.businessos.af/images/kabulfit-base44/source/',
          ),
          isTrue,
        );
        for (final locale in ['en', 'fa', 'ps']) {
          expect(Uri.parse(step.video(locale)).host, 'www.youtube.com');
        }
      }
    }
  });
}
