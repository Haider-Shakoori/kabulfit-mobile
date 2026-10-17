import 'dart:io';

import 'package:image/image.dart' as img;

/// Builds a non-transparent, square launcher master from KabulFit's *original*
/// website favicon. The wordmark used by the splash screen is not altered.
Future<void> main() async {
  final source = File('assets/brand/kabulfit-app-symbol.png');
  if (!source.existsSync()) {
    throw StateError('Missing original KabulFit favicon: ${source.path}');
  }
  final decoded = img.decodePng(await source.readAsBytes());
  if (decoded == null) {
    throw StateError('Unable to decode KabulFit favicon PNG');
  }
  const size = 1024;
  final canvas = img.Image(width: size, height: size, numChannels: 4);
  img.fill(canvas, color: img.ColorRgb8(255, 252, 248));
  final resized = img.copyResize(
    decoded,
    width: 742,
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(
    canvas,
    resized,
    dstX: (size - resized.width) ~/ 2,
    dstY: (size - resized.height) ~/ 2,
  );
  const output = 'assets/brand/kabulfit-icon-square.png';
  await File(output).writeAsBytes(img.encodePng(canvas));
  stdout.writeln('Prepared branded 1024px launcher master: $output');
}
