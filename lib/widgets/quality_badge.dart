import 'package:flutter/material.dart';

import '../theme/aetheris_colors.dart';

/// A subdued, glass-style badge — replaces the previously colorful badges.
/// Uses a near-white/gray palette so it feels elegant, not distracting.
class QualityBadge extends StatelessWidget {
  const QualityBadge({
    super.key,
    required this.label,
    // color param kept for API compat but is now only used for the border tint
    this.color = AetherisColors.textSecondary,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 20 : 26),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 11,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        // Subtle frosted-glass look: dark semi-transparent fill + white border
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 0.8,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          // Soft white-gray — readable but not loud
          color: Colors.white.withValues(alpha: 0.68),
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class TrackQualityBadges extends StatelessWidget {
  const TrackQualityBadges({
    super.key,
    required this.track,
    this.center = false,
    this.compact = false,
  });

  final dynamic track; // Track type kept loose to avoid circular import issues
  final bool center;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[
      QualityBadge(label: track.format, compact: compact),
      if (track.isHiRes) QualityBadge(label: 'Hi-Res', compact: compact),
      QualityBadge(
        label: '${track.bitDepth}-bit / ${track.sampleRateKhz}kHz',
        compact: compact,
      ),
      if (track.isBitPerfect)
        QualityBadge(label: 'Bit-Perfect', compact: compact),
    ];

    return Wrap(
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      spacing: compact ? 5 : 7,
      runSpacing: compact ? 5 : 7,
      children: badges,
    );
  }
}
