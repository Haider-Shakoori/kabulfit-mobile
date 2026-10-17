import 'package:flutter/material.dart';

/// Original Base44 KabulFit brand artwork already migrated to our Laravel host.
/// Keep its native proportions. Never synthesize a substitute wordmark.
class KabulFitBrandLogo extends StatelessWidget {
  const KabulFitBrandLogo({
    super.key,
    this.width = 150,
    this.height = 60,
    this.white = false,
  });

  final double width;
  final double height;
  final bool white;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'KabulFit',
    image: true,
    child: Image.asset(
      white
          ? 'assets/brand/kabulfit-original-logo-white.png'
          : 'assets/brand/kabulfit-original-logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'KabulFit',
    ),
  );
}
