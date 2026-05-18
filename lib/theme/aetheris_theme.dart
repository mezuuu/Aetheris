import 'package:flutter/material.dart';

import 'aetheris_colors.dart';

class AetherisTheme {
  const AetherisTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AetherisColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AetherisColors.accent,
        secondary: AetherisColors.accentSoft,
        surface: AetherisColors.surface,
        error: AetherisColors.error,
        onPrimary: AetherisColors.textPrimary,
        onSecondary: AetherisColors.background,
        onSurface: AetherisColors.textPrimary,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: AetherisColors.textPrimary,
        displayColor: AetherisColors.textPrimary,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AetherisColors.mutedSky,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.14),
        thumbColor: AetherisColors.textSecondary,
        overlayColor: AetherisColors.accent.withValues(alpha: 0.18),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AetherisColors.mutedSky;
          }
          return Colors.white.withValues(alpha: 0.14);
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AetherisColors.textPrimary;
          }
          return AetherisColors.textSecondary;
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AetherisColors.textPrimary,
        centerTitle: true,
      ),
    );
  }
}
