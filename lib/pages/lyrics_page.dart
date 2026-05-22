import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lrc_line.dart';
import '../services/lyrics_service.dart';
import '../services/romanization_service.dart';
import '../services/translation_service.dart';
import '../state/aetheris_scope.dart';
import '../state/app_settings.dart';
import '../widgets/album_art.dart';
import '../widgets/ambient_background.dart';

class LyricsPage extends ConsumerStatefulWidget {
  const LyricsPage({super.key});

  @override
  ConsumerState<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends ConsumerState<LyricsPage> {
  bool _translateEnabled = false;
  bool _romanizationEnabled = false;
  final _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};
  
  LrcData? _lrcData;
  bool _isLoading = true;
  String? _error;
  
  final _lyricsService = LyricsService();
  final _romanizationService = RomanizationService();
  final _translationService = TranslationService();

  int _lastScrolledIndex = -1;
  String? _loadedTrackId;
  int _activeIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadLyrics() async {
    final controller = AetherisScope.of(context);
    final track = controller.currentTrack;
    
    if (track.id == 'empty') {
      setState(() {
        _isLoading = false;
        _error = 'No track playing';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _lrcData = null;
      _lastScrolledIndex = -1;
      _itemKeys.clear();
    });

    final localLyrics = _lyricsFromTrack(track);
    if (localLyrics != null && localLyrics.isSynced) {
      if (mounted && _loadedTrackId == track.id) {
        setState(() {
          _lrcData = localLyrics;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final fetchedData = await _lyricsService.fetchSyncedLyrics(
        track.title, 
        track.artist,
        album: track.album,
        durationMs: track.duration.inMilliseconds,
      );
      
      if (mounted && _loadedTrackId == track.id) {
        if (fetchedData != null) {
          setState(() {
            _lrcData = fetchedData;
            _isLoading = false;
          });
        } else if (localLyrics != null) {
           setState(() {
             _lrcData = localLyrics;
             _isLoading = false;
           });
        } else {
           setState(() {
             _error = 'No lyrics found';
             _isLoading = false;
           });
        }
      }
    } catch (e) {
      if (mounted && _loadedTrackId == track.id) {
        setState(() {
          _error = 'Error loading lyrics';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleTranslate() async {
    if (_lrcData == null || _lrcData!.isEmpty) return;
    
    if (_translateEnabled) {
      setState(() => _translateEnabled = false);
      return;
    }

    setState(() {
      _translateEnabled = true;
    });
    
    if (_lrcData!.lines.any((l) => l.translation != null)) return;
    
    try {
      final targetLang = ref.read(appSettingsProvider).translationLanguage;
      
      final translatedLines = await _translationService.translateLrcLines(
        _lrcData!.lines, 
        targetLang,
      );
      
      if (mounted) {
        setState(() {
          _lrcData = LrcData(
            lines: translatedLines,
            isSynced: _lrcData!.isSynced,
            title: _lrcData!.title,
            artist: _lrcData!.artist,
            album: _lrcData!.album,
            author: _lrcData!.author,
            offset: _lrcData!.offset,
          );
        });
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
  }

  Future<void> _toggleRomanization() async {
    if (_lrcData == null || _lrcData!.isEmpty) return;

    if (_romanizationEnabled) {
      setState(() => _romanizationEnabled = false);
      return;
    }

    setState(() {
      _romanizationEnabled = true;
    });

    if (_lrcData!.lines.any((line) => line.romanization != null)) return;

    final romanizedLines =
        await _romanizationService.romanizeLrcLines(_lrcData!.lines);
    if (!mounted) return;

    setState(() {
      _lrcData = LrcData(
        lines: romanizedLines,
        isSynced: _lrcData!.isSynced,
        title: _lrcData!.title,
        artist: _lrcData!.artist,
        album: _lrcData!.album,
        author: _lrcData!.author,
        offset: _lrcData!.offset,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToActiveIndex(int index, {bool force = false}) {
    if (index < 0 || (!force && index == _lastScrolledIndex)) return;
    
    final key = _itemKeys[index];
    if (key != null && key.currentContext != null) {
      _lastScrolledIndex = index;
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        alignment: 0.4, // Position slightly above center
      );
      return;
    }

    if (!_scrollController.hasClients || _lrcData == null || _lrcData!.isEmpty) {
      return;
    }

    _lastScrolledIndex = index;
    final viewport = _scrollController.position.viewportDimension;
    final lineExtent = _estimatedLyricExtent();
    final target = (index * lineExtent) - (viewport * 0.35);
    final clamped = target.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      clamped.toDouble(),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final builtKey = _itemKeys[index];
      if (builtKey?.currentContext != null) {
        Scrollable.ensureVisible(
          builtKey!.currentContext!,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0.4,
        );
      }
    });
  }

  double _estimatedLyricExtent() {
    var base = 78.0;
    if (_romanizationEnabled) base += 28;
    if (_translateEnabled) base += 34;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);
    final track = controller.currentTrack;
    
    if (track.id != _loadedTrackId) {
      _loadedTrackId = track.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLyrics();
      });
    }
    
    final settings = ref.watch(appSettingsProvider);
    final trackOffsetMs = settings.lyricOffsets[track.id] ?? 0;
    final trackOffset = Duration(milliseconds: trackOffsetMs);

    int activeIndex = -1;
    if (_lrcData != null && _lrcData!.isSynced) {
      activeIndex = _lrcData!.activeIndexAt(controller.position + trackOffset);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveIndex(activeIndex);
      });
    } else if (_lrcData != null && !_lrcData!.isSynced) {
      // Fallback for unsynced lyrics using progress percentage
      activeIndex = (controller.progress * _lrcData!.length).floor().clamp(0, _lrcData!.length - 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveIndex(activeIndex);
      });
    }
    _activeIndex = activeIndex;

    final showOffsetControls = _lrcData != null && _lrcData!.isSynced && !_isLoading && _error == null;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred ambient bg
          AmbientBackground(
            colors: track.coverColors,
            artworkUrl: track.artworkUrl,
          ),

          Column(
            children: [
              // ── Top Bar ─────────────────────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Lyrics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _scrollToActiveIndex(
                          _activeIndex,
                          force: true,
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleRomanization,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _romanizationEnabled
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Roman',
                            style: TextStyle(
                              color: _romanizationEnabled ? Colors.white : Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Translate toggle
                      GestureDetector(
                        onTap: _toggleTranslate,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _translateEnabled
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Translate',
                            style: TextStyle(
                              color: _translateEnabled ? Colors.white : Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Lyrics Content ───────────────────────────────────────
              Expanded(
                child: _buildLyricsContent(activeIndex),
              ),

              // ── Timing Offset Controls ───────────────────────────────
              if (showOffsetControls) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Timing: ${trackOffsetMs >= 0 ? '+' : ''}${(trackOffsetMs / 1000.0).toStringAsFixed(1)}s',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _OffsetButton(
                            label: '-0.5s',
                            onTap: () => _updateOffset(track.id, trackOffsetMs - 500),
                          ),
                          const SizedBox(width: 6),
                          _OffsetButton(
                            label: '-0.1s',
                            onTap: () => _updateOffset(track.id, trackOffsetMs - 100),
                          ),
                          const SizedBox(width: 8),
                          if (trackOffsetMs != 0) ...[
                            GestureDetector(
                              onTap: () => _updateOffset(track.id, 0),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          _OffsetButton(
                            label: '+0.1s',
                            onTap: () => _updateOffset(track.id, trackOffsetMs + 100),
                          ),
                          const SizedBox(width: 6),
                          _OffsetButton(
                            label: '+0.5s',
                            onTap: () => _updateOffset(track.id, trackOffsetMs + 500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // ── Mini Player Bar ──────────────────────────────────────────
              Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 8,
                  top: 12,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AlbumArt(track: track, size: 44, radius: 6, showBadge: false),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.togglePlay,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          controller.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.skipNext(forceNextTrack: true),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.skip_next_rounded, color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsContent(int activeIndex) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.white54, fontSize: 18),
        ),
      );
    }
    
    if (_lrcData == null || _lrcData!.isEmpty) {
      return const Center(
        child: Text(
          'No lyrics available',
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: 24, 
        right: 24,
        top: MediaQuery.of(context).size.height * 0.2,
        bottom: MediaQuery.of(context).size.height * 0.5,
      ),
      itemCount: _lrcData!.length,
      itemBuilder: (context, i) {
        final line = _lrcData!.lines[i];
        final isActive = i == activeIndex;
        final isPast = i < activeIndex;
        
        _itemKeys[i] ??= GlobalKey();

        return Padding(
          key: _itemKeys[i],
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main lyric line
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : (isPast ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.3)),
                  fontSize: isActive ? 32 : 28,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
                child: Text(line.text),
              ),
              if (_romanizationEnabled && line.romanization != null && line.romanization!.isNotEmpty) ...[
                const SizedBox(height: 7),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.72)
                        : Colors.white.withValues(alpha: 0.36),
                    fontSize: isActive ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                  child: Text(line.romanization!),
                ),
              ],
              // Translation below (Apple Music / Spotify style)
              if (_translateEnabled && line.translation != null && line.translation!.isNotEmpty) ...[
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.4),
                    fontSize: isActive ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  child: Text(line.translation!),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  LrcData? _lyricsFromTrack(dynamic track) {
    if (track.lyrics.isEmpty) {
      return null;
    }

    final raw = (track.lyrics as List<String>).join('\n').trim();
    if (raw.isEmpty) {
      return null;
    }

    final hasTimestamps = RegExp(r'\[\d{1,3}:\d{2}(?:\.\d{2,3})?\]').hasMatch(raw);
    final parsed = hasTimestamps ? LrcData.parse(raw) : LrcData.fromPlainText(raw);
    return parsed.isEmpty ? null : parsed;
  }

  void _updateOffset(String trackId, int newOffsetMs) {
    final settings = ref.read(appSettingsProvider);
    final newOffsets = Map<String, int>.from(settings.lyricOffsets);
    if (newOffsetMs == 0) {
      newOffsets.remove(trackId);
    } else {
      newOffsets[trackId] = newOffsetMs;
    }
    
    ref.read(appSettingsProvider.notifier).update(
      settings.copyWith(lyricOffsets: newOffsets),
    );
  }
}

class _OffsetButton extends StatelessWidget {
  const _OffsetButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
