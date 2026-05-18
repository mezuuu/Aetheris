import 'package:flutter/material.dart';

import '../models/album.dart';
import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/album_art.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/primary_button.dart';
import '../widgets/track_tile.dart';

class AlbumDetailPage extends StatelessWidget {
  const AlbumDetailPage({super.key, required this.album});
  
  final Album album;

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);

    return Scaffold(
      body: Stack(
        children: [
          AmbientBackground(colors: album.tracks.first.coverColors),
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
                        const Spacer(),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.07,
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.more_horiz_rounded),
                          color: AetherisColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: album.id == 'liked_songs'
                          ? Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 100),
                            )
                          : AlbumArt(
                              track: album.tracks.first,
                              size: 220,
                              radius: 18,
                            ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      album.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AetherisColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      album.artist,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AetherisColors.textSecondary,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      album.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AetherisColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Play',
                            icon: Icons.play_arrow_rounded,
                            onPressed:
                                () => controller.playTrack(album.tracks.first),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GlassContainer(
                          padding: EdgeInsets.zero,
                          radius: 999,
                          child: IconButton(
                            tooltip: 'Shuffle',
                            color: AetherisColors.textPrimary,
                            onPressed:
                                () => controller.playTrack(album.tracks.last),
                            icon: const Icon(Icons.shuffle_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    for (var i = 0; i < album.tracks.length; i++) ...[
                      TrackTile(track: album.tracks[i], showIndex: i + 1),
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
