import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';

/// Immutable model for a single provider-health matrix cell.
///
/// Contract:
/// - [id] stable within a matrix (selection key).
/// - [providerId] / [providerLabel] identify the provider axis.
/// - [dimensionId] / [dimensionLabel] identify the optional account/model axis.
/// - [operationalState] uses the canonical [DSOperationalState] vocabulary.
/// - [latency] optional round-trip for the cell (fixture ms).
/// - No network, no live provider pings, no API keys.
@immutable
class DSProviderHealthCell {
  /// Stable unique id within a matrix.
  final String id;

  /// Provider axis key (e.g. `openai`).
  final String providerId;

  /// Human-readable provider name (e.g. `OpenAI`).
  final String providerLabel;

  /// Dimension axis key (account, model, or region).
  final String dimensionId;

  /// Human-readable dimension label (e.g. `main-prod`, `gpt-4o`).
  final String dimensionLabel;

  /// Current operational health state.
  final DSOperationalState operationalState;

  /// Optional response latency for this cell.
  final Duration? latency;

  /// Optional tertiary meta (region, quota band, etc.).
  final String? meta;

  const DSProviderHealthCell({
    required this.id,
    required this.providerId,
    required this.providerLabel,
    required this.dimensionId,
    required this.dimensionLabel,
    required this.operationalState,
    this.latency,
    this.meta,
  });

  /// Formatted latency for cell display (null when unset).
  String? get latencyLabel {
    final d = latency;
    if (d == null) return null;
    if (d.inMilliseconds < 1000) return '${d.inMilliseconds}ms';
    final seconds = d.inMilliseconds / 1000.0;
    return '${seconds.toStringAsFixed(seconds >= 10 ? 0 : 1)}s';
  }

  /// Screen-reader label: provider + dimension + state (+ latency).
  String get semanticLabel {
    final buf = StringBuffer(
      '$providerLabel $dimensionLabel: ${operationalState.label}',
    );
    final lat = latencyLabel;
    if (lat != null) buf.write(', $lat');
    if (meta != null && meta!.isNotEmpty) buf.write(', $meta');
    return buf.toString();
  }

  DSProviderHealthCell copyWith({
    String? id,
    String? providerId,
    String? providerLabel,
    String? dimensionId,
    String? dimensionLabel,
    DSOperationalState? operationalState,
    Duration? latency,
    String? meta,
  }) {
    return DSProviderHealthCell(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerLabel: providerLabel ?? this.providerLabel,
      dimensionId: dimensionId ?? this.dimensionId,
      dimensionLabel: dimensionLabel ?? this.dimensionLabel,
      operationalState: operationalState ?? this.operationalState,
      latency: latency ?? this.latency,
      meta: meta ?? this.meta,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSProviderHealthCell &&
        other.id == id &&
        other.providerId == providerId &&
        other.providerLabel == providerLabel &&
        other.dimensionId == dimensionId &&
        other.dimensionLabel == dimensionLabel &&
        other.operationalState == operationalState &&
        other.latency == latency &&
        other.meta == meta;
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    providerLabel,
    dimensionId,
    dimensionLabel,
    operationalState,
    latency,
    meta,
  );
}

/// One provider row in the health matrix (provider → cells).
@immutable
class DSProviderHealthProvider {
  /// Stable provider id.
  final String id;

  /// Display label.
  final String label;

  /// Cells along the dimension axis (≥1 for a useful row).
  final List<DSProviderHealthCell> cells;

  /// Optional provider-level rollup state (defaults to worst cell severity).
  final DSOperationalState? aggregateState;

  const DSProviderHealthProvider({
    required this.id,
    required this.label,
    required this.cells,
    this.aggregateState,
  });

  /// Derived aggregate when [aggregateState] is unset.
  DSOperationalState get effectiveAggregate {
    if (aggregateState != null) return aggregateState!;
    if (cells.isEmpty) return DSOperationalState.disabled;
    return cells.map((c) => c.operationalState).reduce(_worseHealthState);
  }
}

/// ASW Observatory Organism — Provider Health Matrix
///
/// 2D ops grid of provider health cells (provider rows × account/model
/// columns) with operational state, optional latency, and selection.
///
/// **Not** a generic status grid. Prefer [DSStatusGrid] / [DSHealthCard] for
/// flat multi-service dashboards. This organism is CyberCore provider→account
/// →model matrix IA (fixture-first).
///
/// Contract:
/// - [providers] drive rows; each row's [DSProviderHealthProvider.cells]
///   map to columns (by [DSProviderHealthCell.dimensionId]).
/// - Optional [columnLabels] / [columnIds] override header order.
/// - Empty providers → compact empty surface (no crash).
/// - Cell tap fires [onCellSelected]; [selectedCellId] highlights selection.
/// - No live health endpoints, API keys, or polling in this package.
class DSProviderHealthMatrix extends StatelessWidget {
  /// Provider rows for the matrix.
  final List<DSProviderHealthProvider> providers;

  /// Optional ordered column ids. When null, columns are union of all
  /// cell [DSProviderHealthCell.dimensionId] values in first-seen order.
  final List<String>? columnIds;

  /// Optional display labels parallel to [columnIds]. When shorter/missing,
  /// falls back to the first matching cell's [dimensionLabel].
  final List<String>? columnLabels;

  /// Currently selected cell id (controlled highlight).
  final String? selectedCellId;

  /// Fired when a cell is activated (tap / keyboard).
  final ValueChanged<DSProviderHealthCell>? onCellSelected;

  /// Optional matrix container semantic label.
  final String semanticLabel;

  /// When true and [providers] is empty, shows empty placeholder.
  final bool showEmptyPlaceholder;

  /// Empty-state title.
  final String emptyTitle;

  /// Empty-state subtitle.
  final String emptySubtitle;

  /// Minimum cell width in the scrollable grid.
  final double minCellWidth;

  /// Corner header label (top-left).
  final String cornerLabel;

  const DSProviderHealthMatrix({
    super.key,
    required this.providers,
    this.columnIds,
    this.columnLabels,
    this.selectedCellId,
    this.onCellSelected,
    this.semanticLabel = 'Provider health matrix',
    this.showEmptyPlaceholder = true,
    this.emptyTitle = 'No providers',
    this.emptySubtitle = 'Load fixture providers to inspect health cells',
    this.minCellWidth = 120,
    this.cornerLabel = 'Provider',
  });

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) {
      if (!showEmptyPlaceholder) {
        return const SizedBox.shrink();
      }
      return Semantics(
        label: '$semanticLabel: empty',
        child: DSStateSurface.empty(
          icon: Icons.cloud_off_outlined,
          title: emptyTitle,
          subtitle: emptySubtitle,
          compact: true,
        ),
      );
    }

    final columns = _resolveColumns();
    final totalCells = providers.fold<int>(0, (sum, p) => sum + p.cells.length);

    return Semantics(
      container: true,
      label:
          '$semanticLabel: ${providers.length} providers, '
          '${columns.length} dimensions, $totalCells cells',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedWidth = constraints.maxWidth.isFinite;
          const rowHeaderWidth = 128.0;
          final available = hasBoundedWidth
              ? (constraints.maxWidth - rowHeaderWidth).clamp(
                  0.0,
                  double.infinity,
                )
              : columns.length * minCellWidth;
          final cellWidth = columns.isEmpty
              ? minCellWidth
              : (available / columns.length).clamp(minCellWidth, 280.0);

          final table = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _MatrixHeaderRow(
                cornerLabel: cornerLabel,
                rowHeaderWidth: rowHeaderWidth,
                cellWidth: cellWidth,
                columns: columns,
              ),
              const SizedBox(height: DSSpacing.xs),
              for (var i = 0; i < providers.length; i++) ...[
                if (i > 0) const SizedBox(height: DSSpacing.xs),
                _MatrixProviderRow(
                  provider: providers[i],
                  columns: columns,
                  rowHeaderWidth: rowHeaderWidth,
                  cellWidth: cellWidth,
                  selectedCellId: selectedCellId,
                  onCellSelected: onCellSelected,
                ),
              ],
            ],
          );

          // Horizontal scroll when many columns exceed viewport.
          if (hasBoundedWidth &&
              rowHeaderWidth + columns.length * cellWidth >
                  constraints.maxWidth + 0.5) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: rowHeaderWidth + columns.length * cellWidth,
                child: table,
              ),
            );
          }
          return table;
        },
      ),
    );
  }

  List<_MatrixColumn> _resolveColumns() {
    if (columnIds != null && columnIds!.isNotEmpty) {
      return [
        for (var i = 0; i < columnIds!.length; i++)
          _MatrixColumn(
            id: columnIds![i],
            label: (columnLabels != null && i < columnLabels!.length)
                ? columnLabels![i]
                : _firstDimensionLabel(columnIds![i]) ?? columnIds![i],
          ),
      ];
    }

    final seen = <String>{};
    final cols = <_MatrixColumn>[];
    for (final provider in providers) {
      for (final cell in provider.cells) {
        if (seen.add(cell.dimensionId)) {
          cols.add(
            _MatrixColumn(id: cell.dimensionId, label: cell.dimensionLabel),
          );
        }
      }
    }
    return cols;
  }

  String? _firstDimensionLabel(String dimensionId) {
    for (final provider in providers) {
      for (final cell in provider.cells) {
        if (cell.dimensionId == dimensionId) return cell.dimensionLabel;
      }
    }
    return null;
  }
}

class _MatrixColumn {
  final String id;
  final String label;

  const _MatrixColumn({required this.id, required this.label});
}

class _MatrixHeaderRow extends StatelessWidget {
  final String cornerLabel;
  final double rowHeaderWidth;
  final double cellWidth;
  final List<_MatrixColumn> columns;

  const _MatrixHeaderRow({
    required this.cornerLabel,
    required this.rowHeaderWidth,
    required this.cellWidth,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: rowHeaderWidth,
          child: Padding(
            padding: const EdgeInsets.only(
              left: DSSpacing.sm,
              right: DSSpacing.sm,
              bottom: DSSpacing.xs,
            ),
            child: DSText.labelSmall(cornerLabel, color: DSColors.textTertiary),
          ),
        ),
        for (final col in columns)
          SizedBox(
            width: cellWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
              child: DSText.labelSmall(
                col.label,
                color: DSColors.textSecondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _MatrixProviderRow extends StatelessWidget {
  final DSProviderHealthProvider provider;
  final List<_MatrixColumn> columns;
  final double rowHeaderWidth;
  final double cellWidth;
  final String? selectedCellId;
  final ValueChanged<DSProviderHealthCell>? onCellSelected;

  const _MatrixProviderRow({
    required this.provider,
    required this.columns,
    required this.rowHeaderWidth,
    required this.cellWidth,
    required this.selectedCellId,
    required this.onCellSelected,
  });

  @override
  Widget build(BuildContext context) {
    final byDimension = <String, DSProviderHealthCell>{
      for (final cell in provider.cells) cell.dimensionId: cell,
    };
    final aggregate = provider.effectiveAggregate;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: rowHeaderWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
            child: Row(
              children: [
                DSStatusDot(
                  color: aggregate.color,
                  size: 8,
                  animated: aggregate == DSOperationalState.running,
                  tooltip: aggregate.semanticLabel,
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: DSText.labelMedium(
                    provider.label,
                    color: DSColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final col in columns)
          SizedBox(
            width: cellWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xxs),
              child: byDimension.containsKey(col.id)
                  ? _ProviderHealthCellTile(
                      cell: byDimension[col.id]!,
                      selected: byDimension[col.id]!.id == selectedCellId,
                      onSelected: onCellSelected,
                    )
                  : const _EmptyMatrixSlot(),
            ),
          ),
      ],
    );
  }
}

class _EmptyMatrixSlot extends StatelessWidget {
  const _EmptyMatrixSlot();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(DSRadii.sm),
          border: Border.all(
            color: DSColors.borderSubtle.withValues(alpha: 0.4),
          ),
        ),
        alignment: Alignment.center,
        child: const DSText.labelSmall('—', color: DSColors.textDisabled),
      ),
    );
  }
}

class _ProviderHealthCellTile extends StatelessWidget {
  final DSProviderHealthCell cell;
  final bool selected;
  final ValueChanged<DSProviderHealthCell>? onSelected;

  const _ProviderHealthCellTile({
    required this.cell,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final stateColor = cell.operationalState.color;
    final borderColor = selected
        ? DSColors.accentCyan.withValues(alpha: 0.7)
        : stateColor.withValues(alpha: 0.35);
    final bg = selected
        ? DSColors.accentCyan.withValues(alpha: 0.08)
        : DSColors.obsidianElevated;

    final panel = Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              DSStatusDot(
                color: stateColor,
                size: 8,
                animated: cell.operationalState == DSOperationalState.running,
                tooltip: cell.operationalState.semanticLabel,
              ),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: DSText.labelSmall(
                  cell.operationalState.label,
                  color: stateColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (cell.latencyLabel != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            DSText.labelSmall(
              cell.latencyLabel!,
              color: DSColors.textTertiary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (cell.meta != null && cell.meta!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.xxs),
            DSText.labelSmall(
              cell.meta!,
              color: DSColors.textDisabled,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    return DSInteractiveSurface(
      key: Key('provider-health-cell-${cell.id}'),
      semanticLabel: cell.semanticLabel,
      selected: selected,
      onTap: onSelected != null ? () => onSelected!(cell) : null,
      excludeChildSemantics: true,
      child: panel,
    );
  }
}

/// Severity-aware "worse" fold for provider aggregate rollup.
///
/// Order (worst → best for health-ish ops): error > degraded > stale >
/// running > pending > disabled > healthy (and other states map mid-band).
DSOperationalState _worseHealthState(
  DSOperationalState a,
  DSOperationalState b,
) {
  int rank(DSOperationalState s) => switch (s) {
    DSOperationalState.error => 100,
    DSOperationalState.rejected => 95,
    DSOperationalState.exposed => 90,
    DSOperationalState.degraded => 80,
    DSOperationalState.stale => 70,
    DSOperationalState.running => 50,
    DSOperationalState.pending => 40,
    DSOperationalState.unverified => 35,
    DSOperationalState.redacted => 30,
    DSOperationalState.disabled => 20,
    DSOperationalState.excluded => 15,
    DSOperationalState.archived => 10,
    DSOperationalState.approved => 5,
    DSOperationalState.promoted => 4,
    DSOperationalState.healthy => 0,
  };
  return rank(a) >= rank(b) ? a : b;
}

// =============================================================================
// Fixtures (gallery + tests) — mock provider names only, no real keys
// =============================================================================

/// Shared multi-provider fixture matrix (≥2 providers × ≥2 cells).
List<DSProviderHealthProvider> dsProviderHealthMatrixFixtureProviders() {
  return const [
    DSProviderHealthProvider(
      id: 'openai',
      label: 'OpenAI',
      aggregateState: DSOperationalState.degraded,
      cells: [
        DSProviderHealthCell(
          id: 'openai-main-prod',
          providerId: 'openai',
          providerLabel: 'OpenAI',
          dimensionId: 'main-prod',
          dimensionLabel: 'main-prod',
          operationalState: DSOperationalState.healthy,
          latency: Duration(milliseconds: 142),
          meta: 'us-east',
        ),
        DSProviderHealthCell(
          id: 'openai-dev-sandbox',
          providerId: 'openai',
          providerLabel: 'OpenAI',
          dimensionId: 'dev-sandbox',
          dimensionLabel: 'dev-sandbox',
          operationalState: DSOperationalState.degraded,
          latency: Duration(milliseconds: 890),
          meta: 'eu-west',
        ),
        DSProviderHealthCell(
          id: 'openai-batch',
          providerId: 'openai',
          providerLabel: 'OpenAI',
          dimensionId: 'batch',
          dimensionLabel: 'batch',
          operationalState: DSOperationalState.stale,
          latency: Duration(milliseconds: 2100),
          meta: 'us-central',
        ),
      ],
    ),
    DSProviderHealthProvider(
      id: 'anthropic',
      label: 'Anthropic',
      cells: [
        DSProviderHealthCell(
          id: 'anthropic-claude-prod',
          providerId: 'anthropic',
          providerLabel: 'Anthropic',
          dimensionId: 'main-prod',
          dimensionLabel: 'main-prod',
          operationalState: DSOperationalState.running,
          latency: Duration(milliseconds: 318),
          meta: 'us-west',
        ),
        DSProviderHealthCell(
          id: 'anthropic-dev',
          providerId: 'anthropic',
          providerLabel: 'Anthropic',
          dimensionId: 'dev-sandbox',
          dimensionLabel: 'dev-sandbox',
          operationalState: DSOperationalState.error,
          latency: Duration(milliseconds: 4200),
          meta: 'timeout',
        ),
        DSProviderHealthCell(
          id: 'anthropic-batch',
          providerId: 'anthropic',
          providerLabel: 'Anthropic',
          dimensionId: 'batch',
          dimensionLabel: 'batch',
          operationalState: DSOperationalState.disabled,
          meta: 'off',
        ),
      ],
    ),
    DSProviderHealthProvider(
      id: 'local-mock',
      label: 'Local Mock',
      cells: [
        DSProviderHealthCell(
          id: 'local-main',
          providerId: 'local-mock',
          providerLabel: 'Local Mock',
          dimensionId: 'main-prod',
          dimensionLabel: 'main-prod',
          operationalState: DSOperationalState.healthy,
          latency: Duration(milliseconds: 12),
          meta: 'loopback',
        ),
        DSProviderHealthCell(
          id: 'local-dev',
          providerId: 'local-mock',
          providerLabel: 'Local Mock',
          dimensionId: 'dev-sandbox',
          dimensionLabel: 'dev-sandbox',
          operationalState: DSOperationalState.healthy,
          latency: Duration(milliseconds: 8),
        ),
      ],
    ),
  ];
}

/// Compact two-provider / two-cell fixture for minimal tests.
List<DSProviderHealthProvider> dsProviderHealthMatrixMinimalFixture() {
  return const [
    DSProviderHealthProvider(
      id: 'openai',
      label: 'OpenAI',
      cells: [
        DSProviderHealthCell(
          id: 'o-a',
          providerId: 'openai',
          providerLabel: 'OpenAI',
          dimensionId: 'acct-a',
          dimensionLabel: 'acct-a',
          operationalState: DSOperationalState.healthy,
          latency: Duration(milliseconds: 100),
        ),
        DSProviderHealthCell(
          id: 'o-b',
          providerId: 'openai',
          providerLabel: 'OpenAI',
          dimensionId: 'acct-b',
          dimensionLabel: 'acct-b',
          operationalState: DSOperationalState.degraded,
          latency: Duration(milliseconds: 500),
        ),
      ],
    ),
    DSProviderHealthProvider(
      id: 'anthropic',
      label: 'Anthropic',
      cells: [
        DSProviderHealthCell(
          id: 'a-a',
          providerId: 'anthropic',
          providerLabel: 'Anthropic',
          dimensionId: 'acct-a',
          dimensionLabel: 'acct-a',
          operationalState: DSOperationalState.error,
          latency: Duration(milliseconds: 3000),
        ),
        DSProviderHealthCell(
          id: 'a-b',
          providerId: 'anthropic',
          providerLabel: 'Anthropic',
          dimensionId: 'acct-b',
          dimensionLabel: 'acct-b',
          operationalState: DSOperationalState.healthy,
          latency: Duration(milliseconds: 200),
        ),
      ],
    ),
  ];
}
