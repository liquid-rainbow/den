import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/bottom_nav_bar.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/auth/presentation/screens/phone_entry_screen.dart';
import 'features/chat/presentation/screens/chat_list_screen.dart';
import 'features/discovery/presentation/screens/home_screen.dart';
import 'features/likes/presentation/screens/likes_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import 'features/profile/presentation/screens/public_profile_screen.dart';
import 'features/profile/presentation/screens/settings_screen.dart';
import 'features/profile/presentation/screens/user_profile_screen.dart';

class AuthState {
  final bool isAuthenticated;
  final bool hasAcceptedGuardrail;
  final bool isOnboardingComplete;

  const AuthState({
    required this.isAuthenticated,
    required this.hasAcceptedGuardrail,
    required this.isOnboardingComplete,
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
  }) {
    state = AuthState(
      isAuthenticated: isAuthenticated ?? state.isAuthenticated,
      hasAcceptedGuardrail: hasAcceptedGuardrail ?? state.hasAcceptedGuardrail,
      isOnboardingComplete: isOnboardingComplete ?? state.isOnboardingComplete,
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
      if (isAuthRoute || state.matchedLocation == '/onboarding') {
        return '/home';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainBottomNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/likes',
                builder: (context, state) => const LikesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const UserProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: '/public-profile',
                builder: (context, state) => const PublicProfileScreen(),
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
