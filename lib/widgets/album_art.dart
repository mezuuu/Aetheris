import 'dart:convert';
import 'dart:io';

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
    this.highResolution = false,
  });

  final Track track;
  final double size;
  final double radius;
  final bool showBadge;
  final bool highResolution;

  @override
  Widget build(BuildContext context) {
    final colors = track.coverColors.isEmpty
        ? const [Color(0xFF0F273F), Color(0xFF8C5B7D), Color(0xFF101422)]
        : track.coverColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (track.artworkUri != null)
            _buildArtwork(context, track.artworkUri!.toString(), size, colors)
          else
            _buildFallback(size, colors),
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

  Widget _buildFallback(double size, List<Color> colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _AlbumArtPainter(colors)),
        Center(
          child: Icon(
            Icons.graphic_eq_rounded,
            size: size.isFinite ? size * 0.28 : 36,
            color: AetherisColors.textPrimary.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }

  Widget _buildArtwork(
    BuildContext context,
    String uri,
    double size,
    List<Color> colors,
  ) {
    final cacheSize = _cacheSize(context);
    final filterQuality =
        highResolution ? FilterQuality.high : FilterQuality.medium;

    if (uri.startsWith('data:image/')) {
      final comma = uri.indexOf(',');
      if (comma > 0) {
        try {
          return Image.memory(
            base64Decode(uri.substring(comma + 1)),
            fit: BoxFit.cover,
            cacheWidth: cacheSize,
            cacheHeight: cacheSize,
            filterQuality: filterQuality,
            gaplessPlayback: true,
          );
        } catch (_) {
          return _buildFallback(size, colors);
        }
      }
    }

    final parsed = Uri.tryParse(uri);
    if (parsed != null && parsed.scheme == 'file') {
      return Image.file(
        File(parsed.toFilePath()),
        fit: BoxFit.cover,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        filterQuality: filterQuality,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(size, colors);
        },
      );
    }

    // For YouTube thumbnails, rewrite the URL to a pure 16:9 version
    // (maxresdefault = 1280x720, mqdefault = 320x180) to avoid baked-in
    // letterboxing that hqdefault.jpg (480x360 4:3) always contains.
    if (uri.contains('ytimg.com')) {
      final bestUrl = _ytBestThumbnail(uri);
      final fallbackUrl = _ytFallbackThumbnail(uri);
      return Image.network(
        bestUrl,
        fit: BoxFit.cover,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        filterQuality: filterQuality,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildFallback(size, colors);
        },
        errorBuilder: (context, error, stackTrace) {
          // maxresdefault may not exist for all videos; fall back to mqdefault
          return Image.network(
            fallbackUrl,
            fit: BoxFit.cover,
            cacheWidth: cacheSize,
            cacheHeight: cacheSize,
            filterQuality: filterQuality,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _buildFallback(size, colors),
          );
        },
      );
    }

    return Image.network(
      uri,
      fit: BoxFit.cover,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
      filterQuality: filterQuality,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildFallback(size, colors);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback(size, colors);
      },
    );
  }

  /// Rewrite any ytimg.com URL to request `maxresdefault.jpg` (1280×720, pure 16:9).
  static String _ytBestThumbnail(String url) {
    return url
        .replaceAll('hqdefault.jpg', 'maxresdefault.jpg')
        .replaceAll('mqdefault.jpg', 'maxresdefault.jpg')
        .replaceAll('sddefault.jpg', 'maxresdefault.jpg')
        .replaceAll('default.jpg', 'maxresdefault.jpg');
  }

  /// Fallback thumbnail: `mqdefault.jpg` (320×180, pure 16:9, always available).
  static String _ytFallbackThumbnail(String url) {
    return url
        .replaceAll('maxresdefault.jpg', 'mqdefault.jpg')
        .replaceAll('hqdefault.jpg', 'mqdefault.jpg')
        .replaceAll('sddefault.jpg', 'mqdefault.jpg')
        .replaceAll('default.jpg', 'mqdefault.jpg');
  }

  int? _cacheSize(BuildContext context) {
    if (highResolution || !size.isFinite || size <= 0) {
      return null;
    }
    final devicePixels = size * MediaQuery.devicePixelRatioOf(context);
    return devicePixels.round().clamp(64, 360);
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
