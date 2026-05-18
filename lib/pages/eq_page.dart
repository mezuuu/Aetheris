import 'package:flutter/material.dart';

import '../theme/aetheris_colors.dart';

class EqPage extends StatefulWidget {
  const EqPage({super.key});

  @override
  State<EqPage> createState() => _EqPageState();
}

class _EqPageState extends State<EqPage> {
  String _selectedPreset = 'Flat';
  final Map<String, List<double>> _presets = {
    'Flat': [0, 0, 0, 0, 0, 0],
    'Acoustic': [3, 1, 0, 0, 1, 2],
    'Bass Booster': [5, 4, 1, 0, 0, 0],
    'Electronic': [4, 3, -1, 1, 3, 4],
    'Hip-Hop': [5, 3, 0, -1, 2, 3],
    'Pop': [-1, 2, 4, 4, 2, -1],
    'Rock': [4, 2, -2, 0, 3, 4],
    'Custom': [0, 0, 0, 0, 0, 0],
  };

  late List<double> _currentBands;

  @override
  void initState() {
    super.initState();
    _currentBands = List.from(_presets[_selectedPreset]!);
  }

  void _onPresetChanged(String preset) {
    setState(() {
      _selectedPreset = preset;
      _currentBands = List.from(_presets[preset]!);
    });
  }

  void _onBandChanged(int index, double value) {
    setState(() {
      _selectedPreset = 'Custom';
      _currentBands[index] = value;
      _presets['Custom']![index] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AetherisColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Equalizer',
          style: TextStyle(
            color: AetherisColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AetherisColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save logic would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('EQ preset saved')),
              );
            },
            child: const Text('Save', style: TextStyle(color: AetherisColors.accentSoft)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Presets Dropdown
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AetherisColors.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPreset,
                isExpanded: true,
                dropdownColor: AetherisColors.surfaceElevated,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AetherisColors.textSecondary),
                style: const TextStyle(
                  color: AetherisColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                items: _presets.keys.map((String preset) {
                  return DropdownMenuItem<String>(
                    value: preset,
                    child: Text(preset),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) _onPresetChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Sliders
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSlider(0, '60Hz'),
                _buildSlider(1, '230Hz'),
                _buildSlider(2, '910Hz'),
                _buildSlider(3, '3.6kHz'),
                _buildSlider(4, '14kHz'),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSlider(int index, String label) {
    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbColor: AetherisColors.accentSoft,
                activeTrackColor: AetherisColors.accent,
                inactiveTrackColor: AetherisColors.surfaceElevated,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: _currentBands[index],
                min: -12,
                max: 12,
                onChanged: (val) => _onBandChanged(index, val),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            color: AetherisColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
