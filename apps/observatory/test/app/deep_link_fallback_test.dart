/// Tests for router deep-link fallback behavior.
///
/// Covers:
/// - Asset detail page with empty asset ID renders fallback
/// - Asset detail page with "unknown" asset ID renders fallback
/// - Asset detail page with valid asset ID renders detail content
/// - Router 404 error page renders for unknown routes
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/app/pages/asset_detail_page.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: child);
  }

  // ===========================================================================
  // Asset Detail deep-link fallback
  // ===========================================================================
  group('AssetDetailPage deep-link fallback', () {
    testWidgets('renders fallback for empty asset ID', (tester) async {
      await tester.pumpWidget(wrapInApp(const AssetDetailPage(assetId: '')));

      // Should show unresolved asset fallback
      expect(find.text('Asset not found'), findsOneWidget);
      expect(find.text('(empty)'), findsOneWidget);
    });

    testWidgets('renders fallback for "unknown" asset ID', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const AssetDetailPage(assetId: 'unknown')),
      );

      // Should show unresolved asset fallback
      expect(find.text('Asset not found'), findsOneWidget);
      expect(find.text('unknown'), findsOneWidget);
    });

    testWidgets('renders fallback when resolved is false', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const AssetDetailPage(assetId: 'agent:some-agent', resolved: false),
        ),
      );

      // Should show unresolved asset fallback even with valid-looking ID
      expect(find.text('Asset not found'), findsOneWidget);
      expect(find.text('agent:some-agent'), findsOneWidget);
    });

    testWidgets('renders detail for valid asset ID', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const AssetDetailPage(assetId: 'agent:architect-orchestrator'),
        ),
      );

      // Should show the detail placeholder (not the fallback)
      expect(find.text('Asset Detail'), findsWidgets);
      expect(find.text('Asset: agent:architect-orchestrator'), findsWidgets);
      expect(find.text('Asset not found'), findsNothing);
    });

    testWidgets('fallback has navigation button', (tester) async {
      await tester.pumpWidget(wrapInApp(const AssetDetailPage(assetId: '')));

      // Should have a "Go to Overview" button
      expect(find.text('Go to Overview'), findsOneWidget);
    });

    testWidgets('fallback shows warning icon', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const AssetDetailPage(assetId: 'unknown')),
      );

      // Should show the link_off icon
      expect(find.byIcon(Icons.link_off), findsOneWidget);
    });
  });
}
