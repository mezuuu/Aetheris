import 'package:flutter/material.dart';

import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/quality_badge.dart';

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage>
    with SingleTickerProviderStateMixin {
  final _values = <double>[0.52, 0.68, 0.62, 0.73, 0.58, 0.66, 0.49, 0.57];
  bool _enabled = true;
  int _presetIndex = 0;
  late final TabController _tabController;

  static const _labels = ['32', '64', '125', '250', '500', '1K', '4K', '8K'];
  static const _presets = ['Flat', 'Bass+', 'Treble+', 'Vocal', 'Reference'];
  static const _presetValues = [
    [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
    [0.82, 0.74, 0.64, 0.52, 0.50, 0.50, 0.52, 0.48],
    [0.48, 0.50, 0.52, 0.55, 0.58, 0.70, 0.78, 0.82],
    [0.50, 0.52, 0.60, 0.74, 0.76, 0.68, 0.55, 0.50],
    [0.52, 0.68, 0.62, 0.73, 0.58, 0.66, 0.49, 0.57],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyPreset(int i) {
    setState(() {
      _presetIndex = i;
      for (var j = 0; j < _values.length; j++) {
        _values[j] = _presetValues[i][j].toDouble();
      }
    });
  }

  String _dB(double v) {
    final db = ((v - 0.5) * 24).toStringAsFixed(1);
    return '${v >= 0.5 ? '+' : ''}$db';
  }

  @override
  Widget build(BuildContext context) {
    final track = AetherisScope.of(context).currentTrack;

    return Scaffold(
      body: Stack(
        children: [
          AmbientBackground(colors: track.coverColors),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    // ── Header ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.08,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: AetherisColors.textSecondary,
                          ),
                          const Expanded(
                            child: Text(
                              'Audio Engine',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AetherisColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _applyPreset(0),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ),

                    // ── Tabs ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: GlassContainer(
                        radius: 12,
                        padding: const EdgeInsets.all(4),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AetherisColors.mutedSky.withValues(
                              alpha: 0.28,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AetherisColors.mutedSky.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: AetherisColors.textPrimary,
                          unselectedLabelColor: AetherisColors.textSecondary,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: 'Equalizer'),
                            Tab(text: 'Info'),
                          ],
                        ),
                      ),
                    ),

                    // ── Tab content ─────────────────────────────────
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // ── EQ Tab ─────────────────────────────
                          ListView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            children: [
                              // Enable toggle
                              GlassContainer(
                                radius: 14,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Aetheris Reference EQ',
                                            style: TextStyle(
                                              color: AetherisColors.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            '8-band • High-fidelity tuning',
                                            style: TextStyle(
                                              color:
                                                  AetherisColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _enabled,
                                      onChanged:
                                          (v) => setState(() => _enabled = v),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Presets
                              SizedBox(
                                height: 36,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _presets.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, i) {
                                    final sel = _presetIndex == i;
                                    return GestureDetector(
                                      onTap: () => _applyPreset(i),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              sel
                                                  ? AetherisColors.mutedSky
                                                      .withValues(alpha: 0.28)
                                                  : Colors.white.withValues(
                                                    alpha: 0.06,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color:
                                                sel
                                                    ? AetherisColors.mutedSky
                                                        .withValues(alpha: 0.5)
                                                    : Colors.white.withValues(
                                                      alpha: 0.08,
                                                    ),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          _presets[i],
                                          style: TextStyle(
                                            color:
                                                sel
                                                    ? AetherisColors.textPrimary
                                                    : AetherisColors
                                                        .textSecondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // EQ Sliders
                              GlassContainer(
                                radius: 20,
                                padding: const EdgeInsets.all(16),
                                child: SizedBox(
                                  height: 240,
                                  child: Row(
                                    children: [
                                      for (var i = 0; i < _values.length; i++)
                                        Expanded(
                                          child: _EqBand(
                                            label: _labels[i],
                                            value: _values[i],
                                            dbLabel: _dB(_values[i]),
                                            enabled: _enabled,
                                            onChanged:
                                                (v) => setState(
                                                  () => _values[i] = v,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TrackQualityBadges(track: track, center: true),
                            ],
                          ),

                          // ── Info Tab ───────────────────────────
                          ListView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            children: [
                              GlassContainer(
                                radius: 18,
                                child: Column(
                                  children: const [
                                    _InfoRow('Output', 'AAudio Exclusive'),
                                    Divider(
                                      color: Color(0x14FFFFFF),
                                      height: 1,
                                    ),
                                    _InfoRow('DAC', 'External USB • Active'),
                                    Divider(
                                      color: Color(0x14FFFFFF),
                                      height: 1,
                                    ),
                                    _InfoRow('Pipeline', 'Bit-perfect bypass'),
                                    Divider(
                                      color: Color(0x14FFFFFF),
                                      height: 1,
                                    ),
                                    _InfoRow('Latency', '5.3 ms'),
                                    Divider(
                                      color: Color(0x14FFFFFF),
                                      height: 1,
                                    ),
                                    _InfoRow('Buffer', '256 samples'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EqBand extends StatelessWidget {
  const _EqBand({
    required this.label,
    required this.value,
    required this.dbLabel,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final double value;
  final String dbLabel;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          dbLabel,
          style: TextStyle(
            color:
                enabled
                    ? AetherisColors.textSecondary
                    : AetherisColors.textTertiary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(value: value, onChanged: enabled ? onChanged : null),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AetherisColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AetherisColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AetherisColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
