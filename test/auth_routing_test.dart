import 'dart:async';
import 'dart:io';

import 'package:den/src/app.dart';
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

  testWidgets('Existing customer logging in navigates directly to self profile page',
      (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(AuthStateNotifier.new),
      ],
    );

    // Simulate verified existing user login
    container.read(authStateProvider.notifier).updateAuth(
          isAuthenticated: true,
          hasAcceptedGuardrail: true,
          isOnboardingComplete: true,
          phoneNumber: '+919876543210',
          sessionToken: 'test_token_123',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DenApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify user is on Profile page directly
    expect(find.text('raghav'), findsOneWidget);
    expect(find.text('Share Profile'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
  });

  testWidgets('New customer logging in is routed to onboarding flow',
      (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(AuthStateNotifier.new),
      ],
    );

    // Simulate newly verified user who has not completed onboarding
    container.read(authStateProvider.notifier).updateAuth(
          isAuthenticated: true,
          hasAcceptedGuardrail: true,
          isOnboardingComplete: false,
          phoneNumber: '+919876543210',
          sessionToken: 'test_token_123',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DenApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify user is on Onboarding screen
    expect(find.text('STEP 1 OF 8'), findsOneWidget);
  });
}
