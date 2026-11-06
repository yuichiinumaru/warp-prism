import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _dummyBuilder(BuildContext context) => const SizedBox();

/// Ancestry classification per repaired Flutter harness host-composition workflow
/// (`.agents/skills/flutter/workflows/sk-flutter-host-composition.md` §1–§2).
enum AncestryClassification {
  /// Self-contained; renders under a contract-minimal wrapper
  /// (Directionality, MediaQuery, Localizations, Overlay without external Material/Scaffold).
  selfSufficient,

  /// Documented / enforced prerequisite; legitimately requires Material ancestor
  /// or specific host composition environment.
  declaredPrerequisite,

  /// Defect: fails contract-minimal mount without having a declared prerequisite.
  undocumentedPrerequisite,
}

/// Specification for one public widget under test.
class WidgetAncestrySpec {
  final String name;
  final Widget Function() builder;
  final AncestryClassification expectedClassification;
  final String? declaredPrerequisiteRationale;
  final Widget Function(Widget child)? prerequisiteWrapper;
  final void Function()? disposeHook;

  const WidgetAncestrySpec({
    required this.name,
    required this.builder,
    required this.expectedClassification,
    this.declaredPrerequisiteRationale,
    this.prerequisiteWrapper,
    this.disposeHook,
  });
}

/// Contract-minimal wrapper supplying Directionality, MediaQuery, Localizations,
/// and Overlay — but explicitly NO Material and NO Scaffold.
/// This represents a bare host route (such as bare MaterialApp home without Scaffold).
Widget _contractMinimalWrapper(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(1280, 800)),
      child: Localizations(
        locale: const Locale('en', 'US'),
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Overlay(
          initialEntries: [
            OverlayEntry(builder: (context) => SizedBox.expand(child: child)),
          ],
        ),
      ),
    ),
  );
}

/// Wrapper for widgets with declared Material requirement.
Widget _materialPrerequisiteWrapper(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(1280, 800)),
      child: Localizations(
        locale: const Locale('en', 'US'),
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => SizedBox.expand(
                child: Material(type: MaterialType.transparency, child: child),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Material Ancestry Meta-Test — Package-Wide Verification (Task 1835)', () {
    // =========================================================================
    // SECTION 1: Latent Organisms Fixed per 1831 Canon (Proven SELF_SUFFICIENT)
    // =========================================================================
    group('Latent Organisms Fixed per 1831 Canon (Proven SELF_SUFFICIENT)', () {
      testWidgets(
        'PrismFilterWorkbench mounts without Material/Scaffold ancestor',
        (tester) async {
          await tester.pumpWidget(
            _contractMinimalWrapper(
              PrismFilterWorkbench(sections: const [], onChanged: (_) {}),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(PrismFilterWorkbench), findsOneWidget);
        },
      );

      testWidgets(
        'PrismFilterWorkbench with text criterion mounts without Material/Scaffold ancestor',
        (tester) async {
          await tester.pumpWidget(
            _contractMinimalWrapper(
              PrismFilterWorkbench(
                sections: const [
                  PrismFilterSection(
                    id: 'text-sec',
                    title: 'Search Criteria',
                    criteria: [
                      PrismFilterCriterion(
                        id: 'query',
                        label: 'Query Filter',
                        kind: PrismFilterCriterionKind.text,
                        placeholder: 'Type query...',
                      ),
                    ],
                  ),
                ],
                initialValues: const {'query': 'initial query'},
                onChanged: (_) {},
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(PrismFilterWorkbench), findsOneWidget);
          expect(find.byType(TextField), findsOneWidget);
        },
      );

      testWidgets(
        'PrismAiAnalystPanel mounts without Material/Scaffold ancestor',
        (tester) async {
          final controller = PrismAiAnalystController();
          addTearDown(controller.dispose);

          await tester.pumpWidget(
            _contractMinimalWrapper(
              PrismAiAnalystPanel(controller: controller),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(PrismAiAnalystPanel), findsOneWidget);
          expect(find.byType(TextField), findsOneWidget);
        },
      );

      testWidgets(
        'PrismTerminalWorkspace mounts without Material/Scaffold ancestor',
        (tester) async {
          final controller = PrismTerminalWorkspaceController(
            panes: const [PrismTerminalPane(id: 'p1', title: 'Terminal 1')],
          );
          addTearDown(controller.dispose);

          await tester.pumpWidget(
            _contractMinimalWrapper(
              PrismTerminalWorkspace(controller: controller),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(PrismTerminalWorkspace), findsOneWidget);
          expect(find.byType(TextField), findsOneWidget);
        },
      );

      testWidgets(
        'PrismSearchBar (Task 1831 canon) mounts without Material/Scaffold ancestor',
        (tester) async {
          await tester.pumpWidget(
            _contractMinimalWrapper(
              const PrismSearchBar(placeholder: 'Search canon...'),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(PrismSearchBar), findsOneWidget);
          expect(find.byType(TextField), findsOneWidget);
        },
      );
    });

    // =========================================================================
    // SECTION 2: Public Widget Surface Enumeration & Classification
    // =========================================================================
    group('Public Widget Surface Meta-Classification', () {
      final specControllers = <ChangeNotifier>[];

      T trackController<T extends ChangeNotifier>(T controller) {
        specControllers.add(controller);
        return controller;
      }

      final allWidgetSpecs = <WidgetAncestrySpec>[
        // --- ATOMS ---
        WidgetAncestrySpec(
          name: 'PrismButton',
          builder: () => const PrismButton(label: 'Btn'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismCheckbox',
          builder: () => PrismCheckbox(value: true, onChanged: (_) {}),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismSwitch',
          builder: () => PrismSwitch(value: true, onChanged: (_) {}),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismToggle',
          builder: () => PrismToggle(value: true, onChanged: (_) {}),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismBadge',
          builder: () => const PrismBadge(label: 'Badge'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismChip',
          builder: () => const PrismChip(label: 'Chip'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismDivider',
          builder: () => const PrismDivider(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismGlowDivider',
          builder: () => const PrismGlowDivider(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismGlassPanel',
          builder: () =>
              const PrismGlassPanel(child: SizedBox(width: 50, height: 50)),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismGlassPanelSimple',
          builder: () => const PrismGlassPanelSimple(
            child: SizedBox(width: 50, height: 50),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismGlowBorder',
          builder: () =>
              const PrismGlowBorder(child: SizedBox(width: 50, height: 50)),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismIcon',
          builder: () => const PrismIcon(PrismIcons.search),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismSparkline',
          builder: () => const PrismSparkline(data: [1.0, 2.0, 3.0]),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismStatusDot',
          builder: () => const PrismStatusDot(color: Color(0xFF00FFCC)),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismText',
          builder: () => const PrismText('Sample Text'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTextField',
          builder: () => const PrismTextField(label: 'Text Field'),
          expectedClassification: AncestryClassification.declaredPrerequisite,
          declaredPrerequisiteRationale:
              'Requires Material ancestor for underlying Flutter TextField atom',
          prerequisiteWrapper: _materialPrerequisiteWrapper,
        ),

        // --- MOLECULES ---
        WidgetAncestrySpec(
          name: 'PrismMetricTile',
          builder: () => const PrismMetricTile(label: 'Metric', value: '100'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismMetricTileCompact',
          builder: () =>
              const PrismMetricTileCompact(label: 'Metric', value: '100'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismInteractiveSurface',
          builder: () => const PrismInteractiveSurface(
            semanticLabel: 'Surface',
            child: SizedBox(width: 50, height: 50),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismStateSurface',
          builder: () => const PrismStateSurface(
            stateType: PrismStateType.empty,
            title: 'Empty',
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTaskCard',
          builder: () =>
              const PrismTaskCard(id: 1, title: 'Task', lane: 'doing'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismAssetCard',
          builder: () => const PrismAssetCard(name: 'Asset', kind: 'agent'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismSearchBar',
          builder: () => const PrismSearchBar(placeholder: 'Search...'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismFilterChipGroup',
          builder: () => const PrismFilterChipGroup(
            options: [PrismFilterOption(value: '1', label: 'Opt')],
            selected: {'1'},
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismEvidenceRow',
          builder: () => const PrismEvidenceRow(
            label: 'Evidence',
            state: PrismEvidenceState.verified,
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismEvidenceIndicator',
          builder: () =>
              const PrismEvidenceIndicator(state: PrismEvidenceState.verified),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismProvenancePill',
          builder: () =>
              const PrismProvenancePill(canonicality: 'parentcanonical'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTimelineMarker',
          builder: () =>
              const PrismTimelineMarker(date: '2026-09-06', title: 'Marker'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismAccordion',
          builder: () => const PrismAccordion(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismDialog',
          builder: () =>
              const PrismDialog(title: 'Dialog', content: SizedBox()),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismColorField',
          builder: () => const PrismColorField(label: 'Color'),
          expectedClassification: AncestryClassification.declaredPrerequisite,
          declaredPrerequisiteRationale:
              'Composes PrismTextField, requires Material ancestor',
          prerequisiteWrapper: _materialPrerequisiteWrapper,
        ),
        WidgetAncestrySpec(
          name: 'PrismDraggableCard',
          builder: () => const PrismDraggableCard(
            card: PrismTaskCard(id: 1, title: 'T', lane: 'doing'),
            laneId: 'todo',
            index: 0,
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismDropTarget',
          builder: () => const PrismDropTarget(
            laneId: 'todo',
            taskCount: 0,
            child: SizedBox(width: 50, height: 50),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismScaleMeasureBar',
          builder: () => const PrismScaleMeasureBar(label: 'Scale'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismShimmer',
          builder: () => const PrismShimmer(height: 20),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismSkeletonCard',
          builder: () => const PrismSkeletonCard(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismSkeletonTableRows',
          builder: () => const PrismSkeletonTableRows(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismSkeletonTextLine',
          builder: () => const PrismSkeletonTextLine(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismToast',
          builder: () => PrismToast(
            entry: PrismToastEntry(
              id: '1',
              severity: PrismToastSeverity.info,
              title: 'Toast',
            ),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismToastManager',
          builder: () =>
              const PrismToastManager(child: SizedBox(width: 50, height: 50)),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismUptimeBar',
          builder: () => const PrismUptimeBar(uptimePercent: 99.9),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismHealthCard',
          builder: () => const PrismHealthCard(
            serviceName: 'svc',
            operationalState: PrismOperationalState.running,
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),

        // --- ORGANISMS ---
        WidgetAncestrySpec(
          name: 'PrismSelect',
          builder: () => PrismSelect<String>(
            options: const [PrismSelectItem(value: 'a', label: 'Option A')],
            onChanged: (_) {},
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismFilterWorkbench',
          builder: () =>
              PrismFilterWorkbench(sections: const [], onChanged: (_) {}),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismAiAnalystPanel',
          builder: () => PrismAiAnalystPanel(
            controller: trackController(PrismAiAnalystController()),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTerminalWorkspace',
          builder: () => PrismTerminalWorkspace(
            controller: trackController(
              PrismTerminalWorkspaceController(
                panes: const [PrismTerminalPane(id: '1', title: 'T1')],
              ),
            ),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismCommandPalette',
          builder: () => const PrismCommandPalette(commands: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismLaneBoard',
          builder: () => const PrismLaneBoard(
            lanes: [PrismLane(id: 'todo', label: 'To Do', tasks: [])],
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismPageShell',
          builder: () =>
              const PrismPageShell(title: 'Shell', child: SizedBox()),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismMapHudWorkspace',
          builder: () => const PrismMapHudWorkspace(stage: SizedBox()),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismToolStripSlideout',
          builder: () => const PrismToolStripSlideout(tools: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTree',
          builder: () => const PrismTree(nodes: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismAgentTranscript',
          builder: () => const PrismAgentTranscript(messages: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismToolCallCard',
          builder: () => const PrismToolCallCard(
            data: PrismToolCallData(id: '1', toolName: 'tool'),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismMessageStatusHistory',
          builder: () => const PrismMessageStatusHistory(steps: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismProviderHealthMatrix',
          builder: () => const PrismProviderHealthMatrix(providers: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismMcpCapabilityInspector',
          builder: () => const PrismMcpCapabilityInspector(
            capabilities: PrismMcpCapabilities(),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTimingWaterfall',
          builder: () => const PrismTimingWaterfall(spans: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTrafficInspector',
          builder: () => const PrismTrafficInspector(requests: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismWorkflowCanvasStage',
          builder: () => const PrismWorkflowCanvasStage(nodes: [], edges: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismViewPresets',
          builder: () => const PrismViewPresets(presets: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismWorkspaceShareCard',
          builder: () => const PrismWorkspaceShareCard(
            summary: PrismWorkspaceShareSummary(
              workspaceId: '1',
              workspaceName: 'W1',
              shareUrl: 'url',
            ),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismExecutionConsole',
          builder: () => const PrismExecutionConsole(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismLayerControlPanel',
          builder: () => const PrismLayerControlPanel(groups: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTimeMachineScrubber',
          builder: () => const PrismTimeMachineScrubber(buckets: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismEntityIntelPanel',
          builder: () => const PrismEntityIntelPanel(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismEntityLocateSearch',
          builder: () => const PrismEntityLocateSearch(corpora: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismArtifactWorkbench',
          builder: () => const PrismArtifactWorkbench(artifacts: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismStatusTicker',
          builder: () => const PrismStatusTicker(items: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismWatchlistDock',
          builder: () => const PrismWatchlistDock(items: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismCoordinateStatusBar',
          builder: () => const PrismCoordinateStatusBar(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismMapLegend',
          builder: () => const PrismMapLegend(categories: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismOsintWorkbench',
          builder: () =>
              PrismOsintWorkbench(tools: PrismOsintFixtures.minimalTools()),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismFloatingAnalyticsHud',
          builder: () => const PrismFloatingAnalyticsHud(sections: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismOpsControlCluster',
          builder: () => const PrismOpsControlCluster(launchers: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismConnectorPanel',
          builder: () =>
              const PrismConnectorPanel(title: 'Connectors', child: SizedBox()),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismMapCanvasStage',
          builder: () => const PrismMapCanvasStage(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismAgentShellPanel',
          builder: () => PrismAgentShellPanel(
            controller: trackController(PrismAgentShellPanelController()),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismDataTable',
          builder: () => const PrismDataTable(columns: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismStatusCell',
          builder: () =>
              const PrismStatusCell(state: PrismOperationalState.running),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismStatusGrid',
          builder: () => const PrismStatusGrid(items: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismErrorBoundary',
          builder: () => const PrismErrorBoundary(child: SizedBox()),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismFallbackView',
          builder: () => const PrismFallbackView(error: 'Error'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTimeline',
          builder: () => const PrismTimeline(entries: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTimelineGrouped',
          builder: () => const PrismTimelineGrouped(groups: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismShellResponsive',
          builder: () => const PrismShellResponsive(
            sidebar: SizedBox(),
            collapsedSidebar: SizedBox(),
            content: SizedBox(),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismShell',
          builder: () =>
              const PrismShell(sidebar: SizedBox(), content: SizedBox()),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismSidebar',
          builder: () => const PrismSidebar(items: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTopbar',
          builder: () => const PrismTopbar(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTopbarAction',
          builder: () => const PrismTopbarAction(icon: Icons.star),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismStoryPanel',
          builder: () => const PrismStoryPanel(title: 'Stories', insights: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismStoryCardQuick',
          builder: () => const PrismStoryCardQuick(title: 'Title', value: '10'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismVirtualList',
          builder: () => PrismVirtualList(
            itemCount: 1,
            itemBuilder: (_, __) => const SizedBox(),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismVirtualGrid',
          builder: () => PrismVirtualGrid(
            itemCount: 1,
            itemBuilder: (_, __) => const SizedBox(),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTabBar',
          builder: () => PrismTabBar(
            controller: trackController(
              PrismTabController(
                tabs: const [
                  PrismTab(id: '1', label: 'T1', content: _dummyBuilder),
                ],
              ),
            ),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTabView',
          builder: () => PrismTabView(
            controller: trackController(
              PrismTabController(
                tabs: const [
                  PrismTab(id: '1', label: 'T1', content: _dummyBuilder),
                ],
              ),
            ),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismSplitPane',
          builder: () =>
              const PrismSplitPane(leading: SizedBox(), trailing: SizedBox()),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismCodeBlock',
          builder: () => const PrismCodeBlock(source: 'code'),
          expectedClassification: AncestryClassification.declaredPrerequisite,
          declaredPrerequisiteRationale:
              'Header copy button uses InkWell, requires Material ancestor for ink splashes',
          prerequisiteWrapper: _materialPrerequisiteWrapper,
        ),
        WidgetAncestrySpec(
          name: 'PrismMarkdownRenderer',
          builder: () => const PrismMarkdownRenderer(data: '# Title'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismLogViewer',
          builder: () => const PrismLogViewer(entries: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismLogEntryWidget',
          builder: () => PrismLogEntryWidget(
            entry: PrismLogEntry(
              id: '1',
              timestamp: DateTime(2026),
              severity: PrismLogSeverity.info,
              source: 's',
              message: 'm',
            ),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismLogFilterBar',
          builder: () => const PrismLogFilterBar(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismDetailInspector',
          builder: () => const PrismDetailInspector(
            title: 'Detail',
            kind: 'asset',
            sections: [],
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismPropertyRow',
          builder: () => const PrismPropertyRow(label: 'Key', value: 'Val'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismLinkRow',
          builder: () => const PrismLinkRow(label: 'Link'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismGraphCanvas',
          builder: () => const PrismGraphCanvas(nodes: [], edges: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismEntityRelationCard',
          builder: () => const PrismEntityRelationCard(
            title: 'Entity',
            type: 'Node',
            nodes: [],
            edges: [],
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismKeyboardCheatsheet',
          builder: () => const PrismKeyboardCheatsheet(groups: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismMediaDetailOverlay',
          builder: () => const PrismMediaDetailOverlay(items: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismBreadcrumbs',
          builder: () => const PrismBreadcrumbs(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismBadgeCell',
          builder: () => const PrismBadgeCell(text: 'Badge'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismSecretCell',
          builder: () => const PrismSecretCell(maskedValue: '****'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTimestampCell',
          builder: () => const PrismTimestampCell(timestamp: '2026-09-06'),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismActionsCell',
          builder: () => const PrismActionsCell(actions: []),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismTablePagination',
          builder: () => PrismTablePagination(
            currentPage: 0,
            totalRows: 10,
            pageSize: 10,
            onPageChanged: (_) {},
            onPageSizeChanged: (_) {},
          ),
          expectedClassification: AncestryClassification.declaredPrerequisite,
          declaredPrerequisiteRationale:
              'Navigation buttons use IconButton/InkResponse, requires Material ancestor for ink splashes',
          prerequisiteWrapper: _materialPrerequisiteWrapper,
        ),
        WidgetAncestrySpec(
          name: 'PrismCommandPaletteShortcut',
          builder: () => const PrismCommandPaletteShortcut(
            commands: [],
            child: SizedBox(),
          ),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
        WidgetAncestrySpec(
          name: 'PrismThemeEditor',
          builder: () => const PrismThemeEditor(),
          expectedClassification: AncestryClassification.declaredPrerequisite,
          declaredPrerequisiteRationale:
              'Tooling organism composing multiple PrismTextField inputs and InkWell chips, requires Material ancestor and bounded height',
          prerequisiteWrapper: (child) =>
              _materialPrerequisiteWrapper(SizedBox(height: 600, child: child)),
        ),
        WidgetAncestrySpec(
          name: 'DesignSystemGalleryPage',
          builder: () => const DesignSystemGalleryPage(),
          expectedClassification: AncestryClassification.selfSufficient,
        ),
      ];

      for (final spec in allWidgetSpecs) {
        testWidgets(
          '${spec.name} matches expected classification (${spec.expectedClassification.name})',
          (tester) async {
            addTearDown(() {
              for (final c in specControllers) {
                c.dispose();
              }
              specControllers.clear();
            });

            if (spec.expectedClassification ==
                AncestryClassification.selfSufficient) {
              await tester.pumpWidget(_contractMinimalWrapper(spec.builder()));
              final exception = tester.takeException();
              expect(
                exception,
                isNull,
                reason:
                    '${spec.name} threw under contract-minimal wrapper without declaring prerequisite: $exception',
              );
            } else if (spec.expectedClassification ==
                AncestryClassification.declaredPrerequisite) {
              // Under contract-minimal without prerequisite, it throws missing Material assertion
              final caughtErrors = <FlutterErrorDetails>[];
              final originalOnError = FlutterError.onError;
              FlutterError.onError = (details) {
                caughtErrors.add(details);
              };

              await tester.pumpWidget(_contractMinimalWrapper(spec.builder()));
              FlutterError.onError = originalOnError;
              tester
                  .takeException(); // clear any pending exception from binding

              expect(
                caughtErrors.any(
                  (d) => d.exceptionAsString().contains(
                    'No Material widget found',
                  ),
                ),
                isTrue,
                reason:
                    '${spec.name} was classified as declaredPrerequisite but did not throw missing Material assertion',
              );

              // Under wrapper with declared prerequisite, it succeeds
              final wrapper =
                  spec.prerequisiteWrapper ?? _materialPrerequisiteWrapper;
              await tester.pumpWidget(wrapper(spec.builder()));
              expect(
                tester.takeException(),
                isNull,
                reason:
                    '${spec.name} failed even with declared prerequisite: ${spec.declaredPrerequisiteRationale}',
              );
            }
          },
        );
      }
    });
  });
}
