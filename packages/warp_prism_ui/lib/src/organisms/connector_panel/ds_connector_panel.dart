import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_badge.dart';
import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Fixtures
// =============================================================================

/// Shared fixture helpers for gallery / tests (Task 1515 / O-20).
///
/// Domain-agnostic connector chrome demos — no Shodan/SCM/radio clones.
abstract final class DSConnectorPanelFixtures {
  /// Default panel title for gallery demos.
  static const String defaultTitle = 'Connector';

  /// Default status badge label.
  static const String defaultBadgeLabel = 'Live';

  /// Fixture body copy for gallery demos.
  static const String defaultBodyText =
      'Generic connector body slot — host fixture content here. '
      'Prefer this chrome over domain one-off panels.';

  /// Compact body for tests.
  static const String minimalBodyText = 'CONNECTOR_BODY';
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Connector Panel
///
/// Generic minimizable glass panel chrome: **header** (title + optional badge)
/// + **refresh** + **minimize/expand** + **body slot**.
///
/// Prefer this organism over domain one-off panels (Shodan / SCM / radio).
/// Fixture-first — refresh is a callback only; no live network.
///
/// EPIC-15 O-20 / Task 1515.
class DSConnectorPanel extends StatefulWidget {
  /// Header title.
  final String title;

  /// Optional subtitle under the title (collapsed header still shows title).
  final String? subtitle;

  /// Optional badge label rendered next to the title (e.g. "Live", "Stale").
  final String? badgeLabel;

  /// Optional badge color; defaults to [DSColors.accentBlue].
  final Color? badgeColor;

  /// Optional leading widget (icon) before the title.
  final Widget? leading;

  /// Optional trailing slot after refresh/minimize (e.g. overflow menu).
  final Widget? trailing;

  /// Body content when expanded. Hidden when minimized.
  final Widget child;

  /// Controlled minimize state. When non-null, parent owns state.
  final bool? minimized;

  /// Seed minimize for uncontrolled mode.
  final bool initiallyMinimized;

  /// Called when minimize/expand toggles. Argument is the **new** minimized
  /// value (`true` = body hidden).
  final ValueChanged<bool>? onMinimizedChanged;

  /// Optional refresh callback. When null and [showRefresh] is true, the
  /// control is still shown but disabled.
  final VoidCallback? onRefresh;

  /// Whether to show the refresh control. Defaults to true.
  final bool showRefresh;

  /// Whether to show the minimize chevron. Defaults to true.
  final bool showMinimize;

  /// Whether to wrap content in [DSGlassPanel]. Defaults to true.
  final bool wrapInGlass;

  /// Optional fixed width for the panel.
  final double? width;

  /// Semantic label for the panel container.
  final String semanticLabel;

  /// Tooltip / semantics for the refresh control.
  final String refreshLabel;

  const DSConnectorPanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.badgeLabel,
    this.badgeColor,
    this.leading,
    this.trailing,
    this.minimized,
    this.initiallyMinimized = false,
    this.onMinimizedChanged,
    this.onRefresh,
    this.showRefresh = true,
    this.showMinimize = true,
    this.wrapInGlass = true,
    this.width,
    this.semanticLabel = 'Connector panel',
    this.refreshLabel = 'Refresh connector',
  });

  /// Whether minimize is parent-controlled.
  bool get isMinimizeControlled => minimized != null;

  // --- Stable keys ---

  static const Key panelRegionKey = Key('ds-connector-panel');
  static const Key headerKey = Key('ds-connector-header');
  static const Key bodyKey = Key('ds-connector-body');
  static const Key refreshButtonKey = Key('ds-connector-refresh');
  static const Key minimizeButtonKey = Key('ds-connector-minimize');

  /// Semantic label for minimize/expand control.
  static String minimizeSemanticLabel({required bool minimized}) =>
      minimized ? 'Expand connector panel' : 'Minimize connector panel';

  @override
  State<DSConnectorPanel> createState() => _DSConnectorPanelState();
}

class _DSConnectorPanelState extends State<DSConnectorPanel> {
  late bool _uncontrolledMinimized;

  @override
  void initState() {
    super.initState();
    _uncontrolledMinimized = widget.initiallyMinimized;
  }

  @override
  void didUpdateWidget(covariant DSConnectorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When parent drives minimized, keep internal seed in sync so leaving
    // controlled mode does not resurrect a stale expand state.
    if (widget.minimized != null && widget.minimized != oldWidget.minimized) {
      _uncontrolledMinimized = widget.minimized!;
    }
  }

  bool get _minimized => widget.minimized ?? _uncontrolledMinimized;

  void _toggleMinimized() {
    final next = !_minimized;
    if (!widget.isMinimizeControlled) {
      setState(() => _uncontrolledMinimized = next);
    }
    widget.onMinimizedChanged?.call(next);
  }

  void _handleRefresh() {
    if (widget.onRefresh == null) return;
    HapticFeedback.selectionClick();
    widget.onRefresh!();
  }

  @override
  Widget build(BuildContext context) {
    final minimized = _minimized;

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(minimized: minimized),
        if (!minimized) ...[
          const SizedBox(height: DSSpacing.sm),
          KeyedSubtree(key: DSConnectorPanel.bodyKey, child: widget.child),
        ],
      ],
    );

    final padded = Padding(
      padding: const EdgeInsets.all(DSSpacing.sm),
      child: column,
    );

    final content = widget.wrapInGlass
        ? DSGlassPanel.elevated(child: padded)
        : padded;

    final sized = widget.width != null
        ? SizedBox(width: widget.width, child: content)
        : content;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: KeyedSubtree(key: DSConnectorPanel.panelRegionKey, child: sized),
    );
  }

  Widget _buildHeader({required bool minimized}) {
    final badgeColor = widget.badgeColor ?? DSColors.accentBlue;
    final refreshEnabled = widget.onRefresh != null;

    return KeyedSubtree(
      key: DSConnectorPanel.headerKey,
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: DSSpacing.xs),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: DSText.labelLarge(
                        widget.title,
                        color: DSColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.badgeLabel != null &&
                        widget.badgeLabel!.trim().isNotEmpty) ...[
                      const SizedBox(width: DSSpacing.xs),
                      DSBadge(
                        label: widget.badgeLabel,
                        size: DSBadgeSize.small,
                        color: badgeColor,
                      ),
                    ],
                  ],
                ),
                if (widget.subtitle != null &&
                    widget.subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.xxs),
                  DSText.labelSmall(
                    widget.subtitle!,
                    color: DSColors.textTertiary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (widget.showRefresh)
            Semantics(
              key: DSConnectorPanel.refreshButtonKey,
              button: true,
              enabled: refreshEnabled,
              label: widget.refreshLabel,
              excludeSemantics: true,
              child: IconButton(
                tooltip: widget.refreshLabel,
                iconSize: 18,
                visualDensity: VisualDensity.standard,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: kMinInteractiveDimension,
                  minHeight: kMinInteractiveDimension,
                ),
                onPressed: refreshEnabled ? _handleRefresh : null,
                icon: DSIcon(
                  DSIcons.refresh,
                  size: 18,
                  color: refreshEnabled
                      ? DSColors.textSecondary
                      : DSColors.textDisabled,
                ),
              ),
            ),
          if (widget.showMinimize)
            Semantics(
              key: DSConnectorPanel.minimizeButtonKey,
              button: true,
              enabled: true,
              label: DSConnectorPanel.minimizeSemanticLabel(
                minimized: minimized,
              ),
              excludeSemantics: true,
              child: IconButton(
                tooltip: DSConnectorPanel.minimizeSemanticLabel(
                  minimized: minimized,
                ),
                iconSize: 18,
                visualDensity: VisualDensity.standard,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: kMinInteractiveDimension,
                  minHeight: kMinInteractiveDimension,
                ),
                onPressed: _toggleMinimized,
                icon: Icon(
                  minimized ? Icons.expand_more : Icons.expand_less,
                  size: 18,
                  color: DSColors.textSecondary,
                ),
              ),
            ),
          if (widget.trailing != null) ...[
            const SizedBox(width: DSSpacing.xxs),
            widget.trailing!,
          ],
        ],
      ),
    );
  }
}
