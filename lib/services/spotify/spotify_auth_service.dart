import 'dart:convert';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/spotify_config.dart';

// ---------------------------------------------------------------------------
// Spotify OAuth PKCE Auth Service
// ---------------------------------------------------------------------------

/// Handles Spotify Authorization Code with PKCE flow.
///
/// NO client secret is stored or transmitted — this is the recommended
/// approach for mobile applications per Spotify's documentation.
///
/// Flow:
/// 1. Generate code_verifier + code_challenge
/// 2. Open Spotify authorize URL in browser
/// 3. Receive callback with authorization code
/// 4. Exchange code for access_token + refresh_token
/// 5. Auto-refresh when token expires
class SpotifyAuthService extends ChangeNotifier {
  SpotifyAuthService({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final AppLinks _appLinks = AppLinks();

  // Secure storage keys
  static const _kAccessToken = 'spotify_access_token';
  static const _kRefreshToken = 'spotify_refresh_token';
  static const _kTokenExpiry = 'spotify_token_expiry';
  static const _kCodeVerifier = 'spotify_code_verifier';

  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  /// Whether the user has connected their Spotify account.
  bool get isConnected => _accessToken != null && _accessToken!.isNotEmpty;

  /// Current access token (may be expired — use [getValidToken] instead).
  String? get accessToken => _accessToken;

  /// Expiry time of current access token.
  DateTime? get tokenExpiry => _tokenExpiry;

  // -------------------------------------------------------------------------
  // Initialize from secure storage
  // -------------------------------------------------------------------------

  /// Load saved tokens from secure storage.
  Future<void> initialize() async {
    _accessToken = await _storage.read(key: _kAccessToken);
    _refreshToken = await _storage.read(key: _kRefreshToken);

    final expiryStr = await _storage.read(key: _kTokenExpiry);
    if (expiryStr != null) {
      _tokenExpiry = DateTime.tryParse(expiryStr);
    }

    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // PKCE Auth Flow
  // -------------------------------------------------------------------------

  /// Step 1: Open Spotify authorization page in browser.
  ///
  /// Returns a Future that completes when the user is redirected back
  /// to the app with an authorization code.
  Future<bool> startAuthFlow() async {
    // Generate PKCE code verifier (43-128 chars, unreserved URI chars)
    final codeVerifier = _generateCodeVerifier();
    await _storage.write(key: _kCodeVerifier, value: codeVerifier);

    // Create code challenge (S256)
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    // Build authorization URL
    final uri = Uri.parse(SpotifyConfig.authEndpoint).replace(
      queryParameters: {
        'client_id': SpotifyConfig.clientId,
        'response_type': 'code',
        'redirect_uri': SpotifyConfig.redirectUri,
        'scope': SpotifyConfig.scopeString,
        'code_challenge_method': 'S256',
        'code_challenge': codeChallenge,
      },
    );

    // Open in external browser
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Could not open Spotify authorization page.');
    }

    // Listen for the redirect callback
    try {
      final link = await _appLinks.uriLinkStream.firstWhere(
        (uri) => uri.scheme == 'aetheris-audio-player' && uri.host == 'spotify-callback',
      ).timeout(const Duration(minutes: 5));

      final code = link.queryParameters['code'];
      final error = link.queryParameters['error'];

      if (error != null) {
        throw Exception('Spotify authorization denied: $error');
      }

      if (code == null || code.isEmpty) {
        throw Exception('No authorization code received from Spotify.');
      }

      // Exchange code for tokens
      await _exchangeCodeForTokens(code, codeVerifier);
      return true;
    } catch (e) {
      if (kDebugMode) print('SpotifyAuthService: Auth flow error: $e');
      return false;
    }
  }

  /// Step 2: Exchange authorization code for access + refresh tokens.
  Future<void> _exchangeCodeForTokens(
    String code,
    String codeVerifier,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      SpotifyConfig.tokenEndpoint,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
      data: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': SpotifyConfig.redirectUri,
        'client_id': SpotifyConfig.clientId,
        'code_verifier': codeVerifier,
      },
    );

    final data = response.data;
    if (data == null) throw Exception('Empty token response from Spotify.');

    await _saveTokens(data);
  }

  // -------------------------------------------------------------------------
  // Token Management
  // -------------------------------------------------------------------------

  /// Get a valid access token, refreshing if expired.
  ///
  /// Returns null if user is not connected.
  Future<String?> getValidToken() async {
    if (_accessToken == null) return null;

    // Check if token is about to expire (with 60-second buffer)
    if (_tokenExpiry != null &&
        DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(seconds: 60)))) {
      await refreshToken();
    }

    return _accessToken;
  }

  /// Refresh the access token using the refresh token.
  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        SpotifyConfig.tokenEndpoint,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': _refreshToken,
          'client_id': SpotifyConfig.clientId,
        },
      );

      final data = response.data;
      if (data == null) return false;

      await _saveTokens(data);
      return true;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('SpotifyAuthService: Token refresh failed: $e');
      }
      // If refresh fails with 400/401, tokens are revoked — sign out
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        await disconnect();
      }
      return false;
    }
  }

  /// Save tokens to memory and secure storage.
  Future<void> _saveTokens(Map<String, dynamic> data) async {
    _accessToken = data['access_token'] as String?;
    final expiresIn = data['expires_in'] as int? ?? 3600;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

    // Spotify may or may not return a new refresh token
    if (data.containsKey('refresh_token')) {
      _refreshToken = data['refresh_token'] as String?;
    }

    await _storage.write(key: _kAccessToken, value: _accessToken);
    await _storage.write(key: _kRefreshToken, value: _refreshToken);
    await _storage.write(key: _kTokenExpiry, value: _tokenExpiry!.toIso8601String());

    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // Disconnect
  // -------------------------------------------------------------------------

  /// Disconnect Spotify account and clear all stored tokens.
  Future<void> disconnect() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;

    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kTokenExpiry);
    await _storage.delete(key: _kCodeVerifier);

    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // PKCE Helpers
  // -------------------------------------------------------------------------

  /// Generate a cryptographic random code verifier (RFC 7636).
  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(64, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '').substring(0, 128);
  }

  /// Generate S256 code challenge from verifier (RFC 7636).
  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  // -------------------------------------------------------------------------
  // Dispose
  // -------------------------------------------------------------------------

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}
