import 'package:flutter/material.dart';

import '../models/track.dart';
import '../pages/metadata_editor_page.dart';
import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import 'album_art.dart';
import 'glass_container.dart';
import 'quality_badge.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    this.showIndex,
    this.compact = false,
  });

  final Track track;
  final int? showIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    final isCurrent = controller.currentTrack.id == track.id;

    return GlassContainer(
      padding: const EdgeInsets.all(10),
      color:
          isCurrent
              ? AetherisColors.accent.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.055),
      borderColor:
          isCurrent
              ? AetherisColors.accent.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.07),
      onTap: () => controller.playTrack(track),
      child: Row(
        children: [
          if (showIndex != null)
            SizedBox(
              width: 26,
              child: Text(
                showIndex.toString(),
                style: const TextStyle(
                  color: AetherisColors.textTertiary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            AlbumArt(track: track, size: compact ? 44 : 52, radius: 10),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AetherisColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 7),
                  TrackQualityBadges(track: track, compact: true),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit metadata',
            icon: const Icon(Icons.more_vert_rounded),
            color: AetherisColors.textSecondary,
            onPressed: () => showMetadataEditor(context, track),
          ),
        ],
      ),
    );
  }
}
