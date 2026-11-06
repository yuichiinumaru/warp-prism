// Host-composition sweep for the filter-builder seam (Task 1860, F-12).
//
// Exercises two host-shaped routes in one composition:
// - `/library`: a Tempest-like library/models route — [DSFilterBuilder]
//   drives a [DSDataTable] of model rows plus a [DSAssetCard] result summary
//   through caller-side predicate evaluation.
// - `/sessions`: a Command-center-like session list — [DSToolbarPanel] opens
//   a typed status panel that filters the session table; Done reanchors.
//
// Covers: real named-route entry, at least one meaningful interaction per
// route, zero framework errors, representative viewport/text-scale
// conditions, and shared-theme propagation.
//
// LIMITATION (recorded): the real Tempest and Command-center product hosts
// live outside this workspace boundary and no display host was available in
// this environment, so this is a flutter_tester headless composition sweep
// against host-shaped routes with real named-route navigation — not execution
// inside the real product hosts.
// Run: flutter test packages/warp_prism_ui/test/organisms/filter_workbench/filter_builder_1860_host_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/ds_text.dart';
import 'package:warp_prism_ui/src/molecules/ds_asset_card.dart';
import 'package:warp_prism_ui/src/organisms/data_table/ds_data_table.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_filter_builder.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_filter_builder_editors.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_filter_builder_model.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_toolbar_panel.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

// --- Caller-side fixtures (host-owned; Prism carries no semantics). --------

const _models = [
  {'name': 'stem-alpha', 'severity': 'error', 'service': 'obsidian'},
  {'name': 'stem-beta', 'severity': 'warning', 'service': 'tempo'},
  {'name': 'stem-gamma', 'severity': 'info', 'service': 'obsidian'},
];

const _sessions = [
  {'name': 'session-1', 'status': 'active'},
  {'name': 'session-2', 'status': 'idle'},
  {'name': 'session-3', 'status': 'error'},
];

/// Caller-side predicate evaluation: the host projects the committed
/// snapshot onto its own rows. Prism never sees domain semantics.
bool _modelMatches(Map<String, String> row, DSFilterBuilderSnapshot snap) {
  bool visit(DSFilterGroup group) {
    var acc = group.operator == DSFilterGroupOperator.and;
    bool merge(bool b) {
      acc = group.operator == DSFilterGroupOperator.and
          ? (acc && b)
          : (acc || b);
      return acc;
    }

    for (final p in group.predicates) {
      if (p.values.isEmpty) continue;
      final cell = row[p.fieldId];
      if (cell == null) {
        merge(false);
        continue;
      }
      merge(p.values.contains(cell));
    }
    for (final sub in group.subgroups) {
      merge(visit(sub));
    }
    return acc;
  }

  return visit(snap.root);
}

// --- Host-shaped routes ------------------------------------------------------

/// Tempest-like library/models route: builder + table + asset summary.
class LibraryModelsRoute extends StatefulWidget {
  const LibraryModelsRoute({super.key});

  @override
  State<LibraryModelsRoute> createState() => _LibraryModelsRouteState();
}

class _LibraryModelsRouteState extends State<LibraryModelsRoute> {
  List<Map<String, String>> _visible = List.of(_models);

  void _onCommit(DSFilterBuilderSnapshot snapshot) {
    setState(() {
      _visible = _models.where((m) => _modelMatches(m, snapshot)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.obsidianDeep,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 560,
              child: DSFilterBuilder(
                fields: const [
                  DSFilterField(
                    id: 'severity',
                    label: 'Severity',
                    editorKind: DSFilterEditorKind.enumMulti,
                    options: [
                      DSFilterBuilderOption(value: 'error', label: 'Error'),
                      DSFilterBuilderOption(value: 'warning', label: 'Warning'),
                      DSFilterBuilderOption(value: 'info', label: 'Info'),
                    ],
                  ),
                  DSFilterField(
                    id: 'service',
                    label: 'Service',
                    editorKind: DSFilterEditorKind.text,
                  ),
                ],
                initialTree: DSFilterBuilderFake.emptyTree(),
                onCommit: _onCommit,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            DSAssetCard(
              name: 'Filtered models',
              kind: 'model',
              description: '${_visible.length} of ${_models.length} shown',
            ),
            const SizedBox(height: DSSpacing.sm),
            // Wide tables scroll horizontally on narrow hosts instead of
            // overflowing: the route owns the scrollable, not the table.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 480,
                height: 320,
                child: DSDataTable(
                  columns: const [
                    DSDataColumn(id: 'name', label: 'Name', width: 160),
                    DSDataColumn(id: 'severity', label: 'Severity', width: 120),
                    DSDataColumn(id: 'service', label: 'Service', width: 140),
                  ],
                  rows: [
                    for (final m in _visible)
                      DSDataRow(
                        id: m['name']!,
                        cells: {
                          'name': m['name']!,
                          'severity': m['severity']!,
                          'service': m['service']!,
                        },
                      ),
                  ],
                  showPagination: false,
                  paginated: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Command-center-like session list route: toolbar panel + table.
class SessionListRoute extends StatefulWidget {
  final List<String?> reanchored;

  const SessionListRoute({super.key, required this.reanchored});

  @override
  State<SessionListRoute> createState() => _SessionListRouteState();
}

class _SessionListRouteState extends State<SessionListRoute> {
  List<String> _status = const [];

  List<Map<String, String>> get _visible => _status.isEmpty
      ? List.of(_sessions)
      : _sessions.where((s) => _status.contains(s['status'])).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.obsidianDeep,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSToolbarPanel(
              buttonLabel: 'Session filters',
              options: const [
                DSToolbarPanelOption(id: 'status', label: 'Status'),
              ],
              onReanchored: widget.reanchored.add,
              panelBuilder: (context, panelId, close) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DSText.labelLarge(
                    'Status filter',
                    color: DSColors.textPrimary,
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  DSFilterEnumEditor(
                    key: const Key('host-status-editor'),
                    values: _status,
                    fieldLabel: 'Status',
                    allowMultiple: true,
                    options: const [
                      DSFilterBuilderOption(value: 'active', label: 'Active'),
                      DSFilterBuilderOption(value: 'idle', label: 'Idle'),
                      DSFilterBuilderOption(value: 'error', label: 'Error'),
                    ],
                    onChanged: (v) => setState(() => _status = v),
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  TextButton(
                    key: const Key('host-status-done'),
                    onPressed: close,
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 480,
                height: 320,
                child: DSDataTable(
                  columns: const [
                    DSDataColumn(id: 'name', label: 'Session', width: 160),
                    DSDataColumn(id: 'status', label: 'Status', width: 120),
                  ],
                  rows: [
                    for (final s in _visible)
                      DSDataRow(
                        id: s['name']!,
                        cells: {'name': s['name']!, 'status': s['status']!},
                      ),
                  ],
                  showPagination: false,
                  paginated: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bounded settle: fixed frames only (never `pumpAndSettle`, which hangs on
/// blinking text cursors). Total elapse stays under the builder's 350ms
/// debounce so auto-commit never fires mid-sweep; commits happen on Apply.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Widget _hostApp(List<String?> reanchored) => MaterialApp(
  theme: DSTheme.dark(),
  initialRoute: '/library',
  routes: {
    '/library': (_) => const LibraryModelsRoute(),
    '/sessions': (_) => SessionListRoute(reanchored: reanchored),
  },
);

void main() {
  group('filter_1860 host composition sweep', () {
    testWidgets('library route: build, filter, table narrows, no errors', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await tester.pumpWidget(_hostApp(const []));
        await tester.pump();
        await _settle(tester);

        // All three fixture models visible before filtering.
        expect(find.text('stem-alpha'), findsOneWidget);
        expect(find.text('stem-beta'), findsOneWidget);
        expect(find.text('stem-gamma'), findsOneWidget);
        expect(find.text('3 of 3 shown'), findsOneWidget);

        // Add a severity predicate and select Error + Warning.
        await tester.tap(
          find.byKey(DSFilterBuilder.fieldPickKey('root', 'severity')),
        );
        await tester.pump();
        await _settle(tester);
        await tester.tap(find.text('Error'));
        await tester.pump();
        await _settle(tester);
        await tester.tap(find.text('Warning'));
        await tester.pump();
        await _settle(tester);

        // Commit the draft.
        await tester.tap(find.byKey(DSFilterBuilder.applyButtonKey));
        await tester.pump();
        await _settle(tester);
      } finally {
        // Restore BEFORE asserting on captured errors: expects running
        // under the override poison the runner and hang shutdown.
        FlutterError.onError = previous;
      }

      expect(find.text('stem-alpha'), findsOneWidget);
      expect(find.text('stem-beta'), findsOneWidget);
      expect(find.text('stem-gamma'), findsNothing);
      expect(find.text('2 of 3 shown'), findsOneWidget);

      expect(errors, isEmpty);
    });

    testWidgets('library route holds at phone viewport with 2x text', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 2.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: _hostApp(const []),
          ),
        );
        await tester.pump();
        await _settle(tester);

        // At 195x422 logical with 2x text the pick affordance sits inside
        // the builder's internal scroll view: bring it into view first.
        Finder innerScroll() => find.descendant(
          of: find.byKey(DSFilterBuilder.panelKey),
          matching: find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          ),
        );
        final pick = find.byKey(
          DSFilterBuilder.fieldPickKey('root', 'severity'),
        );
        await tester.scrollUntilVisible(pick, 200, scrollable: innerScroll());
        await tester.pump();
        await tester.tap(pick);
        await tester.pump();
        await _settle(tester);

        // The earlier scroll pushed the footer off-screen: bring Apply into
        // view through the route's outer scrollable before tapping it.
        Finder outerScroll() => find.ancestor(
          of: find.byKey(DSFilterBuilder.panelKey),
          matching: find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          ),
        );
        final apply = find.byKey(DSFilterBuilder.applyButtonKey);
        await tester.scrollUntilVisible(apply, 200, scrollable: outerScroll());
        await tester.pump();
        await tester.tap(apply);
        await tester.pump();
        await _settle(tester);
      } finally {
        // Restore BEFORE asserting on captured errors: expects running
        // under the override poison the runner and hang shutdown.
        FlutterError.onError = previous;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }

      // No RenderFlex overflow: settlement completed and table still renders.
      expect(find.byType(DSDataTable), findsOneWidget);
      expect(errors, isEmpty);
    });

    testWidgets('sessions route: toolbar panel filters and reanchors', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;
      final reanchored = <String?>[];
      try {
        await tester.pumpWidget(_hostApp(reanchored));
        await tester.pump();
        await _settle(tester);

        // Navigate to the sessions route by name.
        final context = tester.element(find.byType(Scaffold).first);
        Navigator.of(context).pushNamed('/sessions');
        await tester.pump();
        await _settle(tester);

        expect(find.text('session-1'), findsOneWidget);
        expect(find.text('session-2'), findsOneWidget);
        expect(find.text('session-3'), findsOneWidget);

        // Button → popover → typed panel.
        await tester.tap(find.byKey(DSToolbarPanel.buttonKey));
        await tester.pump();
        await _settle(tester);
        await tester.tap(find.byKey(DSToolbarPanel.optionKey('status')));
        await tester.pump();
        await _settle(tester);
        expect(
          find.byKey(DSToolbarPanel.typedPanelKey('status')),
          findsOneWidget,
        );

        // Pick Error in the typed panel, then Done reanchors.
        await tester.tap(find.text('Error'));
        await tester.pump();
        await _settle(tester);
        await tester.tap(find.byKey(const Key('host-status-done')));
        await tester.pump();
        await _settle(tester);
      } finally {
        // Restore BEFORE asserting on captured errors: expects running
        // under the override poison the runner and hang shutdown.
        FlutterError.onError = previous;
      }

      expect(find.text('session-1'), findsNothing);
      expect(find.text('session-2'), findsNothing);
      expect(find.text('session-3'), findsOneWidget);
      expect(reanchored, ['status']);

      expect(errors, isEmpty);
    });
  });
}
