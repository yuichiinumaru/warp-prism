import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../tokens/tokens.dart';

/// Pipeline step state for [DSMessageStatusHistory].
///
/// Compact subset of lifecycle states used by Open WebUI-style status trails.
/// Distinct from the full [DSOperationalState] vocabulary.
enum DSMessageStatusStepState {
  /// Step not started.
  pending,

  /// Step actively running.
  running,

  /// Step completed successfully.
  success,

  /// Step failed.
  error,
}

/// One ordered step in a [DSMessageStatusHistory] strip.
@immutable
class DSMessageStatusStep {
  /// Stable unique id within a history strip.
  final String id;

  /// Short step label (e.g. "Retrieving", "Thinking", "Generating").
  final String label;

  /// Current step state.
  final DSMessageStatusStepState state;

  /// Optional secondary detail (duration, message).
  final String? detail;

  const DSMessageStatusStep({
    required this.id,
    required this.label,
    this.state = DSMessageStatusStepState.pending,
    this.detail,
  });

  /// Human-readable state label.
  String get stateLabel => switch (state) {
    DSMessageStatusStepState.pending => 'Pending',
    DSMessageStatusStepState.running => 'Running',
    DSMessageStatusStepState.success => 'Success',
    DSMessageStatusStepState.error => 'Error',
  };

  /// Canonical color for the step indicator.
  Color get stateColor => switch (state) {
    DSMessageStatusStepState.pending => DSColors.statusPending,
    DSMessageStatusStepState.running => DSColors.statusRunning,
    DSMessageStatusStepState.success => DSColors.statusSuccess,
    DSMessageStatusStepState.error => DSColors.statusError,
  };

  /// Whether the status dot should pulse.
  bool get isAnimated => state == DSMessageStatusStepState.running;

  DSMessageStatusStep copyWith({
    String? id,
    String? label,
    DSMessageStatusStepState? state,
    String? detail,
    bool clearDetail = false,
  }) {
    return DSMessageStatusStep(
      id: id ?? this.id,
      label: label ?? this.label,
      state: state ?? this.state,
      detail: clearDetail ? null : (detail ?? this.detail),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMessageStatusStep &&
        other.id == id &&
        other.label == label &&
        other.state == state &&
        other.detail == detail;
  }

  @override
  int get hashCode => Object.hash(id, label, state, detail);
}

/// ASW Observatory Organism — Message Status History
///
/// Compact **pipeline status step strip** (Open WebUI StatusHistory pattern)
/// for agent-run stages: pending / running / success / error.
///
/// ## Boundary (false-gap guard)
///
/// | This organism | Not this organism |
/// | --- | --- |
/// | Compact step trail for a single message/run | Full [DSTimeline] event log |
/// | Fixture pipeline stages only | Live orchestration / mutation gates |
/// | Embeddable in transcript custom blocks | Subagent task trees / TraceDialog |
///
/// ## Contract
///
/// - Empty [steps] is safe: renders a zero-size / empty semantic region.
/// - Horizontal (default) or vertical layout via [direction].
/// - Steps are ordered as provided; no reordering in the widget.
/// - No network, no tool execution.
class DSMessageStatusHistory extends StatelessWidget {
  /// Ordered pipeline steps (left→right or top→bottom).
  final List<DSMessageStatusStep> steps;

  /// Layout axis. Defaults to horizontal compact strip.
  final Axis direction;

  /// When true, hide [DSMessageStatusStep.detail] even if present.
  final bool compact;

  /// Semantic label for the status list region.
  final String semanticLabel;

  /// Whether to draw connector lines between steps.
  final bool showConnectors;

  const DSMessageStatusHistory({
    super.key,
    required this.steps,
    this.direction = Axis.horizontal,
    this.compact = false,
    this.semanticLabel = 'Message status history',
    this.showConnectors = true,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Semantics(
        container: true,
        label: '$semanticLabel, empty',
        child: const SizedBox.shrink(),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: direction == Axis.horizontal
          ? _HorizontalStrip(
              steps: steps,
              compact: compact,
              showConnectors: showConnectors,
            )
          : _VerticalStrip(
              steps: steps,
              compact: compact,
              showConnectors: showConnectors,
            ),
    );
  }
}

class _HorizontalStrip extends StatelessWidget {
  final List<DSMessageStatusStep> steps;
  final bool compact;
  final bool showConnectors;

  const _HorizontalStrip({
    required this.steps,
    required this.compact,
    required this.showConnectors,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0 && showConnectors)
                _Connector(previous: steps[i - 1], axis: Axis.horizontal),
              _StepChip(
                step: steps[i],
                index: i + 1,
                compact: compact,
                direction: Axis.horizontal,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerticalStrip extends StatelessWidget {
  final List<DSMessageStatusStep> steps;
  final bool compact;
  final bool showConnectors;

  const _VerticalStrip({
    required this.steps,
    required this.compact,
    required this.showConnectors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepChip(
            step: steps[i],
            index: i + 1,
            compact: compact,
            direction: Axis.vertical,
          ),
          if (i < steps.length - 1 && showConnectors)
            Padding(
              padding: const EdgeInsets.only(left: 7),
              child: _Connector(previous: steps[i], axis: Axis.vertical),
            ),
        ],
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  final DSMessageStatusStep step;
  final int index;
  final bool compact;
  final Axis direction;

  const _StepChip({
    required this.step,
    required this.index,
    required this.compact,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final detail = !compact && step.detail != null && step.detail!.isNotEmpty
        ? step.detail
        : null;

    final semanticsParts = <String>['Step $index', step.label, step.stateLabel];
    if (detail != null) {
      semanticsParts.add(detail);
    }

    final labelColumn = Column(
      crossAxisAlignment: direction == Axis.horizontal
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DSText.labelSmall(
          step.label,
          color: step.state == DSMessageStatusStepState.pending
              ? DSColors.textTertiary
              : DSColors.textPrimary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (detail != null) ...[
          const SizedBox(height: 2),
          DSText.labelSmall(
            detail,
            color: DSColors.textTertiary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    final content = direction == Axis.horizontal
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSStatusDot(
                color: step.stateColor,
                size: 10,
                animated: step.isAnimated,
                tooltip: step.stateLabel,
              ),
              const SizedBox(height: DSSpacing.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: labelColumn,
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSStatusDot(
                color: step.stateColor,
                size: 10,
                animated: step.isAnimated,
                tooltip: step.stateLabel,
              ),
              const SizedBox(width: DSSpacing.sm),
              Flexible(child: labelColumn),
            ],
          );

    return Semantics(
      container: true,
      label: semanticsParts.join(', '),
      child: Padding(
        key: Key('message-status-step-${step.id}'),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.xs,
          vertical: DSSpacing.xs,
        ),
        child: content,
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  final DSMessageStatusStep previous;
  final Axis axis;

  const _Connector({required this.previous, required this.axis});

  @override
  Widget build(BuildContext context) {
    final color =
        previous.state == DSMessageStatusStepState.success ||
            previous.state == DSMessageStatusStepState.running
        ? previous.stateColor.withValues(alpha: 0.55)
        : DSColors.borderSubtle;

    if (axis == Axis.horizontal) {
      return Container(
        width: 20,
        height: 2,
        margin: const EdgeInsets.only(bottom: 22),
        color: color,
      );
    }

    return Container(
      width: 2,
      height: 12,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: color,
    );
  }
}

// =============================================================================
// Fixtures (gallery / tests) — no network
// =============================================================================

/// Shared multi-step status history fixture (happy path).
List<DSMessageStatusStep> dsMessageStatusHistorySuccessFixture() {
  return const [
    DSMessageStatusStep(
      id: 'step-retrieve',
      label: 'Retrieving',
      state: DSMessageStatusStepState.success,
      detail: '42ms',
    ),
    DSMessageStatusStep(
      id: 'step-think',
      label: 'Thinking',
      state: DSMessageStatusStepState.success,
      detail: '180ms',
    ),
    DSMessageStatusStep(
      id: 'step-tool',
      label: 'Tool call',
      state: DSMessageStatusStepState.success,
      detail: '420ms',
    ),
    DSMessageStatusStep(
      id: 'step-generate',
      label: 'Generating',
      state: DSMessageStatusStepState.success,
      detail: '1.2s',
    ),
  ];
}

/// Shared in-progress status history fixture.
List<DSMessageStatusStep> dsMessageStatusHistoryRunningFixture() {
  return const [
    DSMessageStatusStep(
      id: 'step-retrieve',
      label: 'Retrieving',
      state: DSMessageStatusStepState.success,
      detail: '38ms',
    ),
    DSMessageStatusStep(
      id: 'step-think',
      label: 'Thinking',
      state: DSMessageStatusStepState.success,
      detail: '95ms',
    ),
    DSMessageStatusStep(
      id: 'step-tool',
      label: 'Tool call',
      state: DSMessageStatusStepState.running,
      detail: '…',
    ),
    DSMessageStatusStep(
      id: 'step-generate',
      label: 'Generating',
      state: DSMessageStatusStepState.pending,
    ),
  ];
}

/// Shared error-path status history fixture.
List<DSMessageStatusStep> dsMessageStatusHistoryErrorFixture() {
  return const [
    DSMessageStatusStep(
      id: 'step-retrieve',
      label: 'Retrieving',
      state: DSMessageStatusStepState.success,
      detail: '51ms',
    ),
    DSMessageStatusStep(
      id: 'step-tool',
      label: 'Tool call',
      state: DSMessageStatusStepState.error,
      detail: 'refused',
    ),
    DSMessageStatusStep(
      id: 'step-generate',
      label: 'Generating',
      state: DSMessageStatusStepState.pending,
    ),
  ];
}
