import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/auth/presentation/screens/phone_entry_screen.dart';
import 'features/chat/presentation/screens/chat_detail_screen.dart';
import 'features/chat/presentation/screens/chats_list_screen.dart';
import 'features/explore/presentation/screens/explore_screen.dart';
import 'features/home/presentation/screens/filters_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/screens/event_details_screen.dart';
import 'features/home/presentation/screens/event_ticket_screen.dart';
import 'features/home/presentation/screens/event_attendees_screen.dart';
import 'features/home/presentation/screens/event_booking_screen.dart';
import 'features/home/presentation/screens/event_checkout_screen.dart';
import 'features/home/presentation/screens/event_request_screen.dart';
import 'features/main_navigation/presentation/main_shell_screen.dart';
import 'features/notifications/presentation/screens/all_notifications_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/notifications/presentation/screens/recent_notifications_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import 'features/organizer/presentation/screens/create_event_audience_screen.dart';
import 'features/organizer/presentation/screens/create_event_category_screen.dart';
import 'features/organizer/presentation/screens/create_event_contact_screen.dart';
import 'features/organizer/presentation/screens/create_event_coupons_screen.dart';
import 'features/organizer/presentation/screens/create_event_description_screen.dart';
import 'features/organizer/presentation/screens/create_event_details_screen.dart';
import 'features/organizer/presentation/screens/create_event_location_screen.dart';
import 'features/organizer/presentation/screens/create_event_pricing_screen.dart';
import 'features/organizer/presentation/screens/create_event_recap_screen.dart';
import 'features/organizer/presentation/screens/organizer_account_settings_screen.dart';
import 'features/organizer/presentation/screens/organizer_approve_users_screen.dart';
import 'features/organizer/presentation/screens/organizer_connect_instagram_screen.dart';
import 'features/organizer/presentation/screens/organizer_edit_profile_screen.dart';
import 'features/organizer/presentation/screens/organizer_event_dashboard_screen.dart';
import 'features/organizer/presentation/screens/organizer_event_history_screen.dart';
import 'features/organizer/presentation/screens/organizer_followers_screen.dart';
import 'features/organizer/presentation/screens/organizer_intro_screen.dart';
import 'features/organizer/presentation/screens/organizer_invite_link_screen.dart';
import 'features/organizer/presentation/screens/organizer_profile_screen.dart';
import 'features/organizer/presentation/screens/organizer_settings_screen.dart';
import 'features/organizer/presentation/screens/organizer_setup_screen.dart';
import 'features/organizer/presentation/screens/organizer_verify_phone_screen.dart';
import 'features/profile/presentation/screens/account_deletion_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/profile/presentation/screens/face_verification_settings_screen.dart';
import 'features/profile/presentation/screens/following_screen.dart';
import 'features/profile/presentation/screens/ghost_mode_screen.dart';
import 'features/profile/presentation/screens/profile_page_screen.dart';
import 'features/profile/presentation/screens/profile_settings_screen.dart';
import 'features/profile/presentation/screens/public_profile_screen.dart';
import 'features/profile/presentation/screens/share_profile_screen.dart';
import 'features/profile/presentation/screens/username_settings_screen.dart';
import 'features/wallet/presentation/screens/wallet_screen.dart';

class AuthState {
  final bool isAuthenticated;
  final bool hasAcceptedGuardrail;
  final bool isOnboardingComplete;
  final String? sessionToken;
  final String? phoneNumber;

  const AuthState({
    required this.isAuthenticated,
    required this.hasAcceptedGuardrail,
    required this.isOnboardingComplete,
    this.sessionToken,
    this.phoneNumber,
  });
}

class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(
      isAuthenticated: false,
      hasAcceptedGuardrail: false,
      isOnboardingComplete: false,
    );
  }

  void updateAuth({
    bool? isAuthenticated,
    bool? hasAcceptedGuardrail,
    bool? isOnboardingComplete,
    String? sessionToken,
    String? phoneNumber,
  }) {
    state = AuthState(
      isAuthenticated: isAuthenticated ?? state.isAuthenticated,
      hasAcceptedGuardrail: hasAcceptedGuardrail ?? state.hasAcceptedGuardrail,
      isOnboardingComplete: isOnboardingComplete ?? state.isOnboardingComplete,
      sessionToken: sessionToken ?? state.sessionToken,
      phoneNumber: phoneNumber ?? state.phoneNumber,
    );
  }
}

final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(AuthStateNotifier.new);

final routerProvider = Provider<GoRouter>((ref) {
  // Using ref.read here instead of ref.watch to prevent recreating the GoRouter instance on every state change
  final authListenable = ValueNotifier<AuthState>(ref.read(authStateProvider));

  ref.listen<AuthState>(authStateProvider, (_, next) {
    authListenable.value = next;
  });

  ref.onDispose(authListenable.dispose);

  return GoRouter(
    initialLocation: '/auth/phone',
    refreshListenable: authListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final auth = authListenable.value;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!auth.isAuthenticated) {
        return isAuthRoute ? null : '/auth/phone';
      }
      if (!auth.isOnboardingComplete) {
        return state.matchedLocation == '/onboarding' ? null : '/onboarding';
      }
      if (state.matchedLocation == '/auth/phone' ||
          state.matchedLocation == '/auth/otp' ||
          state.matchedLocation == '/onboarding') {
        return '/profile';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const PhoneEntryScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlowScreen(),
      ),

      // 1-on-1 Chat Detail Screen pushed on top of root to hide the bottom navigation bar
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ChatDetailScreen(chatId: id);
        },
      ),

      GoRoute(
        path: '/event/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EventDetailsScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/event/:id/ticket',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EventTicketScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/event/:id/attendees',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EventAttendeesScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/event/:id/book',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EventBookingScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/event/:id/checkout',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final total = state.uri.queryParameters['total'] ?? 'Free';
          return EventCheckoutScreen(eventId: id, total: total);
        },
      ),
      GoRoute(
        path: '/event/:id/request',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EventRequestScreen(eventId: id);
        },
      ),

      GoRoute(
        path: '/u/:username',
        builder: (context, state) {
          final username = state.pathParameters['username'] ?? '';
          return PublicProfileScreen(username: username);
        },
      ),

      // Organizer Suite Routes
      GoRoute(
        path: '/organizer/intro',
        builder: (context, state) => const OrganizerIntroScreen(),
      ),
      GoRoute(
        path: '/organizer/setup',
        builder: (context, state) => const OrganizerSetupScreen(),
      ),
      GoRoute(
        path: '/organizer/instagram',
        builder: (context, state) => const OrganizerConnectInstagramScreen(),
      ),
      GoRoute(
        path: '/organizer/verify-phone',
        builder: (context, state) => const OrganizerVerifyPhoneScreen(),
      ),
      GoRoute(
        path: '/organizer/profile',
        builder: (context, state) => const OrganizerProfileScreen(),
      ),
      GoRoute(
        path: '/organizer/edit',
        builder: (context, state) => const OrganizerEditProfileScreen(),
      ),
      GoRoute(
        path: '/organizer/followers',
        builder: (context, state) => const OrganizerFollowersScreen(),
      ),
      GoRoute(
        path: '/organizer/approve',
        builder: (context, state) => const OrganizerApproveUsersScreen(),
      ),
      GoRoute(
        path: '/organizer/invite-link',
        builder: (context, state) => const OrganizerInviteLinkScreen(),
      ),
      GoRoute(
        path: '/organizer/settings',
        builder: (context, state) => const OrganizerSettingsScreen(),
      ),
      GoRoute(
        path: '/organizer/settings/account',
        builder: (context, state) => const OrganizerAccountSettingsScreen(),
      ),
      GoRoute(
        path: '/organizer/events/history',
        builder: (context, state) => const OrganizerEventHistoryScreen(),
      ),
      GoRoute(
        path: '/organizer/events/:id/dashboard',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrganizerEventDashboardScreen(eventId: id);
        },
      ),

      // Organizer Create Event Wizard Routes
      GoRoute(
        path: '/organizer/events/create/category',
        builder: (context, state) => const CreateEventCategoryScreen(),
      ),
      GoRoute(
        path: '/organizer/events/create/details',
        builder: (context, state) => const CreateEventDetailsScreen(),
      ),
      GoRoute(
        path: '/organizer/events/create/description',
        builder: (context, state) => const CreateEventDescriptionScreen(),
      ),
      GoRoute(
        path: '/organizer/events/create/location',
        builder: (context, state) => const CreateEventLocationScreen(),
      ),
      GoRoute(
        path: '/organizer/events/create/audience',
        builder: (context, state) => const CreateEventAudienceScreen(),
      ),
      GoRoute(
        path: '/organizer/events/create/pricing',
        builder: (context, state) => const CreateEventPricingScreen(),
      ),
      GoRoute(
        path: '/organizer/events/create/coupons',
        builder: (context, state) => const CreateEventCouponsScreen(),
      ),
      GoRoute(
        path: '/organizer/events/create/contact',
        builder: (context, state) => const CreateEventContactScreen(),
      ),
      GoRoute(
        path: '/organizer/events/create/recap',
        builder: (context, state) => const CreateEventRecapScreen(),
      ),

      // Persistent 5-Tab Shell (Home -- Explore -- Notifications -- Chat -- Profile)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'filters',
                    builder: (context, state) => const FiltersScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Explore
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),

          // Branch 2: Notifications
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsScreen(),
                routes: [
                  GoRoute(
                    path: 'all',
                    builder: (context, state) {
                      final tab = state.uri.queryParameters['tab'];
                      return AllNotificationsScreen(initialTab: tab);
                    },
                  ),
                  GoRoute(
                    path: 'recent',
                    builder: (context, state) => const RecentNotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Chat
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatsListScreen(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePageScreen(),
                routes: [
                  GoRoute(
                    path: 'share',
                    builder: (context, state) => const ShareProfileScreen(),
                  ),
                  GoRoute(
                    path: 'wallet',
                    builder: (context, state) => const WalletScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'ghost-mode',
                    builder: (context, state) => const GhostModeScreen(),
                  ),
                  GoRoute(
                    path: 'delete-account',
                    builder: (context, state) => const AccountDeletionScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const ProfileSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'following',
                    builder: (context, state) => const FollowingScreen(),
                  ),
                  GoRoute(
                    path: 'username',
                    builder: (context, state) => const UsernameSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'face-verification',
                    builder: (context, state) => const FaceVerificationSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class DenApp extends ConsumerWidget {
  const DenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DEN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
