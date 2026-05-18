import 'package:flutter/material.dart';

import '../state/aetheris_scope.dart';
import '../widgets/album_art.dart';
import '../widgets/ambient_background.dart';

class LyricsPage extends StatefulWidget {
  const LyricsPage({super.key});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  bool _translateEnabled = false;
  final _scrollController = ScrollController();

  static const _lyrics = [
    'Drifting through the cosmos',
    'Stars collide in silence',
    'Every breath a universe',
    'Light years from the surface',
    'We are made of stardust',
    'Falling through the void',
    'Time bends at the edges',
    'Nothing is destroyed',
    'In the dark between the planets',
    'Where no signal ever lands',
    'I can hear you breathing',
    'Reaching out your hands',
    'Drifting through the cosmos',
    'Stars collide in silence',
    'Every breath a universe',
    'Light years from the surface',
  ];

  static const _translations = [
    'Melayang di luar angkasa',
    'Bintang-bintang bertabrakan dalam sunyi',
    'Setiap napas sebuah semesta',
    'Tahun cahaya dari permukaan',
    'Kita terbuat dari debu bintang',
    'Jatuh menembus kekosongan',
    'Waktu melengkung di tepian',
    'Tidak ada yang musnah',
    'Di kegelapan antar planet',
    'Di mana sinyal tak pernah tiba',
    'Aku bisa mendengar napasmu',
    'Meraih dengan tangan',
    'Melayang di luar angkasa',
    'Bintang-bintang bertabrakan dalam sunyi',
    'Setiap napas sebuah semesta',
    'Tahun cahaya dari permukaan',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    final track = controller.currentTrack;

    // Determine active lyric index based on playback progress
    final totalLines = _lyrics.length;
    final activeIndex = (controller.progress * totalLines).floor().clamp(0, totalLines - 1);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred ambient bg
          AmbientBackground(colors: track.coverColors),

          Column(
            children: [
              // ── Top Bar ─────────────────────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Lyrics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // Translate toggle
                      GestureDetector(
                        onTap: () => setState(() => _translateEnabled = !_translateEnabled),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _translateEnabled
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Translate',
                            style: TextStyle(
                              color: _translateEnabled ? Colors.white : Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Lyrics Scroll Area ───────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  itemCount: _lyrics.length,
                  itemBuilder: (context, i) {
                    final isActive = i == activeIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main lyric line
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              fontSize: isActive ? 30 : 26,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                            child: Text(_lyrics[i]),
                          ),
                          // Translation below (Spotify style)
                          if (_translateEnabled) ...[
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.65)
                                    : Colors.white.withValues(alpha: 0.2),
                                fontSize: isActive ? 18 : 16,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              child: Text(_translations[i]),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Mini Player Bar ──────────────────────────────────────────
              Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 8,
                  top: 12,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AlbumArt(track: track, size: 44, radius: 6, showBadge: false),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.togglePlay,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          controller.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.skipNext(forceNextTrack: true),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.skip_next_rounded, color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
