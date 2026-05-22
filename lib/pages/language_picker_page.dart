import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/languages.dart';
import '../state/app_settings.dart';
import '../theme/aetheris_colors.dart';

class LanguagePickerPage extends ConsumerStatefulWidget {
  const LanguagePickerPage({super.key});

  @override
  ConsumerState<LanguagePickerPage> createState() => _LanguagePickerPageState();
}

class _LanguagePickerPageState extends ConsumerState<LanguagePickerPage> {
  final _searchController = TextEditingController();
  List<AppLanguage> _results = LanguageList.popular;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _results = LanguageList.popular;
      });
    } else {
      setState(() {
        _isSearching = true;
        _results = LanguageList.search(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLangCode = ref.watch(appSettingsProvider).translationLanguage;

    return Scaffold(
      backgroundColor: AetherisColors.background,
      appBar: AppBar(
        backgroundColor: AetherisColors.background,
        title: const Text(
          'Translation Language',
          style: TextStyle(
            color: AetherisColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AetherisColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search 195+ languages...',
                hintStyle: const TextStyle(color: AetherisColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: AetherisColors.textSecondary),
                filled: true,
                fillColor: AetherisColors.surfaceRaised,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _isSearching ? _results.length : LanguageList.all.length + 1,
        itemBuilder: (context, index) {
          if (!_isSearching && index == 0) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'All Languages',
                style: TextStyle(
                  color: AetherisColors.accentSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          final lang = _isSearching 
              ? _results[index] 
              : LanguageList.all[index - 1];
          
          final isSelected = lang.code == currentLangCode;

          return ListTile(
            leading: Text(
              lang.flag,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              lang.name,
              style: TextStyle(
                color: isSelected ? AetherisColors.accentSoft : AetherisColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            subtitle: Text(
              lang.nativeName,
              style: const TextStyle(color: AetherisColors.textSecondary, fontSize: 13),
            ),
            trailing: isSelected 
                ? const Icon(Icons.check_circle_rounded, color: AetherisColors.accentSoft)
                : null,
            onTap: () {
              ref.read(appSettingsProvider.notifier).update(
                ref.read(appSettingsProvider).copyWith(translationLanguage: lang.code)
              );
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
