import 'package:flutter/material.dart';

import '../theme/aetheris_colors.dart';

import '../pages/album_detail_page.dart';
import '../state/aetheris_scope.dart';
import '../widgets/album_art.dart';
import '../widgets/track_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _selectedFilter = 0;
  static const _filters = ['Playlists', 'Albums', 'Artists', 'Songs'];

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Library',
                  style: TextStyle(
                    color: AetherisColors.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.add_rounded, color: AetherisColors.accent, size: 28),
              ),
            ],
          ),
        ),

        // ── Filter Tabs ──────────────────────────────────────────────────────
        const SizedBox(height: 16),
        SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final selected = _selectedFilter == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? AetherisColors.textPrimary : AetherisColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      color: selected ? AetherisColors.background : AetherisColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // ── Content ──────────────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 176),
            children: [
              if (_selectedFilter == 3) ...[
                // Songs
                for (final track in controller.library) ...[
                  TrackTile(track: track),
                  Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 72),
                ],
              ] else if (_selectedFilter == 1) ...[
                // Albums
                for (final album in controller.albums) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: album.id == 'liked_songs'
                        ? Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                          )
                        : AlbumArt(
                            track: album.tracks.first,
                            size: 56,
                            radius: 8,
                            showBadge: false,
                          ),
                    title: Text(
                      album.title,
                      style: const TextStyle(
                        color: AetherisColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${album.artist} · ${album.tracks.length} songs',
                      style: const TextStyle(color: AetherisColors.textSecondary, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AetherisColors.textSecondary),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => AlbumDetailPage(album: album)),
                    ),
                  ),
                  Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 88),
                ],
              ] else if (_selectedFilter == 2) ...[
                // Artists
                ..._buildArtists(controller.library),
              ] else ...[
                // Playlists placeholder
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        Icon(Icons.library_music_rounded, size: 52, color: AetherisColors.textPrimary.withValues(alpha: 0.24)),
                        const SizedBox(height: 16),
                        const Text(
                          'No Playlists Yet',
                          style: TextStyle(color: AetherisColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create a playlist to get started',
                          style: TextStyle(color: AetherisColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildArtists(List<dynamic> tracks) {
    final seen = <String>{};
    final result = <Widget>[];
    for (final track in tracks) {
      if (seen.add(track.artist as String)) {
        result.add(
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: (track.coverColors as List<Color>)),
              ),
              child: const Icon(Icons.person_rounded, color: AetherisColors.textPrimary, size: 24),
            ),
            title: Text(
              track.artist as String,
              style: const TextStyle(color: AetherisColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Artist', style: TextStyle(color: AetherisColors.textSecondary, fontSize: 13)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AetherisColors.textSecondary),
            onTap: () {},
          ),
        );
        result.add(Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 84));
      }
    }
    return result;
  }
}
