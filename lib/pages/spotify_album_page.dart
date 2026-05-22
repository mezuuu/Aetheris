import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/track.dart';
import '../providers/search_provider.dart';
import '../services/spotify_service.dart';
import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/album_art.dart';
import '../widgets/ambient_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/track_tile.dart';

class SpotifyAlbumPage extends ConsumerStatefulWidget {
  const SpotifyAlbumPage({super.key, required this.album});

  final SpotifyAlbum album;

  @override
  ConsumerState<SpotifyAlbumPage> createState() => _SpotifyAlbumPageState();
}

class _SpotifyAlbumPageState extends ConsumerState<SpotifyAlbumPage> {
  late final Future<List<Track>> _tracksFuture;

  @override
  void initState() {
    super.initState();
    _tracksFuture = _loadTracks();
  }

  Future<List<Track>> _loadTracks() async {
    final spotify = ref.read(spotifyServiceProvider);
    final tracks = await spotify.getAlbumTracks(
      widget.album.id,
      albumName: widget.album.title,
      albumImageUrl: widget.album.imageUrl,
    );
    return tracks.map(_trackFromSpotify).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Track>>(
      future: _tracksFuture,
      builder: (context, snapshot) {
        final tracks = snapshot.data ?? const <Track>[];
        final coverTrack = tracks.isNotEmpty
            ? tracks.first
            : Track(
                id: 'spotify_album_${widget.album.id}',
                title: widget.album.title,
                artist: widget.album.artist,
                album: widget.album.title,
                format: 'AAC',
                bitDepth: 16,
                sampleRateKhz: 44,
                duration: Duration.zero,
                coverColors: const [
                  Color(0xFF0F273F),
                  Color(0xFF8C5B7D),
                  Color(0xFF101422),
                ],
                lyrics: const [],
                artworkUrl: widget.album.imageUrl,
              );
        return Scaffold(
          body: Stack(
            children: [
              AmbientBackground(
                colors: coverTrack.coverColors,
                artworkUrl: widget.album.imageUrl,
              ),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 160),
                      children: [
                        Row(
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.07),
                              ),
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: AetherisColors.textSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: AlbumArt(
                            track: coverTrack,
                            size: 220,
                            radius: 18,
                            highResolution: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.album.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AetherisColors.textPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.album.artist,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AetherisColors.textSecondary,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (snapshot.connectionState ==
                            ConnectionState.waiting)
                          const Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AetherisColors.accentSoft,
                              ),
                            ),
                          )
                        else if (tracks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: Text(
                              'No tracks found',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: AetherisColors.textSecondary),
                            ),
                          )
                        else ...[
                          PrimaryButton(
                            label: 'Play',
                            icon: Icons.play_arrow_rounded,
                            onPressed: () {
                              final controller = AetherisScope.of(context);
                              controller.setQueue(tracks, startAt: tracks.first);
                            },
                          ),
                          const SizedBox(height: 28),
                          for (var i = 0; i < tracks.length; i++) ...[
                            TrackTile(track: tracks[i], showIndex: i + 1),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Track _trackFromSpotify(SpotifyTrack track) {
  return Track(
    id: 'spotify_${track.id}',
    title: track.title,
    artist: track.artist,
    album: track.album,
    format: 'AAC',
    bitDepth: 16,
    sampleRateKhz: 44,
    duration: track.duration,
    coverColors: const [
      Color(0xFF0F273F),
      Color(0xFF8C5B7D),
      Color(0xFF101422),
    ],
    lyrics: const [],
    artworkUrl: track.albumArtUrl,
  );
}
