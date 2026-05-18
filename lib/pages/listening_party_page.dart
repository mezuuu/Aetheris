import 'package:flutter/material.dart';

import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/primary_button.dart';
import '../widgets/track_tile.dart';

class ListeningPartyPage extends StatelessWidget {
  const ListeningPartyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);

    return Scaffold(
      body: Stack(
        children: [
          AmbientBackground(colors: controller.currentTrack.coverColors),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 34),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.07,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AetherisColors.textSecondary,
                        ),
                        const Expanded(
                          child: Text(
                            'Listening Party',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AetherisColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 28),
                    GlassContainer(
                      radius: 24,
                      padding: const EdgeInsets.all(26),
                      child: Column(
                        children: [
                          const Text(
                            'HOST CODE',
                            style: TextStyle(
                              color: AetherisColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'AET-924',
                            style: TextStyle(
                              color: AetherisColors.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              color: AetherisColors.textPrimary,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: const CustomPaint(painter: _QrPainter()),
                          ),
                          const SizedBox(height: 22),
                          PrimaryButton(
                            label: 'Invite Guests',
                            icon: Icons.share_rounded,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Guest Requests',
                      style: TextStyle(
                        color: AetherisColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final track in controller.queue.take(3)) ...[
                      TrackTile(track: track, compact: true),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AetherisColors.background;
    final cell = size.width / 9;

    for (var y = 0; y < 9; y++) {
      for (var x = 0; x < 9; x++) {
        final filled =
            (x < 3 && y < 3) ||
            (x > 5 && y < 3) ||
            (x < 3 && y > 5) ||
            ((x * 7 + y * 5) % 4 == 0);
        if (filled) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x * cell + 2, y * cell + 2, cell - 4, cell - 4),
              const Radius.circular(3),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
