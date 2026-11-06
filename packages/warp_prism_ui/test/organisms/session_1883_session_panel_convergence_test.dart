import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_drop_zone_card.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/organisms/ds_detail_inspector.dart';
import 'package:warp_prism_ui/src/organisms/ds_status_grid.dart';
import 'package:warp_prism_ui/src/organisms/ds_timeline.dart';
import 'package:warp_prism_ui/src/organisms/execution_console/execution_console.dart';
import 'package:warp_prism_ui/src/organisms/log_viewer/log_viewer.dart';
import 'package:warp_prism_ui/src/organisms/provider_health_matrix/provider_health_matrix.dart';
import 'package:warp_prism_ui/src/organisms/session_panel/ds_session_panel_compositions.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';
import 'package:warp_prism_ui/src/tokens/ds_action_authority.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

// Task 1883 (F-16): Session/panel convergence proof.
//
// Source reality (revision UNKNOWN — VCS out of scope; workspace-local routes
// attempted): `docs/bridge/tempest/` and `docs/bridge/command-center/`
// contain only `README.md` (symlink targets absent); `references/` carries no
// `ganthritor-tempest` / command-center checkout. Donor shapes below are
// INHERITED REPORT from Task 1882 (`tempest_studio_convergence_test.dart`:
// NavigationRail destinations Library/Separate/Create/Studio/Models/
// Providers/Settings; CC W-A/W-B sessions + event stream).
//
// Limitation: no display host is reachable from this environment, so host
// proof runs as `flutter_tester` headless sweeps: enter route, interact,
// observe framework/runtime errors (takeException + ErrorWidget absence),
// viewport variants, theme propagation. Pixel overflow and screen-reader
// traversal order stay UNKNOWN until a display host exercises these routes.

List<DSSessionRecord> session1883TestSessions() => const [
  DSSessionRecord(
    id: 'sess_alpha_01',
    title: 'Session alpha',
    state: DSOperationalState.approved,
    updatedLabel: '12:04:31',
    verified: true,
  ),
  DSSessionRecord(
    id: 'sess_beta_02',
    title: 'Session beta',
    state: DSOperationalState.pending,
    updatedLabel: '12:03:10',
    authority: DSActionAuthority.constrain,
    authorityReason: 'Read-only replica: edits queue for review',
  ),
  DSSessionRecord(
    id: 'sess_gamma_03',
    title: 'Session gamma',
    state: DSOperationalState.degraded,
    updatedLabel: '11:58:44',
    authority: DSActionAuthority.deny,
    authorityReason: 'Locked by another operator',
  ),
  DSSessionRecord(
    id: 'sess_delta_04',
    title: 'Session delta',
    state: DSOperationalState.healthy,
    updatedLabel: '11:51:02',
    verified: true,
  ),
  DSSessionRecord(
    id: 'sess_epsilon_05',
    title: 'Session epsilon',
    state: DSOperationalState.unverified,
    updatedLabel: '11:44:20',
  ),
  DSSessionRecord(
    id: 'sess_zeta_06',
    title: 'Session zeta',
    state: DSOperationalState.archived,
    updatedLabel: '11:30:00',
  ),
  DSSessionRecord(
    id: 'sess_eta_07',
    title: 'Session eta',
    state: DSOperationalState.stale,
    updatedLabel: '11:12:55',
    authority: DSActionAuthority.deny,
    authorityReason: 'Retention hold: read-only',
  ),
];

List<DSLogEntry> session1883TestLogEntries() => [
  DSLogEntry(
    id: 'log-1',
    timestamp: DateTime.utc(2026, 10, 1, 12, 0, 0),
    severity: DSLogSeverity.info,
    source: 'session-host',
    message: 'Session alpha opened',
    detail: 'Trace: session-host accepted open request (id sess_alpha_01)',
  ),
  DSLogEntry(
    id: 'log-2',
    timestamp: DateTime.utc(2026, 10, 1, 12, 1, 12),
    severity: DSLogSeverity.error,
    source: 'ingest',
    message: 'Chunk 3 rejected by the ingest gate',
  ),
];

List<DSTimelineEntry> session1883TestTimelineEntries() =>
    const <DSTimelineEntry>[
      DSTimelineEntry(
        id: 'tl-1',
        date: '2026-10-01',
        title: 'Session alpha opened',
        project: 'command-center',
        taskId: '1883',
      ),
      DSTimelineEntry(
        id: 'tl-2',
        date: '2026-10-01',
        title: 'Replica lag noted',
        type: 'warning',
        project: 'command-center',
      ),
    ];

List<DSExecutionLine> session1883TestConsoleLines() => const <DSExecutionLine>[
  DSExecutionLine(
    id: 'line-1',
    message: 'run started: nightly-render',
    level: DSExecutionLineLevel.system,
    runGroupId: 'run-1',
  ),
  DSExecutionLine(
    id: 'line-2',
    message: 'chunk 3 rejected by the ingest gate',
    level: DSExecutionLineLevel.stderr,
    runGroupId: 'run-1',
  ),
];

List<DSTempestLibraryItem> session1883TestLibraryItems() =>
    const <DSTempestLibraryItem>[
      DSTempestLibraryItem(
        id: 'lib-vocals',
        name: 'Night vocals',
        kind: 'stem',
        description: 'Lead vocal bus',
        tags: ['vox'],
        filterValue: 'stem',
      ),
      DSTempestLibraryItem(
        id: 'lib-drums',
        name: 'Break 92',
        kind: 'loop',
        description: '92 BPM break',
        tags: ['drums'],
        filterValue: 'loop',
      ),
    ];

Widget session1883Bounded(Widget child, {double width = 1000}) {
  return MaterialApp(
    theme: DSTheme.dark(),
    home: Scaffold(
      body: SizedBox(width: width, height: 900, child: child),
    ),
  );
}

/// Pumps a session-table composition on a real 1280x900 surface.
///
/// The five expanded table columns (verification badges, F-01 gates) need a
/// genuinely wide viewport: the default 800x600 test surface clamps narrower
/// boxes and squeezes badge cells into subpixel Flex overflow. Runs
/// [interact], then restores the surface BEFORE the caller asserts (callers
/// assert — including `takeException` — after return).
Future<void> session1883PumpTable(
  WidgetTester tester,
  Widget child,
  Future<void> Function() interact,
) async {
  await tester.binding.setSurfaceSize(const Size(1280, 900));
  try {
    await tester.pumpWidget(
      MaterialApp(
        theme: DSTheme.dark(),
        home: Scaffold(body: SizedBox(width: 1280, height: 900, child: child)),
      ),
    );
    await tester.pumpAndSettle();
    await interact();
  } finally {
    await tester.binding.setSurfaceSize(null);
  }
}

void main() {
  group('DSSessionListView (DSDataTable + F-01 gates)', () {
    testWidgets('renders rows with state, verification, and gates', (
      tester,
    ) async {
      await session1883PumpTable(
        tester,
        DSSessionListView(sessions: session1883TestSessions()),
        () async {},
      );

      expect(find.text('Session alpha'), findsOneWidget);
      expect(find.text('Session beta'), findsOneWidget);
      // F-01 gate chrome: every row carries an Open gate.
      expect(find.text('Open'), findsWidgets);
      // Denied + constrained reasons stay visible, never hidden.
      expect(find.text('Locked by another operator'), findsOneWidget);
      expect(
        find.text('Read-only replica: edits queue for review'),
        findsOneWidget,
      );
      // Pagination: 7 rows at page size 5.
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('allowed row opens, denied row never dispatches', (
      tester,
    ) async {
      final opened = <String>[];
      final refused = <String>[];
      await session1883PumpTable(
        tester,
        DSSessionListView(
          sessions: session1883TestSessions(),
          onOpenSession: opened.add,
          onActionRefused: (id, _) => refused.add(id),
        ),
        () async {
          await tester.tap(find.text('Session alpha'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Session gamma'));
          await tester.pumpAndSettle();
        },
      );
      expect(opened, ['sess_alpha_01']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('search narrows rows', (tester) async {
      await session1883PumpTable(
        tester,
        DSSessionListView(sessions: session1883TestSessions()),
        () async {
          await tester.enterText(find.byType(TextField), 'beta');
          await tester.pumpAndSettle();
        },
      );
      expect(find.text('Session beta'), findsOneWidget);
      expect(find.text('Session alpha'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('state chip narrows rows', (tester) async {
      await session1883PumpTable(
        tester,
        DSSessionListView(sessions: session1883TestSessions()),
        () async {
          // Toolbar chip precedes the table state cell in traversal order.
          await tester.tap(find.text('Approved').first);
          await tester.pumpAndSettle();
        },
      );
      expect(find.text('Session alpha'), findsOneWidget);
      expect(find.text('Session beta'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pagination advances pages', (tester) async {
      await session1883PumpTable(
        tester,
        DSSessionListView(sessions: session1883TestSessions()),
        () async {
          await tester.tap(find.bySemanticsLabel('Next page'));
          await tester.pumpAndSettle();
        },
      );
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text('Session zeta'), findsOneWidget);
      expect(find.text('Session alpha'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sort header toggles direction', (tester) async {
      var alphaFirstAfterFirstTap = false;
      var zetaFirstAfterSecondTap = false;
      await session1883PumpTable(
        tester,
        DSSessionListView(sessions: session1883TestSessions()),
        () async {
          // Header sort semantics merge the column label into a compound
          // label, so drive the real header control by its visible text and
          // prove direction through row order instead of label strings.
          await tester.tap(find.text('Session'));
          await tester.pumpAndSettle();
          alphaFirstAfterFirstTap = find
              .text('Session alpha')
              .evaluate()
              .isNotEmpty;
          await tester.tap(find.text('Session'));
          await tester.pumpAndSettle();
          zetaFirstAfterSecondTap =
              find.text('Session zeta').evaluate().isNotEmpty &&
              find.text('Session alpha').evaluate().isEmpty;
        },
      );
      // First tap sorts ascending (alpha on page one), second tap flips to
      // descending (zeta on page one, alpha pushed to page two).
      expect(alphaFirstAfterFirstTap, isTrue);
      expect(zetaFirstAfterSecondTap, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('DSSessionDetailView (inspector + mono)', () {
    testWidgets('verified session renders mono id and badge', (tester) async {
      await tester.pumpWidget(
        session1883Bounded(
          DSSessionDetailView(
            session: session1883TestSessions()[0],
            monoProperties: const {'Stream key': 'sess_alpha_01'},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Session alpha'), findsWidgets);
      // Session id renders twice by fixture design: the Session ID mono row
      // and the Stream key mono row carry the same value.
      expect(find.text('sess_alpha_01'), findsWidgets);
      expect(find.bySemanticsLabel('Verification: Approved'), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('unverified session stays fail-closed', (tester) async {
      await tester.pumpWidget(
        session1883Bounded(
          DSSessionDetailView(session: session1883TestSessions()[4]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unverified — no proof yet.'), findsOneWidget);
      expect(find.bySemanticsLabel('Verification: Unverified'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DSEventStreamView (log + timeline + console)', () {
    testWidgets('log section streams, timeline and console expand', (
      tester,
    ) async {
      String? logged;
      String? timelineTapped;
      // The three fixed section viewports (280/300/320) plus accordion
      // chrome need a genuinely tall surface: the default 800x600 test
      // surface clamps the 1200-tall box and pushes sections off-screen.
      await tester.binding.setSurfaceSize(const Size(800, 1280));
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: DSTheme.dark(),
            home: Scaffold(
              body: SizedBox(
                width: 700,
                height: 1200,
                child: DSEventStreamView(
                  logEntries: session1883TestLogEntries(),
                  timelineEntries: session1883TestTimelineEntries(),
                  consoleLines: session1883TestConsoleLines(),
                  consoleGroups: const [
                    DSExecutionRunGroup(
                      id: 'run-1',
                      label: 'Run #12 · nightly-render',
                      status: DSExecutionRunStatus.failed,
                    ),
                  ],
                  onLogTap: (id) => logged = id,
                  onTimelineTap: (id) => timelineTapped = id,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Log stream'), findsOneWidget);
        expect(find.text('Session alpha opened'), findsOneWidget);
        await tester.tap(find.text('Session alpha opened'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Timeline'));
        await tester.pumpAndSettle();
        expect(find.text('Replica lag noted'), findsOneWidget);
        await tester.tap(find.text('Replica lag noted'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Execution console'));
        await tester.pumpAndSettle();
      } finally {
        await tester.binding.setSurfaceSize(null);
      }

      expect(logged, 'log-1');
      expect(timelineTapped, 'tl-2');
      expect(find.text('chunk 3 rejected by the ingest gate'), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('DSProjectPanelView and DSMediaPanelView', () {
    testWidgets('project loading and error states', (tester) async {
      await tester.pumpWidget(
        session1883Bounded(
          const DSProjectPanelView(title: 'Nightly render', isLoading: true),
        ),
      );
      // Loading chrome shows an indeterminate spinner, so settle is
      // unreachable here: a single pump renders the loading frame.
      await tester.pump();
      expect(find.text('Loading Nightly render...'), findsOneWidget);

      var retried = false;
      await tester.pumpWidget(
        session1883Bounded(
          DSProjectPanelView(
            title: 'Nightly render',
            errorMessage: 'Probe unreachable',
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Failed to load Nightly render'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(retried, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('project data renders rows and badge', (tester) async {
      await tester.pumpWidget(
        session1883Bounded(
          const DSProjectPanelView(
            title: 'Nightly render',
            properties: {'Owner': 'ops'},
            monoProperties: {'Project ID': 'proj_nightly_04'},
            state: DSOperationalState.healthy,
            verified: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('proj_nightly_04'), findsOneWidget);
      expect(find.bySemanticsLabel('Verification: Approved'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('media panel opens from header card', (tester) async {
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: DSTheme.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DSMediaPanelView(
                assetName: 'Take 04 master',
                assetKind: 'audio',
                description: 'Stereo mixdown reference',
                tags: const ['stems'],
                properties: const {'Duration': '3:42'},
                verificationState: DSOperationalState.approved,
                onOpen: () => opened = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Take 04 master'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Media panel: Take 04 master'),
        findsOneWidget,
      );
      await tester.tap(find.text('Take 04 master'));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('Tempest screens (search/filter/asset/status/metric/select)', () {
    testWidgets('Library searches and selects', (tester) async {
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: DSTheme.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DSTempestLibraryView(
                items: session1883TestLibraryItems(),
                onSelected: (id) => selected = id,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Library'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'break');
      await tester.pumpAndSettle();
      expect(find.text('Break 92'), findsOneWidget);
      expect(find.text('Night vocals'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Break 92'));
      await tester.pumpAndSettle();
      expect(selected, 'lib-drums');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Models renders metrics and matrix cell selects', (
      tester,
    ) async {
      String? cellId;
      await tester.pumpWidget(
        MaterialApp(
          theme: DSTheme.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DSTempestModelsView(
                metrics: const [
                  DSTempestModelMetric(
                    label: 'Loaded models',
                    value: '6',
                    health: DSMetricTileHealth.healthy,
                  ),
                ],
                providers: const [
                  DSProviderHealthProvider(
                    id: 'openai',
                    label: 'OpenAI',
                    cells: [
                      DSProviderHealthCell(
                        id: 'openai-main',
                        providerId: 'openai',
                        providerLabel: 'OpenAI',
                        dimensionId: 'main',
                        dimensionLabel: 'main-prod',
                        operationalState: DSOperationalState.healthy,
                      ),
                    ],
                  ),
                ],
                onCellSelected: (cell) => cellId = cell.id,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Loaded models'), findsOneWidget);
      expect(find.text('main-prod'), findsOneWidget);
      // The matrix header shows the dimension label; the selectable cell is
      // the interactive tile keyed by cell id (child semantics excluded).
      await tester.tap(
        find.byKey(const Key('provider-health-cell-openai-main')),
      );
      await tester.pumpAndSettle();
      expect(cellId, 'openai-main');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Providers renders matrix and status grid', (tester) async {
      String? service;
      await tester.pumpWidget(
        MaterialApp(
          theme: DSTheme.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DSTempestProvidersView(
                providers: const [
                  DSProviderHealthProvider(
                    id: 'local',
                    label: 'Local',
                    cells: [
                      DSProviderHealthCell(
                        id: 'local-main',
                        providerId: 'local',
                        providerLabel: 'Local',
                        dimensionId: 'main',
                        dimensionLabel: 'main-prod',
                        operationalState: DSOperationalState.unverified,
                      ),
                    ],
                  ),
                ],
                services: const [
                  DSHealthCardData(
                    serviceName: 'ingest',
                    operationalState: DSOperationalState.healthy,
                  ),
                ],
                onServiceTap: (item) => service = item.serviceName,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Providers'), findsOneWidget);
      expect(find.text('ingest'), findsOneWidget);
      await tester.tap(find.text('ingest'));
      await tester.pumpAndSettle();
      expect(service, 'ingest');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Settings changes profile', (tester) async {
      String? profile;
      await tester.pumpWidget(
        MaterialApp(
          theme: DSTheme.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DSTempestSettingsView(
                profileOptions: const [
                  DSSelectItem(value: 'studio', label: 'Studio'),
                  DSSelectItem(value: 'live', label: 'Live room'),
                ],
                profileValue: 'studio',
                onProfileChanged: (value) => profile = value,
                sections: const [
                  DSAccordionItem(
                    id: 'audio',
                    title: 'Audio',
                    content: DSPropertyRow(
                      label: 'Device',
                      value: 'Built-in output',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Settings'), findsOneWidget);
      await tester.tap(find.text('Studio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Live room'));
      await tester.pumpAndSettle();
      expect(profile, 'live');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Separate filters stems', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DSTheme.dark(),
          home: Scaffold(
            body: SizedBox(
              width: 700,
              height: 900,
              child: DSTempestSeparateView(
                stems: session1883TestLibraryItems(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Separate'), findsOneWidget);
      await tester.tap(find.text('loop'));
      await tester.pumpAndSettle();
      expect(find.text('Break 92'), findsOneWidget);
      expect(find.text('Night vocals'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Create denied gate refuses with reason', (tester) async {
      String? refused;
      await tester.pumpWidget(
        MaterialApp(
          theme: DSTheme.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DSTempestCreateView(
                templateOptions: const [
                  DSSelectItem(value: 'song', label: 'Song'),
                ],
                templateValue: 'song',
                createAuthority: DSActionAuthority.deny,
                createReason: 'Creation locked by policy',
                onCreateRefused: (reason) => refused = reason,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(refused, 'Creation locked by policy');
      expect(tester.takeException(), isNull);
    });
  });

  group('DSDropZoneCard (sole extension)', () {
    testWidgets('renders metadata header and lane child', (tester) async {
      await tester.pumpWidget(
        session1883Bounded(
          const DSDropZoneCard(
            metadata: DSDropZoneMetadata(
              label: 'Inbox',
              kind: 'lane',
              description: 'Untriaged session cards',
              tags: ['triage'],
            ),
            laneId: 'inbox',
            taskCount: 1,
            child: SizedBox(
              height: 200,
              child: Center(child: _LaneChildProbe()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Drop zone: Inbox'), findsOneWidget);
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty zone shows drop hint', (tester) async {
      await tester.pumpWidget(
        session1883Bounded(
          const DSDropZoneCard(
            metadata: DSDropZoneMetadata(
              label: 'Archive',
              kind: 'lane',
              emptyHint: 'Drag a session card here',
            ),
            laneId: 'archive',
            taskCount: 0,
            isEmpty: true,
            child: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Drop cards here'), findsOneWidget);
      expect(find.text('Drag a session card here'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Host exercise (AGENTS.md §7.1, headless sweep)', () {
    testWidgets('Tempest Library route: enter, interact, theme intact', (
      tester,
    ) async {
      String? selected;
      var themeIntact = false;
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: DSTheme.dark(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: DSTempestLibraryView(
                  items: session1883TestLibraryItems(),
                  onSelected: (id) => selected = id,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'vocals');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Night vocals'));
        await tester.pumpAndSettle();

        final context = tester.element(find.text('Night vocals'));
        themeIntact = Theme.of(context).brightness == Brightness.dark;
      } finally {
        await tester.binding.setSurfaceSize(null);
      }

      expect(selected, 'lib-vocals');
      expect(themeIntact, isTrue);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Command-center split host: sessions beside event stream', (
      tester,
    ) async {
      String? opened;
      var themeIntact = false;
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: DSTheme.dark(),
            home: Scaffold(
              body: SizedBox(
                width: 1440,
                height: 900,
                child: DSSessionEventSplitHost(
                  sessions: session1883TestSessions(),
                  logEntries: session1883TestLogEntries(),
                  timelineEntries: session1883TestTimelineEntries(),
                  consoleLines: session1883TestConsoleLines(),
                  onOpenSession: (id) => opened = id,
                  // The five-column session table needs a wide leading pane:
                  // the default 0.42 split squeezes verification-badge cells
                  // into Flex overflow. Hosts tune this ratio; 0.60 keeps both
                  // panes clean at 1440 wide.
                  initialRatio: 0.60,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel('Sessions and event stream'),
          findsOneWidget,
        );
        expect(find.text('Log stream'), findsOneWidget);
        await tester.tap(find.text('Session delta'));
        await tester.pumpAndSettle();

        final context = tester.element(find.text('Log stream'));
        themeIntact = Theme.of(context).brightness == Brightness.dark;
      } finally {
        await tester.binding.setSurfaceSize(null);
      }

      expect(opened, 'sess_delta_04');
      expect(themeIntact, isTrue);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('narrow viewport keeps Tempest Library clean', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 900));
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: DSTheme.dark(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: DSTempestLibraryView(
                  items: session1883TestLibraryItems(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      } finally {
        await tester.binding.setSurfaceSize(null);
      }

      expect(find.text('Night vocals'), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Probe widget standing in for lane children in drop-zone tests.
class _LaneChildProbe extends StatelessWidget {
  const _LaneChildProbe();

  @override
  Widget build(BuildContext context) {
    return const Text('lane child probe');
  }
}
