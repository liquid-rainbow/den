import 'package:den/src/app.dart';
import 'package:den/src/features/auth/presentation/screens/phone_entry_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders initial phone entry route screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DenApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(PhoneEntryScreen), findsOneWidget);
  });
}
