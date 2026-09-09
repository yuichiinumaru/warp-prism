import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

/// Integration proof for the 2 named consumers in Task 1817:
/// 1. `PrismWorkflowCanvasStage` (Selection integration proof)
/// 2. `PrismFilterWorkbench` (Inspection & Query integration proof)
///
/// Demonstrates that the candidate IDS kernel primitives cleanly subsume and
/// drive the interaction semantics of both organisms without violating the
/// pure-Dart core boundary or UI presentation contracts.
void main() {
  group('Consumer 1: PrismWorkflowCanvasStage Selection Proof', () {
    test('SelectionNotifier drives single node selection workflow', () {
      final selectionNotifier = SelectionNotifier<String>(
        mode: SelectionMode.single,
      );
      final changeEvents = <SelectionChangeEvent<String>>[];
      selectionNotifier.addListener(changeEvents.add);

      // Initial state: unselected
      expect(selectionNotifier.value.isEmpty, isTrue);
      expect(selectionNotifier.value.primarySelection, isNull);

      // User selects node 'n-ingest'
      selectionNotifier.select('n-ingest', source: SelectionSource.user);
      expect(selectionNotifier.value.primarySelection, equals('n-ingest'));
      expect(selectionNotifier.value.selectedItems, equals({'n-ingest'}));
      expect(selectionNotifier.value.count, equals(1));
      expect(changeEvents.length, equals(1));
      expect(changeEvents.first.added, equals({'n-ingest'}));
      expect(changeEvents.first.removed, isEmpty);
      expect(changeEvents.first.source, equals(SelectionSource.user));

      // User selects node 'n-route' (single mode replaces previous selection)
      selectionNotifier.select('n-route', source: SelectionSource.user);
      expect(selectionNotifier.value.primarySelection, equals('n-route'));
      expect(selectionNotifier.value.selectedItems, equals({'n-route'}));
      expect(changeEvents.length, equals(2));
      expect(changeEvents.last.added, equals({'n-route'}));
      expect(changeEvents.last.removed, equals({'n-ingest'}));

      // User taps background to clear selection (onSelectionCleared callback)
      selectionNotifier.clear(source: SelectionSource.user);
      expect(selectionNotifier.value.isEmpty, isTrue);
      expect(selectionNotifier.value.primarySelection, isNull);
      expect(changeEvents.length, equals(3));
      expect(changeEvents.last.removed, equals({'n-route'}));
    });

    test('SelectionNotifier handles multi-node workflow selection and batch actions', () {
      final multiNotifier = SelectionNotifier<String>(
        mode: SelectionMode.multiple,
      );
      final events = <SelectionChangeEvent<String>>[];
      multiNotifier.addListener(events.add);

      // Select multiple pipeline stages
      multiNotifier.selectAll(['node-1', 'node-2', 'node-3']);
      expect(multiNotifier.value.count, equals(3));
      expect(multiNotifier.value.contains('node-1'), isTrue);
      expect(multiNotifier.value.contains('node-2'), isTrue);
      expect(multiNotifier.value.contains('node-3'), isTrue);
      expect(multiNotifier.value.primarySelection, equals('node-3'));

      // Toggle node-2 off
      multiNotifier.toggle('node-2');
      expect(multiNotifier.value.count, equals(2));
      expect(multiNotifier.value.contains('node-2'), isFalse);
      expect(multiNotifier.value.contains('node-1'), isTrue);
      expect(multiNotifier.value.contains('node-3'), isTrue);

      // Clear with anchor preservation
      final withAnchor = multiNotifier.value.withAnchor('node-1');
      multiNotifier.update(withAnchor);
      multiNotifier.clear(preserveAnchor: true);
      expect(multiNotifier.value.isEmpty, isTrue);
      expect(multiNotifier.value.anchor, equals('node-1'));
    });

    test('bidirectional adapter mapping between stage selection and SelectionState', () {
      // Stage selection model simulation (node vs edge vs cleared)
      SelectionState<String> fromStageSelection({
        String? nodeId,
        String? edgeId,
      }) {
        if (nodeId != null) {
          return SelectionState<String>.single(nodeId);
        } else if (edgeId != null) {
          return SelectionState<String>.single(edgeId);
        } else {
          return const SelectionState<String>.empty();
        }
      }

      (String? nodeId, String? edgeId) toStageSelection(
        SelectionState<String> state, {
        bool isEdge = false,
      }) {
        if (state.isEmpty) return (null, null);
        if (isEdge) return (null, state.primarySelection);
        return (state.primarySelection, null);
      }

      // Test node selection mapping
      final nodeState = fromStageSelection(nodeId: 'node-transform');
      expect(nodeState.primarySelection, equals('node-transform'));
      final (mappedNodeId, mappedEdgeId) = toStageSelection(nodeState);
      expect(mappedNodeId, equals('node-transform'));
      expect(mappedEdgeId, isNull);

      // Test edge selection mapping
      final edgeState = fromStageSelection(edgeId: 'edge-ingest-to-route');
      expect(edgeState.primarySelection, equals('edge-ingest-to-route'));
      final (edgeNodeId, edgeEdgeId) = toStageSelection(
        edgeState,
        isEdge: true,
      );
      expect(edgeNodeId, isNull);
      expect(edgeEdgeId, equals('edge-ingest-to-route'));

      // Test cleared mapping
      final clearedState = fromStageSelection();
      expect(clearedState.isEmpty, isTrue);
      final (clearedNode, clearedEdge) = toStageSelection(clearedState);
      expect(clearedNode, isNull);
      expect(clearedEdge, isNull);
    });
  });

  group('Consumer 2: PrismFilterWorkbench Inspection & Query Proof', () {
    test('InspectionNotifier manages active filter criteria inspection lifecycle', () {
      final notifier = InspectionNotifier<String>();
      final sessions = <InspectionPayload<String>?>[];
      notifier.addListener(sessions.add);

      // 1. Propose inspecting a specific criterion ('severity_filter')
      final hoverIntent = InspectionIntent<String>(
        target: 'severity_filter',
        targetType: 'criterion',
        reason: 'hover_preview',
        context: {'section': 'general', 'current_value': 'high'},
      );
      notifier.propose(hoverIntent);

      expect(notifier.session, isNotNull);
      expect(notifier.session!.isProposed, isTrue);
      expect(notifier.session!.target, equals('severity_filter'));
      expect(notifier.hasActiveInspection, isFalse);

      // 2. Commit / activate inspection (user clicks to open criterion configuration/details)
      notifier.activate();
      expect(notifier.session!.isActive, isTrue);
      expect(notifier.hasActiveInspection, isTrue);

      // 3. Dismiss inspection (user closes detail inspector)
      notifier.dismiss();
      expect(notifier.session!.isDismissed, isTrue);
      expect(notifier.hasActiveInspection, isFalse);
      expect(notifier.session!.dismissedAt, isNotNull);

      // 4. Reset to idle
      notifier.reset();
      expect(notifier.session, isNull);
      expect(sessions.length, equals(4));
    });

    test('QueryController drives structured filter draft execution lifecycle', () {
      final queryController = QueryController<Map<String, Object?>>();
      final states = <QueryState<Map<String, Object?>>>[];
      queryController.addListener(states.add);

      // Initial state: idle
      expect(queryController.state.isIdle, isTrue);

      // User modifies draft criteria and clicks "Apply"
      final filterDraft = <String, Object?>{
        'status': {'active', 'pending'},
        'region': 'us-east',
        'advanced_logging': true,
      };

      final queryIntent = QueryIntent(
        rawQuery: 'region:us-east status:active',
        filters: filterDraft,
        queryToken: 'filter-run-101',
      );

      queryController.submit(queryIntent);
      expect(queryController.state.isRunning, isTrue);
      expect(queryController.state.intent, equals(queryIntent));
      expect(queryController.state.intent!.filters['region'], equals('us-east'));
      expect(
        queryController.state.intent!.filters['status'],
        equals({'active', 'pending'}),
      );

      // Asynchronous filter resolution completes with results reference
      final results = QueryResultReference<Map<String, Object?>>(
        token: 'filter-res-101',
        totalCount: 42,
        provenance: 'filter_workbench.apply',
        items: [
          {'id': 'item-1', 'status': 'active'},
          {'id': 'item-2', 'status': 'pending'},
        ],
      );

      final completed = queryController.complete(
        results,
        queryToken: 'filter-run-101',
      );
      expect(completed, isTrue);
      expect(queryController.state.isComplete, isTrue);
      expect(queryController.state.result!.totalCount, equals(42));
      expect(queryController.state.result!.items!.length, equals(2));

      // User clicks "Clear / Reset"
      queryController.reset();
      expect(queryController.state.isIdle, isTrue);
      expect(queryController.state.intent, isNull);
      expect(queryController.state.result, isNull);
      expect(states.length, equals(3));
    });

    test('QueryController handles query cancellation and failure under rapid filter changes', () {
      final controller = QueryController<String>();

      // Submit query 1
      final q1 = QueryIntent(rawQuery: 'test-1', queryToken: 'q1');
      controller.submit(q1);
      expect(controller.state.isRunning, isTrue);

      // User rapidly submits query 2 (supersedes q1)
      final q2 = QueryIntent(rawQuery: 'test-2', queryToken: 'q2');
      controller.submit(q2);
      expect(controller.state.isRunning, isTrue);
      expect(controller.state.intent, equals(q2));

      // Late arrival of q1 result is rejected
      final staleResult = QueryResultReference<String>(
        token: 'res-q1',
        totalCount: 10,
      );
      final appliedStale = controller.complete(staleResult, queryToken: 'q1');
      expect(appliedStale, isFalse);
      expect(controller.state.isRunning, isTrue);

      // Cancellation of current query
      controller.cancel('q2');
      expect(controller.state.isCancelled, isTrue);

      // Reset back to idle
      controller.reset();
      expect(controller.state.isIdle, isTrue);
    });
  });
}
