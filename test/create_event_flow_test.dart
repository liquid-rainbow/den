import 'package:den/src/core/widgets/den_wheel_picker.dart';
import 'package:den/src/features/home/presentation/screens/home_screen.dart';
import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/application/organizer_events_controller.dart';
import 'package:den/src/features/organizer/domain/models/create_event_draft.dart';
import 'package:den/src/features/organizer/domain/models/organizer_event.dart';
import 'package:den/src/features/organizer/presentation/screens/create_event_category_screen.dart';
import 'package:den/src/features/organizer/presentation/screens/create_event_details_screen.dart';
import 'package:den/src/features/organizer/presentation/screens/create_event_audience_screen.dart';
import 'package:den/src/features/organizer/presentation/screens/create_event_pricing_screen.dart';
import 'package:den/src/features/organizer/presentation/screens/create_event_recap_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateEventController Unit Tests', () {
    test('initial state has default party category and basic draft', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(createEventProvider);
      expect(state.category, EventCategory.party);
      expect(state.pricingType, EventPricingType.paid);
      expect(state.ticketTiers.isNotEmpty, isTrue);
      expect(state.exclusivity, EventExclusivity.approvedOnly);
    });

    test('updateCategory changes draft category', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(createEventProvider.notifier);
      notifier.setCategory(EventCategory.comedyClub);
      expect(container.read(createEventProvider).category, EventCategory.comedyClub);
    });

    test('ticket tiers and coupon operations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(createEventProvider.notifier);
      const newTier = EventTicketTier(
        id: 'tier_vip',
        name: 'VIP Balcony',
        badge: 'VIP',
        price: 1200.0,
      );
      notifier.addTicketTier(newTier);
      expect(container.read(createEventProvider).ticketTiers.any((t) => t.id == 'tier_vip'), isTrue);

      const coupon = EventCoupon(
        id: 'cpn_1',
        code: 'EARLYBIRD',
        type: DiscountType.percentage,
        value: 20.0,
      );
      notifier.addCoupon(coupon);
      expect(container.read(createEventProvider).coupons.any((c) => c.code == 'EARLYBIRD'), isTrue);

      notifier.removeCoupon('cpn_1');
      expect(container.read(createEventProvider).coupons.any((c) => c.code == 'EARLYBIRD'), isFalse);
    });

    test('gallery photos add and remove operations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(createEventProvider.notifier);
      notifier.addGalleryPhoto('photo_1.jpg');
      notifier.addGalleryPhoto('photo_2.jpg');
      expect(container.read(createEventProvider).galleryUrls.length, 2);

      notifier.removeGalleryPhoto(0);
      expect(container.read(createEventProvider).galleryUrls, ['photo_2.jpg']);
    });

    test('publishEvent inserts new event into organizerEventsProvider and resets draft', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(createEventProvider.notifier);
      notifier.updateBasicDetails(
        title: 'Sunset Neon Waves',
        date: DateTime(2026, 10, 24),
        startTime: '19:00',
        endTime: '23:00',
      );
      notifier.updateLocation(
        venueName: 'The Glasshouse',
        venueAddress: 'Hauz Khas Village, New Delhi',
      );

      final published = notifier.publishEvent();
      expect(published.title, 'Sunset Neon Waves');
      expect(published.venueName, 'The Glasshouse');

      final eventsState = container.read(organizerEventsProvider);
      expect(eventsState.upcomingEvents.any((e) => e.title == 'Sunset Neon Waves'), isTrue);
    });
  });

  group('Create Event Flow Widget Tests', () {
    testWidgets('CreateEventCategoryScreen renders category cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateEventCategoryScreen(),
          ),
        ),
      );

      expect(find.text('Select the type of den you want to create'), findsOneWidget);
      expect(find.text('Party'), findsOneWidget);
      expect(find.text('Event'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('Comedy Club'), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);
    });

    testWidgets('CreateEventDetailsScreen renders upload and wheel picker', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(createEventProvider.notifier).updateBasicDetails(bannerUrl: '');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CreateEventDetailsScreen(),
          ),
        ),
      );

      expect(find.text('Event Details'), findsOneWidget);
      expect(find.text('Upload a banner image'), findsOneWidget);
      expect(find.text('Name your den'), findsOneWidget);
      expect(find.text('Date and time'), findsOneWidget);
      expect(find.byType(DenDateTimePicker), findsOneWidget);
    });

    testWidgets('CreateEventAudienceScreen renders exclusivity options and capacity', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateEventAudienceScreen(),
          ),
        ),
      );

      expect(find.text('Approved\nguest only'), findsOneWidget);
      expect(find.text('Open to\neveryone'), findsOneWidget);
      expect(find.text('What is the capacity of your den?'), findsOneWidget);
      expect(find.text('Open to?'), findsOneWidget);
    });

    testWidgets('CreateEventPricingScreen renders pricing breakdown', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateEventPricingScreen(),
          ),
        ),
      );

      expect(find.text('How would you like to sell your tickets?'), findsOneWidget);
      expect(find.text('Free to join'), findsOneWidget);
      expect(find.text('Add tickets'), findsOneWidget);
      expect(find.text('Pricing Breakdown'), findsOneWidget);
      expect(find.text('Guest pays'), findsOneWidget);
      expect(find.text('You get'), findsOneWidget);
    });

    testWidgets('CreateEventRecapScreen renders review summary and Publish button', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(createEventProvider.notifier).updateBasicDetails(bannerUrl: '');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CreateEventRecapScreen(),
          ),
        ),
      );

      expect(find.text('Banner Image'), findsOneWidget);
      expect(find.text('VENUE'), findsOneWidget);
      expect(find.text('CAPACITY & CROWD'), findsOneWidget);
      expect(find.text('PRICING DETAILS'), findsOneWidget);
      expect(find.text('Publish Event'), findsOneWidget);
    });

    testWidgets('HomeScreen renders published events dynamically from provider', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(organizerEventsProvider.notifier).addEvent(
            const OrganizerEvent(
              id: 'custom_1',
              title: 'Live Sunset Electronic Session',
              dateLabel: "28 Oct '26",
              monthShort: 'Oct',
              dayNumber: '28',
              timeRange: '9 PM - 2 AM',
              venueName: 'Skyline Terrace',
              venueAddress: 'Connaught Place, New Delhi',
              imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
              ticketsSold: 50,
              ticketsTotal: 100,
              grossRevenue: 25000.0,
              netEarnings: 23750.0,
              isUpcoming: true,
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Live Sunset Electronic Session'), findsOneWidget);
      expect(find.text('Upcoming Community Events'), findsOneWidget);
    });
  });
}
