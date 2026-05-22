import 'dart:convert';
import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/aetheris_colors.dart';

// Ambient blobs use ImageFiltered (not BackdropFilter) so they are safe on
// Impeller/OpenGLES. They draw INTO the scene, not blur behind widgets.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, this.colors, this.artworkUrl});

  final List<Color>? colors;
  final String? artworkUrl;

  @override
  Widget build(BuildContext context) {
    final palette = (colors == null || colors!.isEmpty)
        ? const [AetherisColors.accent, AetherisColors.sky]
        : colors!;

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
        if (_hasArtwork)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 54, sigmaY: 54),
              child: Transform.scale(
                scale: 1.18,
                child: _AmbientArtwork(url: artworkUrl!),
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AetherisColors.background.withValues(alpha: 0.62),
                AetherisColors.deepMidnight.withValues(alpha: 0.86),
              ],
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

  bool get _hasArtwork {
    final value = artworkUrl?.trim();
    if (value == null || value.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme;
  }
}

class _AmbientArtwork extends StatelessWidget {
  const _AmbientArtwork({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:image/')) {
      final comma = url.indexOf(',');
      if (comma > 0) {
        try {
          return Image.memory(
            base64Decode(url.substring(comma + 1)),
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.46),
            gaplessPlayback: true,
          );
        } catch (_) {
          return const SizedBox.shrink();
        }
      }
    }

    final parsed = Uri.tryParse(url);
    if (parsed != null && parsed.scheme == 'file') {
      return Image.file(
        File(parsed.toFilePath()),
        fit: BoxFit.cover,
        opacity: const AlwaysStoppedAnimation(0.46),
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      opacity: const AlwaysStoppedAnimation(0.46),
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
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
