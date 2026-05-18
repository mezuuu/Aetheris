import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/aetheris_colors.dart';

// Ambient blobs use ImageFiltered (not BackdropFilter) so they are safe on
// Impeller/OpenGLES. They draw INTO the scene, not blur behind widgets.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, this.colors});

  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? const [AetherisColors.accent, AetherisColors.sky];

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AetherisColors.background, AetherisColors.deepMidnight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        _Blob(
          color: palette.first.withValues(alpha: 0.28),
          size: 300,
          top: -100,
          right: -110,
        ),
        _Blob(
          color: palette.last.withValues(alpha: 0.18),
          size: 260,
          bottom: 100,
          left: -110,
        ),
        _Blob(
          color: AetherisColors.accentSoft.withValues(alpha: 0.12),
          size: 200,
          top: 320,
          right: 40,
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.size,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  final Color color;
  final double size;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  static final _blurFilter = ImageFilter.blur(sigmaX: 80, sigmaY: 80);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: _blurFilter,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
