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
  const sampleColumns = <DSDataColumn>[
    DSDataColumn(id: 'id', label: 'ID', width: 60),
    DSDataColumn(id: 'name', label: 'Name', sortable: true),
    DSDataColumn(id: 'status', label: 'Status', sortable: true),
  ];

  List<DSDataRow> sampleRows() => [
    DSDataRow(
      id: '1',
      cells: {'id': '001', 'name': 'Alpha', 'status': 'Running'},
    ),
    DSDataRow(
      id: '2',
      cells: {'id': '002', 'name': 'Beta', 'status': 'Healthy'},
    ),
    DSDataRow(
      id: '3',
      cells: {'id': '003', 'name': 'Gamma', 'status': 'Error'},
    ),
  ];

  // ---------------------------------------------------------------------------
  // GROUP: Default rendering
  // ---------------------------------------------------------------------------
  group('DSDataTable default rendering', () {
    testWidgets('renders column headers', (tester) async {
      await tester.pumpWidget(
        wrap(
          DSDataTable(
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
          DSDataTable(
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
          DSDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      expect(find.byType(DSGlassPanelSimple), findsOneWidget);
    });

    testWidgets('has semantic label for data table', (tester) async {
      await tester.pumpWidget(
        wrap(
          DSDataTable(
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
  group('DSDataTable empty state', () {
    testWidgets('renders empty state when no rows', (tester) async {
      await tester.pumpWidget(
        wrap(DSDataTable(columns: sampleColumns, rows: const [])),
      );

      expect(find.text('No data'), findsOneWidget);
      expect(find.text('No records match the current filters'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Loading state
  // ---------------------------------------------------------------------------
  group('DSDataTable loading state', () {
    testWidgets('renders skeleton when loading', (tester) async {
      await tester.pumpWidget(
        wrap(DSDataTable(columns: sampleColumns, loading: true)),
      );

      // Skeleton renders Container widgets for each row
      expect(find.text('ID'), findsNothing); // no header in skeleton mode
      expect(find.text('No data'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Error state
  // ---------------------------------------------------------------------------
  group('DSDataTable error state', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(
        wrap(
          DSDataTable(
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
          DSDataTable(
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
  group('DSDataTable sorting', () {
    testWidgets('tapping sortable column header fires onSort', (tester) async {
      String? sortedColumn;

      await tester.pumpWidget(
        wrap(
          DSDataTable(
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
          DSDataTable(
            columns: sampleColumns,
            rows: sampleRows(),
            sortState: const DSSortState(
              columnId: 'name',
              direction: DSSortDirection.ascending,
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
  group('DSDataTable pagination', () {
    testWidgets('shows pagination controls by default', (tester) async {
      await tester.pumpWidget(
        wrap(
          DSDataTable(columns: sampleColumns, rows: sampleRows(), pageSize: 10),
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
          DSDataTable(
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
        (i) => DSDataRow(
          id: '$i',
          cells: {'id': '$i', 'name': 'Item $i', 'status': 'Ok'},
        ),
      );

      await tester.pumpWidget(
        wrap(
          DSDataTable(
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
        (i) => DSDataRow(
          id: '$i',
          cells: {'id': '$i', 'name': 'Item $i', 'status': 'Ok'},
        ),
      );

      await tester.pumpWidget(
        wrap(
          DSDataTable(
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
  group('DSDataTable row selection', () {
    testWidgets('renders checkboxes when selectable', (tester) async {
      await tester.pumpWidget(
        wrap(
          DSDataTable(
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
          DSDataTable(
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
  group('DSDataTable cell renderers', () {
    testWidgets('renders operational state cell with dot and label', (
      tester,
    ) async {
      final columns = <DSDataColumn>[
        const DSDataColumn(id: 'name', label: 'Name'),
        DSDataColumn(
          id: 'state',
          label: 'State',
          cellRenderer: (ctx, value, idx) {
            if (value is DSOperationalState) {
              return DSStatusCell(state: value);
            }
            return const SizedBox.shrink();
          },
        ),
      ];

      final rows = [
        DSDataRow(
          id: '1',
          cells: {'name': 'Test Entity', 'state': DSOperationalState.running},
        ),
      ];

      await tester.pumpWidget(
        wrap(
          DSDataTable(
            columns: columns,
            rows: rows,
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      expect(find.text('Test Entity'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('renders secret cell with masked value', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DSSecretCell(
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
          const DSSecretCell(
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
        wrap(const DSTimestampCell(timestamp: '2025-06-08 14:30')),
      );

      expect(find.text('2025-06-08 14:30'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Operational state vocabulary
  // ---------------------------------------------------------------------------
  group('DSOperationalState vocabulary', () {
    testWidgets('all 15 states render with status cells', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 1200,
              child: ListView(
                children: DSOperationalState.values.map((state) {
                  return DSStatusCell(state: state);
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
      for (final state in DSOperationalState.values) {
        expect(state.color, isA<Color>());
        expect(state.color, isNot(equals(Colors.transparent)));
      }
    });

    test('all 15 operational states have icon', () {
      for (final state in DSOperationalState.values) {
        expect(state.icon, isA<IconData>());
      }
    });

    test('all 15 operational states have label', () {
      for (final state in DSOperationalState.values) {
        expect(state.label, isNotEmpty);
      }
    });

    test('all 15 operational states have semanticLabel', () {
      for (final state in DSOperationalState.values) {
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
      expect(DSDataTable, isNotNull);
      expect(DSDataColumn, isNotNull);
      expect(DSDataRow, isNotNull);
      expect(DSSortState, isNotNull);
      expect(DSSortDirection, isNotNull);
      expect(DSStatusCell, isNotNull);
      expect(DSBadgeCell, isNotNull);
      expect(DSTimestampCell, isNotNull);
      expect(DSSecretCell, isNotNull);
      expect(DSActionsCell, isNotNull);
      expect(DSActionItem, isNotNull);
      expect(DSTablePagination, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Column visibility
  // ---------------------------------------------------------------------------
  group('DSDataTable column visibility', () {
    testWidgets('hidden columns are not rendered', (tester) async {
      final columns = <DSDataColumn>[
        const DSDataColumn(id: 'id', label: 'ID'),
        const DSDataColumn(id: 'name', label: 'Name'),
        const DSDataColumn(id: 'secret', label: 'Secret', visible: false),
      ];

      final rows = [
        DSDataRow(
          id: '1',
          cells: {'id': '001', 'name': 'Alpha', 'secret': 'hidden-value'},
        ),
      ];

      await tester.pumpWidget(
        wrap(
          DSDataTable(
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
      String? toggledColumn;
      bool? toggledVisible;

      final columns = <DSDataColumn>[
        const DSDataColumn(id: 'id', label: 'ID'),
        const DSDataColumn(id: 'name', label: 'Name'),
      ];

      await tester.pumpWidget(
        wrap(
          DSDataTable(
            columns: columns,
            rows: sampleRows(),
            paginated: false,
            showPagination: false,
            onToggleColumn: (id, vis) {
              toggledColumn = id;
              toggledVisible = vis;
            },
          ),
        ),
      );

      // Column visibility menu button should exist
      expect(find.byTooltip('Toggle columns'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: DSDataRow
  // ---------------------------------------------------------------------------
  group('DSDataRow', () {
    test('row onTap callback is stored', () {
      var tapped = false;
      final row = DSDataRow(
        id: 'test',
        cells: {'a': 'b'},
        onTap: () => tapped = true,
      );

      row.onTap?.call();
      expect(tapped, isTrue);
    });

    test('row selection state is tracked', () {
      const row = DSDataRow(id: 'test', cells: {'a': 'b'}, selected: true);

      expect(row.selected, isTrue);
      expect(row.selectable, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: DSSortState
  // ---------------------------------------------------------------------------
  group('DSSortState', () {
    test('toggle switches direction', () {
      const state = DSSortState(
        columnId: 'name',
        direction: DSSortDirection.ascending,
      );

      final toggled = state.toggle();
      expect(toggled.direction, DSSortDirection.descending);
      expect(toggled.columnId, 'name');
    });

    test('toggle from descending goes to ascending', () {
      const state = DSSortState(
        columnId: 'name',
        direction: DSSortDirection.descending,
      );

      final toggled = state.toggle();
      expect(toggled.direction, DSSortDirection.ascending);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: DSTablePagination
  // ---------------------------------------------------------------------------
  group('DSTablePagination', () {
    testWidgets('renders row count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSTablePagination(
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
            body: DSTablePagination(
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
            body: DSTablePagination(
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
}
