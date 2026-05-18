import 'package:flutter/material.dart';

import '../models/track.dart';
import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/album_art.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/quality_badge.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  bool _partyMode = false;

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
                child: Column(
                  children: [
                    // ── Header ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        children: [
                          _GlassIconBtn(
                            icon: Icons.keyboard_arrow_down_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.graphic_eq_rounded,
                                      size: 14,
                                      color: AetherisColors.mutedSky,
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'QUEUE',
                                      style: TextStyle(
                                        color: AetherisColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Up Next',
                                  style: TextStyle(
                                    color: AetherisColors.mutedSky,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _GlassIconBtn(
                            icon: Icons.shuffle_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Now Playing card ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _NowPlayingCard(track: controller.currentTrack),
                    ),
                    const SizedBox(height: 14),

                    // ── Action buttons ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionBtn(
                              icon: Icons.shuffle_rounded,
                              label: 'Shuffle',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionBtn(
                              icon: Icons.playlist_add_check_rounded,
                              label: 'Save',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionBtn(
                              icon: Icons.clear_all_rounded,
                              label: 'Clear',
                              color: Colors.red.withValues(alpha: 0.70),
                              onTap: () {
                                setState(() => controller.queue.clear());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Drag-to-reorder queue list ───────────────
                    Expanded(
                      child:
                          controller.queue.isEmpty
                              ? const _EmptyQueue()
                              : ReorderableListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                itemCount: controller.queue.length,
                                proxyDecorator:
                                    (child, index, animation) => Material(
                                      color: Colors.transparent,
                                      child: child,
                                    ),
                                onReorder: (oldIndex, newIndex) {
                                  setState(
                                    () => controller.reorderQueue(
                                      oldIndex,
                                      newIndex,
                                    ),
                                  );
                                },
                                itemBuilder: (context, i) {
                                  final track = controller.queue[i];
                                  return _QueueTile(
                                    key: ValueKey(track.id),
                                    track: track,
                                    index: i + 1,
                                    onPlay: () {
                                      setState(
                                        () => controller.playTrack(track),
                                      );
                                      Navigator.pop(context);
                                    },
                                    onRemove:
                                        () => setState(
                                          () =>
                                              controller.removeFromQueue(track),
                                        ),
                                    onLike:
                                        () => setState(
                                          () => controller.toggleLike(track),
                                        ),
                                    isLiked: controller.isLiked(track),
                                  );
                                },
                              ),
                    ),

                    // ── Listening Party toggle ───────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.09),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AetherisColors.mutedSky.withValues(
                                  alpha: 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.people_rounded,
                                color: AetherisColors.mutedSky,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Listening Party',
                                    style: TextStyle(
                                      color: AetherisColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Allow guests to add songs',
                                    style: TextStyle(
                                      color: AetherisColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _partyMode,
                              onChanged: (v) => setState(() => _partyMode = v),
                            ),
                          ],
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

// ── Now Playing card ─────────────────────────────────────────────────────────
class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    return GlassContainer(
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AlbumArt(track: track, size: 52, radius: 10),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
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
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                color: AetherisColors.textSecondary,
                onPressed: () => _showTrackOptions(context, track, controller),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TrackQualityBadges(track: track, compact: true),
        ],
      ),
    );
  }
}

// ── Draggable queue tile ──────────────────────────────────────────────────────
class _QueueTile extends StatelessWidget {
  const _QueueTile({
    super.key,
    required this.track,
    required this.index,
    required this.onPlay,
    required this.onRemove,
    required this.onLike,
    required this.isLiked,
  });

  final Track track;
  final int index;
  final VoidCallback onPlay;
  final VoidCallback onRemove;
  final VoidCallback onLike;
  final bool isLiked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPlay,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: index - 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: Colors.white.withValues(alpha: 0.28),
                      size: 20,
                    ),
                  ),
                ),

                // Index number
                SizedBox(
                  width: 22,
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Album art
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(colors: track.coverColors),
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),

                // Title + artist + badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AetherisColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          QualityBadge(label: track.format, compact: true),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Duration
                Text(
                  track.durationLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),

                // Three-dot menu
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.white.withValues(alpha: 0.40),
                  onPressed: () => _showTrackMenu(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTrackMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _TrackMenuSheet(
            track: track,
            isLiked: isLiked,
            onLike: onLike,
            onRemove: onRemove,
          ),
    );
  }
}

// ── Three-dot menu sheet ─────────────────────────────────────────────────────
class _TrackMenuSheet extends StatelessWidget {
  const _TrackMenuSheet({
    required this.track,
    required this.isLiked,
    required this.onLike,
    required this.onRemove,
  });

  final Track track;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom + 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF0121220),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            // Song header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(colors: track.coverColors),
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
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
            const SizedBox(height: 16),
            const Divider(color: Color(0x14FFFFFF), height: 1),

            // Options
            _MenuTile(
              icon:
                  isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
              label: isLiked ? 'Remove from Liked' : 'Add to Liked Songs',
              color: isLiked ? Colors.redAccent : AetherisColors.textPrimary,
              onTap: () {
                onLike();
                Navigator.pop(context);
              },
            ),
            _MenuTile(
              icon: Icons.playlist_add_rounded,
              label: 'Add to Album / Playlist',
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylist(context);
              },
            ),
            _MenuTile(
              icon: Icons.delete_outline_rounded,
              label: 'Remove from Queue',
              color: Colors.redAccent.withValues(alpha: 0.80),
              onTap: () {
                onRemove();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylist(BuildContext context) {
    final albums = AetherisScope.of(context).albums;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xF0121220),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add to Album',
                    style: TextStyle(
                      color: AetherisColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final album in albums)
                    _MenuTile(
                      icon: Icons.album_rounded,
                      label: album.title,
                      subtitle: album.artist,
                      onTap: () => Navigator.pop(context),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: clr,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AetherisColors.textSecondary,
                        fontSize: 12,
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

// ── Action button (Shuffle / Save / Clear) ────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
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
    final clr = color ?? Colors.white.withValues(alpha: 0.70);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: clr, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: clr,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty queue placeholder ───────────────────────────────────────────────────
class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.queue_music_rounded,
            size: 52,
            color: Colors.white.withValues(alpha: 0.22),
          ),
          const SizedBox(height: 12),
          Text(
            'Queue is empty',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add songs to get started',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glass icon button ─────────────────────────────────────────────────────────
class _GlassIconBtn extends StatelessWidget {
  const _GlassIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.65),
          size: 20,
        ),
      ),
    );
  }
}

// ── Top-level helper (also used by NowPlayingCard) ────────────────────────────
void _showTrackOptions(BuildContext context, Track track, dynamic controller) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder:
        (_) => _TrackMenuSheet(
          track: track,
          isLiked: controller.isLiked(track),
          onLike: () => controller.toggleLike(track),
          onRemove: () {},
        ),
  );
}
