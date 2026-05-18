import 'package:flutter/material.dart';

import '../models/track.dart';
import '../pages/album_detail_page.dart';
import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import 'album_art.dart';
import 'glass_container.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = GlassContainer(
          padding: EdgeInsets.zero,
          radius: 12,
          onTap: () => AetherisScope.of(context).playTrack(track),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AlbumArt(
                  track: track,
                  size: double.infinity,
                  radius: 12,
                  showBadge: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 4),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AetherisColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (constraints.hasBoundedWidth) {
          return content;
        }

        return SizedBox(width: 142, child: content);
      },
    );
  }
}

class DailyMixCard extends StatelessWidget {
  const DailyMixCard({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      radius: 12,
      onTap: () {
        final controller = AetherisScope.of(context);
        final mixAlbum = controller.albums.firstWhere((a) => a.title.contains('Daily') || a.id == 'liked_songs', orElse: () => controller.albums.first);
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => AlbumDetailPage(album: mixAlbum)),
        );
      },
      child: SizedBox(
        height: 150,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      track.coverColors.first.withValues(alpha: 0.90),
                      AetherisColors.surfaceElevated,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Mix',
                    style: TextStyle(
                      color: AetherisColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'A personalized blend of your favorite high-fidelity tracks.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AetherisColors.textSecondary,
                      fontSize: 14,
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
