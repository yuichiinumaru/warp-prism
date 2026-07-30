import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Toast
///
/// Individual toast notification widget with severity coloring,
/// glass-panel styling, and optional action button.
///
/// This widget is a pure renderer — it holds no timers and manages no
/// overlay entries. Pair it with [DSToastManager] for stacking,
/// auto-dismiss, and overlay management.
///
/// Usage:
/// ```dart
/// DSToast(
///   entry: DSToastEntry(
///     id: '1',
///     severity: DSToastSeverity.success,
///     title: 'Task completed',
///     message: 'All proofs verified',
///   ),
///   onDismiss: () => manager.dismiss('1'),
/// )
/// ```
class DSToast extends StatelessWidget {
  /// The toast entry data.
  final DSToastEntry entry;

  /// Called when the close button is tapped.
  final VoidCallback? onDismiss;

  /// Called when the action button is tapped.
  final VoidCallback? onAction;

  /// Whether this toast is currently hovered (for pause-on-hover).
  final bool hovered;

  const DSToast({
    super.key,
    required this.entry,
    this.onDismiss,
    this.onAction,
    this.hovered = false,
  });

  @override
  Widget build(BuildContext context) {
    final risk = entry.riskTier;
    final severityColor = risk?.color ?? entry.severity.color;
    final severityIcon = risk?.icon ?? entry.severity.icon;
    final severityLabel = risk?.label ?? entry.severity.label;

    // Live-region label encodes severity/risk + title + optional message so
    // decorative children can stay excluded without dropping message text.
    final regionSuffix = entry.riskRegion == null
        ? ''
        : ' · ${entry.riskRegion}';
    final liveRegionLabel = entry.message == null
        ? '$severityLabel$regionSuffix: ${entry.title}'
        : '$severityLabel$regionSuffix: ${entry.title}. ${entry.message}';

    return Semantics(
      container: true,
      explicitChildNodes: true,
      liveRegion: true,
      label: liveRegionLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        // Glass budget: multi-instance overlays (up to DSToastManager.maxVisible)
        // must stay on the simple path. Near-opaque fill already reads as glass;
        // BackdropFilter would stack GPU cost for little visual gain.
        child: DSGlassPanelSimple(
          radius: DSRadii.md,
          backgroundColor: DSColors.obsidianElevated.withValues(alpha: 0.95),
          borderColor: risk != null
              ? severityColor.withValues(alpha: 0.55)
              : DSColors.borderDefault,
          shadows: DSShadows.elevation2,
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              // Severity accent bar (4px left edge)
              //
              // height cannot be double.infinity because the toast may live
              // inside an overlay with unconstrained height constraints.
              // Using kMinInteractiveDimension (48) ensures a consistent,
              // accessible minimum height while keeping the bar visually
              // proportional to the content.
              Container(
                width: 4,
                height: kMinInteractiveDimension,
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(DSRadii.md),
                    bottomLeft: Radius.circular(DSRadii.md),
                  ),
                ),
              ),

              // Severity icon
              // Exclude from semantics — the outer Semantics(label: ...)
              // already encodes the severity+title combination.
              ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: DSSpacing.md,
                    top: DSSpacing.md,
                    bottom: DSSpacing.md,
                  ),
                  child: DSIcon(
                    severityIcon,
                    color: severityColor,
                    size: 20,
                    semanticLabel: severityLabel,
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.md,
                  ),
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (risk != null) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DSSpacing.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: severityColor.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(
                                    DSRadii.sm,
                                  ),
                                  border: Border.all(
                                    color: severityColor.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  entry.riskRegion == null
                                      ? risk.label.toUpperCase()
                                      : '${risk.label.toUpperCase()} · ${entry.riskRegion}',
                                  style: DSTypography.labelSmall.copyWith(
                                    color: severityColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DSSpacing.xxs),
                        ],
                        Text(
                          entry.title,
                          style: DSTypography.labelLarge.copyWith(
                            color: DSColors.textPrimary,
                          ),
                        ),
                        if (entry.message != null) ...[
                          const SizedBox(height: DSSpacing.xxs),
                          Text(
                            entry.message!,
                            style: DSTypography.bodySmall.copyWith(
                              color: DSColors.textTertiary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Action button
              if (entry.actionLabel != null)
                Padding(
                  padding: const EdgeInsets.only(right: DSSpacing.xs),
                  child: Semantics(
                    label: entry.actionLabel,
                    button: true,
                    child: TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: severityColor,
                        // Enforce WCAG 48x48 minimum interactive target.
                        minimumSize: const Size(
                          kMinInteractiveDimension,
                          kMinInteractiveDimension,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: DSSpacing.xs,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DSRadii.sm),
                        ),
                        tapTargetSize: MaterialTapTargetSize.padded,
                      ),
                      child: ExcludeSemantics(
                        child: Text(
                          entry.actionLabel!,
                          style: DSTypography.labelMedium.copyWith(
                            color: severityColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Dismiss button
              if (onDismiss != null)
                Padding(
                  padding: const EdgeInsets.only(right: DSSpacing.xs),
                  child: Semantics(
                    label: 'Dismiss notification',
                    button: true,
                    child: SizedBox(
                      width: kMinInteractiveDimension,
                      height: kMinInteractiveDimension,
                      child: IconButton(
                        onPressed: onDismiss,
                        icon: const DSIcon.small(
                          DSIcons.close,
                          color: DSColors.textTertiary,
                        ),
                        padding: EdgeInsets.zero,
                        splashRadius: kMinInteractiveDimension / 2,
                        tooltip: 'Dismiss',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Severity levels for [DSToast].
///
/// Each severity maps to a distinct [DSColors] color and [DSIcons] icon.
enum DSToastSeverity {
  /// Informational — neutral blue.
  info(color: DSColors.statusInfo, icon: DSIcons.info, label: 'Info'),

  /// Success — green.
  success(
    color: DSColors.statusSuccess,
    icon: DSIcons.success,
    label: 'Success',
  ),

  /// Warning — amber.
  warning(
    color: DSColors.statusWarning,
    icon: DSIcons.warning,
    label: 'Warning',
  ),

  /// Error — red.
  error(color: DSColors.statusError, icon: DSIcons.error, label: 'Error');

  const DSToastSeverity({
    required this.color,
    required this.icon,
    required this.label,
  });

  /// The accent color for this severity.
  final Color color;

  /// The icon for this severity.
  final IconData icon;

  /// Human-readable label for accessibility.
  final String label;
}

/// Risk tier for geo / ops risk toast variants (Task 1522 / O-28).
///
/// Extends the **existing** toast system — not a second toast stack.
/// Maps to operational/risk colors already present on [DSColors] while still
/// projecting a base [DSToastSeverity] so [DSToastManager] stays unchanged.
enum DSToastRiskTier {
  /// Low residual risk / informational geo notice.
  low,

  /// Elevated awareness — not blocking.
  moderate,

  /// High risk requiring operator attention.
  high,

  /// Critical risk — immediate escalation.
  critical;

  /// Accent color from the operational/risk palette.
  ///
  /// Four-step ladder with **distinct** hex values (not token aliases of each
  /// other): info blue → warning amber → rule orange → error red. High does
  /// **not** reuse [DSColors.statusExposed] because that alias equals
  /// [DSColors.statusError] and would collapse high vs critical chrome.
  Color get color {
    switch (this) {
      case DSToastRiskTier.low:
        return DSColors.statusInfo;
      case DSToastRiskTier.moderate:
        return DSColors.statusWarning;
      case DSToastRiskTier.high:
        return DSColors
            .assetRule; // orange — elevated ops risk, not critical red
      case DSToastRiskTier.critical:
        return DSColors.statusError;
    }
  }

  /// Icon for this risk tier.
  IconData get icon {
    switch (this) {
      case DSToastRiskTier.low:
        return DSIcons.info;
      case DSToastRiskTier.moderate:
        return DSIcons.warning;
      case DSToastRiskTier.high:
        // Distinct from moderate warning amber — report/priority chrome.
        return Icons.report_outlined;
      case DSToastRiskTier.critical:
        return DSIcons.error;
    }
  }

  /// Human-readable risk label for accessibility and badge chrome.
  String get label {
    switch (this) {
      case DSToastRiskTier.low:
        return 'Low risk';
      case DSToastRiskTier.moderate:
        return 'Moderate risk';
      case DSToastRiskTier.high:
        return 'High risk';
      case DSToastRiskTier.critical:
        return 'Critical risk';
    }
  }

  /// Base toast severity for manager/live-region fallbacks.
  DSToastSeverity get asToastSeverity {
    switch (this) {
      case DSToastRiskTier.low:
        return DSToastSeverity.info;
      case DSToastRiskTier.moderate:
        return DSToastSeverity.warning;
      case DSToastRiskTier.high:
        return DSToastSeverity.error;
      case DSToastRiskTier.critical:
        return DSToastSeverity.error;
    }
  }
}

/// Immutable data class representing a single toast notification entry.
///
/// Used by [DSToast] for rendering and by [DSToastManager] for lifecycle
/// management.
///
/// The [id] field must be unique within a manager's active entry list.
/// Use [createdAt] for ordering and auto-dismiss calculations.
///
/// Risk-aware toasts use [DSToastEntry.risk] (or set [riskTier]) so geo/ops
/// risk chrome rides the **same** [DSToastManager] stack (Task 1522 / O-28).
class DSToastEntry {
  /// Unique identifier for this toast.
  final String id;

  /// Severity level that determines color and icon.
  final DSToastSeverity severity;

  /// Primary message (required).
  final String title;

  /// Optional secondary description.
  final String? message;

  /// Optional action button label (e.g., "Undo", "View").
  final String? actionLabel;

  /// Optional entry-owned action callback.
  ///
  /// When set, [DSToastManager] invokes this on action press instead of
  /// only dismissing. Pair with [dismissOnAction] to keep the toast open.
  final VoidCallback? onAction;

  /// Whether the manager should dismiss this toast after [onAction].
  ///
  /// Defaults to `true`. Set to `false` for persistent action toasts.
  final bool dismissOnAction;

  /// How long this toast should remain visible before auto-dismiss.
  ///
  /// Defaults to 4 seconds. Set to [Duration.zero] to disable auto-dismiss.
  final Duration duration;

  /// Timestamp when this entry was created.
  ///
  /// Used for auto-dismiss timer calculation and stacking order.
  final DateTime createdAt;

  /// Optional risk tier — when set, [DSToast] renders risk chrome using
  /// operational/risk colors while still flowing through [DSToastManager].
  final DSToastRiskTier? riskTier;

  /// Optional geo/region label shown with the risk badge (e.g. `"Sector-7"`).
  final String? riskRegion;

  DSToastEntry({
    required this.id,
    required this.severity,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.dismissOnAction = true,
    this.duration = const Duration(seconds: 4),
    DateTime? createdAt,
    this.riskTier,
    this.riskRegion,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Risk-aware toast factory — single manager, risk-styled content.
  ///
  /// Maps [riskTier] onto base [DSToastSeverity] so existing manager timers,
  /// stacking, and dismiss paths remain unchanged.
  factory DSToastEntry.risk({
    required String id,
    required DSToastRiskTier riskTier,
    required String title,
    String? message,
    String? riskRegion,
    String? actionLabel,
    VoidCallback? onAction,
    bool dismissOnAction = true,
    Duration duration = const Duration(seconds: 6),
    DateTime? createdAt,
  }) {
    return DSToastEntry(
      id: id,
      severity: riskTier.asToastSeverity,
      title: title,
      message: message,
      riskTier: riskTier,
      riskRegion: riskRegion,
      actionLabel: actionLabel,
      onAction: onAction,
      dismissOnAction: dismissOnAction,
      duration: duration,
      createdAt: createdAt,
    );
  }

  /// Whether this entry is a risk-styled variant.
  bool get isRiskVariant => riskTier != null;

  /// Creates a copy with optional overrides.
  DSToastEntry copyWith({
    String? id,
    DSToastSeverity? severity,
    String? title,
    String? message,
    bool clearMessage = false,
    String? actionLabel,
    bool clearActionLabel = false,
    VoidCallback? onAction,
    bool clearOnAction = false,
    bool? dismissOnAction,
    Duration? duration,
    DateTime? createdAt,
    DSToastRiskTier? riskTier,
    bool clearRiskTier = false,
    String? riskRegion,
    bool clearRiskRegion = false,
  }) {
    return DSToastEntry(
      id: id ?? this.id,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: clearMessage ? null : (message ?? this.message),
      actionLabel: clearActionLabel ? null : (actionLabel ?? this.actionLabel),
      onAction: clearOnAction ? null : (onAction ?? this.onAction),
      dismissOnAction: dismissOnAction ?? this.dismissOnAction,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      riskTier: clearRiskTier ? null : (riskTier ?? this.riskTier),
      riskRegion: clearRiskRegion ? null : (riskRegion ?? this.riskRegion),
    );
  }
}
