import 'package:meta/meta.dart';

/// Pure-Dart driver for the staged job-banner vocabulary (Task 1858, F-10).
///
/// Models one banner lifecycle — queued → running → terminal
/// (succeeded / failed / cancelled) — with staged ordering, cancel
/// availability, terminal receipt attachment, and the fail-closed
/// indeterminate contract (macro-review C6 convergence).
///
/// Receipt rule: receipt lines are opaque consumer content. This model stores
/// and returns them verbatim; it never computes, hashes, or verifies them
/// (Prism owns the slot, never the bytes).
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
enum JobBannerPhase {
  /// Ordered before execution begins. Determinate, non-terminal.
  queued,

  /// Execution in flight. Determinate when staged progress is present.
  running,

  /// Terminal success. Receipt lines may be attached.
  succeeded,

  /// Terminal failure. Carries an optional caller-provided reason.
  failed,

  /// Terminal operator cancellation. Carries the propagated cancel reason.
  cancelled,

  /// Determination withheld (Task 1869 F-02 vocabulary, read-only here).
  ///
  /// Fail-closed: never maps to success, enabled, or disabled presentation.
  unknown,
}

/// Ordered lifecycle position of one banner stage.
@experimental
enum JobBannerStageState {
  /// Not yet started.
  pending,

  /// Currently executing.
  active,

  /// Finished. Terminal per stage, not per job.
  done,

  /// Bypassed without execution (caller-determined, never inferred here).
  skipped,
}

/// One named stage with deterministic fractional progress.
///
/// [progress] is clamped to `0.0..1.0` at construction.
@experimental
@immutable
class JobBannerStage {
  /// Human-readable stage label (caller-provided, e.g. `Separating vocals`).
  final String label;

  /// Fractional completion, clamped to `0.0..1.0`.
  final double progress;

  /// Lifecycle position of this stage.
  final JobBannerStageState state;

  /// Creates a stage. [progress] is clamped to `0.0..1.0`.
  const JobBannerStage({
    required this.label,
    double progress = 0.0,
    this.state = JobBannerStageState.pending,
  }) : progress = progress < 0.0 ? 0.0 : (progress > 1.0 ? 1.0 : progress);

  /// Returns a copy with overridden fields.
  JobBannerStage copyWith({
    String? label,
    double? progress,
    JobBannerStageState? state,
  }) {
    return JobBannerStage(
      label: label ?? this.label,
      progress: progress ?? this.progress,
      state: state ?? this.state,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is JobBannerStage &&
      other.label == label &&
      other.progress == progress &&
      other.state == state;

  @override
  int get hashCode => Object.hash(label, progress, state);

  @override
  String toString() =>
      'JobBannerStage($label, ${(progress * 100).round()}%, $state)';
}

/// Fail-closed presentation contract for [JobBannerPhase] (Task 1869 reuse).
///
/// Centralizes the rule the banner shares with `DSStateType`: withheld
/// determination must never be presented through success or disabled
/// affordances.
@experimental
extension JobBannerPhaseSemantics on JobBannerPhase {
  /// True for [JobBannerPhase.succeeded], [JobBannerPhase.failed], and
  /// [JobBannerPhase.cancelled]. Receipt content may only exist here.
  bool get isTerminal =>
      this == JobBannerPhase.succeeded ||
      this == JobBannerPhase.failed ||
      this == JobBannerPhase.cancelled;

  /// True only for [JobBannerPhase.unknown]. Withheld determination is
  /// excluded from golden capture and from progress animation.
  bool get isIndeterminate => this == JobBannerPhase.unknown;

  /// Screen-reader phase description. The withheld-determination wording
  /// mirrors the frozen F-02 vocabulary (`no action taken`).
  String get semanticLabel {
    switch (this) {
      case JobBannerPhase.queued:
        return 'Queued: waiting to start';
      case JobBannerPhase.running:
        return 'Running: execution in flight';
      case JobBannerPhase.succeeded:
        return 'Succeeded: terminal receipt available';
      case JobBannerPhase.failed:
        return 'Failed: execution ended with an error';
      case JobBannerPhase.cancelled:
        return 'Cancelled: stopped by operator request';
      case JobBannerPhase.unknown:
        return 'Job indeterminate: state not yet determined, no action taken';
    }
  }
}

/// In-memory staged job-banner driver for deterministic testing.
///
/// Models one banner lifecycle: queued → running → terminal
/// (succeeded / failed / cancelled), with an indeterminate escape hatch
/// ([markUnknown]) that consumes the frozen F-02 vocabulary read-only.
///
/// Transition law (fail-closed, deterministic):
///
/// - Cancel is offered only when [cancellable] is true and the phase is
///   non-terminal; otherwise [requestCancel] throws [StateError].
/// - A cancel request requires a non-empty reason, propagated verbatim to
///   [cancelReason] for announcement (never colour-only).
/// - Receipt lines attach only on [complete] (terminal success) and are
///   returned verbatim. [fail], [requestCancel], and [markUnknown] clear them.
/// - Terminal phases are absorbing: every mutating transition from a
///   terminal phase throws [StateError].
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class FakeJobBannerModel {
  JobBannerPhase _phase = JobBannerPhase.queued;
  final List<JobBannerStage> _stages;
  bool _cancellable;
  String? _cancelReason;
  List<String>? _receiptLines;
  String? _failureReason;

  /// Creates a driver over caller-provided stage labels.
  ///
  /// [cancellable] and [cancelReason] follow the gated-action rule: a
  /// non-empty [cancelReason] is required whenever [cancellable] is true.
  FakeJobBannerModel({
    required List<String> stageLabels,
    bool cancellable = false,
    String? cancelReason,
  }) : _stages = [
         for (final label in stageLabels) JobBannerStage(label: label),
       ],
       _cancellable = cancellable,
       _cancelReason = cancelReason {
    if (_cancellable && (_cancelReason == null || _cancelReason!.isEmpty)) {
      throw ArgumentError.value(
        cancelReason,
        'cancelReason',
        'A cancellable banner requires a non-empty cancel reason.',
      );
    }
  }

  /// Current lifecycle phase.
  JobBannerPhase get phase => _phase;

  /// Ordered stage snapshots (unmodifiable).
  List<JobBannerStage> get stages => List.unmodifiable(_stages);

  /// Whether cancel is currently offered.
  ///
  /// True only when the banner opted into cancellation and the phase is
  /// non-terminal. Terminal phases never offer cancel.
  bool get cancelOffered => _cancellable && !_phase.isTerminal;

  /// Propagated cancel reason, if any.
  String? get cancelReason => _cancelReason;

  /// Opaque consumer receipt lines. Non-null only after [complete].
  List<String>? get receiptLines =>
      _receiptLines == null ? null : List.unmodifiable(_receiptLines!);

  /// Caller-provided failure reason, if failed.
  String? get failureReason => _failureReason;

  /// Whether the banner holds a terminal receipt.
  bool get hasReceipt => _receiptLines != null && _phase.isTerminal;

  /// Queued → running. Throws [StateError] from any other phase.
  void start() {
    _requirePhase(JobBannerPhase.queued, 'start');
    _phase = JobBannerPhase.running;
  }

  /// Marks stage [index] active.
  void activateStage(int index) {
    _requireNonTerminal('activateStage');
    _replaceStage(
      index,
      _stages[_checkedIndex(index)].copyWith(state: JobBannerStageState.active),
    );
  }

  /// Sets deterministic fractional progress for stage [index].
  ///
  /// Values are clamped to `0.0..1.0` by [JobBannerStage].
  void setStageProgress(int index, double value) {
    _requireNonTerminal('setStageProgress');
    _replaceStage(
      index,
      _stages[_checkedIndex(index)].copyWith(progress: value),
    );
  }

  /// Marks stage [index] done at full progress.
  void completeStage(int index) {
    _requireNonTerminal('completeStage');
    _replaceStage(
      index,
      const JobBannerStage(label: '').copyWith(
        label: _stages[_checkedIndex(index)].label,
        progress: 1.0,
        state: JobBannerStageState.done,
      ),
    );
  }

  /// Running → succeeded with opaque consumer receipt lines.
  ///
  /// [receiptLines] must be non-empty and are stored verbatim — never
  /// parsed, hashed, or verified here.
  void complete({required List<String> receiptLines}) {
    _requireNonTerminal('complete');
    if (receiptLines.isEmpty) {
      throw ArgumentError.value(
        receiptLines,
        'receiptLines',
        'A terminal receipt requires at least one consumer line.',
      );
    }
    _receiptLines = List.of(receiptLines);
    _failureReason = null;
    _phase = JobBannerPhase.succeeded;
  }

  /// Non-terminal → failed with an optional caller-provided reason.
  ///
  /// Clears any staged receipt: only success carries a receipt.
  void fail({String? reason}) {
    _requireNonTerminal('fail');
    _receiptLines = null;
    _failureReason = reason;
    _phase = JobBannerPhase.failed;
  }

  /// Requests operator cancellation. Requires [cancelOffered] and a
  /// non-empty [reason], propagated verbatim to [cancelReason].
  ///
  /// Throws [StateError] when cancel is not offered (not cancellable or
  /// already terminal) or when [reason] is empty.
  void requestCancel({required String reason}) {
    if (!cancelOffered) {
      throw StateError(
        'Cancel is not offered (cancellable=$_cancellable, phase=$_phase).',
      );
    }
    if (reason.isEmpty) {
      throw ArgumentError.value(
        reason,
        'reason',
        'Cancellation requires a non-empty reason for announcement.',
      );
    }
    _receiptLines = null;
    _failureReason = null;
    _cancelReason = reason;
    _phase = JobBannerPhase.cancelled;
  }

  /// Withholds determination (Task 1869 F-02 vocabulary, read-only).
  ///
  /// Allowed from any non-terminal phase. Clears staged receipts — only
  /// terminal success carries a receipt — and never maps to success or
  /// disabled presentation (see [JobBannerPhaseSemantics]).
  void markUnknown() {
    _requireNonTerminal('markUnknown');
    _receiptLines = null;
    _failureReason = null;
    _phase = JobBannerPhase.unknown;
  }

  /// Updates the cancellation gate. Disabling cancel clears the reason;
  /// enabling requires a non-empty reason.
  void setCancellable(bool value, {String? reason}) {
    if (value && (reason ?? _cancelReason ?? '').isEmpty) {
      throw ArgumentError.value(
        reason,
        'reason',
        'A cancellable banner requires a non-empty cancel reason.',
      );
    }
    _cancellable = value;
    _cancelReason = value ? (reason ?? _cancelReason) : null;
  }

  int _checkedIndex(int index) {
    if (index < 0 || index >= _stages.length) {
      throw RangeError.index(index, _stages, 'index');
    }
    return index;
  }

  void _replaceStage(int index, JobBannerStage stage) {
    _stages[_checkedIndex(index)] = stage;
  }

  void _requirePhase(JobBannerPhase expected, String operation) {
    if (_phase != expected) {
      throw StateError(
        'Cannot $operation from phase $_phase (expected $expected).',
      );
    }
  }

  void _requireNonTerminal(String operation) {
    if (_phase.isTerminal) {
      throw StateError('Cannot $operation from terminal phase $_phase.');
    }
  }
}
