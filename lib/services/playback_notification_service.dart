import 'dart:async';

import 'package:flutter/services.dart';

import '../models/track.dart';

class PlaybackNotificationService {
  PlaybackNotificationService() {
    _ensureHandlerAttached();
  }

  static const _channel = MethodChannel('aetheris/playback_notification');

  FutureOr<void> Function(String action, Duration? position)? _onAction;
  String? _lastPayloadKey;
  bool _handlerAttached = false;

  void setActionHandler(
    FutureOr<void> Function(String action, Duration? position) handler,
  ) {
    _onAction = handler;
    _ensureHandlerAttached();
  }

  Future<void> sync({
    required Track track,
    required bool isPlaying,
    required Duration position,
    required Duration duration,
  }) async {
    if (track.id == 'empty') {
      await hide();
      return;
    }

    final payloadKey = [
      track.id,
      track.title,
      track.artist,
      isPlaying,
      position.inSeconds,
      duration.inSeconds,
    ].join('|');
    if (payloadKey == _lastPayloadKey) {
      return;
    }
    _lastPayloadKey = payloadKey;

    try {
      await _channel.invokeMethod<void>('show', {
        'trackId': track.id,
        'title': track.title,
        'artist': track.artist,
        'isPlaying': isPlaying,
        'positionMs': position.inMilliseconds,
        'durationMs': duration.inMilliseconds,
        'artworkUrl': track.artworkUrl,
      });
    } catch (_) {
      // Notification controls are Android-only and optional in tests/desktop.
    }
  }

  Future<void> hide() async {
    _lastPayloadKey = null;
    try {
      await _channel.invokeMethod<void>('hide');
    } catch (_) {
      // Notification controls are Android-only and optional in tests/desktop.
    }
  }

  void _ensureHandlerAttached() {
    if (_handlerAttached) {
      return;
    }
    try {
      _channel.setMethodCallHandler(_handleMethodCall);
      _handlerAttached = true;
    } catch (_) {
      // Unit tests can construct the service before a binding exists.
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'action') {
      return;
    }
    final args = call.arguments;
    final action = args is Map ? args['action'] as String? : null;
    if (action == null || action.isEmpty) {
      return;
    }
    final positionMs = args is Map ? args['positionMs'] as int? : null;
    await _onAction?.call(
      action,
      positionMs == null ? null : Duration(milliseconds: positionMs),
    );
  }
}
