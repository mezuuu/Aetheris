import 'package:flutter/material.dart';

import '../models/track.dart';
import '../theme/aetheris_colors.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({
    super.key,
    required this.track,
    this.size = 56,
    this.radius = 12,
    this.showBadge = false,
  });

  final Track track;
  final double size;
  final double radius;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: track.coverColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: track.coverColors.first.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _AlbumArtPainter(track.coverColors)),
          Center(
            child: Icon(
              Icons.graphic_eq_rounded,
              size: size.isFinite ? size * 0.28 : 36,
              color: AetherisColors.textPrimary.withValues(alpha: 0.82),
            ),
          ),
          if (showBadge)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.56),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(
                  track.format,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AetherisColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlbumArtPainter extends CustomPainter {
  const _AlbumArtPainter(this.colors);

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final glow =
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0),
              colors.length > 1
                  ? colors[1].withValues(alpha: 0.74)
                  : Colors.white,
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..strokeWidth = size.height * 0.018
          ..style = PaintingStyle.stroke;

    final path =
        Path()
          ..moveTo(-size.width * 0.1, size.height * 0.48)
          ..quadraticBezierTo(
            size.width * 0.35,
            size.height * 0.44,
            size.width * 0.72,
            size.height * 0.51,
          )
          ..quadraticBezierTo(
            size.width * 0.92,
            size.height * 0.56,
            size.width * 1.12,
            size.height * 0.48,
          );

    canvas.drawPath(path, glow);

    final speck = Paint()..color = Colors.white.withValues(alpha: 0.30);
    for (var i = 0; i < 12; i++) {
      final dx = ((i * 37) % 100) / 100 * size.width;
      final dy = ((i * 53) % 100) / 100 * size.height;
      canvas.drawCircle(Offset(dx, dy), 0.8 + (i % 3) * 0.35, speck);
    }
  }

  @override
  bool shouldRepaint(covariant _AlbumArtPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}
