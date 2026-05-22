import 'package:flutter/material.dart';

import '../theme/aetheris_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_library.dart';
import '../models/track.dart';
import '../providers/search_provider.dart';
import '../state/aetheris_scope.dart';
import '../widgets/album_art.dart';
import 'artist_profile_page.dart';
import 'metadata_editor_page.dart';
import 'spotify_album_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill controller if there is an existing query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = ref.read(searchQueryProvider);
      if (query.isNotEmpty) {
        _controller.text = query;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appController = AetherisScope.of(context);
    final searchState = ref.watch(searchStateProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final currentQuery = ref.watch(searchQueryProvider);

    return ListView(
      key: const ValueKey('search'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 176),
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: Text(
            'Search',
            style: TextStyle(
              color: AetherisColors.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // ── Search Field ─────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AetherisColors.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AetherisColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: AetherisColors.textPrimary, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Artists, songs, or podcasts',
                    hintStyle: TextStyle(color: AetherisColors.textSecondary, fontSize: 16),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                ),
              ),
              if (currentQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    ref.read(searchStateProvider.notifier).clear();
                  },
                  child: const Icon(Icons.cancel_rounded, color: AetherisColors.textSecondary, size: 20),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Search Source Chips ──────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SourceChip(label: 'All', value: SearchSource.all, current: searchState.activeSource),
              const SizedBox(width: 8),
              _SourceChip(label: 'Spotify', value: SearchSource.spotify, current: searchState.activeSource),
              const SizedBox(width: 8),
              _SourceChip(label: 'YouTube Music', value: SearchSource.youtube, current: searchState.activeSource),
              const SizedBox(width: 8),
              _SourceChip(label: 'Local', value: SearchSource.local, current: searchState.activeSource),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Search results ───────────────────────────────────────────────────
        if (currentQuery.isNotEmpty) ...[
          if (searchState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: CircularProgressIndicator(color: AetherisColors.accentSoft),
              ),
            )
          else if (searchState.error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  searchState.error!,
                  style: const TextStyle(color: AetherisColors.error, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (searchState.results.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'No results found',
                  style: TextStyle(color: AetherisColors.textPrimary.withValues(alpha: 0.54), fontSize: 16),
                ),
              ),
            )
          else ...[
            Text(
              '${searchState.results.length} results for "$currentQuery"',
              style: TextStyle(color: AetherisColors.textPrimary.withValues(alpha: 0.54), fontSize: 13),
            ),
            const SizedBox(height: 14),
            for (final result in searchState.results) ...[
              _SearchResultRow(result: result),
              Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 72),
            ],
          ],
        ] else ...[
          // ── Recent Searches ─────────────────────────────────────────────
          if (recentSearches.isNotEmpty) ...[
            const Text(
              'Recent Searches',
              style: TextStyle(
                color: AetherisColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final query in recentSearches.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_rounded, color: AetherisColors.textSecondary),
                title: Text(
                  query,
                  style: const TextStyle(color: AetherisColors.textPrimary, fontSize: 16),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, color: AetherisColors.textSecondary, size: 20),
                  onPressed: () => ref.read(recentSearchesProvider.notifier).removeSearch(query),
                ),
                onTap: () {
                  _controller.text = query;
                  ref.read(searchStateProvider.notifier).search(query);
                },
              ),
            const SizedBox(height: 32),
          ],
          const Text(
            'Browse Categories',
            style: TextStyle(
              color: AetherisColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: genres.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final genre = genres[index];
              return _GenreCard(name: genre.$1, colors: genre.$2);
            },
          ),
          const SizedBox(height: 32),

          // ── Recently Searched ─────────────────────────────────────────────
          const Text(
            'Your Library',
            style: TextStyle(
              color: AetherisColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final track in appController.library.take(5)) ...[
            _SearchTrackRow(track: track),
            Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 64),
          ],
        ],
      ],
    );
  }
}

class _SourceChip extends ConsumerWidget {
  const _SourceChip({required this.label, required this.value, required this.current});
  final String label;
  final SearchSource value;
  final SearchSource current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == current;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => ref.read(searchSourceProvider.notifier).state = value,
      selectedColor: AetherisColors.accentSoft,
      backgroundColor: AetherisColors.surfaceRaised,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AetherisColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.result});
  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    final isTrack = result.type == SearchResultType.track;
    final track = isTrack ? result.toTrack() : Track.empty;
    
    Widget badge;
    if (result.type == SearchResultType.artist) {
      badge = _Badge(color: AetherisColors.accentSoft, icon: Icons.person_rounded);
    } else if (result.type == SearchResultType.album) {
      badge = _Badge(color: Colors.blueGrey, icon: Icons.album_rounded);
    } else if (result.type == SearchResultType.playlist) {
      badge = _Badge(color: Colors.green, icon: Icons.queue_music_rounded);
    } else {
      badge = const SizedBox();
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          children: [
            if (isTrack)
              AlbumArt(track: track, size: 48, radius: 4, showBadge: false)
            else
              _SearchArtwork(
                imageUrl: result.coverUrl,
                isCircle: result.type == SearchResultType.artist,
              ),
            if (result.type != SearchResultType.track)
              Positioned(right: -2, bottom: -2, child: badge),
          ],
        ),
      ),
      title: Text(
        result.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AetherisColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _subtitleFor(result),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AetherisColors.textSecondary, fontSize: 13),
      ),
      trailing: result.type == SearchResultType.artist
          ? const Icon(Icons.chevron_right_rounded, color: AetherisColors.textSecondary)
          : GestureDetector(
              onTap: isTrack
                  ? () => showTrackOptions(context, track)
                  : null,
              child: const Icon(Icons.more_horiz_rounded, color: AetherisColors.textSecondary),
            ),
      onTap: () {
        if (result.type == SearchResultType.artist &&
            result.spotifyArtist != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ArtistProfilePage(artist: result.spotifyArtist!),
            ),
          );
          return;
        }
        if (result.type == SearchResultType.album &&
            result.spotifyAlbum != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SpotifyAlbumPage(album: result.spotifyAlbum!),
            ),
          );
          return;
        }
        if (isTrack) {
          controller.playTrack(track);
        }
      },
    );
  }

  static String _subtitleFor(SearchResult result) {
    return switch (result.type) {
      SearchResultType.artist => 'Artist',
      SearchResultType.album => 'Album • ${result.artist}',
      SearchResultType.playlist => 'Playlist • ${result.artist}',
      SearchResultType.track => result.source == SearchSource.spotify
          ? 'Song • ${result.artist}'
          : result.artist,
    };
  }
}

class _SearchArtwork extends StatelessWidget {
  const _SearchArtwork({required this.imageUrl, required this.isCircle});

  final String? imageUrl;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final radius = isCircle ? 24.0 : 4.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: 48,
        height: 48,
        color: AetherisColors.surfaceRaised,
        child: imageUrl == null
            ? Icon(
                isCircle ? Icons.person_rounded : Icons.music_note_rounded,
                color: AetherisColors.textSecondary,
              )
            : Image.network(imageUrl!, fit: BoxFit.cover),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.color, required this.icon});
  final Color color;
  final IconData icon;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 10),
    );
  }
}

class _SearchTrackRow extends StatelessWidget {
  const _SearchTrackRow({required this.track});
  final dynamic track;

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: AlbumArt(track: track, size: 48, radius: 4, showBadge: false),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AetherisColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AetherisColors.textSecondary, fontSize: 13),
      ),
      trailing: GestureDetector(
        onTap: () => showTrackOptions(context, track as Track),
        child: const Icon(Icons.more_horiz_rounded, color: AetherisColors.textSecondary),
      ),
      onTap: () => controller.playTrack(track),
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({required this.name, required this.colors});

  final String name;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(14),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          name,
          style: const TextStyle(
            color: AetherisColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
