import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';
import '../services/library_service.dart';
import 'services_provider.dart';

/// Library state notifier
class LibraryStateNotifier extends StateNotifier<AsyncValue<List<Track>>> {
  LibraryStateNotifier(this._libraryService)
      : super(const AsyncValue.loading());

  final LibraryService _libraryService;

  Future<void> loadLibrary() async {
    state = const AsyncValue.loading();
    try {
      final library = await _libraryService.loadLibrary();
      state = AsyncValue.data(library);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> scanFolder(String path) async {
    try {
      await _libraryService.scanFolder(path);
      await loadLibrary();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTrack(Track track) async {
    try {
      await _libraryService.addTrack(track);
      await loadLibrary();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Library provider
final libraryProvider =
    StateNotifierProvider<LibraryStateNotifier, AsyncValue<List<Track>>>(
        (ref) {
  final libraryService = ref.watch(libraryServiceProvider);
  return LibraryStateNotifier(libraryService);
});

/// Library size provider
final librarySizeProvider = Provider<int>((ref) {
  final library = ref.watch(libraryProvider);
  return library.when(
    data: (tracks) => tracks.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results provider
final searchResultsProvider = Provider<List<Track>>((ref) {
  final libraryService = ref.watch(libraryServiceProvider);
  final query = ref.watch(searchQueryProvider);
  return libraryService.searchTracks(query);
});

/// Artists provider
final artistsProvider = Provider<List<String>>((ref) {
  final libraryService = ref.watch(libraryServiceProvider);
  return libraryService.getArtists();
});

/// Albums provider
final albumsProvider = Provider<List<String>>((ref) {
  final libraryService = ref.watch(libraryServiceProvider);
  return libraryService.getAlbums();
});
