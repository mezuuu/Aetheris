import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/aetheris_colors.dart';
import '../widgets/ambient_background.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  static const _features = [
    (
      Icons.graphic_eq_rounded,
      'Lossless FLAC Playback',
      'Enjoy clean, detailed sound without lossy compression.',
    ),
    (
      Icons.memory_rounded,
      'Bit-Perfect Output',
      'Bypass Android resampling and send pure audio to your DAC.',
    ),
    (
      Icons.cloud_sync_rounded,
      'Cloud Sync',
      'Sync your library, playlists, lyrics, and metadata across devices.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(
            colors: [AetherisColors.accent, AetherisColors.sky],
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
                  children: [
                    const Center(child: _WaveformIcon()),
                    const SizedBox(height: 28),
                    const Text(
                      'Welcome to Aetheris',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AetherisColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your premium lossless listening space',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 44),
                    ...List.generate(_features.length, (i) {
                      final feature = _features[i];
                      return _FeatureCard(
                        icon: feature.$1,
                        title: feature.$2,
                        subtitle: feature.$3,
                        delay: i * 100,
                        controller: _anim,
                      );
                    }),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AetherisColors.mutedSky,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: widget.onDone,
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
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

class _WaveformIcon extends StatefulWidget {
  const _WaveformIcon();

  @override
  State<_WaveformIcon> createState() => _WaveformIconState();
}

class _WaveformIconState extends State<_WaveformIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 64,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(painter: _WavePainter(_ctrl.value)),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AetherisColors.mutedSky.withValues(alpha: 0.88)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill;

    const bars = 5;
    final barW = size.width / (bars * 2 - 1);
    final maxH = size.height;
    final minH = maxH * 0.22;

    final heights = [0.45, 0.72, 1.0, 0.72, 0.45];
    final phases = [0.0, 0.3, 0.6, 0.3, 0.0];

    for (var i = 0; i < bars; i++) {
      final wave = t * 2 * 3.14159 + phases[i];
      final normalized = wave - wave.floorToDouble();
      final curve =
          normalized < 0.5
              ? 4 * normalized * (0.5 - normalized)
              : -4 * (normalized - 0.5) * (1.0 - normalized);
      final h = minH + (maxH - minH) * heights[i] * (0.6 + 0.4 * curve);
      final x = i * barW * 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, (maxH - h) / 2, barW, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.t != t;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.delay,
    required this.controller,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int delay;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AetherisColors.mutedSky.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AetherisColors.mutedSky, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AetherisColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.52),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
