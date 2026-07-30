import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';
import '../virtual_scroll/virtual_scroll.dart';

// ============================================================================
// SORT STATE
// ============================================================================

/// Sort direction for table columns.
enum DSSortDirection { ascending, descending }

/// Current sort state of the table.
class DSSortState {
  /// The column id being sorted.
  final String columnId;

  /// The sort direction.
  final DSSortDirection direction;

  const DSSortState({
    required this.columnId,
    this.direction = DSSortDirection.ascending,
  });

  /// Returns a copy with toggled direction.
  DSSortState toggle() => DSSortState(
    columnId: columnId,
    direction: direction == DSSortDirection.ascending
        ? DSSortDirection.descending
        : DSSortDirection.ascending,
  );
}

// ============================================================================
// COLUMN DEFINITION
// ============================================================================

/// Cell renderer callback — receives the cell value and row index.
typedef DSCellRenderer =
    Widget Function(BuildContext context, dynamic value, int rowIndex);

/// Column configuration for [DSDataTable].
class DSDataColumn {
  /// Unique column identifier (must match keys in row cell maps).
  final String id;

  /// Display label for the column header.
  final String label;

  /// Whether this column supports sorting.
  final bool sortable;

  /// Whether this column is currently visible.
  final bool visible;

  /// Optional fixed width. If null, the column flexes.
  final double? width;

  /// Optional alignment for cell content.
  final TextAlign? textAlign;

  /// Custom cell renderer. If null, renders as [DSText.bodyMedium].
  final DSCellRenderer? cellRenderer;

  const DSDataColumn({
    required this.id,
    required this.label,
    this.sortable = false,
    this.visible = true,
    this.width,
    this.textAlign,
    this.cellRenderer,
  });

  /// Copy with visibility toggle.
  DSDataColumn copyWith({bool? visible}) => DSDataColumn(
    id: id,
    label: label,
    sortable: sortable,
    visible: visible ?? this.visible,
    width: width,
    textAlign: textAlign,
    cellRenderer: cellRenderer,
  );
}

// ============================================================================
// ROW DATA
// ============================================================================

/// Row data for [DSDataTable].
class DSDataRow {
  /// Unique row identifier.
  final String id;

  /// Cell values keyed by column id.
  final Map<String, dynamic> cells;

  /// Whether this row is currently selected.
  final bool selected;

  /// Whether this row is selectable.
  final bool selectable;

  /// Optional tap callback for the entire row.
  final VoidCallback? onTap;

  const DSDataRow({
    required this.id,
    required this.cells,
    this.selected = false,
    this.selectable = true,
    this.onTap,
  });
}

// ============================================================================
// CELL RENDERERS
// ============================================================================

/// Renders an [DSOperationalState] as a status dot + label.
class DSStatusCell extends StatelessWidget {
  final DSOperationalState state;

  const DSStatusCell({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: state.semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSStatusDot(color: state.color, tooltip: state.label),
          const SizedBox(width: DSSpacing.xs),
          Flexible(child: DSText.labelSmall(state.label, color: state.color)),
        ],
      ),
    );
  }
}

/// Renders a value as a badge.
class DSBadgeCell extends StatelessWidget {
  final String text;
  final Color color;

  const DSBadgeCell({
    super.key,
    required this.text,
    this.color = DSColors.accentCyan,
  });

  @override
  Widget build(BuildContext context) {
    return DSBadge.count(int.tryParse(text) ?? 0, color: color);
  }
}

/// Renders a timestamp in monospace.
class DSTimestampCell extends StatelessWidget {
  final String timestamp;

  const DSTimestampCell({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return DSText(
      timestamp,
      variant: DSTextVariant.numericSmall,
      color: DSColors.textTertiary,
    );
  }
}

/// Renders a secret/masked value with reveal toggle.
class DSSecretCell extends StatefulWidget {
  final String maskedValue;
  final String? fullValue;

  const DSSecretCell({super.key, required this.maskedValue, this.fullValue});

  @override
  State<DSSecretCell> createState() => _DSSecretCellState();
}

class _DSSecretCellState extends State<DSSecretCell> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DSText(
          _revealed
              ? (widget.fullValue ?? widget.maskedValue)
              : widget.maskedValue,
          variant: DSTextVariant.codeSmall,
          color: _revealed ? DSColors.statusRedacted : DSColors.textTertiary,
        ),
        if (widget.fullValue != null) ...[
          const SizedBox(width: DSSpacing.xs),
          // Single a11y node: Semantics owns the label; exclude IconButton subtree.
          Semantics(
            button: true,
            label: _revealed ? 'Hide value' : 'Reveal value',
            excludeSemantics: true,
            child: SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: IconButton(
                onPressed: () => setState(() => _revealed = !_revealed),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: kMinInteractiveDimension,
                  minHeight: kMinInteractiveDimension,
                ),
                splashRadius: kMinInteractiveDimension / 2,
                tooltip: _revealed ? 'Hide value' : 'Reveal value',
                icon: Icon(
                  _revealed
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                  color: DSColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Renders action buttons for a row.
class DSActionsCell extends StatelessWidget {
  final List<DSActionItem> actions;

  const DSActionsCell({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(left: DSSpacing.xs),
          child: Semantics(
            button: true,
            label: action.tooltip,
            excludeSemantics: true,
            child: SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: IconButton(
                onPressed: action.onTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: kMinInteractiveDimension,
                  minHeight: kMinInteractiveDimension,
                ),
                splashRadius: kMinInteractiveDimension / 2,
                tooltip: action.tooltip,
                icon: Icon(
                  action.icon,
                  size: 16,
                  color: action.color ?? DSColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Action item configuration for [DSActionsCell].
class DSActionItem {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? color;

  const DSActionItem({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.color,
  });
}

// ============================================================================
// PAGINATION CONTROLS
// ============================================================================

/// Pagination controls for [DSDataTable].
class DSTablePagination extends StatelessWidget {
  /// Current page (0-indexed).
  final int currentPage;

  /// Total number of rows.
  final int totalRows;

  /// Rows per page.
  final int pageSize;

  /// Available page sizes for the dropdown.
  final List<int> pageSizes;

  /// Callback when page changes.
  final ValueChanged<int> onPageChanged;

  /// Callback when page size changes.
  final ValueChanged<int> onPageSizeChanged;

  const DSTablePagination({
    super.key,
    required this.currentPage,
    required this.totalRows,
    required this.pageSize,
    this.pageSizes = const [10, 25, 50, 100],
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  int get totalPages => totalRows == 0 ? 1 : (totalRows / pageSize).ceil();

  int get startRow => totalRows == 0 ? 0 : currentPage * pageSize + 1;

  int get endRow => ((currentPage + 1) * pageSize).clamp(0, totalRows);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Table pagination, page ${currentPage + 1} of $totalPages',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Row count
            DSText.bodySmall(
              '$startRow–$endRow of $totalRows',
              color: DSColors.textTertiary,
            ),
            const Spacer(),
            // Page size selector
            const DSText.labelSmall('Rows:', color: DSColors.textTertiary),
            const SizedBox(width: DSSpacing.xs),
            _PageSizeDropdown(
              pageSize: pageSize,
              pageSizes: pageSizes,
              onChanged: onPageSizeChanged,
            ),
            const SizedBox(width: DSSpacing.lg),
            // Page navigation
            _PageButton(
              icon: Icons.chevron_left,
              enabled: currentPage > 0,
              onTap: () => onPageChanged(currentPage - 1),
              semanticLabel: 'Previous page',
            ),
            const SizedBox(width: DSSpacing.xs),
            DSText.labelMedium(
              '${currentPage + 1} / $totalPages',
              color: DSColors.textSecondary,
            ),
            const SizedBox(width: DSSpacing.xs),
            _PageButton(
              icon: Icons.chevron_right,
              enabled: currentPage < totalPages - 1,
              onTap: () => onPageChanged(currentPage + 1),
              semanticLabel: 'Next page',
            ),
          ],
        ),
      ),
    );
  }
}

class _PageSizeDropdown extends StatelessWidget {
  final int pageSize;
  final List<int> pageSizes;
  final ValueChanged<int> onChanged;

  const _PageSizeDropdown({
    required this.pageSize,
    required this.pageSizes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(color: DSColors.borderSubtle),
      ),
      child: DropdownButton<int>(
        value: pageSize,
        underline: const SizedBox.shrink(),
        isDense: true,
        dropdownColor: DSColors.obsidianElevated,
        style: DSTypography.labelSmall.copyWith(color: DSColors.textSecondary),
        items: pageSizes
            .map((s) => DropdownMenuItem(value: s, child: Text('$s')))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
  final String semanticLabel;

  const _PageButton({
    required this.icon,
    required this.enabled,
    this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: enabled,
      excludeSemantics: true,
      child: SizedBox(
        width: kMinInteractiveDimension,
        height: kMinInteractiveDimension,
        child: IconButton(
          onPressed: enabled ? onTap : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: kMinInteractiveDimension,
            minHeight: kMinInteractiveDimension,
          ),
          splashRadius: kMinInteractiveDimension / 2,
          tooltip: semanticLabel,
          icon: Icon(
            icon,
            size: 18,
            color: enabled ? DSColors.textSecondary : DSColors.textDisabled,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TABLE HEADER
// ============================================================================

class _DSTableHeader extends StatelessWidget {
  final List<DSDataColumn> columns;
  final DSSortState? sortState;
  final ValueChanged<String>? onSort;
  final bool selectable;
  final bool allSelected;
  final ValueChanged<bool?>? onSelectAll;
  final void Function(String, bool)? onToggleColumn;

  const _DSTableHeader({
    required this.columns,
    this.sortState,
    this.onSort,
    this.selectable = false,
    this.allSelected = false,
    this.onSelectAll,
    this.onToggleColumn,
  });

  @override
  Widget build(BuildContext context) {
    final visibleColumns = columns.where((c) => c.visible).toList();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: DSColors.obsidianElevated,
        border: Border(
          bottom: BorderSide(color: DSColors.borderDefault, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Select-all checkbox — WCAG 48×48 min interactive target.
          if (selectable) ...[
            SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: Checkbox(
                value: allSelected,
                onChanged: onSelectAll,
                activeColor: DSColors.accentCyan,
                side: const BorderSide(color: DSColors.borderDefault),
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
            ),
          ],
          // Column headers
          for (int i = 0; i < visibleColumns.length; i++) ...[
            if (i > 0) const SizedBox(width: DSSpacing.md),
            _ColumnHeaderCell(
              column: visibleColumns[i],
              sortState: sortState,
              onSort: onSort,
            ),
          ],
          // Column visibility menu
          if (onToggleColumn != null) ...[
            const Spacer(),
            _ColumnVisibilityMenu(columns: columns, onToggle: onToggleColumn!),
          ],
        ],
      ),
    );
  }
}

class _ColumnHeaderCell extends StatelessWidget {
  final DSDataColumn column;
  final DSSortState? sortState;
  final ValueChanged<String>? onSort;

  const _ColumnHeaderCell({required this.column, this.sortState, this.onSort});

  @override
  Widget build(BuildContext context) {
    final isSorted = sortState?.columnId == column.id;
    final isAscending =
        isSorted && sortState?.direction == DSSortDirection.ascending;
    final isDescending =
        isSorted && sortState?.direction == DSSortDirection.descending;

    Widget label = DSText.labelMedium(
      column.label,
      color: DSColors.textSecondary,
    );

    if (column.width != null) {
      return SizedBox(
        width: column.width,
        child: _buildHeaderContent(label, isSorted, isAscending, isDescending),
      );
    }

    return Expanded(
      child: _buildHeaderContent(label, isSorted, isAscending, isDescending),
    );
  }

  Widget _buildHeaderContent(
    Widget label,
    bool isSorted,
    bool isAscending,
    bool isDescending,
  ) {
    if (!column.sortable) {
      return label;
    }

    final sortHint = isAscending
        ? 'sorted ascending'
        : isDescending
        ? 'sorted descending'
        : 'not sorted';
    return Semantics(
      button: true,
      label: 'Sort by ${column.label}, $sortHint',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => onSort?.call(column.id),
          borderRadius: BorderRadius.circular(DSRadii.sm),
          focusColor: DSColors.accentCyan.withValues(alpha: 0.12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                label,
                const SizedBox(width: DSSpacing.xs),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_drop_up,
                      size: 14,
                      color: isAscending
                          ? DSColors.accentCyan
                          : DSColors.textDisabled,
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 14,
                      color: isDescending
                          ? DSColors.accentCyan
                          : DSColors.textDisabled,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColumnVisibilityMenu extends StatelessWidget {
  final List<DSDataColumn> columns;
  final void Function(String id, bool visible) onToggle;

  const _ColumnVisibilityMenu({required this.columns, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const DSIcon.small(
        Icons.view_column_outlined,
        color: DSColors.textTertiary,
        semanticLabel: 'Column visibility',
      ),
      tooltip: 'Toggle columns',
      color: DSColors.obsidianElevated,
      onSelected: (id) {
        final col = columns.firstWhere((c) => c.id == id);
        onToggle(id, !col.visible);
      },
      itemBuilder: (context) => columns.map((col) {
        return CheckedPopupMenuItem<String>(
          value: col.id,
          checked: col.visible,
          child: DSText.bodySmall(col.label, color: DSColors.textPrimary),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// TABLE ROW
// ============================================================================

class _DSTableRow extends StatelessWidget {
  final DSDataRow row;
  final List<DSDataColumn> columns;
  final int rowIndex;
  final bool selectable;
  final ValueChanged<bool?>? onSelect;
  final bool isHovered;

  const _DSTableRow({
    required this.row,
    required this.columns,
    required this.rowIndex,
    this.selectable = false,
    this.onSelect,
    this.isHovered = false,
  });

  @override
  Widget build(BuildContext context) {
    final visibleColumns = columns.where((c) => c.visible).toList();

    // Row tap uses Semantics+InkWell (not bare GestureDetector) for a11y.
    final rowBody = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: row.selected
            ? DSColors.accentCyan.withValues(alpha: 0.05)
            : isHovered
            ? DSColors.obsidianHover
            : DSColors.transparent,
        border: const Border(
          bottom: BorderSide(color: DSColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Selection checkbox — WCAG 48×48 min interactive target.
          if (selectable) ...[
            SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: Checkbox(
                value: row.selected,
                onChanged: onSelect,
                activeColor: DSColors.accentCyan,
                side: const BorderSide(color: DSColors.borderDefault),
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
            ),
          ],
          // Cell values
          for (int i = 0; i < visibleColumns.length; i++) ...[
            if (i > 0) const SizedBox(width: DSSpacing.md),
            _buildCell(context, visibleColumns[i]),
          ],
        ],
      ),
    );

    if (row.onTap == null) {
      return rowBody;
    }

    return Semantics(
      button: true,
      label: 'Select table row',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: row.onTap,
          mouseCursor: SystemMouseCursors.click,
          child: rowBody,
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, DSDataColumn column) {
    final value = row.cells[column.id];

    Widget cell;
    if (column.cellRenderer != null) {
      cell = column.cellRenderer!.call(context, value, rowIndex);
    } else {
      cell = _defaultRenderer(value, column);
    }

    if (column.width != null) {
      return SizedBox(width: column.width, child: cell);
    }

    return Expanded(child: cell);
  }

  Widget _defaultRenderer(dynamic value, DSDataColumn column) {
    final text = value?.toString() ?? '';

    return DSText.bodyMedium(text, color: DSColors.textPrimary);
  }
}

// ============================================================================
// VIRTUALIZED ROW WRAPPER (hover state)
// ============================================================================

class _VirtualRow extends StatefulWidget {
  final DSDataRow row;
  final List<DSDataColumn> columns;
  final int rowIndex;
  final bool selectable;
  final ValueChanged<bool?>? onSelect;

  const _VirtualRow({
    super.key,
    required this.row,
    required this.columns,
    required this.rowIndex,
    this.selectable = false,
    this.onSelect,
  });

  @override
  State<_VirtualRow> createState() => _VirtualRowState();
}

class _VirtualRowState extends State<_VirtualRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: _DSTableRow(
        row: widget.row,
        columns: widget.columns,
        rowIndex: widget.rowIndex,
        selectable: widget.selectable,
        onSelect: widget.onSelect,
        isHovered: _hovered,
      ),
    );
  }
}

// ============================================================================
// LOADING SKELETON
// ============================================================================

class _TableSkeleton extends StatelessWidget {
  final List<DSDataColumn> columns;
  final bool selectable;

  const _TableSkeleton({required this.columns, this.selectable = false});

  @override
  Widget build(BuildContext context) {
    final visibleColumns = columns.where((c) => c.visible).toList();

    return Column(
      children: [
        // Skeleton header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: DSColors.obsidianElevated,
            border: Border(
              bottom: BorderSide(color: DSColors.borderDefault, width: 1),
            ),
          ),
          child: Row(
            children: [
              if (selectable)
                const SizedBox(width: kMinInteractiveDimension),
              for (int i = 0; i < visibleColumns.length; i++) ...[
                if (i > 0) const SizedBox(width: DSSpacing.md),
                _skeletonBar(80, 14),
              ],
            ],
          ),
        ),
        // Skeleton rows
        for (int r = 0; r < 5; r++)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.md,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: DSColors.borderSubtle, width: 1),
              ),
            ),
            child: Row(
              children: [
                if (selectable)
                  const SizedBox(width: kMinInteractiveDimension),
                for (int i = 0; i < visibleColumns.length; i++) ...[
                  if (i > 0) const SizedBox(width: DSSpacing.md),
                  _skeletonBar(visibleColumns[i].width ?? 120, 14),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _skeletonBar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DSColors.obsidianHover,
        borderRadius: BorderRadius.circular(DSRadii.xs),
      ),
    );
  }
}

// ============================================================================
// MAIN TABLE WIDGET
// ============================================================================

/// A reusable, sortable, filterable, paginated data table organism for the
/// Warp Prism design system.
///
/// Supports:
/// - Sortable columns with ascending/descending toggle
/// - Column visibility configuration
/// - Row selection (single and multi)
/// - Custom cell renderers for operational states, badges, timestamps, secrets, actions
/// - Pagination with configurable page sizes
/// - Virtualized rendering for large datasets via [ListView.builder]
/// - Empty, loading, and error state handling via [DSStateSurface]
/// - Glass-panel aesthetic consistent with existing DS
///
/// ## State Matrix
///
/// | State | Visual Treatment | Color Source | Behavior |
/// |-------|-----------------|--------------|----------|
/// | empty | DSStateSurface.empty centered | textTertiary | No action |
/// | loading | Skeleton rows | accentCyan | Pulse indicator |
/// | error | DSStateSurface.error centered | statusError | Retry button |
/// | data | Virtualized row list | - | Sort/filter/select |
class DSDataTable extends StatefulWidget {
  /// Column definitions.
  final List<DSDataColumn> columns;

  /// Row data.
  final List<DSDataRow> rows;

  /// Current sort state. If null, no column is sorted.
  final DSSortState? sortState;

  /// Callback when a column header is tapped for sorting.
  final ValueChanged<String>? onSort;

  /// Whether rows are selectable.
  final bool selectable;

  /// Callback when selected rows change.
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// Current page (0-indexed).
  final int currentPage;

  /// Rows per page.
  final int pageSize;

  /// Available page sizes.
  final List<int> pageSizes;

  /// Callback when page changes.
  final ValueChanged<int>? onPageChanged;

  /// Callback when page size changes.
  final ValueChanged<int>? onPageSizeChanged;

  /// Whether the table is in loading state.
  final bool loading;

  /// Error message to display (if non-null).
  final String? errorMessage;

  /// Callback for retry action.
  final VoidCallback? onRetry;

  /// Widget displayed above the table (e.g., search bar, filter chips).
  final Widget? toolbar;

  /// Whether to show pagination controls.
  final bool showPagination;

  /// Whether to use paginated mode (false = virtual scroll all rows).
  final bool paginated;

  /// Optional column visibility toggle callback.
  final void Function(String columnId, bool visible)? onToggleColumn;

  /// Optional virtual scroll configuration for the table body.
  ///
  /// When provided and [paginated] is false, the table body renders using
  /// [DSVirtualList] with this configuration. This enables O(1) scroll
  /// offset computation for fixed-height rows at 10K+ item scale.
  ///
  /// If null, the table falls back to a plain [ListView.builder].
  final DSVirtualScrollConfig? virtualScrollConfig;

  const DSDataTable({
    super.key,
    required this.columns,
    this.rows = const [],
    this.sortState,
    this.onSort,
    this.selectable = false,
    this.onSelectionChanged,
    this.currentPage = 0,
    this.pageSize = 25,
    this.pageSizes = const [10, 25, 50, 100],
    this.onPageChanged,
    this.onPageSizeChanged,
    this.loading = false,
    this.errorMessage,
    this.onRetry,
    this.toolbar,
    this.showPagination = true,
    this.paginated = true,
    this.onToggleColumn,
    this.virtualScrollConfig,
  });

  @override
  State<DSDataTable> createState() => _DSDataTableState();
}

class _DSDataTableState extends State<DSDataTable> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.rows
        .where((r) => r.selected)
        .map((r) => r.id)
        .toSet();
  }

  @override
  void didUpdateWidget(DSDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows) {
      _selectedIds = widget.rows
          .where((r) => r.selected)
          .map((r) => r.id)
          .toSet();
    }
  }

  void _toggleSelection(String rowId) {
    setState(() {
      if (_selectedIds.contains(rowId)) {
        _selectedIds.remove(rowId);
      } else {
        _selectedIds.add(rowId);
      }
    });
    widget.onSelectionChanged?.call(_selectedIds);
  }

  void _toggleSelectAll(bool? value) {
    final visibleRows = _visibleRows;
    setState(() {
      if (value == true) {
        _selectedIds.addAll(visibleRows.map((r) => r.id));
      } else {
        _selectedIds.removeAll(visibleRows.map((r) => r.id));
      }
    });
    widget.onSelectionChanged?.call(_selectedIds);
  }

  List<DSDataRow> get _visibleRows {
    if (!widget.paginated) return widget.rows;
    final start = widget.currentPage * widget.pageSize;
    final end = (start + widget.pageSize).clamp(0, widget.rows.length);
    if (start >= widget.rows.length) return [];
    return widget.rows.sublist(start, end);
  }

  bool get _allSelected {
    if (_visibleRows.isEmpty) return false;
    return _visibleRows.every((r) => _selectedIds.contains(r.id));
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Data table with ${widget.columns.where((c) => c.visible).length} columns'
          '${widget.rows.isNotEmpty ? ' and ${widget.rows.length} rows' : ''}',
      child: DSGlassPanelSimple(
        padding: EdgeInsets.zero,
        borderColor: DSColors.borderDefault,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toolbar
            if (widget.toolbar != null) ...[
              Padding(
                padding: const EdgeInsets.all(DSSpacing.md),
                child: widget.toolbar!,
              ),
            ],
            // Content
            if (widget.loading)
              _TableSkeleton(
                columns: widget.columns,
                selectable: widget.selectable,
              )
            else if (widget.errorMessage != null)
              DSStateSurface.error(
                title: 'Failed to load data',
                subtitle: widget.errorMessage,
                onAction: widget.onRetry,
                compact: true,
              )
            else if (widget.rows.isEmpty)
              const DSStateSurface.empty(
                title: 'No data',
                subtitle: 'No records match the current filters',
                compact: true,
              )
            else ...[
              // Header
              _DSTableHeader(
                columns: widget.columns,
                sortState: widget.sortState,
                onSort: widget.onSort,
                selectable: widget.selectable,
                allSelected: _allSelected,
                onSelectAll: _toggleSelectAll,
                onToggleColumn: widget.onToggleColumn,
              ),
              // Body — virtual scroll or paginated list
              Flexible(child: _buildBody()),
              // Pagination
              if (widget.showPagination)
                DSTablePagination(
                  currentPage: widget.currentPage,
                  totalRows: widget.rows.length,
                  pageSize: widget.pageSize,
                  pageSizes: widget.pageSizes,
                  onPageChanged: widget.onPageChanged ?? (_) {},
                  onPageSizeChanged: widget.onPageSizeChanged ?? (_) {},
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final rows = _visibleRows;

    // Use DSVirtualList when virtualScrollConfig is provided for
    // optimized rendering at 10K+ item scale.
    if (widget.virtualScrollConfig != null) {
      return DSVirtualList(
        itemCount: rows.length,
        config: widget.virtualScrollConfig!,
        semanticLabel: 'Table body, ${rows.length} rows',
        itemBuilder: (context, index) {
          final row = rows[index];
          return _VirtualRow(
            key: ValueKey(row.id),
            row: row.copyWith(selected: _selectedIds.contains(row.id)),
            columns: widget.columns,
            rowIndex: index,
            selectable: widget.selectable,
            onSelect: (_) => _toggleSelection(row.id),
          );
        },
      );
    }

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return _VirtualRow(
          key: ValueKey(row.id),
          row: row.copyWith(selected: _selectedIds.contains(row.id)),
          columns: widget.columns,
          rowIndex: index,
          selectable: widget.selectable,
          onSelect: (_) => _toggleSelection(row.id),
        );
      },
    );
  }
}

/// Extension on [DSDataRow] to support copyWith.
extension _DSDataRowCopyWith on DSDataRow {
  DSDataRow copyWith({bool? selected}) => DSDataRow(
    id: id,
    cells: cells,
    selected: selected ?? this.selected,
    selectable: selectable,
    onTap: onTap,
  );
}
