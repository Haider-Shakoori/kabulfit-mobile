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

  static const _darkLogo =
      'https://kabulfit.businessos.af/images/kabulfit-base44/source/4ce74c49d_KabulFit_logo_shopify_header.png';
  static const _whiteLogo =
      'https://kabulfit.businessos.af/images/kabulfit-base44/source/b6d3c7505_KabulFit_logo_white.png';

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'KabulFit',
    image: true,
    child: Image.network(
      white ? _whiteLogo : _darkLogo,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Text(
        'KabulFit',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'serif',
          color: white ? Colors.white : const Color(0xFF74263D),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
