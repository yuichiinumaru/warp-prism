// Golden tests for DSDataTable — renders data table organism with deterministic
// columns and rows.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_data_table_golden_test.dart
//   flutter test test/goldens/ds_data_table_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/data_table/ds_data_table.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: child),
    ),
  );
}

/// Deterministic column definitions for golden testing.
List<DSDataColumn> _testColumns() {
  return const [
    DSDataColumn(id: 'name', label: 'Name', width: 120),
    DSDataColumn(id: 'status', label: 'Status', width: 100),
    DSDataColumn(id: 'count', label: 'Count', width: 80),
  ];
}

/// Deterministic row data for golden testing.
List<DSDataRow> _testRows() {
  return const [
    DSDataRow(
      id: 'row-1',
      cells: {'name': 'Alpha', 'status': 'Active', 'count': '42'},
    ),
    DSDataRow(
      id: 'row-2',
      cells: {'name': 'Beta', 'status': 'Idle', 'count': '17'},
    ),
    DSDataRow(
      id: 'row-3',
      cells: {'name': 'Gamma', 'status': 'Offline', 'count': '0'},
    ),
  ];
}

void main() {
  group('DSDataTable golden — default state', () {
    testWidgets('renders default DSDataTable with 3 columns and 3 rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        _inApp(
          SizedBox(
            width: 400,
            height: 300,
            child: DSDataTable(
              columns: _testColumns(),
              rows: _testRows(),
              showPagination: false,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(DSDataTable),
        matchesGoldenFile('goldens/data_table_default.png'),
      );
    });
  });
}
