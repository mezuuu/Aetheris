import 'package:flutter/material.dart';

import '../theme/aetheris_colors.dart';

import '../models/track.dart';
import '../state/aetheris_scope.dart';
import '../widgets/album_art.dart';
import '../widgets/album_card.dart';
import '../widgets/section_label.dart';
import '../widgets/track_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Good Night';
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);

    return ListView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 176),
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _greeting(),
                  style: const TextStyle(
                    color: AetherisColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _AvatarButton(),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ── Quick Access Grid (2 per row, 4 total) ───────────────────────
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final track = controller.library[index % controller.library.length];
            return _QuickAccessCell(track: track);
          },
        ),
        const SizedBox(height: 32),

        // ── Recently Played ──────────────────────────────────────────────
        const SectionLabel('Recently Played'),
        const SizedBox(height: 14),
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.library.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final track = controller.library[i];
              return _RecentCard(track: track);
            },
          ),
        ),
        const SizedBox(height: 32),

        // ── Made For You ─────────────────────────────────────────────────
        const SectionLabel('Made For You'),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.library.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final track = controller.library[i];
              return AlbumCard(track: track);
            },
          ),
        ),
        const SizedBox(height: 32),

        // ── Top Picks ────────────────────────────────────────────────────
        const SectionLabel('Top Picks'),
        const SizedBox(height: 12),
        for (final track in controller.library.take(5)) ...[
          TrackTile(track: track),
          Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 72),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Quick Access Cell (Spotify-style) ───────────────────────────────────────
class _QuickAccessCell extends StatelessWidget {
  const _QuickAccessCell({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    return GestureDetector(
      onTap: () => controller.playTrack(track),
      child: Container(
        decoration: BoxDecoration(
          color: AetherisColors.surfaceRaised,
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            AlbumArt(track: track, size: 48, radius: 0, showBadge: false),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                track.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AetherisColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Card ─────────────────────────────────────────────────────────────
class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    return GestureDetector(
      onTap: () => controller.playTrack(track),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AlbumArt(track: track, size: 120, radius: 8, showBadge: false),
            const SizedBox(height: 6),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AetherisColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AetherisColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar button ───────────────────────────────────────────────────────────
class _AvatarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF535353),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_rounded, color: AetherisColors.textPrimary, size: 20),
      ),
    );
  }
}
