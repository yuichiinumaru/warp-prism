/// Widget tests for the Workspace Snapshot page (Task 0019 + Task 0020).
///
/// Verifies that the page renders scan status, metric tiles, lane summary,
/// and asset lists using Prism primitives from the loaded snapshot. Also
/// covers loading, error, and empty states by overriding the provider.
///
/// Task 0020 path-to-100 additions: card select opens inspector, clear closes
/// and stays closed under deep-link, graph mode/node selection path.
///
/// Task 1407 classification: **KEEP + fix** (F-1407-03 resolved).
/// Production `lib/features/workspace_snapshot/**` now uses public Prism*
/// APIs via `package:warp_prism_ui/warp_prism_ui.dart`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/workspace_snapshot.dart';
import 'package:warp_prism_observatory/features/workspace_snapshot/workspace_snapshot_page.dart';
import 'package:warp_prism_observatory/features/workspace_snapshot/workspace_snapshot_provider.dart';
import 'package:warp_prism_observatory/features/workspace_snapshot/widgets/workspace_graph_panel.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// A notifier that returns a fixed test snapshot.
class _FixedSnapshotNotifier extends WorkspaceSnapshotNotifier {
  @override
  Future<WorkspaceSnapshot> build() async => _testSnapshot();
}

/// A notifier that always errors.
class _ErrorSnapshotNotifier extends WorkspaceSnapshotNotifier {
  @override
  Future<WorkspaceSnapshot> build() async =>
      throw StateError('scan failed in test');
}

WorkspaceSnapshot _testSnapshot() {
  return WorkspaceSnapshot(
    agents: [
      const WorkspaceAsset(
        id: 'agent:test',
        kind: AssetKind.agent,
        name: 'Test Agent',
        path: '/ws/.agents/agents/test.md',
        description: 'A test agent',
      ),
    ],
    skills: [
      const WorkspaceAsset(
        id: 'skill:test',
        kind: AssetKind.skill,
        name: 'Test Skill',
        path: '/ws/.agents/skills/test/SKILL.md',
        description: 'A test skill',
      ),
    ],
    workflows: const [],
    tasks: const [],
    changelogEntries: const [],
    metadata: WorkspaceScanMetadata(
      rootPath: '/test-ws',
      scannedAt: DateTime(2026, 6, 7, 12, 0, 0),
      filesScanned: 2,
      parseErrors: 0,
    ),
  );
}

Widget _wrapInApp(List<Override> overrides, {String? assetId}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: WorkspaceSnapshotPage(assetId: assetId)),
  );
}

void main() {
  group('WorkspaceSnapshotPage widget', () {
    testWidgets('renders loading state while scanning', (tester) async {
      await tester.pumpWidget(
        _wrapInApp([
          workspaceSnapshotProvider.overrideWith(
            () => _FixedSnapshotNotifier(),
          ),
        ]),
      );
      // First frame: loading.
      expect(find.text('Scanning workspace...'), findsOneWidget);
      // Allow the async notifier to complete.
      await tester.pumpAndSettle();
    });

    testWidgets('renders metric tiles and asset lists after load', (
      tester,
    ) async {
      // Give the page enough vertical room so the topbar is laid out.
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapInApp([
          workspaceSnapshotProvider.overrideWith(
            () => _FixedSnapshotNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Metric tile labels (rendered in the body, off the topbar path).
      expect(find.text('Agents'), findsWidgets);
      expect(find.text('Skills'), findsWidgets);
      expect(find.text('Total'), findsOneWidget);
      // Scan metadata footer mentions the root path.
      expect(find.textContaining('/test-ws'), findsWidgets);
      // The derived agent and skill cards carry the asset name.
      expect(find.text('Test Agent'), findsOneWidget);
      expect(find.text('Test Skill'), findsOneWidget);
    });

    testWidgets('renders error state on scan failure', (tester) async {
      await tester.pumpWidget(
        _wrapInApp([
          workspaceSnapshotProvider.overrideWith(
            () => _ErrorSnapshotNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to scan workspace'), findsOneWidget);
    });

    testWidgets('renders empty state when no assets found', (tester) async {
      await tester.pumpWidget(
        _wrapInApp([
          workspaceSnapshotProvider.overrideWith(
            () => _EmptySnapshotNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Empty workspace'), findsOneWidget);
    });

    testWidgets('card tap opens detail inspector', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapInApp([
          workspaceSnapshotProvider.overrideWith(
            () => _FixedSnapshotNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrismDetailInspector), findsNothing);

      // Cards sit below metric tiles in a scroll view — ensure visible first.
      final card = find.bySemanticsLabel('agent asset: Test Agent');
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.byType(PrismDetailInspector), findsOneWidget);
      expect(find.text('agent:test'), findsOneWidget);
      expect(find.byTooltip('Close'), findsOneWidget);
    });

    testWidgets('clear closes inspector and deep-link does not re-open', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapInApp([
          workspaceSnapshotProvider.overrideWith(
            () => _FixedSnapshotNotifier(),
          ),
        ], assetId: 'agent:test'),
      );
      // Allow async load + post-frame deep-link one-shot.
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WorkspaceSnapshotPage)),
      );

      expect(container.read(selectedAssetIdProvider), equals('agent:test'));
      expect(find.byType(PrismDetailInspector), findsOneWidget);
      expect(find.text('agent:test'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(container.read(selectedAssetIdProvider), isNull);
      expect(find.byType(PrismDetailInspector), findsNothing);

      // Force additional frames/rebuilds — one-shot must not re-select.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(container.read(selectedAssetIdProvider), isNull);
      expect(find.byType(PrismDetailInspector), findsNothing);
    });

    testWidgets('graph node select path opens selection via panel onNodeTap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          workspaceSnapshotProvider.overrideWith(
            () => _FixedSnapshotNotifier(),
          ),
          // Force a known projection with a selectable agent node.
          graphProjectionProvider.overrideWithValue(
            const GraphProjection(
              nodes: [
                GraphNode(id: 'agent:test', label: 'AgentX', type: 'agent'),
              ],
              edges: [],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                // Freeze layout for a stable canvas under test.
                child: WorkspaceGraphPanel(enablePhysics: false),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(container.read(selectedAssetIdProvider), isNull);
      expect(find.byType(PrismGraphCanvas), findsOneWidget);
      expect(find.text('AgentX'), findsOneWidget);

      // Invoke the panel-wired canvas callback directly. Canvas force layout +
      // parent scale gestures make hit-testing flaky; the contract under test
      // is that WorkspaceGraphPanel routes onNodeTap → selectAsset.
      final canvas = tester.widget<PrismGraphCanvas>(
        find.byType(PrismGraphCanvas),
      );
      expect(canvas.onNodeTap, isNotNull);
      expect(canvas.nodes, isNotEmpty);
      canvas.onNodeTap!(canvas.nodes.first);
      await tester.pump();

      expect(container.read(selectedAssetIdProvider), equals('agent:test'));
    });

    testWidgets('graph mode toggle switches containment/operational', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          workspaceSnapshotProvider.overrideWith(
            () => _FixedSnapshotNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: WorkspaceGraphPanel(enablePhysics: false),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(container.read(graphModeProvider), GraphMode.containment);

      await tester.tap(find.text('Operational'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(container.read(graphModeProvider), GraphMode.operational);
      expect(find.byType(PrismGraphCanvas), findsOneWidget);
    });
  });
}

/// A notifier that returns an empty snapshot.
class _EmptySnapshotNotifier extends WorkspaceSnapshotNotifier {
  @override
  Future<WorkspaceSnapshot> build() async =>
      WorkspaceSnapshot.empty('/empty-ws');
}
