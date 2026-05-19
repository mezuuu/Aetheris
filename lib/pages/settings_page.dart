import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_settings.dart';
import '../theme/aetheris_colors.dart';
import 'eq_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    return ListView(
      key: const ValueKey('settings'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 176),
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 24),
          child: Text(
            'Settings',
            style: TextStyle(
              color: AetherisColors.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // ── Account ──────────────────────────────────────────────────────────
        _AccountTile(),
        const SizedBox(height: 24),

        // ── Playback ──────────────────────────────────────────────────────────
        _SectionHeader('Playback'),
        _ToggleTile(
          title: 'Crossfade',
          subtitle: 'Allow seamless transitions between songs',
          value: settings.crossfade,
          onChanged: (v) => notifier.update(settings.copyWith(crossfade: v)),
        ),
        if (settings.crossfade)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Off',
                  style: TextStyle(
                    color: AetherisColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: settings.crossfadeDuration,
                    min: 0,
                    max: 12,
                    divisions: 12,
                    activeColor: AetherisColors.accentSoft,
                    inactiveColor: AetherisColors.surfaceElevated,
                    onChanged:
                        (v) => notifier.update(
                          settings.copyWith(crossfadeDuration: v),
                        ),
                  ),
                ),
                const Text(
                  '12s',
                  style: TextStyle(
                    color: AetherisColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        _ToggleTile(
          title: 'Automix',
          subtitle: 'Allow smooth transitions between songs in a playlist.',
          value: settings.automix,
          onChanged: (v) => notifier.update(settings.copyWith(automix: v)),
        ),
        _ToggleTile(
          title: 'Auto-Play',
          subtitle:
              'Enjoy non-stop listening. When your audio ends, we\'ll play you something similar.',
          value: settings.autoPlay,
          onChanged: (v) => notifier.update(settings.copyWith(autoPlay: v)),
        ),
        _ToggleTile(
          title: 'Normalize Volume',
          subtitle: 'Set the same volume level for all songs',
          value: settings.normalizeVolume,
          onChanged:
              (v) => notifier.update(settings.copyWith(normalizeVolume: v)),
        ),
        _ToggleTile(
          title: 'Show Lyrics',
          value: settings.showLyrics,
          onChanged: (v) => notifier.update(settings.copyWith(showLyrics: v)),
        ),
        _NavTile(
          title: 'Equalizer',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EqPage()),
              ),
        ),
        const SizedBox(height: 24),

        // ── Audio Quality ─────────────────────────────────────────────────────
        _SectionHeader('Audio Quality'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WiFi streaming',
                      style: TextStyle(
                        color: AetherisColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButton<String>(
                value: settings.audioQuality,
                dropdownColor: AetherisColors.surfaceRaised,
                iconEnabledColor: AetherisColors.accentSoft,
                underline: const SizedBox(),
                style: const TextStyle(
                  color: AetherisColors.textSecondary,
                  fontSize: 14,
                ),
                items: const [
                  DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                  DropdownMenuItem(
                    value: 'Very High',
                    child: Text('Very High'),
                  ),
                  DropdownMenuItem(value: 'Lossless', child: Text('Lossless')),
                ],
                onChanged:
                    (v) => notifier.update(settings.copyWith(audioQuality: v!)),
              ),
            ],
          ),
        ),
        _ToggleTile(
          title: 'Exclusive Mode',
          subtitle: 'Direct hardware access for bit-perfect audio',
          value: settings.exclusiveMode,
          onChanged:
              (v) => notifier.update(settings.copyWith(exclusiveMode: v)),
        ),
        const SizedBox(height: 24),

        // ── Downloads ─────────────────────────────────────────────────────────
        _SectionHeader('Storage'),
        _ToggleTile(
          title: 'Download over Wi-Fi only',
          value: settings.wifiOnly,
          onChanged: (v) => notifier.update(settings.copyWith(wifiOnly: v)),
        ),
        _DownloadFormatTile(
          value: settings.downloadFormat,
          onChanged:
              (value) =>
                  notifier.update(settings.copyWith(downloadFormat: value)),
        ),
        const _InfoTile(
          title: 'Spotify links',
          subtitle:
              'Spotify tracks can be opened as references only. Offline files require a licensed audio source from the app catalog.',
        ),
        _NavTile(title: 'Download Location', subtitle: '/Music', onTap: () {}),
        _NavTile(
          title: 'Delete All Downloads',
          titleColor: AetherisColors.error,
          onTap: () {},
        ),
        const SizedBox(height: 24),

        // ── Notifications ────────────────────────────────────────────────────
        _SectionHeader('Notifications'),
        _ToggleTile(
          title: 'Show Playback Notification',
          value: settings.showNotification,
          onChanged:
              (v) => notifier.update(settings.copyWith(showNotification: v)),
        ),
        const SizedBox(height: 24),

        // ── About ─────────────────────────────────────────────────────────────
        _SectionHeader('About'),
        _NavTile(title: 'Version', subtitle: '1.0.0 (build 100)', onTap: () {}),
        _NavTile(title: 'Privacy Policy', onTap: () {}),
        _NavTile(title: 'Terms of Service', onTap: () {}),
        const SizedBox(height: 32),

        // Sign out
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Log out',
              style: TextStyle(
                color: AetherisColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AetherisColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Account tile ─────────────────────────────────────────────────────────────
class _AccountTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: AetherisColors.surfaceRaised,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_rounded,
          color: AetherisColors.textPrimary,
          size: 28,
        ),
      ),
      title: const Text(
        'Akbar',
        style: TextStyle(
          color: AetherisColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: const Text(
        'View profile',
        style: TextStyle(color: AetherisColors.textSecondary, fontSize: 13),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AetherisColors.textSecondary,
      ),
      onTap: () {},
    );
  }
}

// ─── Toggle tile ──────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AetherisColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AetherisColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AetherisColors.textPrimary,
            activeTrackColor: AetherisColors.accent,
            inactiveThumbColor: AetherisColors.textSecondary,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.14),
          ),
        ],
      ),
    );
  }
}

class _DownloadFormatTile extends StatelessWidget {
  const _DownloadFormatTile({required this.value, required this.onChanged});

  static const _formats = ['MP3', 'WAV', 'FLAC'];

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Download format',
            style: TextStyle(color: AetherisColors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Default format for licensed offline files.',
            style: TextStyle(color: AetherisColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final format in _formats)
                ChoiceChip(
                  label: Text(format),
                  selected: value == format,
                  onSelected: (_) => onChanged(format),
                  selectedColor: AetherisColors.accent,
                  backgroundColor: AetherisColors.surfaceElevated,
                  checkmarkColor: AetherisColors.textPrimary,
                  side: BorderSide(
                    color:
                        value == format
                            ? AetherisColors.accentSoft
                            : Colors.white.withValues(alpha: 0.10),
                  ),
                  labelStyle: TextStyle(
                    color:
                        value == format
                            ? AetherisColors.textPrimary
                            : AetherisColors.textSecondary,
                    fontWeight:
                        value == format ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(
        title,
        style: const TextStyle(color: AetherisColors.textPrimary, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AetherisColors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(
        Icons.link_rounded,
        color: AetherisColors.accentSoft,
        size: 20,
      ),
    );
  }
}

// ─── Navigation tile ──────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AetherisColors.textPrimary,
          fontSize: 16,
        ),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle!,
                style: const TextStyle(
                  color: AetherisColors.textSecondary,
                  fontSize: 13,
                ),
              )
              : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AetherisColors.textSecondary,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
