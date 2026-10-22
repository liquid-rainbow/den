import 'package:den/src/features/chat/data/chat_api_repository.dart';
import 'package:den/src/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:den/src/features/chat/presentation/screens/chats_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeChatApi extends ChatApiRepository {
  FakeChatApi() : super('test');
  bool failSend = false;
  String? liked;
  final saved = <Map<String, dynamic>>[];
  @override
  Future<List<Map<String, dynamic>>> conversations() async => [
    {'id': 'conversation', 'name': 'Tejb', 'lastMessage': null},
  ];
  @override
  Future<Map<String, dynamic>> like(String username) async {
    liked = username;
    return {'matched': false};
  }

  @override
  Future<List<Map<String, dynamic>>> messages(
    String id, {
    String? before,
  }) async => List.of(saved);
  @override
  Future<void> send(String id, String text) async {
    if (failSend) throw Exception('offline');
    saved.add({
      'id': '${saved.length + 1}',
      'text': text,
      'isMe': true,
      'createdAt': '2026-10-19T10:00:00Z',
    });
  }
}

void main() {
  Future<void> show(WidgetTester tester, FakeChatApi api, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [chatApiProvider.overrideWithValue(api)],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Chat list loads real names and submits a like', (tester) async {
    final api = FakeChatApi();
    await show(tester, api, const ChatsListScreen());
    expect(find.text('Tejb'), findsOneWidget);
    expect(find.text('Alex Rivera'), findsNothing);
    await tester.enterText(find.byType(TextField), 'ragh');
    await tester.tap(find.text('Like'));
    await tester.pumpAndSettle();
    expect(api.liked, 'ragh');
    expect(
      find.text('Like sent. Chat opens when they like you back.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'Sending saves message and polling retrieves another user reply',
    (tester) async {
      final api = FakeChatApi();
      await show(tester, api, const ChatDetailScreen(chatId: 'conversation'));
      await tester.enterText(find.byType(TextField), 'Hello Tejb');
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect(api.saved.single['text'], 'Hello Tejb');
      expect(find.text('Hello Tejb'), findsOneWidget);
      api.saved.add({
        'id': '2',
        'text': 'Hello Ragh',
        'isMe': false,
        'createdAt': '2026-10-19T10:01:00Z',
      });
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Hello Ragh'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('Failed send retains draft and does not show a sent bubble', (
    tester,
  ) async {
    final api = FakeChatApi()..failSend = true;
    await show(tester, api, const ChatDetailScreen(chatId: 'conversation'));
    await tester.enterText(find.byType(TextField), 'Keep this draft');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(api.saved, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Keep this draft',
    );
    expect(
      find.text('Could not connect. Check your connection and try again.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
