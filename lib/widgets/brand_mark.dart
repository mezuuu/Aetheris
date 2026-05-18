import 'package:flutter/material.dart';

import '../theme/aetheris_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/icon_aetheris.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Icon(
          Icons.graphic_eq_rounded,
          size: size,
          color: AetherisColors.mutedSky,
        );
      },
    );
  }
}
