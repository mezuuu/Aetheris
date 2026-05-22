import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/track.dart';
import '../providers/auth_provider.dart';
import '../providers/search_provider.dart';
import '../services/spotify_service.dart';
import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/album_art.dart';

class ArtistProfilePage extends ConsumerStatefulWidget {
  const ArtistProfilePage({super.key, required this.artist});

  final SpotifyArtist artist;

  @override
  ConsumerState<ArtistProfilePage> createState() => _ArtistProfilePageState();
}

class _ArtistProfilePageState extends ConsumerState<ArtistProfilePage> {
  late Future<_ArtistProfileData> _profileFuture;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final artistId = widget.artist.id;
    if (artistId.trim().isNotEmpty) {
      final isFollowing = await ref.read(firestoreSyncProvider).isFollowingArtist(artistId);
      if (mounted) {
        setState(() => _isFollowing = isFollowing);
      }
    }
  }

  Future<void> _toggleFollow() async {
    final artistId = widget.artist.id;
    if (artistId.trim().isEmpty) return;

    final syncService = ref.read(firestoreSyncProvider);
    final isNowFollowing = !_isFollowing;
    
    setState(() => _isFollowing = isNowFollowing);

    if (isNowFollowing) {
      await syncService.followArtist(artistId, {
        'id': artistId,
        'name': widget.artist.name,
        'imageUrl': widget.artist.imageUrl,
        'followers': widget.artist.followers,
      });
    } else {
      await syncService.unfollowArtist(artistId);
    }
  }

  Future<_ArtistProfileData> _loadProfile() async {
    final spotify = ref.read(spotifyServiceProvider);
    final artist = await _resolveExactArtist(spotify) ?? widget.artist;
    final artistId = artist.id.trim();

    final topTracksFuture = artistId.isEmpty
        ? Future<List<SpotifyTrack>>.value(const [])
        : spotify.getArtistTopTracks(artistId);
    final officialAlbumsFuture = artistId.isEmpty
        ? Future<List<SpotifyAlbum>>.value(const [])
        : spotify.getArtistAlbums(artistId, limit: 50);

    final results = await Future.wait<Object>([
      topTracksFuture,
      officialAlbumsFuture,
      spotify.searchAlbums(widget.artist.name, limit: 40),
      spotify.searchPlaylists(widget.artist.name, limit: 20),
      spotify.searchArtistTracks(widget.artist.name, limit: 60),
      spotify.searchTracks(widget.artist.name, limit: 60),
    ]);

    final topTracks = results[0] as List<SpotifyTrack>;
    final officialAlbums = results[1] as List<SpotifyAlbum>;
    final searchedAlbums = results[2] as List<SpotifyAlbum>;
    final playlists = results[3] as List<SpotifyPlaylist>;
    final artistSearchTracks = results[4] as List<SpotifyTrack>;
    final generalSearchTracks = results[5] as List<SpotifyTrack>;
    final ownedAlbums = _dedupeAlbums([
      ...officialAlbums,
      ...searchedAlbums.where(_albumBelongsToArtist),
    ]);

    final albumTracks = <SpotifyTrack>[];
    for (final album in ownedAlbums.take(12)) {
      final tracks = await spotify.getAlbumTracks(
        album.id,
        albumName: album.title,
        albumImageUrl: album.imageUrl,
      );
      albumTracks.addAll(tracks);
    }

    return _ArtistProfileData(
      tracks: _dedupeTracks([
        ...topTracks.where(_trackBelongsToArtist),
        ...artistSearchTracks.where(_trackBelongsToArtist),
        ...generalSearchTracks.where(_trackBelongsToArtist),
        ...albumTracks,
      ]),
      albums: ownedAlbums,
      playlists: playlists.where(_playlistBelongsToArtist).toList(growable: false),
    );
  }

  bool _trackBelongsToArtist(SpotifyTrack track) {
    return _artistParts(track.artist).any(_sameArtistName);
  }

  bool _albumBelongsToArtist(SpotifyAlbum album) {
    return _artistParts(album.artist).any(_sameArtistName);
  }

  bool _playlistBelongsToArtist(SpotifyPlaylist playlist) {
    return _containsExactArtistToken(playlist.name) ||
        _containsExactArtistToken(playlist.owner);
  }

  bool _sameArtistName(String value) {
    final target = _normalizeArtistName(widget.artist.name);
    return target.isNotEmpty && _normalizeArtistName(value) == target;
  }

  static List<SpotifyTrack> _dedupeTracks(List<SpotifyTrack> tracks) {
    final seen = <String>{};
    return tracks.where((track) {
      final key = '${track.id}|${track.title.toLowerCase()}|${track.artist.toLowerCase()}';
      return seen.add(key);
    }).toList(growable: false);
  }

  static List<SpotifyAlbum> _dedupeAlbums(List<SpotifyAlbum> albums) {
    final seen = <String>{};
    return albums.where((album) {
      final key = album.id.isNotEmpty
          ? album.id
          : '${album.title.toLowerCase()}|${album.artist.toLowerCase()}';
      return seen.add(key);
    }).toList(growable: false);
  }

  bool _containsExactArtistToken(String value) {
    final target = widget.artist.name.trim();
    if (target.isEmpty) {
      return false;
    }
    return RegExp(
      r'(^|[^A-Za-z0-9])' + RegExp.escape(target) + r'([^A-Za-z0-9]|$)',
    ).hasMatch(value);
  }

  Future<SpotifyArtist?> _resolveExactArtist(SpotifyService spotify) async {
    if (widget.artist.id.trim().isNotEmpty) {
      return widget.artist;
    }
    final artists = await spotify.searchArtists(widget.artist.name, limit: 10);
    for (final artist in artists) {
      if (_sameArtistName(artist.name) && artist.id.trim().isNotEmpty) {
        return artist;
      }
    }
    return null;
  }

  static List<String> _artistParts(String value) {
    return value
        .split(RegExp(
          r'\s*(,|&| and | x | with | feat\.? | ft\.? | featuring )\s*',
          caseSensitive: false,
        ))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  static String _normalizeArtistName(String value) {
    // Preserve case to distinguish artists like "RYO" vs "Ryo".
    // Only normalize whitespace for comparison.
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AetherisColors.background,
      body: FutureBuilder<_ArtistProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final data = snapshot.data ?? const _ArtistProfileData();
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AetherisColors.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AetherisColors.textPrimary,
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  title: Text(
                    widget.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AetherisColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 34,
                    ),
                  ),
                  background: _ArtistHeaderImage(url: widget.artist.imageUrl),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _followersLabel(widget.artist.followers),
                            style: const TextStyle(
                              color: AetherisColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _toggleFollow,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isFollowing ? AetherisColors.surfaceRaised : Colors.transparent,
                                border: Border.all(
                                  color: _isFollowing ? Colors.transparent : AetherisColors.textSecondary,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _isFollowing ? 'Following' : 'Follow',
                                style: TextStyle(
                                  color: _isFollowing ? AetherisColors.accent : AetherisColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          _PlayArtistButton(tracks: data.tracks),
                        ],
                      ),
                      if (widget.artist.genres.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          widget.artist.genres.take(4).join(' • '),
                          style: const TextStyle(
                            color: AetherisColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      const _SectionTitle('Popular'),
                      const SizedBox(height: 10),
                      if (isLoading)
                        const _SectionLoading()
                      else if (data.tracks.isEmpty)
                        const _EmptySection('No popular tracks found')
                      else
                        for (final entry in data.tracks.take(10).indexed)
                          _ArtistTrackRow(index: entry.$1 + 1, track: entry.$2),
                      const SizedBox(height: 28),
                      const _SectionTitle('Albums & Singles'),
                      const SizedBox(height: 14),
                      if (isLoading)
                        const _SectionLoading()
                      else
                        _HorizontalSpotifyCards(
                          items: [
                            for (final album in data.albums)
                              _SpotifyCardData(
                                title: album.title,
                                subtitle: album.releaseDate ?? album.artist,
                                imageUrl: album.imageUrl,
                              ),
                          ],
                          emptyText: 'No albums found',
                        ),
                      const SizedBox(height: 28),
                      const _SectionTitle('Featuring Playlists'),
                      const SizedBox(height: 14),
                      if (isLoading)
                        const _SectionLoading()
                      else
                        _HorizontalSpotifyCards(
                          items: [
                            for (final playlist in data.playlists)
                              _SpotifyCardData(
                                title: playlist.name,
                                subtitle: playlist.owner,
                                imageUrl: playlist.imageUrl,
                              ),
                          ],
                          emptyText: 'No playlists found',
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _followersLabel(int? followers) {
    if (followers == null || followers <= 0) {
      return 'Artist';
    }
    return '${_compactNumber(followers)} followers';
  }

  static String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

class _ArtistProfileData {
  const _ArtistProfileData({
    this.tracks = const [],
    this.albums = const [],
    this.playlists = const [],
  });

  final List<SpotifyTrack> tracks;
  final List<SpotifyAlbum> albums;
  final List<SpotifyPlaylist> playlists;
}

class _ArtistHeaderImage extends StatelessWidget {
  const _ArtistHeaderImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (url != null)
          Image.network(url!, fit: BoxFit.cover)
        else
          Container(color: AetherisColors.surfaceRaised),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x33000000),
                Color(0xCC000000),
                AetherisColors.background,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayArtistButton extends StatelessWidget {
  const _PlayArtistButton({required this.tracks});

  final List<SpotifyTrack> tracks;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF5CDF68),
        foregroundColor: Colors.black,
        fixedSize: const Size(58, 58),
      ),
      icon: const Icon(Icons.play_arrow_rounded, size: 34),
      onPressed: tracks.isEmpty
          ? null
          : () {
              final controller = AetherisScope.of(context);
              controller.playTrack(_trackFromSpotify(tracks.first));
            },
    );
  }
}

class _ArtistTrackRow extends StatelessWidget {
  const _ArtistTrackRow({required this.index, required this.track});

  final int index;
  final SpotifyTrack track;

  @override
  Widget build(BuildContext context) {
    final appController = AetherisScope.of(context);
    final playableTrack = _trackFromSpotify(track);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 56,
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AetherisColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
            AlbumArt(track: playableTrack, size: 42, radius: 4, showBadge: false),
          ],
        ),
      ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AetherisColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AetherisColors.textSecondary),
      ),
      trailing: const Icon(Icons.more_vert_rounded, color: AetherisColors.textSecondary),
      onTap: () => appController.playTrack(playableTrack),
    );
  }
}

class _HorizontalSpotifyCards extends StatelessWidget {
  const _HorizontalSpotifyCards({required this.items, required this.emptyText});

  final List<_SpotifyCardData> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptySection(emptyText);
    }
    return SizedBox(
      height: 184,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 136,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: item.imageUrl == null
                        ? Container(color: AetherisColors.surfaceRaised)
                        : Image.network(item.imageUrl!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AetherisColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AetherisColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SpotifyCardData {
  const _SpotifyCardData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AetherisColors.textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(
          color: AetherisColors.accentSoft,
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: const TextStyle(color: AetherisColors.textSecondary),
      ),
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
