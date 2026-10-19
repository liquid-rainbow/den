import 'dart:async';
import 'dart:io';

import 'package:den/src/app.dart';
import 'package:den/src/features/chat/presentation/screens/chats_list_screen.dart';
import 'package:den/src/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl ||
        invocation.memberName == #openUrl ||
        invocation.memberName == #get) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    if (invocation.memberName == #headers) {
      return _MockHttpHeaders();
    }
    return null;
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  testWidgets('Authenticated app renders 5 footer tabs with icons and text labels',
      (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(AuthStateNotifier.new),
      ],
    );

    // Set authenticated and onboarding complete state
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

    // Verify 5 tabs in footer
    expect(find.text('HOME'), findsWidgets);
    expect(find.text('EXPLORE'), findsOneWidget);
    expect(find.text('NOTIFICATIONS'), findsOneWidget);
    expect(find.text('CHAT'), findsOneWidget);
    expect(find.text('PROFILE'), findsOneWidget);

    // Verify footer icons
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.travel_explore_outlined), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('Chats list renders conversations correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatsListScreen(),
      ),
    );

    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('Chloe'), findsOneWidget);
    expect(find.text('Design Gang'), findsOneWidget);
    expect(find.text("Buster's Daycare"), findsOneWidget);
    expect(find.text('Search chats...'), findsOneWidget);
  });

  testWidgets('Notifications screen renders Recent feed and Invites correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsScreen(),
      ),
    );

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Invites'), findsOneWidget);
    expect(find.text('You are invited to the event'), findsOneWidget);
    expect(find.text('Your request has been approved'), findsOneWidget);
    expect(find.text('Sophia, 24'), findsOneWidget);
    expect(find.text('Alex, 26'), findsOneWidget);
  });
}
