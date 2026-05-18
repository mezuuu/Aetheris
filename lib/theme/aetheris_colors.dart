import 'package:flutter/material.dart';

class AetherisColors {
  const AetherisColors._();

  static const background = Color(0xFF0A0A0F);
  static const deepMidnight = Color(0xFF161126);
  static const surface = Color(0xFF12121A);
  static const surfaceRaised = Color(0xFF1A1A2E);
  static const surfaceElevated = Color(0xFF20203A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB7B4C7);
  static const textTertiary = Color(0xFF777287);
  static const accent = Color(0xFF6C5CE7);
  static const accentSoft = Color(0xFFA29BFE);
  static const sky = Color(0xFF74B9FF);
  static const mutedSky = Color(0xFF6F89A8);
  static const success = Color(0xFF00D2A0);
  static const warning = Color(0xFFFDCB6E);
  static const error = Color(0xFFFF6B6B);
  static const hiResGold = Color(0xFFF9CA24);
  static const spotify = Color(0xFF1DB954);

  static const accentGradient = LinearGradient(
    colors: [accent, accentSoft, sky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
