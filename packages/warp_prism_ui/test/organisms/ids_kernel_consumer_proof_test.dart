import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Integration proof test for Task 1817.
///
/// Proves that the Interaction Design System (IDS) candidate kernel in
/// `warp_prism_interaction` drives the actual, real organisms in
/// `warp_prism_ui` without any production dependency leakage.
///
/// Tested Named Consumers:
/// 1. [PrismWorkflowCanvasStage] (Selection Integration)
/// 2. [PrismFilterWorkbench] (Inspection & Query Integration)
///
/// Seam architecture:
/// - `warp_prism_ui/lib/` remains 100% pure presentation.
/// - `warp_prism_ui/test/` imports `warp_prism_interaction` via dev_dependency
///   to test-drive the real widgets with kernel state (the Task 1820 binding
///   layer in miniature).
void main() {
  Widget harness({
    required Widget child,
    double width = 800,
    double height = 600,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  group(
    'Consumer 1 Proof: Real PrismWorkflowCanvasStage driven by IDS Selection Kernel',
    () {
      testWidgets(
        'SelectionNotifier drives single node selection workflow on real widget',
        (tester) async {
          final notifier = SelectionNotifier<String>(
            mode: SelectionMode.single,
          );
          final changeEvents = <SelectionChangeEvent<String>>[];
          notifier.addListener(changeEvents.add);

          final nodes = prismWorkflowCanvasStageFixtureNodes();
          final edges = prismWorkflowCanvasStageFixtureEdges();

          PrismWorkflowNode? lastSelectedNode;
          PrismWorkflowSelection? lastWorkflowSelection;
          bool clearedCalled = false;

          // Miniature test binding adapter (prototyping Task 1820 bindings)
          Widget buildStage() {
            final currentSelection = notifier.value;
            final selectedId = currentSelection.primarySelection;
            final isNode = nodes.any((n) => n.id == selectedId);
            final isEdge = edges.any((e) => e.id == selectedId);

            return PrismWorkflowCanvasStage(
              nodes: nodes,
              edges: edges,
              selectedNodeId: isNode ? selectedId : null,
              selectedEdgeId: isEdge ? selectedId : null,
              onNodeSelected: (node) {
                lastSelectedNode = node;
              },
              onSelectionChanged: (selection) {
                lastWorkflowSelection = selection;
                if (selection.hasNode) {
                  notifier.select(
                    selection.nodeId!,
                    source: SelectionSource.user,
                  );
                } else if (selection.hasEdge) {
                  notifier.select(
                    selection.edgeId!,
                    source: SelectionSource.user,
                  );
                } else {
                  notifier.clear(source: SelectionSource.user);
                }
              },
              onSelectionCleared: () {
                clearedCalled = true;
                notifier.clear(source: SelectionSource.user);
              },
            );
          }

          await tester.pumpWidget(
            harness(
              child: StatefulBuilder(
                builder: (context, setState) {
                  notifier.addListener((_) => setState(() {}));
                  return buildStage();
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Initial state: empty selection
          expect(notifier.value.isEmpty, isTrue);
          expect(find.byType(PrismWorkflowCanvasStage), findsOneWidget);

          // 1. Tap 'n-ingest' node chip
          final ingestFinder = find.byKey(
            PrismWorkflowCanvasStage.nodeKey('n-ingest'),
          );
          expect(ingestFinder, findsOneWidget);
          await tester.tap(ingestFinder);
          await tester.pumpAndSettle();

          // Verify real widget callback fired with real PrismWorkflowNode type
          expect(lastSelectedNode, isNotNull);
          expect(lastSelectedNode!.id, equals('n-ingest'));
          expect(lastSelectedNode!.kind, equals(PrismWorkflowNodeKind.ingest));

          // Verify real selection payload
          expect(lastWorkflowSelection, isNotNull);
          expect(lastWorkflowSelection!.hasNode, isTrue);
          expect(lastWorkflowSelection!.nodeId, equals('n-ingest'));

          // Verify kernel SelectionNotifier state updated losslessly
          expect(notifier.value.primarySelection, equals('n-ingest'));
          expect(notifier.value.selectedItems, equals({'n-ingest'}));
          expect(changeEvents.length, equals(1));
          expect(changeEvents.last.added, equals({'n-ingest'}));
          expect(changeEvents.last.removed, isEmpty);

          // 2. Tap 'n-route' node chip -> selection replaces in single mode
          final routeFinder = find.byKey(
            PrismWorkflowCanvasStage.nodeKey('n-route'),
          );
          expect(routeFinder, findsOneWidget);
          await tester.tap(routeFinder);
          await tester.pumpAndSettle();

          expect(lastSelectedNode!.id, equals('n-route'));
          expect(lastWorkflowSelection!.nodeId, equals('n-route'));
          expect(notifier.value.primarySelection, equals('n-route'));
          expect(notifier.value.selectedItems, equals({'n-route'}));
          expect(changeEvents.length, equals(2));
          expect(changeEvents.last.added, equals({'n-route'}));
          expect(changeEvents.last.removed, equals({'n-ingest'}));

          // 3. Tap edge in edge strip -> drives edge selection through kernel
          final edgeFinder = find.byKey(
            PrismWorkflowCanvasStage.edgeKey('e-ingest-route'),
          );
          expect(edgeFinder, findsOneWidget);
          await tester.tap(edgeFinder);
          await tester.pumpAndSettle();

          expect(lastWorkflowSelection!.hasEdge, isTrue);
          expect(lastWorkflowSelection!.edgeId, equals('e-ingest-route'));
          expect(notifier.value.primarySelection, equals('e-ingest-route'));
          expect(notifier.value.selectedItems, equals({'e-ingest-route'}));

          // 4. Tap canvas background to clear selection (canvasKey holds the background gesture recognizer)
          final canvasFinder = find.byKey(PrismWorkflowCanvasStage.canvasKey);
          await tester.tap(canvasFinder);
          await tester.pumpAndSettle();

          expect(clearedCalled, isTrue);
          expect(notifier.value.isEmpty, isTrue);
          expect(lastWorkflowSelection!.isEmpty, isTrue);
        },
      );

      testWidgets(
        'Kernel SelectionState programmatically drives PrismWorkflowCanvasStage render',
        (tester) async {
          final notifier = SelectionNotifier<String>(
            mode: SelectionMode.single,
          );
          final nodes = prismWorkflowCanvasStageFixtureNodes();
          final edges = prismWorkflowCanvasStageFixtureEdges();

          Widget buildStage() {
            final currentSelection = notifier.value;
            final selectedId = currentSelection.primarySelection;
            final isNode = nodes.any((n) => n.id == selectedId);
            final isEdge = edges.any((e) => e.id == selectedId);

            return PrismWorkflowCanvasStage(
              nodes: nodes,
              edges: edges,
              selectedNodeId: isNode ? selectedId : null,
              selectedEdgeId: isEdge ? selectedId : null,
            );
          }

          await tester.pumpWidget(
            harness(
              child: StatefulBuilder(
                builder: (context, setState) {
                  notifier.addListener((_) => setState(() {}));
                  return buildStage();
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Programmatically update kernel state
          notifier.select('n-tool', source: SelectionSource.programmatic);
          await tester.pumpAndSettle();

          // Widget reflects kernel selection
          final stage = tester.widget<PrismWorkflowCanvasStage>(
            find.byType(PrismWorkflowCanvasStage),
          );
          expect(stage.selectedNodeId, equals('n-tool'));
          expect(stage.selectedEdgeId, isNull);

          // Programmatically update kernel to edge
          notifier.select('e-route-tool', source: SelectionSource.programmatic);
          await tester.pumpAndSettle();

          final stageWithEdge = tester.widget<PrismWorkflowCanvasStage>(
            find.byType(PrismWorkflowCanvasStage),
          );
          expect(stageWithEdge.selectedNodeId, isNull);
          expect(stageWithEdge.selectedEdgeId, equals('e-route-tool'));

          // Programmatically clear kernel
          notifier.clear(source: SelectionSource.programmatic);
          await tester.pumpAndSettle();

          final stageCleared = tester.widget<PrismWorkflowCanvasStage>(
            find.byType(PrismWorkflowCanvasStage),
          );
          expect(stageCleared.selectedNodeId, isNull);
          expect(stageCleared.selectedEdgeId, isNull);
        },
      );

      test(
        'Lossless 1:1 mapping between PrismWorkflowSelection and SelectionState',
        () {
          // Empty selection mapping
          const emptyKernel = SelectionState<String>.empty();
          const emptyWorkflow = PrismWorkflowSelection.cleared();
          expect(emptyWorkflow.isEmpty, isTrue);
          expect(emptyKernel.isEmpty, isTrue);

          // Node selection mapping
          final nodeKernel = SelectionState<String>.single('n-ingest');
          const nodeWorkflow = PrismWorkflowSelection.node('n-ingest');
          expect(nodeKernel.primarySelection, equals(nodeWorkflow.nodeId));
          expect(nodeKernel.contains('n-ingest'), isTrue);

          // Edge selection mapping
          final edgeKernel = SelectionState<String>.single('e-1');
          const edgeWorkflow = PrismWorkflowSelection.edge('e-1');
          expect(edgeKernel.primarySelection, equals(edgeWorkflow.edgeId));
          expect(edgeKernel.contains('e-1'), isTrue);
        },
      );
    },
  );

  group(
    'Consumer 2 Proof: Real PrismFilterWorkbench driven by IDS Inspection & Query Kernel',
    () {
      List<PrismFilterSection> fixtureSections() => [
        const PrismFilterSection(
          id: 'assets',
          title: 'Asset type',
          criteria: [
            PrismFilterCriterion(
              id: 'asset_type',
              label: 'Types',
              kind: PrismFilterCriterionKind.multiSelect,
              options: [
                PrismFilterOption(value: 'agent', label: 'Agent', count: 5),
                PrismFilterOption(value: 'skill', label: 'Skill', count: 12),
              ],
            ),
            PrismFilterCriterion(
              id: 'lifecycle',
              label: 'Lifecycle',
              kind: PrismFilterCriterionKind.singleSelect,
              options: [
                PrismFilterOption(value: 'active', label: 'Active'),
                PrismFilterOption(value: 'stale', label: 'Stale'),
              ],
            ),
            PrismFilterCriterion(
              id: 'pinned',
              label: 'Pinned only',
              kind: PrismFilterCriterionKind.boolean,
            ),
          ],
        ),
      ];

      test(
        'InspectionNotifier manages active filter criteria inspection lifecycle',
        () {
          final notifier = InspectionNotifier<String>();
          final sessions = <InspectionPayload<String>?>[];
          notifier.addListener(sessions.add);

          // 1. Propose criterion inspection (e.g. hover or focus on asset_type criterion)
          notifier.propose(
            InspectionIntent<String>(
              target: 'asset_type',
              targetType: 'filter_criterion',
            ),
          );
          expect(notifier.session, isNotNull);
          expect(notifier.session!.target, equals('asset_type'));
          expect(
            notifier.session!.intent.targetType,
            equals('filter_criterion'),
          );
          expect(
            notifier.session!.status,
            equals(InspectionLifecycle.proposed),
          );
          expect(notifier.session!.isProposed, isTrue);

          // 2. Activate inspector (e.g. open criterion detail drawer / modal)
          notifier.activate();
          expect(notifier.session!.status, equals(InspectionLifecycle.active));
          expect(notifier.session!.isActive, isTrue);

          // 3. Dismiss inspector (e.g. close drawer)
          notifier.dismiss();
          expect(
            notifier.session!.status,
            equals(InspectionLifecycle.dismissed),
          );
          expect(notifier.session!.isDismissed, isTrue);

          // 4. Reset inspector session
          notifier.reset();
          expect(notifier.session, isNull);
        },
      );

      testWidgets(
        'QueryController drives structured filter draft execution, apply, and reset on real widget',
        (tester) async {
          final queryController = QueryController<Map<String, Object?>>();
          final queryStates = <QueryState<Map<String, Object?>>>[];
          queryController.addListener(queryStates.add);

          Map<String, Object?>? lastChangedMap;
          Map<String, Object?>? lastAppliedMap;
          bool resetFired = false;
          int queryCounter = 0;

          await tester.pumpWidget(
            harness(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return PrismFilterWorkbench(
                    sections: fixtureSections(),
                    onChanged: (draft) {
                      lastChangedMap = draft;
                      final token = 'query-draft-${++queryCounter}';
                      queryController.submit(
                        QueryIntent(
                          rawQuery: 'filter_draft_change',
                          filters: draft,
                          queryToken: token,
                        ),
                      );
                    },
                    onApply: (applied) {
                      lastAppliedMap = applied;
                      final token = 'query-apply-${++queryCounter}';
                      queryController.submit(
                        QueryIntent(
                          rawQuery: 'filter_applied',
                          filters: applied,
                          queryToken: token,
                        ),
                      );
                    },
                    onReset: () {
                      resetFired = true;
                      if (queryController.state.isRunning) {
                        queryController.cancel();
                      }
                      queryController.reset();
                    },
                  );
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(queryController.state.isIdle, isTrue);
          expect(find.byType(PrismFilterWorkbench), findsOneWidget);

          // 1. Toggle 'Agent' chip in quick chips bar
          final agentChip = find.text('Agent');
          expect(agentChip, findsOneWidget);
          await tester.tap(agentChip);
          await tester.pumpAndSettle();

          // Verify real onChanged payload contains typed Set<String>
          expect(lastChangedMap, isNotNull);
          expect(lastChangedMap!['asset_type'], equals({'agent'}));

          // Verify QueryController is running with the exact filter payload
          expect(queryController.state.isRunning, isTrue);
          expect(
            queryController.state.intent!.filters['asset_type'],
            equals({'agent'}),
          );

          // Complete the draft query asynchronously
          final draftToken = queryController.state.intent!.queryToken;
          queryController.complete(
            QueryResultReference(token: 'res-draft-1', totalCount: 5),
            queryToken: draftToken,
          );
          expect(queryController.state.isComplete, isTrue);
          expect(queryController.state.result!.totalCount, equals(5));

          // 2. Tap Apply button
          final applyButton = find.byKey(PrismFilterWorkbench.applyButtonKey);
          expect(applyButton, findsOneWidget);
          await tester.tap(applyButton);
          await tester.pumpAndSettle();

          // Verify onApply fired with exact applied map
          expect(lastAppliedMap, isNotNull);
          expect(lastAppliedMap!['asset_type'], equals({'agent'}));

          // Verify QueryController handles apply query submission & completion
          expect(queryController.state.isRunning, isTrue);
          final applyToken = queryController.state.intent!.queryToken;
          queryController.complete(
            QueryResultReference(token: 'res-apply-final', totalCount: 5),
            queryToken: applyToken,
          );
          expect(queryController.state.isComplete, isTrue);
          expect(
            queryController.state.result!.token,
            equals('res-apply-final'),
          );

          // 3. Tap Clear button
          final clearButton = find.byKey(PrismFilterWorkbench.clearButtonKey);
          expect(clearButton, findsOneWidget);
          await tester.tap(clearButton);
          await tester.pumpAndSettle();

          expect(resetFired, isTrue);
          expect(queryController.state.isIdle, isTrue);
          expect(queryController.state.intent, isNull);
        },
      );

      testWidgets(
        'QueryController ignores stale completions from rapid widget interactions',
        (tester) async {
          final queryController = QueryController<Map<String, Object?>>();
          var correlationCounter = 0;

          await tester.pumpWidget(
            harness(
              child: PrismFilterWorkbench(
                sections: fixtureSections(),
                onChanged: (draft) {
                  queryController.submit(
                    QueryIntent(
                      rawQuery: 'search',
                      filters: draft,
                      queryToken: 'token-${++correlationCounter}',
                    ),
                  );
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          // User selects 'Agent' -> submits token-1
          await tester.tap(find.text('Agent'));
          await tester.pumpAndSettle();
          expect(queryController.state.intent!.queryToken, equals('token-1'));

          // User quickly selects 'Skill' -> submits token-2
          await tester.tap(find.text('Skill'));
          await tester.pumpAndSettle();
          expect(queryController.state.intent!.queryToken, equals('token-2'));

          // Stale response for token-1 arrives
          queryController.complete(
            QueryResultReference(token: 'stale-res', totalCount: 5),
            queryToken: 'token-1',
          );

          // QueryController remains running for token-2, stale token-1 did not overwrite state
          expect(queryController.state.isRunning, isTrue);
          expect(queryController.state.intent!.queryToken, equals('token-2'));

          // Fresh response for token-2 arrives
          queryController.complete(
            QueryResultReference(token: 'fresh-res', totalCount: 17),
            queryToken: 'token-2',
          );
          expect(queryController.state.isComplete, isTrue);
          expect(queryController.state.result!.token, equals('fresh-res'));
          expect(queryController.state.result!.totalCount, equals(17));
        },
      );

      testWidgets(
        'QueryController captures error state during filter execution',
        (tester) async {
          final queryController = QueryController<Map<String, Object?>>();
          final exception = TimeoutException('Backend query timeout');
          final stack = StackTrace.current;

          await tester.pumpWidget(
            harness(
              child: PrismFilterWorkbench(
                sections: fixtureSections(),
                onApply: (draft) {
                  queryController.submit(
                    QueryIntent(
                      rawQuery: 'apply',
                      filters: draft,
                      queryToken: 'apply-tok',
                    ),
                  );
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(PrismFilterWorkbench.applyButtonKey));
          await tester.pumpAndSettle();

          expect(queryController.state.isRunning, isTrue);

          queryController.fail(exception, stack, 'apply-tok');
          expect(queryController.state.isError, isTrue);
          expect(queryController.state.error, equals(exception));
          expect(queryController.state.stackTrace, equals(stack));
        },
      );
    },
  );
}
