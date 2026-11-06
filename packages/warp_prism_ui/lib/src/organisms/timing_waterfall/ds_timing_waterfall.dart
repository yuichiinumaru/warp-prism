import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Immutable timing span for [DSTimingWaterfall].
///
/// Contract:
/// - [id] stable within a waterfall (selection / semantic key).
/// - [name] human-readable phase label (DNS, TLS, TTFB, …).
/// - [startMs] offset from request origin in milliseconds (≥0).
/// - [durationMs] span length in milliseconds (≥0; zero is valid).
/// - [depth] optional nesting level for indented rows (0 = root).
/// - Fixture-only — no live tracing or Recharts/chart ports.
@immutable
class DSTimingSpan {
  /// Stable unique id within a waterfall.
  final String id;

  /// Display name for the span phase.
  final String name;

  /// Start offset from the timeline origin, in milliseconds.
  final int startMs;

  /// Duration of this span, in milliseconds (zero allowed).
  final int durationMs;

  /// Nesting depth for row indent (0 = top-level).
  final int depth;

  /// Optional accent override; defaults cycle by depth.
  final Color? color;

  /// Optional secondary meta (provider, region, etc.).
  final String? meta;

  const DSTimingSpan({
    required this.id,
    required this.name,
    required this.startMs,
    required this.durationMs,
    this.depth = 0,
    this.color,
    this.meta,
  });

  /// Inclusive end offset (`startMs + durationMs`).
  int get endMs => startMs + durationMs;

  /// Formatted duration for UI and a11y (e.g. `12ms`, `1.5s`).
  String get durationLabel {
    if (durationMs < 1000) return '${durationMs}ms';
    final seconds = durationMs / 1000.0;
    return '${seconds.toStringAsFixed(seconds >= 10 ? 0 : 1)}s';
  }

  /// Screen-reader label: name + duration (+ meta).
  String get semanticLabel {
    final buf = StringBuffer('$name, $durationLabel');
    if (meta != null && meta!.isNotEmpty) {
      buf.write(', $meta');
    }
    return buf.toString();
  }

  DSTimingSpan copyWith({
    String? id,
    String? name,
    int? startMs,
    int? durationMs,
    int? depth,
    Color? color,
    String? meta,
    bool clearColor = false,
    bool clearMeta = false,
  }) {
    return DSTimingSpan(
      id: id ?? this.id,
      name: name ?? this.name,
      startMs: startMs ?? this.startMs,
      durationMs: durationMs ?? this.durationMs,
      depth: depth ?? this.depth,
      color: clearColor ? null : (color ?? this.color),
      meta: clearMeta ? null : (meta ?? this.meta),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSTimingSpan &&
        other.id == id &&
        other.name == name &&
        other.startMs == startMs &&
        other.durationMs == durationMs &&
        other.depth == depth &&
        other.color == color &&
        other.meta == meta;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, startMs, durationMs, depth, color, meta);
}

// =============================================================================
// Layout math (pure — unit-testable)
// =============================================================================

/// Waterfall layout helpers.
///
/// Bar geometry is pure Flutter layout (no Recharts / chart packages):
/// - Domain: `[0, maxEndMs]` where `maxEndMs = max(span.endMs)` (or 1 if 0).
/// - `leftFraction  = startMs / maxEndMs`
/// - `widthFraction = max(durationMs / maxEndMs, minBarFraction)` for visibility
/// - Zero-duration spans still paint a thin marker at their start offset.
abstract final class DSTimingWaterfallLayout {
  /// Minimum painted bar fraction so zero/near-zero spans remain visible.
  static const double minBarFraction = 0.01;

  /// Label column width for name + duration text.
  static const double labelWidth = 148;

  /// Row height for each span.
  static const double rowHeight = 36;

  /// Indent per depth level.
  static const double depthIndent = 12;

  /// Resolves timeline domain end (never zero so fractions stay finite).
  static int resolveMaxEndMs(List<DSTimingSpan> spans) {
    if (spans.isEmpty) return 1;
    var maxEnd = 0;
    for (final s in spans) {
      if (s.endMs > maxEnd) maxEnd = s.endMs;
    }
    return maxEnd <= 0 ? 1 : maxEnd;
  }

  /// Left edge fraction of the bar track for [span].
  static double leftFraction(DSTimingSpan span, int maxEndMs) {
    if (maxEndMs <= 0) return 0;
    final f = span.startMs / maxEndMs;
    return f.clamp(0.0, 1.0);
  }

  /// Width fraction of the bar track for [span] (≥ [minBarFraction]).
  static double widthFraction(DSTimingSpan span, int maxEndMs) {
    if (maxEndMs <= 0) return minBarFraction;
    final raw = span.durationMs / maxEndMs;
    if (raw <= 0) return minBarFraction;
    return raw.clamp(minBarFraction, 1.0);
  }

  /// Default accent by depth (cyan → violet → gold cycle).
  static Color defaultBarColor(int depth) {
    switch (depth % 3) {
      case 0:
        return DSColors.accentBlue;
      case 1:
        return DSColors.accentViolet;
      default:
        return DSColors.accentGold;
    }
  }
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Timing Waterfall
///
/// Fixture-driven request/execution timing bars (OmniRoute C-09). Pure
/// Flutter layout — **no Recharts**, MapLibre, or chart engines.
///
/// Contract:
/// - [spans] ordered list of [DSTimingSpan] rows.
/// - Empty list → optional empty surface (no crash).
/// - Zero-duration spans render a thin marker at [DSTimingSpan.startMs].
/// - Bar widths scale with duration relative to the max end offset.
/// - Span a11y labels include name + duration.
class DSTimingWaterfall extends StatelessWidget {
  /// Timing spans to render.
  final List<DSTimingSpan> spans;

  /// Optional controlled selection highlight.
  final String? selectedSpanId;

  /// Fired when a span row is activated.
  final ValueChanged<DSTimingSpan>? onSpanSelected;

  /// Region semantic label.
  final String semanticLabel;

  /// When true and [spans] is empty, show empty placeholder.
  final bool showEmptyPlaceholder;

  /// Empty-state title.
  final String emptyTitle;

  /// Empty-state subtitle.
  final String emptySubtitle;

  /// Whether to show a header with total duration.
  final bool showHeader;

  /// Optional header title override.
  final String title;

  /// Wrap in glass panel chrome.
  final bool wrapInGlass;

  const DSTimingWaterfall({
    super.key,
    required this.spans,
    this.selectedSpanId,
    this.onSpanSelected,
    this.semanticLabel = 'Timing waterfall',
    this.showEmptyPlaceholder = true,
    this.emptyTitle = 'No timing spans',
    this.emptySubtitle = 'Load fixture spans to inspect latency phases',
    this.showHeader = true,
    this.title = 'Timing',
    this.wrapInGlass = true,
  });

  /// Stable keys for tests.
  static const Key panelKey = Key('ds-timing-waterfall');
  static const Key emptyKey = Key('ds-timing-waterfall-empty');
  static const Key listKey = Key('ds-timing-waterfall-list');

  static Key rowKey(String spanId) => Key('ds-timing-waterfall-row-$spanId');
  static Key barKey(String spanId) => Key('ds-timing-waterfall-bar-$spanId');

  @override
  Widget build(BuildContext context) {
    final body = spans.isEmpty ? _buildEmpty() : _buildContent();

    final content = Semantics(
      container: true,
      label: spans.isEmpty
          ? '$semanticLabel: empty'
          : '$semanticLabel: ${spans.length} spans, '
                'total ${_totalDurationLabel()}',
      child: Column(
        key: panelKey,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader && spans.isNotEmpty) _buildHeader(),
          if (showHeader && spans.isNotEmpty) const DSDivider.subtle(),
          body,
        ],
      ),
    );

    if (!wrapInGlass) {
      return content;
    }

    return DSGlassPanelSimple(
      backgroundColor: DSColors.obsidianBase.withValues(alpha: 0.95),
      borderColor: DSColors.borderSubtle,
      padding: EdgeInsets.zero,
      child: content,
    );
  }

  String _totalDurationLabel() {
    final maxEnd = DSTimingWaterfallLayout.resolveMaxEndMs(spans);
    if (maxEnd < 1000) return '${maxEnd}ms';
    final s = maxEnd / 1000.0;
    return '${s.toStringAsFixed(s >= 10 ? 0 : 1)}s';
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.md,
      ),
      child: Row(
        children: [
          DSIcon.small(Icons.bar_chart_outlined, color: DSColors.accentBlue),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.labelLarge(title, color: DSColors.textPrimary),
          ),
          DSBadge(label: _totalDurationLabel(), color: DSColors.accentBlue),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    if (!showEmptyPlaceholder) {
      return const SizedBox.shrink(key: emptyKey);
    }
    return Padding(
      key: emptyKey,
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: DSStateSurface.empty(
        icon: Icons.timeline_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
        compact: true,
      ),
    );
  }

  Widget _buildContent() {
    final maxEnd = DSTimingWaterfallLayout.resolveMaxEndMs(spans);

    return ListView.builder(
      key: listKey,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: spans.length,
      itemExtent: DSTimingWaterfallLayout.rowHeight,
      itemBuilder: (context, index) {
        final span = spans[index];
        return _TimingSpanRow(
          span: span,
          maxEndMs: maxEnd,
          selected: selectedSpanId == span.id,
          onSelected: onSpanSelected,
        );
      },
    );
  }
}

// =============================================================================
// Row
// =============================================================================

class _TimingSpanRow extends StatelessWidget {
  final DSTimingSpan span;
  final int maxEndMs;
  final bool selected;
  final ValueChanged<DSTimingSpan>? onSelected;

  const _TimingSpanRow({
    required this.span,
    required this.maxEndMs,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final left = DSTimingWaterfallLayout.leftFraction(span, maxEndMs);
    final width = DSTimingWaterfallLayout.widthFraction(span, maxEndMs);
    final barColor =
        span.color ?? DSTimingWaterfallLayout.defaultBarColor(span.depth);
    final indent = span.depth * DSTimingWaterfallLayout.depthIndent;

    final row = Padding(
      key: DSTimingWaterfall.rowKey(span.id),
      padding: EdgeInsets.only(
        left: DSSpacing.md + indent,
        right: DSSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: DSTimingWaterfallLayout.labelWidth - indent.clamp(0.0, 48.0),
            child: Row(
              children: [
                Expanded(
                  child: DSText.bodySmall(
                    span.name,
                    color: selected
                        ? DSColors.textPrimary
                        : DSColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
                DSText.labelSmall(
                  span.durationLabel,
                  color: DSColors.textTertiary,
                ),
              ],
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackW = constraints.maxWidth;
                final barLeft = left * trackW;
                // Layout math: width scales with duration; zero-duration gets
                // minBarFraction (clamped to ≥2px) so the marker stays visible.
                final barW = (width * trackW).clamp(2.0, trackW);
                return SizedBox(
                  height: DSSpacing.lg,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: DSColors.obsidianHover,
                            borderRadius: BorderRadius.circular(DSRadii.sm),
                          ),
                        ),
                      ),
                      Positioned(
                        left: barLeft,
                        width: barW,
                        top: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          key: DSTimingWaterfall.barKey(span.id),
                          decoration: BoxDecoration(
                            color: barColor.withValues(
                              alpha: selected ? 0.95 : 0.75,
                            ),
                            borderRadius: BorderRadius.circular(DSRadii.sm),
                            border: selected
                                ? Border.all(color: barColor, width: 1)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (onSelected == null) {
      return Semantics(
        label: span.semanticLabel,
        // Child DSText labels would otherwise concatenate into the a11y tree;
        // the span semanticLabel already includes name + duration.
        excludeSemantics: true,
        child: row,
      );
    }

    return DSInteractiveSurface(
      semanticLabel: span.semanticLabel,
      selected: selected,
      excludeChildSemantics: true,
      onTap: () => onSelected!(span),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? DSColors.obsidianActive.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
        child: row,
      ),
    );
  }
}

// =============================================================================
// Fixtures (gallery + tests) — mock request IDs only, no live capture
// =============================================================================

/// Multi-phase timing fixture (DNS → connect → TLS → TTFB → download).
List<DSTimingSpan> dsTimingWaterfallFixtureSpans() {
  return const [
    DSTimingSpan(
      id: 'span-dns',
      name: 'DNS',
      startMs: 0,
      durationMs: 18,
      meta: 'resolver',
    ),
    DSTimingSpan(
      id: 'span-connect',
      name: 'Connect',
      startMs: 18,
      durationMs: 42,
      depth: 0,
    ),
    DSTimingSpan(
      id: 'span-tls',
      name: 'TLS',
      startMs: 60,
      durationMs: 85,
      depth: 1,
      meta: 'TLS1.3',
    ),
    DSTimingSpan(
      id: 'span-ttfb',
      name: 'TTFB',
      startMs: 145,
      durationMs: 320,
      depth: 0,
      meta: 'origin',
    ),
    DSTimingSpan(
      id: 'span-download',
      name: 'Download',
      startMs: 465,
      durationMs: 180,
      depth: 0,
    ),
    DSTimingSpan(
      id: 'span-parse',
      name: 'Parse',
      startMs: 645,
      durationMs: 0,
      depth: 1,
      meta: 'zero-duration marker',
    ),
  ];
}

/// Compact fixture for unit/widget tests (includes zero-duration span).
List<DSTimingSpan> dsTimingWaterfallMinimalFixture() {
  return const [
    DSTimingSpan(id: 't-dns', name: 'DNS', startMs: 0, durationMs: 20),
    DSTimingSpan(id: 't-ttfb', name: 'TTFB', startMs: 20, durationMs: 100),
    DSTimingSpan(id: 't-mark', name: 'Mark', startMs: 120, durationMs: 0),
  ];
}
