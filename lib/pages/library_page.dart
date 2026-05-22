import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

import '../theme/aetheris_colors.dart';

import '../models/track.dart';
import '../pages/album_detail_page.dart';
import '../state/aetheris_scope.dart';
import '../widgets/album_art.dart';
import '../widgets/track_tile.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
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
                onTap: () {
                  _showCreatePlaylistDialog();
                },
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
                StreamBuilder<List<Track>>(
                  stream: ref.watch(firestoreSyncProvider).watchSavedSongs(),
                  builder: (context, snapshot) {
                    final songs = snapshot.data ?? [];
                    final displaySongs = songs.isEmpty ? controller.library : songs;
                    return Column(
                      children: displaySongs.expand((track) => [
                        TrackTile(track: track),
                        Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 72),
                      ]).toList(),
                    );
                  },
                ),
              ] else if (_selectedFilter == 1) ...[
                // Albums
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: ref.watch(firestoreSyncProvider).watchSavedAlbums(),
                  builder: (context, snapshot) {
                    final albums = snapshot.data ?? [];
                    if (albums.isNotEmpty) {
                      return Column(
                        children: albums.expand((album) => [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AetherisColors.surfaceRaised,
                                borderRadius: BorderRadius.circular(8),
                                image: album['imageUrl'] != null
                                    ? DecorationImage(image: NetworkImage(album['imageUrl'] as String), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: album['imageUrl'] == null
                                  ? const Icon(Icons.album_rounded, color: AetherisColors.textPrimary, size: 28)
                                  : null,
                            ),
                            title: Text(
                              album['title'] as String? ?? 'Unknown Album',
                              style: const TextStyle(
                                color: AetherisColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${album['artist'] ?? 'Unknown'}',
                              style: const TextStyle(color: AetherisColors.textSecondary, fontSize: 13),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded, color: AetherisColors.textSecondary),
                            onTap: () {},
                          ),
                          Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 88),
                        ]).toList(),
                      );
                    }

                    // Fallback to local albums
                    return Column(
                      children: controller.albums.expand((album) => [
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
                      ]).toList(),
                    );
                  },
                ),
              ] else if (_selectedFilter == 2) ...[
                // Artists
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: ref.watch(firestoreSyncProvider).watchFollowedArtists(),
                  builder: (context, snapshot) {
                    final artists = snapshot.data ?? [];
                    if (artists.isNotEmpty) {
                      return Column(
                        children: artists.expand((artist) => [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AetherisColors.surfaceRaised,
                                image: artist['imageUrl'] != null
                                    ? DecorationImage(image: NetworkImage(artist['imageUrl'] as String), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: artist['imageUrl'] == null
                                  ? const Icon(Icons.person_rounded, color: AetherisColors.textPrimary, size: 24)
                                  : null,
                            ),
                            title: Text(
                              artist['name'] as String? ?? 'Unknown Artist',
                              style: const TextStyle(color: AetherisColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('Artist', style: TextStyle(color: AetherisColors.textSecondary, fontSize: 13)),
                            trailing: const Icon(Icons.chevron_right_rounded, color: AetherisColors.textSecondary),
                            onTap: () {},
                          ),
                          Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 84),
                        ]).toList(),
                      );
                    }

                    // Fallback to local artists
                    return Column(
                      children: _buildArtists(controller.library),
                    );
                  },
                ),
              ] else ...[
                // Playlists
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: ref.watch(firestoreSyncProvider).watchPlaylists(),
                  builder: (context, snapshot) {
                    final playlists = snapshot.data ?? [];
                    if (playlists.isEmpty) {
                      return Center(
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
                              const SizedBox(height: 8),
                              const Text(
                                'Tap the + icon to create a playlist',
                                style: TextStyle(color: AetherisColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: playlists.map((p) {
                        final trackCount = (p['tracks'] as List?)?.length ?? 0;
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              leading: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AetherisColors.surfaceRaised,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.queue_music_rounded, color: AetherisColors.textPrimary, size: 28),
                              ),
                              title: Text(
                                p['name'] as String? ?? 'Unnamed Playlist',
                                style: const TextStyle(
                                  color: AetherisColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '$trackCount songs',
                                style: const TextStyle(color: AetherisColors.textSecondary, fontSize: 13),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: AetherisColors.textSecondary),
                              onTap: () {
                                // TODO: Navigate to PlaylistDetailPage
                              },
                            ),
                            Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 88),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AetherisColors.surfaceRaised,
          title: const Text('Create Playlist', style: TextStyle(color: AetherisColors.textPrimary)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AetherisColors.textPrimary),
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(color: AetherisColors.textSecondary),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AetherisColors.textSecondary)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AetherisColors.accent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AetherisColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  ref.read(firestoreSyncProvider).createPlaylist(name);
                }
                Navigator.pop(context);
              },
              child: const Text('Create', style: TextStyle(color: AetherisColors.accent, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
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
                gradient: LinearGradient(
                  colors: track.coverColors.isEmpty
                      ? const [Color(0xFF0F273F), Color(0xFF8C5B7D)]
                      : (track.coverColors as List<Color>),
                ),
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
