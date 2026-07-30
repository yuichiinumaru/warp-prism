/// Tests for router deep-link fallback behavior.
///
/// Covers:
/// - Asset detail page with empty asset ID renders fallback
/// - Asset detail page with "unknown" asset ID renders fallback
/// - Asset detail page with valid asset ID renders mapper-backed detail
/// - Explicit resolved:false keeps shell unresolved fallback
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/app/pages/asset_detail_page.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/agent_detail_view.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/asset_detail_view.dart';

const _agent = WorkspaceAsset(
  id: 'agent:architect-orchestrator',
  kind: AssetKind.agent,
  name: 'Architect Orchestrator',
  path: 'agents/architect-orchestrator.md',
  description: 'Coordinates architecture work.',
  frontmatter: {'model': 'gpt-4', 'status': 'active'},
);

const _graph = WorkspaceGraphResult(
  assetsById: {'agent:architect-orchestrator': _agent},
  edges: [],
  assetsByKind: {
    AssetKind.agent: [_agent],
  },
);

void main() {
  /// Avoid Material 3 InkSparkle (needs GPU shader stages unavailable
  /// in headless CI / some Linux test backends).
  Widget wrapInApp(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        home: child,
      ),
    );
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

    testWidgets('renders mapper-backed detail for known asset ID', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const AssetDetailPage(assetId: 'agent:architect-orchestrator'),
          overrides: [
            workspaceGraphAsyncProvider.overrideWith(
              () => _StaticGraphNotifier(_graph),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AssetDetailView), findsOneWidget);
      expect(find.byType(AgentDetailView), findsOneWidget);
      expect(find.text('Architect Orchestrator'), findsWidgets);
      expect(find.text('Asset not found'), findsNothing);
      expect(find.textContaining('coming soon'), findsNothing);
    });

    testWidgets('renders unresolved when graph lacks asset', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const AssetDetailPage(assetId: 'agent:missing'),
          overrides: [
            workspaceGraphAsyncProvider.overrideWith(
              () => _StaticGraphNotifier(_graph),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Asset not found'), findsOneWidget);
      expect(find.text('agent:missing'), findsOneWidget);
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

class _StaticGraphNotifier extends WorkspaceGraphAsyncNotifier {
  _StaticGraphNotifier(this._graph);

  final WorkspaceGraphResult _graph;

  @override
  Future<WorkspaceGraphResult> build() async => _graph;
}
