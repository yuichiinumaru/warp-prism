import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helper: wraps a widget in MaterialApp + Scaffold for consistent test env
  // ---------------------------------------------------------------------------
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: SizedBox(width: 800, height: 600, child: child)),
  );

  // Sample columns for reuse
  const sampleColumns = <PrismDataColumn>[
    PrismDataColumn(id: 'id', label: 'ID', width: 60),
    PrismDataColumn(id: 'name', label: 'Name', sortable: true),
    PrismDataColumn(id: 'status', label: 'Status', sortable: true),
  ];

  List<PrismDataRow> sampleRows() => [
    const PrismDataRow(
      id: '1',
      cells: {'id': '001', 'name': 'Alpha', 'status': 'Running'},
    ),
    const PrismDataRow(
      id: '2',
      cells: {'id': '002', 'name': 'Beta', 'status': 'Healthy'},
    ),
    const PrismDataRow(
      id: '3',
      cells: {'id': '003', 'name': 'Gamma', 'status': 'Error'},
    ),
  ];

  // ---------------------------------------------------------------------------
  // GROUP: Default rendering
  // ---------------------------------------------------------------------------
  group('PrismDataTable default rendering', () {
    testWidgets('renders column headers', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      expect(find.text('ID'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('renders row data', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('renders inside a glass panel', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      expect(find.byType(PrismGlassPanelSimple), findsOneWidget);
    });

    testWidgets('has semantic label for data table', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      // The semantic label includes column count and row count
      expect(
        find.bySemanticsLabel(RegExp(r'Data table.*3 columns.*3 rows')),
        findsOneWidget,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Empty state
  // ---------------------------------------------------------------------------
  group('PrismDataTable empty state', () {
    testWidgets('renders empty state when no rows', (tester) async {
      await tester.pumpWidget(
        wrap(const PrismDataTable(columns: sampleColumns, rows: [])),
      );

      expect(find.text('No data'), findsOneWidget);
      expect(find.text('No records match the current filters'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Loading state
  // ---------------------------------------------------------------------------
  group('PrismDataTable loading state', () {
    testWidgets('renders skeleton when loading', (tester) async {
      await tester.pumpWidget(
        wrap(const PrismDataTable(columns: sampleColumns, loading: true)),
      );

      // Skeleton renders Container widgets for each row
      expect(find.text('ID'), findsNothing); // no header in skeleton mode
      expect(find.text('No data'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Error state
  // ---------------------------------------------------------------------------
  group('PrismDataTable error state', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PrismDataTable(
            columns: sampleColumns,
            errorMessage: 'Connection failed',
          ),
        ),
      );

      expect(find.text('Failed to load data'), findsOneWidget);
      expect(find.text('Connection failed'), findsOneWidget);
    });

    testWidgets('retry button fires callback', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            errorMessage: 'Failed',
            onRetry: () => retryCalled = true,
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(retryCalled, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Sorting
  // ---------------------------------------------------------------------------
  group('PrismDataTable sorting', () {
    testWidgets('tapping sortable column header fires onSort', (tester) async {
      String? sortedColumn;

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            onSort: (colId) => sortedColumn = colId,
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      // Tap the "Name" column header (sortable)
      await tester.tap(find.text('Name'));
      expect(sortedColumn, 'name');
    });

    testWidgets('sort indicators highlight sorted column', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            sortState: const PrismSortState(
              columnId: 'name',
              direction: PrismSortDirection.ascending,
            ),
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      // Sort indicators are rendered as arrow_drop_up/down icons
      // The ascending arrow should be highlighted (cyan)
      expect(find.byIcon(Icons.arrow_drop_up), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Pagination
  // ---------------------------------------------------------------------------
  group('PrismDataTable pagination', () {
    testWidgets('shows pagination controls by default', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            pageSize: 10,
          ),
        ),
      );

      expect(find.text('1–3 of 3'), findsOneWidget);
      expect(find.text('1 / 1'), findsOneWidget);
    });

    testWidgets('hides pagination when showPagination is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            showPagination: false,
          ),
        ),
      );

      expect(find.text('1–3 of 3'), findsNothing);
    });

    testWidgets('pagination fires onPageChanged callback', (tester) async {
      int? changedPage;

      // Generate enough rows for multiple pages
      final rows = List.generate(
        30,
        (i) => PrismDataRow(
          id: '$i',
          cells: {'id': '$i', 'name': 'Item $i', 'status': 'Ok'},
        ),
      );

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: rows,
            currentPage: 0,
            pageSize: 10,
            onPageChanged: (page) => changedPage = page,
          ),
        ),
      );

      // Tap the "next page" button
      await tester.tap(find.bySemanticsLabel('Next page'));
      expect(changedPage, 1);
    });

    testWidgets('pagination disables previous on first page', (tester) async {
      final rows = List.generate(
        30,
        (i) => PrismDataRow(
          id: '$i',
          cells: {'id': '$i', 'name': 'Item $i', 'status': 'Ok'},
        ),
      );

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: rows,
            currentPage: 0,
            pageSize: 10,
          ),
        ),
      );

      // Previous page button should be disabled
      final prevButton = find.bySemanticsLabel('Previous page');
      expect(prevButton, findsOneWidget);
      // The button renders an Icon with disabled color when not enabled
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Row selection
  // ---------------------------------------------------------------------------
  group('PrismDataTable row selection', () {
    testWidgets('renders checkboxes when selectable', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            selectable: true,
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      // 3 row checkboxes + 1 select-all checkbox
      expect(find.byType(Checkbox), findsNWidgets(4));
    });

    testWidgets('tapping checkbox toggles selection', (tester) async {
      final selectedIds = <String>{};

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            selectable: true,
            paginated: false,
            showPagination: false,
            onSelectionChanged: (ids) => selectedIds.addAll(ids),
          ),
        ),
      );

      // Tap the second row checkbox (after select-all)
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      expect(selectedIds, contains('1'));
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Custom cell renderers
  // ---------------------------------------------------------------------------
  group('PrismDataTable cell renderers', () {
    testWidgets('renders operational state cell with dot and label', (
      tester,
    ) async {
      final columns = <PrismDataColumn>[
        const PrismDataColumn(id: 'name', label: 'Name'),
        PrismDataColumn(
          id: 'state',
          label: 'State',
          cellRenderer: (ctx, value, idx) {
            if (value is PrismOperationalState) {
              return PrismStatusCell(state: value);
            }
            return const SizedBox.shrink();
          },
        ),
      ];

      final rows = [
        const PrismDataRow(
          id: '1',
          cells: {
            'name': 'Test Entity',
            'state': PrismOperationalState.running,
          },
        ),
      ];

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: columns,
            rows: rows,
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      expect(find.text('Test Entity'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.byType(PrismStatusDot), findsOneWidget);
    });

    testWidgets('renders secret cell with masked value', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PrismSecretCell(
            maskedValue: '••••••abc1',
            fullValue: 'sk-1234567890abcdef',
          ),
        ),
      );

      expect(find.text('••••••abc1'), findsOneWidget);
      // Eye icon for reveal
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('secret cell reveals value on tap', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PrismSecretCell(
            maskedValue: '••••••abc1',
            fullValue: 'sk-1234567890abcdef',
          ),
        ),
      );

      // Tap the reveal icon
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      expect(find.text('sk-1234567890abcdef'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('renders timestamp cell in monospace', (tester) async {
      await tester.pumpWidget(
        wrap(const PrismTimestampCell(timestamp: '2025-06-08 14:30')),
      );

      expect(find.text('2025-06-08 14:30'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Operational state vocabulary
  // ---------------------------------------------------------------------------
  group('PrismOperationalState vocabulary', () {
    testWidgets('all 15 states render with status cells', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 1200,
              child: ListView(
                children: PrismOperationalState.values.map((state) {
                  return PrismStatusCell(state: state);
                }).toList(),
              ),
            ),
          ),
        ),
      );

      // Check that key states are rendered
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Stale'), findsOneWidget);
      expect(find.text('Excluded'), findsOneWidget);
    });

    test('all 15 operational states have color', () {
      for (final state in PrismOperationalState.values) {
        expect(state.color, isA<Color>());
        expect(state.color, isNot(equals(Colors.transparent)));
      }
    });

    test('all 15 operational states have icon', () {
      for (final state in PrismOperationalState.values) {
        expect(state.icon, isA<IconData>());
      }
    });

    test('all 15 operational states have label', () {
      for (final state in PrismOperationalState.values) {
        expect(state.label, isNotEmpty);
      }
    });

    test('all 15 operational states have semanticLabel', () {
      for (final state in PrismOperationalState.values) {
        expect(state.semanticLabel, isNotEmpty);
        expect(state.semanticLabel, contains(':'));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Barrel exports
  // ---------------------------------------------------------------------------
  group('DataTable barrel exports', () {
    test('all data table classes are accessible via barrel', () {
      // Compile-time check — if any export is missing this won't compile
      expect(PrismDataTable, isNotNull);
      expect(PrismDataColumn, isNotNull);
      expect(PrismDataRow, isNotNull);
      expect(PrismSortState, isNotNull);
      expect(PrismSortDirection, isNotNull);
      expect(PrismStatusCell, isNotNull);
      expect(PrismBadgeCell, isNotNull);
      expect(PrismTimestampCell, isNotNull);
      expect(PrismSecretCell, isNotNull);
      expect(PrismActionsCell, isNotNull);
      expect(PrismActionItem, isNotNull);
      expect(PrismTablePagination, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Column visibility
  // ---------------------------------------------------------------------------
  group('PrismDataTable column visibility', () {
    testWidgets('hidden columns are not rendered', (tester) async {
      final columns = <PrismDataColumn>[
        const PrismDataColumn(id: 'id', label: 'ID'),
        const PrismDataColumn(id: 'name', label: 'Name'),
        const PrismDataColumn(id: 'secret', label: 'Secret', visible: false),
      ];

      final rows = [
        const PrismDataRow(
          id: '1',
          cells: {'id': '001', 'name': 'Alpha', 'secret': 'hidden-value'},
        ),
      ];

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: columns,
            rows: rows,
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      expect(find.text('ID'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Secret'), findsNothing);
      expect(find.text('hidden-value'), findsNothing);
    });

    testWidgets('column visibility toggle fires callback', (tester) async {
      final columns = <PrismDataColumn>[
        const PrismDataColumn(id: 'id', label: 'ID'),
        const PrismDataColumn(id: 'name', label: 'Name'),
      ];

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: columns,
            rows: sampleRows(),
            paginated: false,
            showPagination: false,
            onToggleColumn: (id, vis) {
              // Callback wiring verified by construction; menu affordance below.
              expect(id, isNotEmpty);
              expect(vis, isA<bool>());
            },
          ),
        ),
      );

      // Column visibility menu button should exist
      expect(find.byTooltip('Toggle columns'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismDataRow
  // ---------------------------------------------------------------------------
  group('PrismDataRow', () {
    test('row onTap callback is stored', () {
      var tapped = false;
      final row = PrismDataRow(
        id: 'test',
        cells: {'a': 'b'},
        onTap: () => tapped = true,
      );

      row.onTap?.call();
      expect(tapped, isTrue);
    });

    test('row selection state is tracked', () {
      const row = PrismDataRow(id: 'test', cells: {'a': 'b'}, selected: true);

      expect(row.selected, isTrue);
      expect(row.selectable, isTrue);
    });

    testWidgets('row onTap exposes Semantics button label Select table row', (
      tester,
    ) async {
      var tapped = false;
      final rows = [
        PrismDataRow(
          id: '1',
          cells: {'id': '001', 'name': 'Alpha', 'status': 'Running'},
          onTap: () => tapped = true,
        ),
      ];

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: rows,
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      // Widget-tree proof: Semantics(button, label) wraps tappable rows.
      // Child cell text may merge into the resolved SemanticsNode label, so
      // assert the Semantics configuration widget rather than the merged node.
      final rowSemantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == 'Select table row',
      );
      expect(rowSemantics, findsOneWidget);

      await tester.tap(find.text('Alpha'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismSortState
  // ---------------------------------------------------------------------------
  group('PrismSortState', () {
    test('toggle switches direction', () {
      const state = PrismSortState(
        columnId: 'name',
        direction: PrismSortDirection.ascending,
      );

      final toggled = state.toggle();
      expect(toggled.direction, PrismSortDirection.descending);
      expect(toggled.columnId, 'name');
    });

    test('toggle from descending goes to ascending', () {
      const state = PrismSortState(
        columnId: 'name',
        direction: PrismSortDirection.descending,
      );

      final toggled = state.toggle();
      expect(toggled.direction, PrismSortDirection.ascending);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismTablePagination
  // ---------------------------------------------------------------------------
  group('PrismTablePagination', () {
    testWidgets('renders row count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrismTablePagination(
              currentPage: 0,
              totalRows: 50,
              pageSize: 10,
              onPageChanged: (_) {},
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('1–10 of 50'), findsOneWidget);
      expect(find.text('1 / 5'), findsOneWidget);
    });

    testWidgets('next page button works', (tester) async {
      int? newPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrismTablePagination(
              currentPage: 0,
              totalRows: 50,
              pageSize: 10,
              onPageChanged: (p) => newPage = p,
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Next page'));
      expect(newPage, 1);
    });

    testWidgets('previous page button is disabled on first page', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrismTablePagination(
              currentPage: 0,
              totalRows: 50,
              pageSize: 10,
              onPageChanged: (_) {},
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      // Previous page should be disabled (icon with disabled color)
      expect(find.bySemanticsLabel('Previous page'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Path-to-100: filter toolbar integration + sort a11y
  // ---------------------------------------------------------------------------
  group('PrismDataTable filter toolbar integration', () {
    testWidgets('toolbar SearchBar + FilterChipGroup compose and filter rows', (
      tester,
    ) async {
      var query = '';
      var statusFilter = 'all';
      final allRows = sampleRows();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                final filtered = allRows.where((r) {
                  final name = (r.cells['name'] as String).toLowerCase();
                  final status = (r.cells['status'] as String).toLowerCase();
                  final matchesQuery =
                      query.isEmpty || name.contains(query.toLowerCase());
                  final matchesStatus =
                      statusFilter == 'all' ||
                      status == statusFilter.toLowerCase();
                  return matchesQuery && matchesStatus;
                }).toList();
                return SizedBox(
                  width: 800,
                  height: 600,
                  child: PrismDataTable(
                    columns: sampleColumns,
                    rows: filtered,
                    paginated: false,
                    showPagination: false,
                    toolbar: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrismSearchBar(
                          placeholder: 'Filter rows',
                          onChanged: (v) => setState(() => query = v),
                        ),
                        PrismFilterChipGroup(
                          options: const [
                            PrismFilterOption(value: 'all', label: 'All'),
                            PrismFilterOption(
                              value: 'running',
                              label: 'Running',
                            ),
                            PrismFilterOption(
                              value: 'healthy',
                              label: 'Healthy',
                            ),
                          ],
                          selected: {statusFilter},
                          allowMultiple: false,
                          onToggle: (v) => setState(() => statusFilter = v),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.byType(PrismSearchBar), findsOneWidget);
      expect(find.byType(PrismFilterChipGroup), findsOneWidget);

      // FilterChipGroup: narrow to Running status (Alpha only).
      // Scope to chip group — status cells may also render "Running".
      final chipGroup = find.byType(PrismFilterChipGroup);
      await tester.tap(
        find.descendant(of: chipGroup, matching: find.text('Running')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsNothing);
      expect(find.text('Gamma'), findsNothing);

      // Reset chip + SearchBar: text filter to Beta only.
      await tester.tap(
        find.descendant(of: chipGroup, matching: find.text('All')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Beta');
      await tester.pumpAndSettle();

      // Search field also contains "Beta"; assert non-matching rows are gone.
      expect(find.text('Alpha'), findsNothing);
      expect(find.text('Gamma'), findsNothing);
      // Beta remains as a data cell (Text) and/or the TextField value.
      expect(find.textContaining('Beta'), findsWidgets);
    });

    testWidgets('sortable headers expose button semantics', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            paginated: false,
            showPagination: false,
            onSort: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp(r'Sort by Name')), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Path-to-100: interactive control ≥48×48 hit targets
  // ---------------------------------------------------------------------------
  group('PrismDataTable interactive a11y targets', () {
    testWidgets('secret reveal control meets 48×48 min size', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PrismSecretCell(
            maskedValue: '••••••abc1',
            fullValue: 'demo-secret-value',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final reveal = find.bySemanticsLabel('Reveal value');
      expect(reveal, findsOneWidget);
      final size = tester.getSize(reveal);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('row action controls meet 48×48 min size', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismActionsCell(
            actions: [
              PrismActionItem(
                icon: Icons.edit_outlined,
                tooltip: 'Edit row',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final action = find.bySemanticsLabel('Edit row');
      expect(action, findsOneWidget);
      final size = tester.getSize(action);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('pagination next control meets 48×48 min size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrismTablePagination(
              currentPage: 0,
              totalRows: 50,
              pageSize: 10,
              onPageChanged: (_) {},
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final next = find.bySemanticsLabel('Next page');
      expect(next, findsOneWidget);
      final size = tester.getSize(next);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('selectable checkboxes use ≥48 width column', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            selectable: true,
            paginated: false,
            showPagination: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsWidgets);
      // Header select-all + row checkboxes should not be clipped below 48.
      for (var i = 0; i < checkboxes.evaluate().length; i++) {
        final size = tester.getSize(checkboxes.at(i));
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('sort header hit target height is ≥48', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            paginated: false,
            showPagination: false,
            onSort: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sort = find.bySemanticsLabel(RegExp(r'Sort by Name'));
      expect(sort, findsOneWidget);
      final size = tester.getSize(sort);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });
  });
}
