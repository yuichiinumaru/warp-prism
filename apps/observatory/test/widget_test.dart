import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/app/app.dart';

void main() {
  testWidgets('Observatory app bootstrap smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WarpPrismApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(WarpPrismApp), findsOneWidget);
  });
}
