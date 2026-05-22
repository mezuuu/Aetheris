import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_scroll/text_scroll.dart';
import '../providers/services_provider.dart';

import '../models/track.dart';
import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/album_art.dart';
import '../widgets/ambient_background.dart';
import 'download_sheet.dart';
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
          AmbientBackground(
            colors: track.coverColors,
            artworkUrl: track.artworkUrl,
          ),

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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'PLAYING FROM LIBRARY',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              TextScroll(
                                track.album,
                                mode: TextScrollMode.endless,
                                velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
                                delayBefore: const Duration(milliseconds: 2000),
                                pauseBetween: const Duration(milliseconds: 1000),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                      child: AnimatedScale(
                        scale: controller.isPlaying ? 1.0 : 0.82,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
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
                                  highResolution: true,
                                );
                              }
                            ),
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
                                _AudioLabel(track: track),
                                const SizedBox(height: 10),
                                Text(
                                  track.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.08,
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
                              '-${_fmt(controller.remaining)}',
                              style: _timeStyle,
                            ),
                          ],
                        ),
                      ),
                      if (controller.playbackError != null) ...[
                        const SizedBox(height: 10),
                        _PlaybackErrorBanner(message: controller.playbackError!),
                      ],
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
                      const SizedBox(height: 20),
                      
                      const SizedBox(height: 4),
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
      backgroundColor: Colors.transparent,
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

class _AudioLabel extends StatelessWidget {
  const _AudioLabel({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final pieces = [
      track.format.toUpperCase(),
      '${track.bitDepth}-bit',
      '${track.sampleRateKhz} kHz',
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final piece in pieces)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              piece,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}

class _PlaybackErrorBanner extends StatelessWidget {
  const _PlaybackErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.26)),
      ),
      child: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.86),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.25,
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

// ── Player track options (three-dot menu) ─────────────────────────────────────

class _TrackOptionsSheet extends ConsumerWidget {
  const _TrackOptionsSheet({required this.controller});
  final dynamic controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = controller.currentTrack as Track;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom + 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF2101018),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),

            // Track header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  AlbumArt(track: track, size: 44, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AetherisColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          track.artist,
                          style: const TextStyle(
                            color: AetherisColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),

            // Options
            _OptTile(
              icon: Icons.file_download_rounded,
              label: 'Download',
              onTap: () {
                Navigator.pop(context);
                final service = ref.read(downloadServiceProvider);
                showDownloadSheet(context, track: track, downloadService: service);
              },
            ),
            _OptTile(
              icon: Icons.favorite_border_rounded,
              label: 'Love',
              onTap: () {
                controller.toggleLike(track);
                Navigator.pop(context);
              },
            ),
            _OptTile(
              icon: Icons.playlist_add_rounded,
              label: 'Add to Playlist',
              onTap: () => Navigator.pop(context),
            ),
            _OptTile(
              icon: Icons.share_rounded,
              label: 'Share Song',
              onTap: () => Navigator.pop(context),
            ),
            _OptTile(
              icon: Icons.block_rounded,
              label: "Don't Recommend",
              color: Colors.redAccent.withValues(alpha: 0.8),
              onTap: () {
                controller.blacklistTrack(track);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '"${track.title}" won\'t appear in auto-queue anymore',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xE0101018),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: AetherisColors.accent,
                      onPressed: () => controller.unblacklistTrack(track),
                    ),
                  ),
                );
              },
            ),
            _OptTile(
              icon: Icons.info_outline_rounded,
              label: 'Song Info',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OptTile extends StatelessWidget {
  const _OptTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final clr = color ?? AetherisColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: clr, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: clr,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
