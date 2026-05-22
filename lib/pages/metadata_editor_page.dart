import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/services_provider.dart';

import '../models/track.dart';
import '../services/download_service.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/album_art.dart';
import '../widgets/glass_container.dart';
import '../widgets/primary_button.dart';
import '../widgets/quality_badge.dart';
import '../state/aetheris_scope.dart';
import 'download_sheet.dart';

/// Shows a track options bottom sheet (the ⋮ menu).
///
/// Includes: Download, Metadata Editor, Add to Playlist, etc.
Future<void> showTrackOptions(
  BuildContext context,
  Track track, {
  DownloadService? downloadService,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TrackOptionsSheet(
      track: track,
      downloadService: downloadService,
    ),
  );
}

/// Legacy entry point — kept for backward compatibility.
Future<void> showMetadataEditor(BuildContext context, Track track) {
  return showTrackOptions(context, track);
}

class _TrackOptionsSheet extends ConsumerWidget {
  const _TrackOptionsSheet({
    required this.track,
    this.downloadService,
  });

  final Track track;
  final DownloadService? downloadService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),

            // ── Track header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  AlbumArt(track: track, size: 44, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AetherisColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          track.artist,
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
            const SizedBox(height: 14),
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),

            // ── Options list ────────────────────────────────────────────

            _OptionTile(
              icon: Icons.file_download_rounded,
              label: 'Download',
              onTap: () {
                Navigator.pop(context);
                final DownloadService service = downloadService ?? ref.read(downloadServiceProvider);
                showDownloadSheet(
                  context,
                  track: track,
                  downloadService: service,
                );
              },
            ),
            _OptionTile(
              icon: Icons.queue_music_rounded,
              label: 'Add to Queue',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${track.title}" to queue'),
                    backgroundColor: AetherisColors.surfaceElevated,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            _OptionTile(
              icon: Icons.playlist_add_rounded,
              label: 'Add to Playlist',
              onTap: () => Navigator.pop(context),
            ),
            _OptionTile(
              icon: Icons.share_rounded,
              label: 'Share Song',
              onTap: () => Navigator.pop(context),
            ),
            Builder(
              builder: (context) {
                final controller = AetherisScope.of(context);
                return _OptionTile(
                  icon: Icons.block_rounded,
                  label: "Don't Recommend",
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  onTap: () {
                    controller.blacklistTrack(track);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '"${track.title}" won\'t appear in auto-queue',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xE0101018),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                        action: SnackBarAction(
                          label: 'Undo',
                          textColor: AetherisColors.accentSoft,
                          onPressed: () => controller.unblacklistTrack(track),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            _OptionTile(
              icon: Icons.edit_note_rounded,
              label: 'Edit Metadata',
              onTap: () {
                Navigator.pop(context);
                _showMetadataEditor(context, track);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showMetadataEditor(BuildContext context, Track track) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MetadataEditorSheet(track: track),
    );
  }
}

// ---------------------------------------------------------------------------
// Option tile
// ---------------------------------------------------------------------------

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final clr = color ?? AetherisColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: clr, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: clr,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metadata editor (moved from the original standalone page)
// ---------------------------------------------------------------------------

class _MetadataEditorSheet extends StatelessWidget {
  const _MetadataEditorSheet({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom + 14),
      child: GlassContainer(
        radius: 28,
        color: const Color(0xE60A0A14),
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  AlbumArt(track: track, size: 78, radius: 14),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Metadata Editor',
                          style: TextStyle(
                            color: AetherisColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TrackQualityBadges(track: track, compact: true),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _Field(label: 'Title', value: track.title),
              _Field(label: 'Artist', value: track.artist),
              _Field(label: 'Album', value: track.album),
              _Field(label: 'Audio Spec', value: track.audioSpec),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                      label: const Text('Fetch'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Save',
                      onPressed: () => Navigator.pop(context),
                      compact: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        style: const TextStyle(color: AetherisColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AetherisColors.textSecondary),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.07),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AetherisColors.mutedSky),
          ),
        ),
      ),
    );
  }
}
