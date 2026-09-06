import 'package:den/src/features/organizer/application/organizer_controller.dart';
import 'package:den/src/features/organizer/application/organizer_events_controller.dart';
import 'package:den/src/features/organizer/domain/models/organizer_audience.dart';
import 'package:den/src/features/organizer/presentation/screens/organizer_intro_screen.dart';
import 'package:den/src/features/organizer/presentation/screens/organizer_setup_screen.dart';
import 'package:den/src/features/organizer/presentation/screens/organizer_followers_screen.dart';
import 'package:den/src/features/organizer/presentation/screens/organizer_event_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrganizerController Unit Tests', () {
    test('initial state has no organizer profile', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(organizerProvider);
      expect(state.hasOrganizerProfile, isFalse);
      expect(state.profile, isNull);
      expect(state.activeMode, ProfileMode.user);
    });

    test('updateDraft and completeSetup creates an organizer profile', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(organizerProvider.notifier);
      notifier.updateDraft(
        name: 'Neon Nights Events',
        username: 'neonnights',
        instagramHandle: 'neonnights_ny',
        phoneNumber: '5551234567',
      );

      expect(container.read(organizerProvider).draft.name, 'Neon Nights Events');
      expect(container.read(organizerProvider).draft.username, 'neonnights');

      notifier.completeSetup();

      final state = container.read(organizerProvider);
      expect(state.hasOrganizerProfile, isTrue);
      expect(state.profile?.name, 'Neon Nights Events');
      expect(state.profile?.username, 'neonnights');
      expect(state.profile?.displayHandle, '@neonnights');
      expect(state.activeMode, ProfileMode.organizer);
    });

    test('switchMode toggles between user and organizer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(organizerProvider.notifier);
      notifier.switchMode(ProfileMode.organizer);
      expect(container.read(organizerProvider).activeMode, ProfileMode.organizer);

      notifier.switchMode(ProfileMode.user);
      expect(container.read(organizerProvider).activeMode, ProfileMode.user);
    });

    test('deleteOrganizerProfile clears state and switches mode back to user', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(organizerProvider.notifier);
      notifier.updateDraft(name: 'Aura', username: 'aura');
      notifier.completeSetup();

      expect(container.read(organizerProvider).hasOrganizerProfile, isTrue);

      notifier.deleteOrganizerProfile();

      expect(container.read(organizerProvider).hasOrganizerProfile, isFalse);
      expect(container.read(organizerProvider).profile, isNull);
      expect(container.read(organizerProvider).activeMode, ProfileMode.user);
    });
  });

  group('OrganizerEventsController Unit Tests', () {
    test('initial state contains upcoming and past events', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(organizerEventsProvider);
      expect(state.upcomingEvents.isNotEmpty, isTrue);
      expect(state.pastEvents.isNotEmpty, isTrue);
      expect(state.followers.isNotEmpty, isTrue);
      expect(state.approvedUsers.isNotEmpty, isTrue);
      expect(state.inviteLink.contains('neon-nights.app/join/'), isTrue);
    });

    test('toggleFollow, removeFollower, approveUser and revokeApproval work correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(organizerEventsProvider.notifier);
      final firstFollower = container.read(organizerEventsProvider).followers.first;

      notifier.toggleFollow(firstFollower.id);
      expect(
        container.read(organizerEventsProvider).followers.firstWhere((f) => f.id == firstFollower.id).isFollowed,
        !firstFollower.isFollowed,
      );

      final newGuest = const AudienceUser(
        id: 'new_1',
        name: 'New Guest',
        username: 'new_guest',
        avatarUrl: 'https://example.com/avatar.jpg',
      );
      notifier.approveUser(newGuest);
      expect(
        container.read(organizerEventsProvider).approvedUsers.any((u) => u.id == 'new_1'),
        isTrue,
      );

      notifier.revokeApproval('new_1');
      expect(
        container.read(organizerEventsProvider).approvedUsers.any((u) => u.id == 'new_1'),
        isFalse,
      );
    });
  });

  group('Organizer Widget Tests', () {
    testWidgets('OrganizerIntroScreen renders title and CTA', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OrganizerIntroScreen(),
          ),
        ),
      );

      expect(find.text('Get Started'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains("Let's create your"),
        ),
        findsOneWidget,
      );
    });

    testWidgets('OrganizerSetupScreen renders input fields and button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OrganizerSetupScreen(),
          ),
        ),
      );

      expect(find.text('Setup Your Profile'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('OrganizerFollowersScreen renders segmented tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OrganizerFollowersScreen(),
          ),
        ),
      );

      expect(find.text('Followers'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Approve users manually'), findsOneWidget);
      expect(find.text('Approval invite link'), findsOneWidget);
    });

    testWidgets('OrganizerEventDashboardScreen renders metrics and charts', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OrganizerEventDashboardScreen(eventId: 'evt_1'),
          ),
        ),
      );

      expect(find.text('TICKET INVENTORY'), findsOneWidget);
      expect(find.text('GROSS VALUE'), findsOneWidget);
      expect(find.text('NET EARNINGS'), findsOneWidget);
      expect(find.text('Audience'), findsOneWidget);
    });
  });
}
