/// Spotify OAuth PKCE configuration for Aetheris.
///
/// Uses Authorization Code with PKCE flow — NO client secret required.
/// This is the recommended flow for mobile applications.
///
/// SETUP:
/// 1. Go to https://developer.spotify.com/dashboard
/// 2. Create/select your app
/// 3. Add redirect URI: aetheris-audio-player://spotify-callback
/// 4. Copy your Client ID below
class SpotifyConfig {
  SpotifyConfig._();

  /// Spotify Client ID (public, safe to include in app).
  static const String clientId = 'bc0941ea725c4a84bf23eee059abf714';

  /// Redirect URI — must match Spotify Dashboard AND AndroidManifest.xml.
  static const String redirectUri = 'aetheris-audio-player://spotify-callback';

  /// Spotify authorization endpoint.
  static const String authEndpoint = 'https://accounts.spotify.com/authorize';

  /// Spotify token exchange endpoint.
  static const String tokenEndpoint = 'https://accounts.spotify.com/api/token';

  /// Spotify Web API base URL.
  static const String apiBase = 'https://api.spotify.com/v1';

  /// OAuth scopes requested.
  static const List<String> scopes = [
    'user-read-private',
    'user-read-email',
    'user-top-read',
    'user-read-recently-played',
    'user-library-read',
    'playlist-read-private',
    'playlist-read-collaborative',
    'playlist-modify-public',
    'playlist-modify-private',
    'user-follow-read',
    'user-follow-modify',
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-read-currently-playing',
    'streaming',
  ];

  /// Scopes as a space-separated string.
  static String get scopeString => scopes.join(' ');
}
