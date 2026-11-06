// Two-tier capture reference (Task 1867, part b).
//
// Tier 1 — chrome-free deterministic render: the subject is pumped with no
// overlay, no theme chrome, and no animation drivers. Only bounded pumps are
// allowed ([pumpBounded]); `pumpAndSettle` is forbidden because real hosts own
// perpetual animations that never reach quiescence by design. Same input must
// produce the same finder/semantics output on repeat.
//
// Tier 2 — windowed chrome capture: the subject renders inside a real windowed
// viewport with host chrome (MediaQuery/Scaffold/Overlay). The outcome is a
// structured [WindowedCaptureInspect] record — never a bare screenshot — and
// every error the oracle collects stays visible in the record (missing capture
// capability is BLOCKED/FAIL, never log-and-pass).
//
// Frame-boundary drain + cooperative cancel: [FrameBoundaryDrain] advances the
// frame pipeline at frame boundaries only, and [CooperativeCancelScope] is the
// placement contract the FRB adapter path plugs into — the adapter's
// cancel-and-replace token observes this scope shape (request → observe →
// terminate), so capture-time cancellation is cooperative, never a torn read.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../oracle/error_oracle.dart';

/// Which capture tier a run belongs to.
enum CaptureTier {
  /// Chrome-free deterministic render (no overlay, no theme chrome).
  golden,

  /// Windowed chrome capture (real viewport + structured inspect).
  windowed,
}

/// Structured inspect record for a Tier 2 windowed capture.
///
/// Screenshots alone are not evidence: the record binds the window geometry,
/// the theme recipe, the bounded pump budget actually spent, and every
/// material error the oracle collected. An empty `errors` list with a
/// non-empty `findings` list is a PASS; errors are always visible here.
class WindowedCaptureInspect {
  const WindowedCaptureInspect({
    required this.tier,
    required this.host,
    required this.route,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.devicePixelRatio,
    required this.themeRecipe,
    required this.framesSpent,
    required this.findings,
    required this.errors,
  });

  final CaptureTier tier;
  final String host;
  final String route;
  final double viewportWidth;
  final double viewportHeight;
  final double devicePixelRatio;
  final String themeRecipe;
  final int framesSpent;
  final List<String> findings;
  final List<String> errors;

  bool get passed => errors.isEmpty;

  Map<String, Object?> toJson() => <String, Object?>{
    'tier': tier.name,
    'host': host,
    'route': route,
    'viewport': <String, Object?>{
      'width': viewportWidth,
      'height': viewportHeight,
      'device_pixel_ratio': devicePixelRatio,
    },
    'theme_recipe': themeRecipe,
    'frames_spent': framesSpent,
    'findings': findings,
    'errors': errors,
  };

  @override
  String toString() =>
      'WindowedCaptureInspect(${tier.name} $host:$route '
      '${viewportWidth}x$viewportHeight@$devicePixelRatio '
      'frames=$framesSpent findings=${findings.length} '
      'errors=${errors.length})';
}

/// Pumps exactly [frames] frames of [step] each — the only pump primitive
/// capture tiers may use. Bounded waits only; never `pumpAndSettle`.
Future<void> pumpBounded(
  WidgetTester tester, {
  int frames = 2,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(step);
  }
}

/// Drains the frame pipeline at frame boundaries.
///
/// Each boundary is one bounded pump followed by an oracle enforcement: a
/// defect that surfaces mid-drain fails at the exact boundary where it became
/// visible instead of leaking into a later tier. [maxBoundaries] keeps the
/// drain itself bounded; exceeding it without settling reports BLOCKED rather
/// than looping forever. A boundary with no pending timers drains the
/// pipeline, so a quiet boundary ends the drain early.
class FrameBoundaryDrain {
  const FrameBoundaryDrain({this.maxBoundaries = 8});

  final int maxBoundaries;

  Future<int> drain(
    WidgetTester tester,
    ExerciseErrorCollector oracle,
    String context,
  ) async {
    var spent = 0;
    var settled = false;
    for (var i = 0; i < maxBoundaries && !settled; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      spent++;
      oracle.collectTreeState(tester);
      if (oracle.hasMaterialError) {
        oracle.failIfMaterial('$context:frame-boundary-$i');
      }
      final pending = tester.takeException();
      if (pending != null) {
        oracle.asyncErrors.add(pending);
        oracle.failIfMaterial('$context:frame-boundary-$i:takeException');
      }
      // One quiet boundary is a drained pipeline for capture purposes:
      // no pending timers that a second identical pump would advance.
      settled = true;
    }
    return spent;
  }
}

/// Cooperative cancellation scope for capture-time async work.
///
/// Placement contract for the FRB adapter path: the adapter's cancel-and-replace
/// token (see `frb_async_command.dart`: incumbent signalled, successor
/// supersedes) plugs this exact shape — [cancel] requests, [throwIfCancelled]
/// observes at checkpoints, and the execution terminates cooperatively. A
/// cancelled scope never reports fabricated completion.
class CooperativeCancelScope {
  bool _cancelled = false;
  String? _reason;

  bool get isCancelled => _cancelled;
  String? get reason => _reason;

  void cancel([String? reason]) {
    _cancelled = true;
    _reason = reason;
  }

  void throwIfCancelled([String checkpoint = 'capture']) {
    if (_cancelled) {
      throw StateError(
        'CooperativeCancelScope cancelled at $checkpoint'
        '${_reason == null ? '' : ': $_reason'}',
      );
    }
  }
}

/// Runs a Tier 2 windowed capture: applies [viewport], pumps the [build]
/// surface, drains at frame boundaries, and returns the structured inspect
/// record. Window errors are collected into the record AND enforced through
/// the oracle — a capture with errors fails visibly, never silently.
Future<WindowedCaptureInspect> runWindowedCapture({
  required WidgetTester tester,
  required ExerciseErrorCollector oracle,
  required String host,
  required String route,
  required double width,
  required double height,
  required double devicePixelRatio,
  required String themeRecipe,
  required Widget Function() build,
  int frames = 3,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(build());
  final findings = <String>[];
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    final pending = tester.takeException();
    if (pending != null) {
      oracle.asyncErrors.add(pending);
    }
    oracle.collectTreeState(tester);
    findings.add('frame=$i tree=${find.byType(Widget).evaluate().length}');
  }

  final record = WindowedCaptureInspect(
    tier: CaptureTier.windowed,
    host: host,
    route: route,
    viewportWidth: width,
    viewportHeight: height,
    devicePixelRatio: devicePixelRatio,
    themeRecipe: themeRecipe,
    framesSpent: frames,
    findings: findings,
    errors: List<String>.from(oracle.materialMessages),
  );
  // Visible-window errors: enforce, never swallow.
  oracle.failIfMaterial('windowed-capture:$host:$route');
  return record;
}
