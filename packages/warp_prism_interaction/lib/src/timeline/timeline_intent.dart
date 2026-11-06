import '../input/action_availability.dart';

/// Timeline verbs + commit invariant (IDS semantics, pure Dart).
///
/// A timeline gesture is a sequence of live previews ([TimelineScrub]) closed
/// by exactly one committed history step ([TimelineSet]). Products own the
/// history store; this module owns the typing that keeps live and committed
/// positions distinct and the gating that keeps denied verbs from dispatching.
///
/// Donor shape (INHERITED-REPORT via `docs/bridge/warpblade/ads-debt.md`
/// §3.2 `TimelineStrip` — continuous playhead with scrubbing, seek delegated
/// to an intent surface — and `docs/bridge/tempest/ads-debt.md` §1.3
/// `StudioTimelineWorkspace` — bidirectional scroll sync with clip rendering):
/// scrub/seek arrive as verbs over an injected model, never as widget state.
/// The one-gesture-one-history-step rule mirrors the shared B1 commit
/// invariant (`FieldEdit Set|Scrub`): many live updates, one commit.
///
/// Position values are **opaque caller numbers**. Prism owns no time ontology:
/// the same verbs drive a seconds ruler and a bar/beat ruler because the
/// caller formats and converts. Pixel mapping below is pure proportional math
/// on those opaque numbers — no tempo, meter, frame, or clock semantics.
///
/// Gating consumes Task 1868's frozen outcome type ([ActionAvailability]) —
/// outcomes are consumed, never re-invented. A denied verb resolves to
/// [TimelineRefusal], never to a dispatch.
///
/// Determinism: same inputs ⇒ same outputs. No wall-clock, no timers, no
/// randomness.
///
/// Lifecycle: EXPERIMENTAL (Task 1874). Spec + fake + suite only; no barrel
/// export, no STABLE promotion in this task.

/// Edit typing: live preview vs committed history step.
///
/// Mirrors the B1 `FieldEdit Set|Scrub` discipline: [TimelineScrub] moves only
/// the live position (zero history cost); [TimelineSet] moves live +
/// committed and costs exactly one history step.
sealed class TimelineEdit {
  const TimelineEdit();

  /// Opaque caller position carried by this edit (never interpreted here).
  double get position;
}

/// Committed edit: exactly one history step.
///
/// Produced by discrete verbs ([TimelineSeek], [TimelineStep]) and by the
/// close of a scrub gesture ([TimelineScrubEnd]).
final class TimelineSet extends TimelineEdit {
  @override
  final double position;

  const TimelineSet(this.position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineSet && other.position == position);

  @override
  int get hashCode => Object.hash(runtimeType, position);

  @override
  String toString() => 'TimelineSet($position)';
}

/// Live-preview edit: moves the live position, commits nothing.
///
/// Produced by [TimelineScrubStart] and [TimelineScrubUpdate]. A gesture may
/// emit any number of scrubs; the commit happens once at [TimelineScrubEnd].
final class TimelineScrub extends TimelineEdit {
  @override
  final double position;

  const TimelineScrub(this.position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineScrub && other.position == position);

  @override
  int get hashCode => Object.hash(runtimeType, position);

  @override
  String toString() => 'TimelineScrub($position)';
}

/// Verbs a timeline surface may emit over an injected model.
///
/// Every verb carries opaque caller numbers only. Verbs never mutate: they
/// resolve through [resolveTimelineVerb] into a [TimelineResolution] the
/// product applies to its own model and history store.
sealed class TimelineIntent {
  const TimelineIntent();
}

/// Discrete jump to [position]: resolves to one [TimelineSet].
final class TimelineSeek extends TimelineIntent {
  final double position;

  const TimelineSeek(this.position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineSeek && other.position == position);

  @override
  int get hashCode => Object.hash(runtimeType, position);

  @override
  String toString() => 'TimelineSeek($position)';
}

/// Gesture open at [position]: resolves to one [TimelineScrub] (no commit).
final class TimelineScrubStart extends TimelineIntent {
  final double position;

  const TimelineScrubStart(this.position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineScrubStart && other.position == position);

  @override
  int get hashCode => Object.hash(runtimeType, position);

  @override
  String toString() => 'TimelineScrubStart($position)';
}

/// Gesture move at [position]: resolves to one [TimelineScrub] (no commit).
final class TimelineScrubUpdate extends TimelineIntent {
  final double position;

  const TimelineScrubUpdate(this.position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineScrubUpdate && other.position == position);

  @override
  int get hashCode => Object.hash(runtimeType, position);

  @override
  String toString() => 'TimelineScrubUpdate($position)';
}

/// Gesture close at [position]: resolves to exactly one [TimelineSet].
///
/// This is the commit-invariant edge: however many scrubs preceded it, the
/// gesture costs one history step, applied here.
final class TimelineScrubEnd extends TimelineIntent {
  final double position;

  const TimelineScrubEnd(this.position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineScrubEnd && other.position == position);

  @override
  int get hashCode => Object.hash(runtimeType, position);

  @override
  String toString() => 'TimelineScrubEnd($position)';
}

/// Signed caller step (e.g. a transport step delta or nudge).
///
/// [delta] is opaque: the product owns step magnitude. Resolution adds it to
/// [anchorPosition] and yields one [TimelineSet]; the anchor arrives from the
/// product's live position, never from a Prism-owned clock.
final class TimelineStep extends TimelineIntent {
  final double delta;

  const TimelineStep(this.delta);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TimelineStep && other.delta == delta);

  @override
  int get hashCode => Object.hash(runtimeType, delta);

  @override
  String toString() => 'TimelineStep($delta)';
}

/// Outcome of resolving a [TimelineIntent] against an authority outcome.
sealed class TimelineResolution {
  const TimelineResolution();
}

/// The verb may apply: carry [edit] to the injected model.
///
/// [limitation] is non-null only when the governing outcome was constrained —
/// the product shows it alongside the applied edit, never hidden.
final class TimelineDispatch extends TimelineResolution {
  final TimelineEdit edit;
  final String? limitation;

  const TimelineDispatch(this.edit, {this.limitation});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineDispatch &&
          other.edit == edit &&
          other.limitation == limitation);

  @override
  int get hashCode => Object.hash(runtimeType, edit, limitation);

  @override
  String toString() => 'TimelineDispatch($edit, limitation: $limitation)';
}

/// The verb must not apply: [reason] travels to the caller, never dropped.
///
/// Denied ≠ hidden ≠ enabled: the surface keeps the control visible with this
/// reason and never dispatches.
final class TimelineRefusal extends TimelineResolution {
  final String reason;

  TimelineRefusal(String reason)
    : reason = reason.trim().isEmpty ? 'Unavailable' : reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineRefusal && other.reason == reason);

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString() => 'TimelineRefusal($reason)';
}

/// Resolves [intent] against the frozen Task 1868 outcome [authority].
///
/// - deny ⇒ [TimelineRefusal] carrying the refusal reason (never a dispatch);
/// - constrain ⇒ [TimelineDispatch] carrying the limitation alongside;
/// - allow ⇒ [TimelineDispatch] with no limitation.
///
/// [anchorPosition] is required for [TimelineStep] (the product's live
/// position the signed delta applies to) and ignored by every other verb.
/// Pure function of its inputs: same intent + authority + anchor ⇒ same
/// resolution.
TimelineResolution resolveTimelineVerb(
  TimelineIntent intent, {
  required ActionAvailability authority,
  double? anchorPosition,
}) {
  if (authority.isDenied) {
    return TimelineRefusal(authority.reason ?? 'Unavailable');
  }
  final limitation = authority.isConstrained ? authority.reason : null;

  final TimelineEdit edit = switch (intent) {
    TimelineSeek(:final position) => TimelineSet(position),
    TimelineScrubStart(:final position) => TimelineScrub(position),
    TimelineScrubUpdate(:final position) => TimelineScrub(position),
    TimelineScrubEnd(:final position) => TimelineSet(position),
    TimelineStep(:final delta) => TimelineSet((anchorPosition ?? 0.0) + delta),
  };
  return TimelineDispatch(edit, limitation: limitation);
}

/// Tracks one scrub gesture at the verb level.
///
/// Accepts any number of [addUpdate] calls (each a live [TimelineScrub]),
/// then [finish] yields exactly one [TimelineSet]. [updateCount] exposes the
/// gesture length so the suite can prove the invariant directly: N updates +
/// one finish ⇒ one commit, regardless of N.
final class TimelineScrubSession {
  int _updates = 0;
  bool _finished = false;

  /// Number of live updates recorded by this gesture so far.
  int get updateCount => _updates;

  /// Whether [finish] has already produced the gesture's single commit.
  bool get isFinished => _finished;

  /// Records one live move. Returns the [TimelineScrub] the product previews.
  TimelineScrub addUpdate(double position) {
    assert(!_finished, 'TimelineScrubSession: gesture already finished');
    _updates++;
    return TimelineScrub(position);
  }

  /// Closes the gesture. Returns the gesture's exactly-one [TimelineSet].
  TimelineSet finish(double position) {
    assert(!_finished, 'TimelineScrubSession: finish called twice');
    _finished = true;
    return TimelineSet(position);
  }
}

/// Maps a horizontal pixel to an opaque position under fixed geometry.
///
/// Pure proportional mapping: `visibleStart + (dx / viewportWidth) *
/// (visibleEnd - visibleStart)`, clamped to the visible interval. Fixed
/// geometry ⇒ fixed mapping: same inputs always yield the same position.
/// No ontology, no clock — the numbers stay opaque.
double timeForPixel({
  required double dx,
  required double viewportWidth,
  required double visibleStart,
  required double visibleEnd,
}) {
  assert(viewportWidth > 0, 'timeForPixel: viewportWidth must be positive');
  assert(
    visibleEnd > visibleStart,
    'timeForPixel: visibleEnd must exceed visibleStart',
  );
  final clamped = dx.clamp(0.0, viewportWidth);
  final fraction = clamped / viewportWidth;
  return visibleStart + fraction * (visibleEnd - visibleStart);
}

/// Maps an opaque position to a horizontal pixel under fixed geometry.
///
/// Inverse of [timeForPixel]: fixed geometry ⇒ fixed pixel. Clamped to the
/// viewport so out-of-range positions pin to an edge instead of escaping.
double pixelForTime({
  required double time,
  required double viewportWidth,
  required double visibleStart,
  required double visibleEnd,
}) {
  assert(viewportWidth > 0, 'pixelForTime: viewportWidth must be positive');
  assert(
    visibleEnd > visibleStart,
    'pixelForTime: visibleEnd must exceed visibleStart',
  );
  final clamped = time.clamp(visibleStart, visibleEnd);
  final fraction = (clamped - visibleStart) / (visibleEnd - visibleStart);
  return fraction * viewportWidth;
}
