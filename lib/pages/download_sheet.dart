import 'package:flutter/material.dart';

import '../models/track.dart';
import '../services/download_service.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/album_art.dart';

/// Shows the download quality picker bottom sheet.
///
/// Returns `true` if a download was started, `false` or `null` otherwise.
Future<bool?> showDownloadSheet(
  BuildContext context, {
  required Track track,
  required DownloadService downloadService,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DownloadSheet(
      track: track,
      downloadService: downloadService,
    ),
  );
}

class _DownloadSheet extends StatefulWidget {
  const _DownloadSheet({
    required this.track,
    required this.downloadService,
  });

  final Track track;
  final DownloadService downloadService;

  @override
  State<_DownloadSheet> createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<_DownloadSheet>
    with SingleTickerProviderStateMixin {
  String _selectedQuality = 'LOSSLESS';
  bool _isDownloading = false;
  String? _error;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    final job = await widget.downloadService.downloadTrack(
      widget.track,
      quality: _selectedQuality,
      onCompleted: (success, path, error) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(success ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    success ? 'Downloaded: ${widget.track.title}' : 'Failed to download: ${widget.track.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: success ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );

    if (!mounted) return;

    if (job != null) {
      final preset = DownloadQuality.presets.firstWhere(
        (q) => q.id == _selectedQuality,
        orElse: () => DownloadQuality.presets.last,
      );
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Downloading ${widget.track.title} • ${preset.format}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AetherisColors.accent.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      setState(() {
        _isDownloading = false;
        _error = 'Download failed to start. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom + 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF2101018),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // ── Drag handle ────────────────────────────────────
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),

              // ── Track header ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    AlbumArt(track: widget.track, size: 56, radius: 12),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AetherisColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AetherisColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Divider ────────────────────────────────────────
              Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: 1,
              ),

              // ── Quality options ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  children: [
                    for (final q in DownloadQuality.presets)
                      _QualityTile(
                        quality: q,
                        isSelected: _selectedQuality == q.id,
                        onTap: () => setState(() => _selectedQuality = q.id),
                      ),
                  ],
                ),
              ),

              // ── Error ──────────────────────────────────────────
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AetherisColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // ── Download button ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _isDownloading
                      ? _AnimatedDownloadButton(controller: _pulseController)
                      : FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AetherisColors.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _startDownload,
                          icon: const Icon(Icons.arrow_downward_rounded, size: 20),
                          label: const Text(
                            'Download',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                ),
              ),

              // ── Save location ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 2),
                child: Text(
                  '📁  Music/Aetheris',
                  style: TextStyle(
                    color: AetherisColors.textTertiary.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quality option tile — clean and minimal
// ---------------------------------------------------------------------------

class _QualityTile extends StatelessWidget {
  const _QualityTile({
    required this.quality,
    required this.isSelected,
    required this.onTap,
  });

  final DownloadQuality quality;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLossless = quality.id == 'FLAC' || quality.id == 'WAV';
    final accentColor = isLossless
        ? AetherisColors.hiResGold
        : isSelected
            ? AetherisColors.accent
            : AetherisColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.white.withValues(alpha: 0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Format label
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  quality.format,
                  style: TextStyle(
                    color: isSelected ? accentColor : AetherisColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          quality.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? AetherisColors.textPrimary
                                : AetherisColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isLossless) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AetherisColors.hiResGold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'HI-RES',
                            style: TextStyle(
                              color: AetherisColors.hiResGold,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    quality.description,
                    style: TextStyle(
                      color: AetherisColors.textTertiary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Bitrate
            Text(
              quality.bitrate,
              style: TextStyle(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.9)
                    : AetherisColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),

            // Radio
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : AetherisColors.textTertiary.withValues(alpha: 0.3),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated download button (pulse while downloading)
// ---------------------------------------------------------------------------

class _AnimatedDownloadButton extends StatelessWidget {
  const _AnimatedDownloadButton({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final opacity = 0.6 + (controller.value * 0.4);
        return Opacity(
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
              color: AetherisColors.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Downloading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
