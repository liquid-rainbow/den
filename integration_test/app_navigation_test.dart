import 'package:den/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Real Device End-to-End Navigation Test', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Simulate authenticated state with onboarding complete
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

    debugPrint('[REAL_DEVICE_LOGCAT] App launched on OnePlus device. Landed on Home tab.');
    expect(find.text('HOME: Profile Discovery Feed + Events Feed'), findsOneWidget);

    // 1. Tap Likes
    await tester.tap(find.text('Likes'));
    await tester.pumpAndSettle();
    debugPrint('[REAL_DEVICE_LOGCAT] Tapped Likes tab -> Rendered LIKES: Profiles Liked By User');
    expect(find.text('LIKES: Profiles Liked By User'), findsOneWidget);

    // 2. Tap Notifications
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    debugPrint('[REAL_DEVICE_LOGCAT] Tapped Notifications tab -> Rendered NOTIFICATIONS');
    expect(find.text('NOTIFICATIONS'), findsOneWidget);

    // 3. Tap Chats
    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    debugPrint('[REAL_DEVICE_LOGCAT] Tapped Chats tab -> Rendered CHATS: Conversation List');
    expect(find.text('CHATS: Conversation List'), findsOneWidget);

    // 4. Tap Profile
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    debugPrint('[REAL_DEVICE_LOGCAT] Tapped Profile tab -> Rendered USER PROFILE: My Profile (Editable)');
    expect(find.text('USER PROFILE: My Profile (Editable)'), findsOneWidget);

    // 5. Navigate Profile -> Settings
    await tester.tap(find.text('Go to Settings'));
    await tester.pumpAndSettle();
    debugPrint('[REAL_DEVICE_LOGCAT] Tapped Go to Settings -> Rendered SETTINGS: Account, Edit Name/Phone, Delete Account');
    expect(find.text('SETTINGS: Account, Edit Name/Phone, Delete Account'), findsOneWidget);

    // 6. Navigate Settings -> Back (Profile)
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    debugPrint('[REAL_DEVICE_LOGCAT] Tapped Back button -> Returned to USER PROFILE');
    expect(find.text('USER PROFILE: My Profile (Editable)'), findsOneWidget);

    debugPrint('[REAL_DEVICE_LOGCAT] Navigation sequence completed successfully on real OnePlus device!');
  });
}
