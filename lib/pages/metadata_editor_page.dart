import 'package:flutter/material.dart';

import '../models/track.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/album_art.dart';
import '../widgets/glass_container.dart';
import '../widgets/primary_button.dart';
import '../widgets/quality_badge.dart';

Future<void> showMetadataEditor(BuildContext context, Track track) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _MetadataSheet(track: track),
  );
}

class _MetadataSheet extends StatelessWidget {
  const _MetadataSheet({required this.track});

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
