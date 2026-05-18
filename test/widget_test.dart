import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aetheris_audio_player/app/aetheris_app.dart';

void main() {
  Future<void> openMainShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const AetherisApp(
        startPlaybackClock: false,
        showOnboarding: false,
        showLogin: false,
      ),
    );
    await tester.pump();
  }

  testWidgets('Aetheris shell renders core home content', (tester) async {
    await openMainShell(tester);

    expect(find.byKey(const ValueKey('home')), findsOneWidget);
    expect(find.text('Recently Played'), findsOneWidget);
    expect(find.text('Made For You'), findsOneWidget);
    expect(find.text('Clear Sky'), findsWidgets);
  });

  testWidgets('bottom navigation opens search page', (tester) async {
    await openMainShell(tester);

    await tester.tap(find.text('Search').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('search')), findsOneWidget);
    expect(find.text('Browse Categories'), findsOneWidget);
  });

  testWidgets('login opens main shell without blocking', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const AetherisApp(startPlaybackClock: false, showOnboarding: false),
    );
    await tester.pump();

    expect(find.text('Log in to Aetheris'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Login with Google'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, 'user@example.com');
    await tester.enterText(find.byType(EditableText).last, 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('home')), findsOneWidget);
    expect(find.text('Recently Played'), findsOneWidget);
  });

  testWidgets('google login opens main shell without blocking', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const AetherisApp(startPlaybackClock: false, showOnboarding: false),
    );
    await tester.pump();

    await tester.tap(find.text('Login with Google'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('home')), findsOneWidget);
  });
}
