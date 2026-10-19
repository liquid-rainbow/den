import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/organizer_audience.dart';
import '../domain/models/organizer_event.dart';

class OrganizerEventsState {
  final List<OrganizerEvent> upcomingEvents;
  final List<OrganizerEvent> pastEvents;
  final List<AudienceUser> followers;
  final List<AudienceUser> approvedUsers;
  final String inviteLink;
  final DateTime inviteExpiresAt;

  const OrganizerEventsState({
    required this.upcomingEvents,
    required this.pastEvents,
    required this.followers,
    required this.approvedUsers,
    required this.inviteLink,
    required this.inviteExpiresAt,
  });

  factory OrganizerEventsState.initial() {
    return OrganizerEventsState(
      upcomingEvents: const [
        OrganizerEvent(
          id: 'evt_1',
          title: 'Silent Dinner Series',
          dateLabel: "24 Aug '25",
          monthShort: 'Oct',
          dayNumber: '24',
          timeRange: '8 PM - 11 PM',
          venueName: 'The Glass House',
          venueAddress: 'Brooklyn, NY',
          imageUrl:
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
          ticketsSold: 428,
          ticketsTotal: 500,
          grossRevenue: 204500,
          netEarnings: 182400,
          platformFeePercent: 10.0,
          femaleDemographicPercent: 60,
          maleDemographicPercent: 35,
          otherDemographicPercent: 5,
          firstTimerPercent: 58,
          returningPercent: 42,
          attendedCount: 382,
          isUpcoming: true,
        ),
        OrganizerEvent(
          id: 'evt_2',
          title: 'Digital Detox',
          dateLabel: "12 Sep '25",
          monthShort: 'Sep',
          dayNumber: '12',
          timeRange: '10 AM - 6 PM',
          venueName: 'Upstate Sanctuary',
          venueAddress: 'Upstate NY',
          imageUrl:
              'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=800&q=80',
          ticketsSold: 120,
          ticketsTotal: 150,
          grossRevenue: 95000,
          netEarnings: 85500,
          isUpcoming: true,
        ),
        OrganizerEvent(
          id: 'evt_3',
          title: 'Neon Nights Festival',
          dateLabel: "24 Aug '25",
          monthShort: 'Aug',
          dayNumber: '24',
          timeRange: '10 PM - 2 AM',
          venueName: 'Cyber Pier 9',
          venueAddress: 'Downtown Marina',
          imageUrl:
              'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=800&q=80',
          ticketsSold: 428,
          ticketsTotal: 500,
          grossRevenue: 204500,
          netEarnings: 182400,
          platformFeePercent: 10.0,
          femaleDemographicPercent: 60,
          maleDemographicPercent: 35,
          otherDemographicPercent: 5,
          firstTimerPercent: 58,
          returningPercent: 42,
          attendedCount: 382,
          isUpcoming: true,
        ),
      ],
      pastEvents: const [
        OrganizerEvent(
          id: 'evt_past_1',
          title: 'Silent Dinner Series (Vol. 1)',
          dateLabel: "24 Aug '24",
          monthShort: 'Aug',
          dayNumber: '24',
          timeRange: '7 PM - 11 PM',
          venueName: 'The Glasshouse',
          venueAddress: 'The Glasshouse, Brooklyn',
          imageUrl:
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
          ticketsSold: 200,
          ticketsTotal: 200,
          grossRevenue: 150000,
          netEarnings: 135000,
          isUpcoming: false,
        ),
        OrganizerEvent(
          id: 'evt_past_2',
          title: 'Aura Sunset Gathering',
          dateLabel: "15 Jun '24",
          monthShort: 'Jun',
          dayNumber: '15',
          timeRange: '6 PM - 10 PM',
          venueName: 'Skyline Terrace',
          venueAddress: 'Manhattan, NY',
          imageUrl:
              'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=800&q=80',
          ticketsSold: 350,
          ticketsTotal: 350,
          grossRevenue: 260000,
          netEarnings: 234000,
          isUpcoming: false,
        ),
      ],
      followers: const [
        AudienceUser(
          id: 'u_1',
          name: 'Aarav Sharma',
          username: 'aarav_s',
          avatarUrl:
              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80',
          isApproved: false,
          isFollowed: false,
        ),
        AudienceUser(
          id: 'u_2',
          name: 'Maya Patel',
          username: 'maya_p',
          avatarUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
          isApproved: false,
          isFollowed: true,
        ),
        AudienceUser(
          id: 'u_3',
          name: 'Chen Wei',
          username: 'chen_wei99',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
          isApproved: false,
          isFollowed: false,
        ),
        AudienceUser(
          id: 'u_4',
          name: 'Sarah Jenkins',
          username: 'sarah_jinks',
          avatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
          isApproved: false,
          isFollowed: true,
        ),
      ],
      approvedUsers: const [
        AudienceUser(
          id: 'app_1',
          name: 'Diego Martinez',
          username: 'diego_m',
          avatarUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
          isApproved: true,
          isFollowed: true,
        ),
        AudienceUser(
          id: 'app_2',
          name: 'Chloe Kim',
          username: 'chloe_creates',
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          isApproved: true,
          isFollowed: true,
        ),
        AudienceUser(
          id: 'app_3',
          name: 'Omar Farooq',
          username: 'omar_f',
          avatarUrl:
              'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=400&q=80',
          isApproved: true,
          isFollowed: false,
        ),
      ],
      inviteLink: 'neon-nights.app/join/aura-collective-482',
      inviteExpiresAt: DateTime.now().add(const Duration(hours: 48)),
    );
  }

  OrganizerEventsState copyWith({
    List<OrganizerEvent>? upcomingEvents,
    List<OrganizerEvent>? pastEvents,
    List<AudienceUser>? followers,
    List<AudienceUser>? approvedUsers,
    String? inviteLink,
    DateTime? inviteExpiresAt,
  }) {
    return OrganizerEventsState(
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      pastEvents: pastEvents ?? this.pastEvents,
      followers: followers ?? this.followers,
      approvedUsers: approvedUsers ?? this.approvedUsers,
      inviteLink: inviteLink ?? this.inviteLink,
      inviteExpiresAt: inviteExpiresAt ?? this.inviteExpiresAt,
    );
  }
}

class OrganizerEventsController extends Notifier<OrganizerEventsState> {
  @override
  OrganizerEventsState build() => OrganizerEventsState.initial();

  void toggleFollow(String userId) {
    final updated = state.followers.map((u) {
      if (u.id == userId) {
        return u.copyWith(isFollowed: !u.isFollowed);
      }
      return u;
    }).toList();
    state = state.copyWith(followers: updated);
  }

  void removeFollower(String userId) {
    state = state.copyWith(
      followers: state.followers.where((u) => u.id != userId).toList(),
    );
  }

  void revokeApproval(String userId) {
    state = state.copyWith(
      approvedUsers: state.approvedUsers.where((u) => u.id != userId).toList(),
    );
  }

  void approveUser(AudienceUser user) {
    final updated = [...state.approvedUsers, user.copyWith(isApproved: true)];
    state = state.copyWith(approvedUsers: updated);
  }

  void addEvent(OrganizerEvent event) {
    state = state.copyWith(
      upcomingEvents: [event, ...state.upcomingEvents],
    );
  }

  void regenerateInviteLink(String organizerHandle) {
    final randomSuffix = 100 + Random().nextInt(900);
    final handleClean = organizerHandle.replaceAll('@', '').toLowerCase();
    final newLink = 'neon-nights.app/join/$handleClean-$randomSuffix';
    state = state.copyWith(
      inviteLink: newLink,
      inviteExpiresAt: DateTime.now().add(const Duration(hours: 48)),
    );
  }

  OrganizerEvent? getEventById(String id) {
    for (final e in state.upcomingEvents) {
      if (e.id == id) return e;
    }
    for (final e in state.pastEvents) {
      if (e.id == id) return e;
    }
    return null;
  }
}

final organizerEventsProvider =
    NotifierProvider<OrganizerEventsController, OrganizerEventsState>(
        OrganizerEventsController.new);
