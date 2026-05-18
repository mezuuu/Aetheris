import 'package:flutter/material.dart';

import '../state/aetheris_scope.dart';
import '../widgets/album_art.dart';
import '../widgets/ambient_background.dart';
import 'lyrics_page.dart';
import 'queue_page.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    final track = controller.currentTrack;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient blurred background from album art colours
          AmbientBackground(colors: track.coverColors),

          // Main scrollable content
          SafeArea(
            child: Column(
              children: [
                // ── Top Bar ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Chevron down
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                      // Station label
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'PLAYING FROM LIBRARY',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            track.album,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Ellipsis menu
                      GestureDetector(
                        onTap: () => _showTrackOptions(context, controller),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.more_horiz_rounded, color: Colors.white, size: 26),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Album Art ────────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return AlbumArt(
                                track: track,
                                size: constraints.maxWidth,
                                radius: 12,
                                showBadge: false,
                              );
                            }
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Controls ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Song info + Like
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  track.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _LikeButton(track: track),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Seekbar ─────────────────────────────────────
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          thumbColor: Colors.white,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          overlayColor: Colors.white12,
                        ),
                        child: Slider(
                          value: controller.progress,
                          onChanged: controller.seekToPercent,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(controller.position), style: _timeStyle),
                            Text(
                              '-${_fmt(track.duration - controller.position)}',
                              style: _timeStyle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Transport Controls ─────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TransportBtn(
                            icon: Icons.shuffle_rounded,
                            size: 22,
                            color: controller.isShuffleEnabled
                                ? Colors.white
                                : Colors.white38,
                            onPressed: controller.toggleShuffle,
                            dot: controller.isShuffleEnabled,
                          ),
                          _TransportBtn(
                            icon: Icons.skip_previous_rounded,
                            size: 46,
                            onPressed: controller.skipPrevious,
                          ),
                          // Big play / pause
                          GestureDetector(
                            onTap: controller.togglePlay,
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              controller.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_filled_rounded,
                              color: Colors.white,
                              size: 76,
                            ),
                          ),
                          _TransportBtn(
                            icon: Icons.skip_next_rounded,
                            size: 46,
                            onPressed: () => controller.skipNext(forceNextTrack: true),
                          ),
                          _TransportBtn(
                            icon: controller.repeatMode == 2
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            size: 22,
                            color: controller.repeatMode > 0
                                ? Colors.white
                                : Colors.white38,
                            onPressed: controller.toggleRepeat,
                            dot: controller.repeatMode > 0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // ── Bottom Toolbar ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ToolbarBtn(
                        icon: Icons.lyrics_rounded,
                        label: 'Lyrics',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(builder: (_) => const LyricsPage()),
                        ),
                      ),
                      _ToolbarBtn(
                        icon: Icons.airplay_rounded,
                        label: 'AirPlay',
                        onTap: () {},
                      ),
                      _ToolbarBtn(
                        icon: Icons.queue_music_rounded,
                        label: 'Queue',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(builder: (_) => const QueuePage()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTrackOptions(BuildContext ctx, dynamic controller) {
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _TrackOptionsSheet(controller: controller),
    );
  }

  static const _timeStyle = TextStyle(
    color: Colors.white54,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.track});
  final dynamic track;

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    final liked = controller.isLiked(track);
    return GestureDetector(
      onTap: () => controller.toggleLike(track),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: liked ? Colors.redAccent : Colors.white60,
          size: 28,
        ),
      ),
    );
  }
}

class _TransportBtn extends StatelessWidget {
  const _TransportBtn({
    required this.icon,
    required this.onPressed,
    this.size = 28,
    this.color = Colors.white,
    this.dot = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color color;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: size),
          ),
          if (dot)
            Positioned(
              bottom: 2,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  const _ToolbarBtn({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class _TrackOptionsSheet extends StatelessWidget {
  const _TrackOptionsSheet({required this.controller});
  final dynamic controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _OptionTile(icon: Icons.favorite_border_rounded, label: 'Love', onTap: () => Navigator.pop(context)),
          _OptionTile(icon: Icons.playlist_add_rounded, label: 'Add to Playlist', onTap: () => Navigator.pop(context)),
          _OptionTile(icon: Icons.share_rounded, label: 'Share Song', onTap: () => Navigator.pop(context)),
          _OptionTile(icon: Icons.info_outline_rounded, label: 'Song Info', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
