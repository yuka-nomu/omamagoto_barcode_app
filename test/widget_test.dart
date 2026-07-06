import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omamagoto_barcode_app/app.dart';

void main() {
  testWidgets('Home screen smoke test', (WidgetTester tester) async {
    // Wrap MyApp in ProviderScope to provide Riverpod state
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the AppBar title is displayed
    expect(find.text('おままごとレジ'), findsOneWidget);
    // Verify that the big Scan button is displayed
    expect(find.text('スキャン開始'), findsOneWidget);
  });
}
