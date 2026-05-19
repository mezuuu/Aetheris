import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../pages/home_page.dart';
import '../pages/library_page.dart';
import '../pages/login_page.dart';
import '../pages/onboarding_page.dart';
import '../pages/search_page.dart';
import '../pages/settings_page.dart';
import '../state/aetheris_scope.dart';
import '../theme/aetheris_colors.dart';
import 'mini_player.dart';

class AetherisShell extends StatefulWidget {
  const AetherisShell({
    super.key,
    this.showOnboarding = true,
    this.showLogin = true,
  });

  final bool showOnboarding;
  final bool showLogin;

  @override
  State<AetherisShell> createState() => _AetherisShellState();
}

class _AetherisShellState extends State<AetherisShell> {
  bool _onboardingDone = false;
  bool _loginDone = false;
  bool _didRequestMediaPermission = false;

  static const _pages = [
    HomePage(),
    SearchPage(),
    LibraryPage(),
    SettingsPage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRequestMediaPermission) return;
    _didRequestMediaPermission = true;
    _requestMediaPermissionAndRefresh();
  }

  Future<void> _requestMediaPermissionAndRefresh() async {
    final controller = AetherisScope.of(context);
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      await controller.refreshLibrary();
      return;
    }
    try {
      final audioStatus = await Permission.audio.request();
      if (!audioStatus.isGranted) {
        await Permission.storage.request();
      }
    } catch (_) {
      // Keep app usable even if permission plugin fails on non-Android targets.
    }
    await controller.refreshLibrary();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);

    if (widget.showOnboarding && !_onboardingDone) {
      return OnboardingPage(
        onDone: () => setState(() => _onboardingDone = true),
      );
    }

    if (widget.showLogin && !_loginDone) {
      return LoginPage(
        onLogin: () {
          setState(() => _loginDone = true);
          _requestMediaPermissionAndRefresh();
        },
        onSkip: () {
          setState(() => _loginDone = true);
          _requestMediaPermissionAndRefresh();
        },
      );
    }

    return Scaffold(
      backgroundColor: AetherisColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: _pages[controller.selectedIndex],
                ),
              ),
            ),
          ),
          const _BottomChrome(),
        ],
      ),
    );
  }
}

// ─── Bottom Chrome (MiniPlayer + TabBar) ─────────────────────────────────────
class _BottomChrome extends StatelessWidget {
  const _BottomChrome();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: MiniPlayer(),
            ),
            const SizedBox(height: 4),
            Container(
              padding: EdgeInsets.only(bottom: bottom),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF000000), Color(0x00000000)],
                ),
              ),
              child: const _AetherisBottomNav(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _AetherisBottomNav extends StatelessWidget {
  const _AetherisBottomNav();

  static const _items = [
    (
      Icons.play_circle_filled_rounded,
      Icons.play_circle_outline_rounded,
      'Listen Now',
    ),
    (Icons.search_rounded, Icons.search_rounded, 'Search'),
    (Icons.library_music_rounded, Icons.library_music_outlined, 'Library'),
    (Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = AetherisScope.of(context);

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: _NavItem(
                activeIcon: _items[i].$1,
                inactiveIcon: _items[i].$2,
                label: _items[i].$3,
                selected: controller.selectedIndex == i,
                onTap: () => controller.selectTab(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AetherisColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? activeIcon : inactiveIcon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
