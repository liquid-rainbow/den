import 'package:den/src/app.dart';
import 'package:den/src/features/auth/presentation/screens/phone_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders initial phone entry route screen when unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DenApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial route redirects to auth phone screen
    expect(find.byType(PhoneEntryScreen), findsOneWidget);
  });

  testWidgets('Navigates to home screen and 5 tabs when onboarding is complete', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Set auth state to completed onboarding
    container.read(authStateProvider.notifier).updateAuth(
          isAuthenticated: true,
          hasAcceptedGuardrail: true,
          isOnboardingComplete: true,
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DenApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Should land on Home tab
    expect(find.text('HOME: Profile Discovery Feed + Events Feed'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // 2. Tap Likes tab
    await tester.tap(find.text('Likes'));
    await tester.pumpAndSettle();
    expect(find.text('LIKES: Profiles Liked By User'), findsOneWidget);

    // 3. Tap Notifications tab
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('NOTIFICATIONS'), findsOneWidget);

    // 4. Tap Chats tab
    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    expect(find.text('CHATS: Conversation List'), findsOneWidget);

    // 5. Tap Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('USER PROFILE: My Profile (Editable)'), findsOneWidget);

    // 6. Navigate to Settings from Profile
    await tester.tap(find.text('Go to Settings'));
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS: Account, Edit Name/Phone, Delete Account'), findsOneWidget);
  });
}
