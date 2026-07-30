import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_badge.dart';
import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Single operational launcher entry for [DSOpsControlCluster].
///
/// Fixture-friendly: identity, icon, label, optional badge, enabled flag.
/// Activation is handled by the cluster callback — no live mutation backends.
@immutable
class DSOpsLauncher {
  /// Stable launcher identity within a cluster.
  final String id;

  /// Icon shown on the launcher control.
  final IconData icon;

  /// Human-readable name — also the base Semantics label.
  final String label;

  /// Optional tooltip; defaults to [label] when null.
  final String? tooltip;

  /// Optional count badge (e.g. unread DMs). Mutually exclusive display with
  /// [badgeLabel] when both set — count wins.
  final int? badgeCount;

  /// Optional text badge when [badgeCount] is null.
  final String? badgeLabel;

  /// Whether the launcher is interactive. Defaults to true.
  final bool enabled;

  /// Optional accent for selected/active glyph tint.
  final Color? accentColor;

  const DSOpsLauncher({
    required this.id,
    required this.icon,
    required this.label,
    this.tooltip,
    this.badgeCount,
    this.badgeLabel,
    this.enabled = true,
    this.accentColor,
  });

  /// Whether a badge should render.
  bool get hasBadge =>
      (badgeCount != null && badgeCount! > 0) ||
      (badgeLabel != null && badgeLabel!.trim().isNotEmpty);

  DSOpsLauncher copyWith({
    String? id,
    IconData? icon,
    String? label,
    String? tooltip,
    int? badgeCount,
    String? badgeLabel,
    bool? enabled,
    Color? accentColor,
    bool clearTooltip = false,
    bool clearBadgeCount = false,
    bool clearBadgeLabel = false,
    bool clearAccentColor = false,
  }) {
    return DSOpsLauncher(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      label: label ?? this.label,
      tooltip: clearTooltip ? null : (tooltip ?? this.tooltip),
      badgeCount: clearBadgeCount ? null : (badgeCount ?? this.badgeCount),
      badgeLabel: clearBadgeLabel ? null : (badgeLabel ?? this.badgeLabel),
      enabled: enabled ?? this.enabled,
      accentColor: clearAccentColor ? null : (accentColor ?? this.accentColor),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSOpsLauncher &&
        other.id == id &&
        other.icon == icon &&
        other.label == label &&
        other.tooltip == tooltip &&
        other.badgeCount == badgeCount &&
        other.badgeLabel == badgeLabel &&
        other.enabled == enabled &&
        other.accentColor == accentColor;
  }

  @override
  int get hashCode => Object.hash(
    id,
    icon,
    label,
    tooltip,
    badgeCount,
    badgeLabel,
    enabled,
    accentColor,
  );
}

// =============================================================================
// Fixtures
// =============================================================================

/// Shared fixture catalog for gallery / tests (Task 1515 / O-16).
///
/// Status + navigate affordances only — no write/admin mutation.
abstract final class DSOpsControlClusterFixtures {
  /// Default top-right ops launcher set used by gallery demos.
  static const List<DSOpsLauncher> defaultLaunchers = <DSOpsLauncher>[
    DSOpsLauncher(
      id: 'console',
      icon: Icons.terminal_outlined,
      label: 'Console',
      tooltip: 'Open fixture console',
      accentColor: DSColors.accentCyan,
    ),
    DSOpsLauncher(
      id: 'providers',
      icon: Icons.cloud_outlined,
      label: 'Providers',
      tooltip: 'Provider health overview',
      badgeLabel: '3',
      accentColor: DSColors.accentViolet,
    ),
    DSOpsLauncher(
      id: 'alerts',
      icon: Icons.notifications_outlined,
      label: 'Alerts',
      tooltip: 'Operational alerts',
      badgeCount: 2,
      accentColor: DSColors.statusWarning,
    ),
    DSOpsLauncher(
      id: 'settings',
      icon: Icons.settings_outlined,
      label: 'Settings',
      tooltip: 'Workspace settings (read-only)',
    ),
    DSOpsLauncher(
      id: 'deploy',
      icon: Icons.rocket_launch_outlined,
      label: 'Deploy',
      tooltip: 'Deploy actions disabled in fixture mode',
      enabled: false,
    ),
  ];

  /// Compact two-launcher fixture for tests.
  static const List<DSOpsLauncher> minimalLaunchers = <DSOpsLauncher>[
    DSOpsLauncher(
      id: 'console',
      icon: Icons.terminal_outlined,
      label: 'Console',
    ),
    DSOpsLauncher(
      id: 'settings',
      icon: Icons.settings_outlined,
      label: 'Settings',
      enabled: false,
    ),
  ];
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Ops Control Cluster
///
/// Dense cluster of operational **launcher** controls (status + navigate
/// affordances). Fixture-first — no live deploy mutation, no mesh crypto,
/// no admin write paths.
///
/// EPIC-15 O-16 / Task 1515.
class DSOpsControlCluster extends StatelessWidget {
  /// Ordered launcher entries (leading → trailing for horizontal).
  final List<DSOpsLauncher> launchers;

  /// Called when an enabled launcher is activated (tap / keyboard).
  final ValueChanged<DSOpsLauncher>? onLauncherActivated;

  /// Layout axis. Defaults to [Axis.horizontal] (top-right ops row).
  final Axis direction;

  /// Optional selected launcher id for visual highlight only.
  final String? selectedId;

  /// Whether to wrap the cluster in [DSGlassPanel]. Defaults to true.
  final bool wrapInGlass;

  /// Optional dense mode (slightly tighter gaps / icon size).
  final bool dense;

  /// Semantic label for the cluster container.
  final String semanticLabel;

  const DSOpsControlCluster({
    super.key,
    required this.launchers,
    this.onLauncherActivated,
    this.direction = Axis.horizontal,
    this.selectedId,
    this.wrapInGlass = true,
    this.dense = false,
    this.semanticLabel = 'Ops control cluster',
  });

  // --- Stable keys ---

  static const Key clusterRegionKey = Key('ds-ops-control-cluster');

  /// Key for an individual launcher control by [launcherId].
  static Key launcherKey(String launcherId) =>
      Key('ds-ops-launcher-$launcherId');

  /// Semantic label for a launcher (includes disabled / selected / badge).
  static String launcherSemanticLabel(
    DSOpsLauncher launcher, {
    required bool selected,
  }) {
    final parts = <String>[launcher.label];
    if (!launcher.enabled) {
      parts.add('disabled');
    } else if (selected) {
      parts.add('selected');
    }
    if (launcher.badgeCount != null && launcher.badgeCount! > 0) {
      parts.add('${launcher.badgeCount} notifications');
    } else if (launcher.badgeLabel != null &&
        launcher.badgeLabel!.trim().isNotEmpty) {
      parts.add(launcher.badgeLabel!.trim());
    }
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final gap = dense ? DSSpacing.xxs : DSSpacing.xs;
    final children = <Widget>[];
    for (var i = 0; i < launchers.length; i++) {
      if (i > 0) {
        children.add(
          direction == Axis.horizontal
              ? SizedBox(width: gap)
              : SizedBox(height: gap),
        );
      }
      final launcher = launchers[i];
      children.add(
        _OpsLauncherButton(
          launcher: launcher,
          selected: selectedId == launcher.id,
          dense: dense,
          onActivated: launcher.enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onLauncherActivated?.call(launcher);
                }
              : null,
        ),
      );
    }

    final body = direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);

    final padded = Padding(
      padding: EdgeInsets.all(dense ? DSSpacing.xs : DSSpacing.sm),
      child: body,
    );

    final content = wrapInGlass ? DSGlassPanel.elevated(child: padded) : padded;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: KeyedSubtree(key: clusterRegionKey, child: content),
    );
  }
}

// =============================================================================
// Internals
// =============================================================================

class _OpsLauncherButton extends StatefulWidget {
  final DSOpsLauncher launcher;
  final bool selected;
  final bool dense;
  final VoidCallback? onActivated;

  const _OpsLauncherButton({
    required this.launcher,
    required this.selected,
    required this.dense,
    required this.onActivated,
  });

  @override
  State<_OpsLauncherButton> createState() => _OpsLauncherButtonState();
}

class _OpsLauncherButtonState extends State<_OpsLauncherButton> {
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'ops-launcher-${widget.launcher.id}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final launcher = widget.launcher;
    final enabled = launcher.enabled;
    final selected = widget.selected && enabled;
    final highlight = enabled && (selected || _hovered || _focused);
    // Dense mode only tightens visual density (icon/gap); hit target stays ≥48dp.
    // Material kMinInteractiveDimension is the WCAG / ADS floor for all modes.
    const minSize = kMinInteractiveDimension;
    assert(minSize >= 48.0);
    final iconSize = widget.dense ? 18.0 : 20.0;

    final bg = !enabled
        ? Colors.transparent
        : selected
        ? DSColors.obsidianActive
        : highlight
        ? DSColors.obsidianHover
        : Colors.transparent;

    final accent = launcher.accentColor ?? DSColors.accentCyan;
    final iconColor = !enabled
        ? DSColors.textDisabled
        : selected
        ? accent
        : highlight
        ? DSColors.textPrimary
        : DSColors.textSecondary;

    final borderColor = !enabled
        ? Colors.transparent
        : selected
        ? accent.withValues(alpha: 0.55)
        : _focused
        ? accent.withValues(alpha: 0.4)
        : Colors.transparent;

    final label = DSOpsControlCluster.launcherSemanticLabel(
      launcher,
      selected: selected,
    );

    return Semantics(
      key: DSOpsControlCluster.launcherKey(launcher.id),
      button: true,
      enabled: enabled,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: launcher.tooltip ?? launcher.label,
        waitDuration: const Duration(milliseconds: 400),
        child: Focus(
          focusNode: _focusNode,
          onFocusChange: (focused) {
            if (enabled) setState(() => _focused = focused);
          },
          onKeyEvent: (node, event) {
            if (!enabled || widget.onActivated == null) {
              return KeyEventResult.ignored;
            }
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.space)) {
              widget.onActivated!();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: MouseRegion(
            onEnter: (_) {
              if (enabled) setState(() => _hovered = true);
            },
            onExit: (_) {
              if (enabled) setState(() => _hovered = false);
            },
            cursor: enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: widget.onActivated,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: DSMotion.fast,
                curve: DSMotion.standard,
                constraints: const BoxConstraints(
                  minWidth: minSize,
                  minHeight: minSize,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(DSRadii.md),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(DSSpacing.xs),
                      child: DSIcon(
                        launcher.icon,
                        color: iconColor,
                        size: iconSize,
                      ),
                    ),
                    if (launcher.hasBadge)
                      Positioned(
                        right: -2,
                        top: -2,
                        child:
                            launcher.badgeCount != null &&
                                launcher.badgeCount! > 0
                            ? DSBadge.count(
                                launcher.badgeCount!,
                                size: DSBadgeSize.small,
                                color: DSColors.statusError,
                              )
                            : DSBadge(
                                label: launcher.badgeLabel,
                                size: DSBadgeSize.small,
                                color: accent,
                              ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
