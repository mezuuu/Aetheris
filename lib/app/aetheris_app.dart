import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/aetheris_theme.dart';
import '../widgets/aetheris_shell.dart';

/// Aetheris App using Riverpod for state management
class AetherisApp extends ConsumerWidget {
  const AetherisApp({
    super.key,
    this.showOnboarding = true,
    this.showLogin = true,
  });

  final bool showOnboarding;
  final bool showLogin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize providers if needed
    // ref.watch(playerServiceProvider);
    // ref.watch(libraryServiceProvider);

    return MaterialApp(
      title: 'Aetheris',
      debugShowCheckedModeBanner: false,
      theme: AetherisTheme.dark(),
      home: AetherisShell(
        showOnboarding: showOnboarding,
        showLogin: showLogin,
      ),
    );
  }
}
