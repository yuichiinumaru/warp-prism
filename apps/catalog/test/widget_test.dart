import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_catalog/main.dart';

void main() {
  testWidgets('Catalog app renders gallery page', (tester) async {
    await tester.pumpWidget(const WarpPrismCatalogApp());
    // The gallery page should render without crashing.
    expect(find.byType(WarpPrismCatalogApp), findsOneWidget);
  });
}
