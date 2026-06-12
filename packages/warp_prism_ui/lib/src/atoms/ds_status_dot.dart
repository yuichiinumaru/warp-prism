import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Status Dot — small colored indicator for operational states.
///
/// Supports:
/// - Basic semantic constructors: [success], [warning], [error], [info], [neutral]
/// - All 15 operational state constructors: [pending], [running], [approved],
///   [rejected], [promoted], [archived], [healthy], [degraded], [disabled],
///   [unverified], [exposed], [redacted], [stale], [excluded]
/// - An operational state factory: [DSStatusDot.operational]
/// - An optional [animated] flag for pulsing glow
/// - An optional [tooltip]
///
/// ## State Matrix
///
/// | State | Color | Animated | Tooltip Default |
/// |-------|-------|----------|-----------------|
/// | pending | textTertiary | No | "Pending" |
/// | running | accentGold | Yes | "Running" |
/// | approved | statusSuccess | No | "Approved" |
/// | rejected | statusError | No | "Rejected" |
/// | promoted | accentCyan | No | "Promoted" |
/// | archived | textDisabled | No | "Archived" |
/// | healthy | statusSuccess | No | "Healthy" |
/// | degraded | statusWarning | No | "Degraded" |
/// | error | statusError | No | "Error" |
/// | disabled | textDisabled | No | "Disabled" |
/// | unverified | textTertiary | No | "Unverified" |
/// | exposed | statusError | Yes | "Exposed" |
/// | redacted | accentViolet | No | "Redacted" |
/// | stale | statusWarning | No | "Stale" |
/// | excluded | textDisabled | No | "Excluded" |
///
/// Contract:
/// - All status constructors are const.
/// - Default size is 8px (matches DSSpacing.xxs + visual padding).
/// - [animated] produces a pulsing glow via [DSMotion] curves.
/// - [tooltip] wraps in [Tooltip] when non-null.
class DSStatusDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool animated;
  final String? tooltip;

  const DSStatusDot({
    super.key,
    required this.color,
    this.size = 8,
    this.animated = false,
    this.tooltip,
  });

  // === BASIC CONSTRUCTORS ===
  const DSStatusDot.success({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip,
  }) : color = DSColors.statusSuccess;

  const DSStatusDot.warning({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip,
  }) : color = DSColors.statusWarning;

  const DSStatusDot.error({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip,
  }) : color = DSColors.statusError;

  const DSStatusDot.info({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip,
  }) : color = DSColors.statusInfo;

  const DSStatusDot.neutral({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip,
  }) : color = DSColors.textTertiary;

  // === OPERATIONAL STATE CONSTRUCTORS ===
  // Lifecycle states

  /// Pending — awaiting start. Muted neutral dot.
  const DSStatusDot.pending({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Pending',
  }) : color = DSColors.statusPending;

  /// Running — actively in progress. Animated gold dot.
  const DSStatusDot.running({
    super.key,
    this.size = 8,
    this.animated = true,
    this.tooltip = 'Running',
  }) : color = DSColors.statusRunning;

  /// Approved — review accepted. Green dot.
  const DSStatusDot.approved({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Approved',
  }) : color = DSColors.statusApproved;

  /// Rejected — review declined. Red dot.
  const DSStatusDot.rejected({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Rejected',
  }) : color = DSColors.statusRejected;

  /// Promoted — advanced to next stage. Cyan dot.
  const DSStatusDot.promoted({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Promoted',
  }) : color = DSColors.statusPromoted;

  /// Archived — terminal completed state. Gray dot.
  const DSStatusDot.archived({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Archived',
  }) : color = DSColors.statusArchived;

  // Health states

  /// Healthy — operating normally. Green dot.
  const DSStatusDot.healthy({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Healthy',
  }) : color = DSColors.statusHealthy;

  /// Degraded — partial impairment. Amber dot.
  const DSStatusDot.degraded({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Degraded',
  }) : color = DSColors.statusDegraded;

  /// Disabled — intentionally inactive. Gray dot.
  const DSStatusDot.disabled({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Disabled',
  }) : color = DSColors.statusDisabled;

  // Verification states

  /// Unverified — not yet verified. Muted neutral dot.
  const DSStatusDot.unverified({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Unverified',
  }) : color = DSColors.statusUnverified;

  /// Exposed — at risk, unverified and critical. Animated red dot.
  const DSStatusDot.exposed({
    super.key,
    this.size = 8,
    this.animated = true,
    this.tooltip = 'Exposed',
  }) : color = DSColors.statusExposed;

  /// Redacted — content hidden. Violet dot.
  const DSStatusDot.redacted({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Redacted',
  }) : color = DSColors.statusRedacted;

  // Governance states

  /// Stale — needs refresh. Amber dot.
  const DSStatusDot.stale({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Stale',
  }) : color = DSColors.statusStale;

  /// Excluded — filtered out. Gray dot.
  const DSStatusDot.excluded({
    super.key,
    this.size = 8,
    this.animated = false,
    this.tooltip = 'Excluded',
  }) : color = DSColors.statusExcluded;

  // === OPERATIONAL STATE FACTORY ===
  /// Creates a status dot from a [DSOperationalState].
  ///
  /// The dot color is derived from the state's canonical color mapping.
  /// The `running` and `exposed` states default to [animated] = true.
  ///
  /// If [tooltip] is null, the state's label is used.
  factory DSStatusDot.operational(
    DSOperationalState state, {
    Key? key,
    double size = 8,
    bool? animated,
    String? tooltip,
  }) {
    return DSStatusDot(
      key: key,
      color: state.color,
      size: size,
      animated:
          animated ??
          (state == DSOperationalState.running ||
              state == DSOperationalState.exposed),
      tooltip: tooltip ?? state.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dot = animated
        ? _AnimatedDot(color: color, size: size)
        : Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );

    if (tooltip != null) {
      return Semantics(
        label: tooltip,
        child: Tooltip(message: tooltip!, child: dot),
      );
    }

    return dot;
  }
}

class _AnimatedDot extends StatefulWidget {
  final Color color;
  final double size;

  const _AnimatedDot({required this.color, required this.size});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5 * _animation.value),
                blurRadius: 4 + (4 * _animation.value),
                spreadRadius: 1 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
