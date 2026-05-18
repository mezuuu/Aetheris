import 'package:flutter/material.dart';

import '../theme/aetheris_colors.dart';

import '../data/demo_library.dart';
import '../state/aetheris_scope.dart';
import '../widgets/album_art.dart';
import '../widgets/track_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appController = AetherisScope.of(context);
    final results = _query.isEmpty ? <dynamic>[] : appController.searchLibrary(_query);

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
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (_query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() => _query = '');
                  },
                  child: const Icon(Icons.cancel_rounded, color: AetherisColors.textSecondary, size: 20),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Search results ───────────────────────────────────────────────────
        if (_query.isNotEmpty) ...[
          if (results.isEmpty)
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
              '${results.length} results for "$_query"',
              style: TextStyle(color: AetherisColors.textPrimary.withValues(alpha: 0.54), fontSize: 13),
            ),
            const SizedBox(height: 14),
            for (final track in results) ...[
              TrackTile(track: track),
              Divider(color: AetherisColors.textPrimary.withValues(alpha: 0.12), height: 1, indent: 72),
            ],
          ],
        ] else ...[
          // ── Browse Categories ─────────────────────────────────────────────
          const Text(
            'Browse Categories',
            style: TextStyle(
              color: AetherisColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
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
      trailing: const Icon(Icons.more_horiz_rounded, color: AetherisColors.textSecondary),
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
