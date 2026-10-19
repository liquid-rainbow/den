import 'package:den/src/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App renders initial phone entry route screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DenApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login or sign up'), findsOneWidget);
    expect(find.text('Den'), findsOneWidget);
  });
}
