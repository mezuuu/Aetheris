import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/aetheris_colors.dart';

class EqPage extends StatefulWidget {
  const EqPage({super.key});

  @override
  State<EqPage> createState() => _EqPageState();
}

class _EqPageState extends State<EqPage> {
  String _selectedPreset = 'Flat';
  
  // 22 Default Spotify-matching EQ presets (8 bands)
  final Map<String, List<double>> _defaultPresets = {
    'Flat': [0, 0, 0, 0, 0, 0, 0, 0],
    'Acoustic': [3, 3, 2, 0, -1, 1, 3, 3],
    'Bass booster': [6, 5, 4, 2, 0, 0, 0, 0],
    'Bass reducer': [-6, -5, -4, -2, 0, 0, 0, 0],
    'Classical': [3, 2, 1, 0, -1, 0, 2, 3],
    'Dance': [5, 4, 1, -1, -2, 1, 3, 4],
    'Deep': [4, 3, 1, 0, 0, 0, 0, 0],
    'Electronic': [5, 4, 1, 0, -2, 2, 4, 5],
    'HipHop': [5, 4, 1, -1, -1, 1, 3, 4],
    'Jazz': [3, 2, 1, 0, -1, 1, 3, 4],
    'Latin': [4, 3, 0, -1, -2, 1, 4, 5],
    'Loudness': [5, 4, 0, -1, -1, 0, 4, 5],
    'Lounge': [-3, -2, -1, 0, 1, 2, 3, -1],
    'Piano': [2, 1, 0, 2, 3, 1, 2, 3],
    'Pop': [-1, 0, 2, 3, 3, 1, -1, -2],
    'RnB': [5, 4, 2, -1, -1, 1, 3, 4],
    'Rock': [5, 4, 2, 0, -1, 2, 4, 5],
    'Small speakers': [4, 3, 2, 1, 0, -1, -2, -3],
    'Spoken word': [-2, -1, 0, 1, 3, 4, 1, -2],
    'Treble booster': [0, 0, 0, 0, 1, 3, 5, 6],
    'Treble reducer': [0, 0, 0, 0, -1, -3, -5, -6],
    'Vocal booster': [-2, -1, 0, 1, 4, 4, 2, 0],
    'Custom': [0, 0, 0, 0, 0, 0, 0, 0],
  };

  Map<String, List<double>> _customPresets = {};
  late List<double> _currentBands;
  
  final List<String> _bandLabels = [
    '50Hz', '100Hz', '250Hz', '500Hz', '1kHz', '3kHz', '8kHz', '12kHz'
  ];

  @override
  void initState() {
    super.initState();
    _currentBands = List.from(_defaultPresets['Flat']!);
    _loadCustomPresets();
  }

  Future<void> _loadCustomPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('custom_eq_presets');
    if (data != null) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        setState(() {
          _customPresets = decoded.map((k, v) => MapEntry(k, (v as List).cast<num>().map((n) => n.toDouble()).toList()));
        });
      } catch (e) {
        // Ignore parsing errors
      }
    }
  }

  Future<void> _saveCustomPresetsMap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_eq_presets', jsonEncode(_customPresets));
  }

  void _onPresetChanged(String preset) {
    setState(() {
      _selectedPreset = preset;
      if (_customPresets.containsKey(preset)) {
        _currentBands = List.from(_customPresets[preset]!);
      } else {
        _currentBands = List.from(_defaultPresets[preset]!);
      }
    });
  }

  void _onBandChanged(int index, double value) {
    setState(() {
      if (!_customPresets.containsKey(_selectedPreset)) {
        _selectedPreset = 'Custom';
      }
      _currentBands[index] = value;
      if (_selectedPreset == 'Custom') {
        _defaultPresets['Custom']![index] = value;
      } else {
        _customPresets[_selectedPreset]![index] = value;
        _saveCustomPresetsMap();
      }
    });
  }

  Future<void> _showSavePresetDialog() async {
    String name = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AetherisColors.surfaceRaised,
          title: const Text('Save Custom Preset', style: TextStyle(color: Colors.white)),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Preset Name',
              hintStyle: TextStyle(color: AetherisColors.textSecondary),
            ),
            onChanged: (v) => name = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AetherisColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, name),
              child: const Text('Save', style: TextStyle(color: AetherisColors.accentSoft)),
            ),
          ],
        );
      }
    );

    if (result != null && result.trim().isNotEmpty) {
      final presetName = result.trim();
      if (_customPresets.containsKey(presetName)) {
        // Overwrite existing
        setState(() {
          _customPresets[presetName] = List.from(_currentBands);
          _selectedPreset = presetName;
        });
        await _saveCustomPresetsMap();
      } else {
        if (_customPresets.length >= 5) {
          // Slots full, ask to overwrite one
          final toDelete = await _showDeletePresetDialog();
          if (toDelete != null) {
            _customPresets.remove(toDelete);
            setState(() {
              _customPresets[presetName] = List.from(_currentBands);
              _selectedPreset = presetName;
            });
            await _saveCustomPresetsMap();
          }
        } else {
          // Save new
          setState(() {
            _customPresets[presetName] = List.from(_currentBands);
            _selectedPreset = presetName;
          });
          await _saveCustomPresetsMap();
        }
      }
    }
  }

  Future<String?> _showDeletePresetDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AetherisColors.surfaceRaised,
          title: const Text('Custom Slots Full', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a preset to replace:', style: TextStyle(color: AetherisColors.textSecondary)),
              const SizedBox(height: 16),
              ..._customPresets.keys.map((k) => ListTile(
                title: Text(k, style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, k),
                trailing: const Icon(Icons.delete_outline, color: AetherisColors.error),
              ))
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AetherisColors.textSecondary)),
            )
          ],
        );
      }
    );
  }

  void _deleteCurrentCustomPreset() {
    if (_customPresets.containsKey(_selectedPreset)) {
      setState(() {
        _customPresets.remove(_selectedPreset);
        _selectedPreset = 'Flat';
        _currentBands = List.from(_defaultPresets['Flat']!);
      });
      _saveCustomPresetsMap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPresets = [
      ..._defaultPresets.keys,
      ..._customPresets.keys,
    ];

    // Ensure _selectedPreset is valid in the dropdown.
    if (!allPresets.contains(_selectedPreset)) {
      _selectedPreset = 'Flat';
    }

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
          if (_customPresets.containsKey(_selectedPreset))
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AetherisColors.error),
              onPressed: _deleteCurrentCustomPreset,
            ),
          TextButton(
            onPressed: _showSavePresetDialog,
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
                items: allPresets.map((String preset) {
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
              children: List.generate(8, (index) => _buildSlider(index, _bandLabels[index])),
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
