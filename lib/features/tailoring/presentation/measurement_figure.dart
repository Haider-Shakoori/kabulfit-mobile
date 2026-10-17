import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Simple, self-contained front-view fitting diagram. Decorative only:
/// never renders or infers an individual's body shape from measurements.
class MeasurementFigure extends StatelessWidget {
  const MeasurementFigure({super.key, this.height = 280});

  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Tailoring measurement illustration showing neck, chest, waist and hip lines',
    image: true,
    child: CustomPaint(
      size: Size(height * 0.64, height),
      painter: const _MeasurementFigurePainter(),
    ),
  );
}

class _MeasurementFigurePainter extends CustomPainter {
  const _MeasurementFigurePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 340);

    final skin = Paint()
      ..color = const Color(0xFFEBC2B1)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = BrandColors.mutedInk.withValues(alpha: .65)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final hair = Paint()..color = const Color(0xFF493434);
    final fabric = Paint()..color = const Color(0xFFF3D9CD);
    final burgundy = Paint()
      ..color = BrandColors.burgundy
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke;

    // Shoulders, arms and a relaxed front-facing body.
    final body = Path()
      ..moveTo(80, 78)
      ..quadraticBezierTo(61, 84, 53, 103)
      ..lineTo(29, 197)
      ..quadraticBezierTo(25, 215, 35, 222)
      ..quadraticBezierTo(44, 227, 51, 210)
      ..lineTo(66, 155)
      ..quadraticBezierTo(68, 195, 66, 219)
      ..lineTo(71, 316)
      ..quadraticBezierTo(76, 329, 86, 326)
      ..quadraticBezierTo(95, 321, 95, 308)
      ..lineTo(100, 243)
      ..lineTo(105, 308)
      ..quadraticBezierTo(106, 321, 114, 326)
      ..quadraticBezierTo(126, 329, 129, 316)
      ..lineTo(134, 219)
      ..quadraticBezierTo(132, 193, 134, 155)
      ..lineTo(149, 210)
      ..quadraticBezierTo(156, 227, 165, 222)
      ..quadraticBezierTo(175, 215, 171, 197)
      ..lineTo(147, 103)
      ..quadraticBezierTo(140, 84, 120, 78)
      ..close();
    canvas.drawPath(body, skin);
    canvas.drawPath(body, outline);

    // Face, neck and a softly styled hair outline.
    canvas.drawOval(const Rect.fromLTWH(78, 20, 44, 58), hair);
    canvas.drawOval(const Rect.fromLTWH(85, 29, 30, 44), skin);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(92, 69, 16, 21),
        const Radius.circular(6),
      ),
      skin,
    );
    final ponytail = Path()
      ..moveTo(84, 33)
      ..quadraticBezierTo(78, 69, 76, 98)
      ..quadraticBezierTo(68, 109, 75, 120)
      ..quadraticBezierTo(89, 99, 86, 72)
      ..close();
    canvas.drawPath(ponytail, hair);
    canvas.drawArc(
      const Rect.fromLTWH(82, 25, 35, 45),
      3.15,
      2.4,
      false,
      hair..style = PaintingStyle.stroke..strokeWidth = 5,
    );

    // Fitting garment texture, not a person-specific body model.
    final garment = Path()
      ..moveTo(83, 84)
      ..quadraticBezierTo(100, 101, 117, 84)
      ..lineTo(138, 109)
      ..quadraticBezierTo(126, 158, 128, 205)
      ..quadraticBezierTo(100, 215, 72, 205)
      ..quadraticBezierTo(74, 160, 62, 109)
      ..close();
    canvas.drawPath(garment, fabric);
    canvas.drawPath(garment, outline);

    // Guided measurement markers: neck, shoulders, bust, waist, hip.
    _guide(canvas, 86, 78, 114, 78, burgundy);
    _guide(canvas, 62, 103, 138, 103, burgundy);
    _guide(canvas, 67, 145, 133, 145, burgundy);
    _guide(canvas, 73, 184, 127, 184, burgundy);
    _guide(canvas, 72, 213, 128, 213, burgundy);
    canvas.drawLine(const Offset(140, 106), const Offset(165, 201), burgundy);
    canvas.restore();
  }

  void _guide(Canvas canvas, double left, double y, double right, double y2, Paint line) {
    for (double x = left; x < right; x += 8) {
      canvas.drawLine(Offset(x, y), Offset((x + 4).clamp(left, right), y2), line);
    }
    final marker = Paint()..color = BrandColors.gold;
    canvas.drawCircle(Offset(left, y), 3, marker);
    canvas.drawCircle(Offset(right, y2), 3, marker);
  }

  @override
  bool shouldRepaint(covariant _MeasurementFigurePainter oldDelegate) => false;
}
