import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/search_provider.dart';
import '../services/spotify_service.dart';

import '../theme/aetheris_colors.dart';

import '../models/track.dart';
import '../state/aetheris_scope.dart';
import '../widgets/album_art.dart';
import '../widgets/album_card.dart';
import '../widgets/section_label.dart';
import '../widgets/track_tile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<Track>? _madeForYou;
  List<Track>? _topPicks;
  bool _isFallback = false;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    final isLoggedIn = ref.read(isSignedInProvider);
    final spotify = ref.read(spotifyServiceProvider);
    
    if (isLoggedIn) {
      // Get recently played tracks for personalized seeds
      final recentTracks = await ref.read(firestoreSyncProvider).watchRecentlyPlayed(limit: 5).first;
      final seedTracks = recentTracks
          .where((t) => t.id.startsWith('spotify_'))
          .map((t) => t.id.replaceAll('spotify_', ''))
          .take(5)
          .toList();

      List<SpotifyTrack> recs = [];
      List<SpotifyTrack> top = [];

      if (seedTracks.isNotEmpty) {
        recs = await spotify.getRecommendations(seedTracks: seedTracks);
        // We can get another set for top picks by shuffling seeds or using genres
        top = await spotify.getRecommendations(seedGenres: ['pop', 'electronic'], limit: 10);
      } else {
        // Fallback for logged in user but no history
        recs = await spotify.getRecommendations(seedGenres: ['pop', 'acoustic', 'chill']);
        top = await spotify.getRecommendations(seedGenres: ['rock', 'electronic']);
      }
      
      if (mounted) {
        setState(() {
          _madeForYou = recs.map(_trackFromSpotify).toList();
          _topPicks = top.map(_trackFromSpotify).toList();
          _isFallback = false;
        });
      }
    } else {
      final fallbackMadeForYou = await spotify.searchTracks('trending acoustic', limit: 10);
      final fallbackTop = await spotify.searchTracks('top hits', limit: 10);
      
      if (mounted) {
        setState(() {
          _madeForYou = fallbackMadeForYou.map(_trackFromSpotify).toList();
          _topPicks = fallbackTop.map(_trackFromSpotify).toList();
          _isFallback = true;
        });
      }
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
      coverColors: const [Color(0xFF0F273F), Color(0xFF8C5B7D), Color(0xFF101422)],
      lyrics: const [],
      artworkUrl: track.albumArtUrl,
    );
  }

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
    final recentStream = ref.watch(firestoreSyncProvider).watchRecentlyPlayed(limit: 10);

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
        StreamBuilder<List<Track>>(
          stream: recentStream,
          builder: (context, snapshot) {
            final recent = snapshot.data ?? [];
            final displayTracks = recent.isEmpty ? controller.library.take(4).toList() : recent.take(4).toList();
            if (displayTracks.isEmpty) return const SizedBox.shrink();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayTracks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return _QuickAccessCell(track: displayTracks[index]);
              },
            );
          },
        ),
        const SizedBox(height: 32),

        // ── Recently Played ──────────────────────────────────────────────
        const SectionLabel('Recently Played'),
        const SizedBox(height: 14),
        StreamBuilder<List<Track>>(
          stream: recentStream,
          builder: (context, snapshot) {
            final recent = snapshot.data ?? [];
            final displayTracks = recent.isEmpty ? controller.library.take(10).toList() : recent;
            if (displayTracks.isEmpty) {
              return const SizedBox(
                height: 165,
                child: Center(child: Text('No recently played tracks', style: TextStyle(color: AetherisColors.textSecondary))),
              );
            }
            return SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayTracks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  return _RecentCard(track: displayTracks[i]);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // ── Made For You / Curated Discoveries ───────────────────────────
        SectionLabel(_isFallback ? 'Curated Discoveries' : 'Made For You'),
        const SizedBox(height: 14),
        if (_madeForYou == null)
          const SizedBox(height: 190, child: Center(child: CircularProgressIndicator(color: AetherisColors.accentSoft)))
        else if (_madeForYou!.isEmpty)
          const SizedBox(height: 190, child: Center(child: Text('Nothing to recommend right now.', style: TextStyle(color: AetherisColors.textSecondary))))
        else
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _madeForYou!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                return AlbumCard(track: _madeForYou![i]);
              },
            ),
          ),
        const SizedBox(height: 32),

        // ── Top Picks ────────────────────────────────────────────────────
        const SectionLabel('Top Picks'),
        const SizedBox(height: 12),
        if (_topPicks == null)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AetherisColors.accentSoft)))
        else
          for (final track in _topPicks!.take(5)) ...[
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
