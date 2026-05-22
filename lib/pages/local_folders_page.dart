import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_settings.dart';
import '../theme/aetheris_colors.dart';

class LocalFoldersPage extends ConsumerWidget {
  const LocalFoldersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final folders = settings.allowedLocalFolders;

    return Scaffold(
      backgroundColor: AetherisColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Local Audio Folders',
          style: TextStyle(
            color: AetherisColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AetherisColors.textPrimary),
      ),
      body: folders.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No folders added.\\nTap + to select a folder for local music scanning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AetherisColors.textSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folderPath = folders[index];
                return ListTile(
                  leading: const Icon(
                    Icons.folder_rounded,
                    color: AetherisColors.accentSoft,
                  ),
                  title: Text(
                    folderPath.split('/').lastWhere((s) => s.isNotEmpty,
                        orElse: () => folderPath),
                    style: const TextStyle(
                      color: AetherisColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    folderPath,
                    style: const TextStyle(
                      color: AetherisColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.redAccent),
                    onPressed: () {
                      final newFolders = List<String>.from(folders)
                        ..removeAt(index);
                      notifier.update(
                          settings.copyWith(allowedLocalFolders: newFolders));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AetherisColors.accent,
        foregroundColor: Colors.white,
        onPressed: () async {
          final String? selectedDirectory = await FilePicker.getDirectoryPath();
          if (selectedDirectory != null) {
            final newFolders = List<String>.from(folders);
            if (!newFolders.contains(selectedDirectory)) {
              newFolders.add(selectedDirectory);
              notifier.update(settings.copyWith(allowedLocalFolders: newFolders));
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Folder', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
