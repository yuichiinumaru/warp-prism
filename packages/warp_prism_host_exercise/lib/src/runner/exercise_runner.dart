import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../artifacts/trace_writer.dart';
import '../discovery/action_discovery.dart';
import '../models/exercise_trace.dart';
import '../models/host_config.dart';
import '../models/viewport_matrix.dart';
import '../oracle/error_oracle.dart';

/// Callbacks the host adapter supplies (the only host-specific code).
class ExerciseRunCallbacks {
  /// Cheapest valid deterministic reset: rebuild the test shell
  /// (fresh app widget), reset fixture state, return to route root.
  final Future<void> Function() resetAndPump;

  /// Current route/entrypoint id for trace records.
  final String Function() currentRoute;

  /// Applies a theme recipe without reconstructing the route where the
  /// host supports it. Null when the host cannot hot-switch recipes.
  final Future<void> Function(String recipeId)? applyThemeRecipe;

  const ExerciseRunCallbacks({
    required this.resetAndPump,
    required this.currentRoute,
    this.applyThemeRecipe,
  });
}

/// Shared host-agnostic runner for SMOKE / CRAWL / FUZZ / REPLAY.
///
/// Machine-readable exit status: the returned [ExerciseTrace] carries
/// `errors`; the caller fails the test when `errors` is non-empty (plus
/// the oracle throws on first material error, so a swallowed exception
/// can never report PASS).
class ExerciseRunner {
  /// Applies [viewport] to the test surface.
  static void applyViewport(WidgetTester tester, ExerciseViewport viewport) {
    tester.view.physicalSize = Size(viewport.width, viewport.height);
    tester.view.devicePixelRatio = viewport.devicePixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Pumps, drains microtasks, advances bounded frames, then enforces the
  /// strict oracle (Flutter errors, ErrorWidget events, and
  /// `tester.takeException` — including interaction throws and route
  /// transition failures).
  ///
  /// Deliberately avoids `pumpAndSettle`: real hosts own perpetual
  /// animations (graph physics, shimmer, tickers) that never reach
  /// quiescence by design. Animation quiescence is not a correctness
  /// criterion; bounded frames plus the error oracle are.
  ///
  /// [softFail] collects and continues without throwing — used ONLY by
  /// calibration flows that assert a known defect's presence. Regular
  /// gates must keep the default hard-fail semantics.
  static Future<void> pumpAndEnforce(
    WidgetTester tester,
    ExerciseErrorCollector oracle,
    String context, {
    bool softFail = false,
  }) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    final pending = tester.takeException();
    if (pending != null) {
      oracle.asyncErrors.add(pending);
    }
    oracle.collectTreeState(tester);
    if (softFail) return;
    oracle.failIfMaterial(context);
  }

  /// Runs SMOKE: cheap deterministic canonical paths.
  ///
  /// [softFail] (default false) is the calibration escape hatch: errors
  /// are collected into `trace.errors` without throwing, so a caller can
  /// assert a known defect IS detected. Production gates use hard-fail.
  static Future<ExerciseTrace> runSmoke({
    required WidgetTester tester,
    required HostExerciseConfig config,
    required ExerciseRunCallbacks callbacks,
    required ExerciseErrorCollector oracle,
    bool softFail = false,
  }) async {
    applyViewport(tester, config.viewport);
    await callbacks.resetAndPump();
    await pumpAndEnforce(
      tester,
      oracle,
      'smoke-reset:${config.host}',
      softFail: softFail,
    );

    final steps = <ExerciseStep>[];
    final errors = <String>[];
    final targets = config.smokeTargets.take(config.actionBudget).toList();

    for (var i = 0; i < targets.length; i++) {
      final target = targets[i];
      final routeBefore = callbacks.currentRoute();
      final discovered = ExerciseActionDiscovery.discover(
        tester,
        config: config,
      );
      final stateMarker = 'candidates=${discovered.length}';
      try {
        final finder = ExerciseActionDiscovery.resolveFinder(tester, target);
        if (finder == null || finder.evaluate().isEmpty) {
          errors.add('smoke target unreachable: $target ($stateMarker)');
          break;
        }
        await tester.tap(finder.first);
        await pumpAndEnforce(
          tester,
          oracle,
          'smoke:$target',
          softFail: softFail,
        );
        steps.add(
          ExerciseStep(
            index: i,
            target: target,
            action: 'tap',
            routeBefore: routeBefore,
            routeAfter: callbacks.currentRoute(),
            stateMarker: stateMarker,
          ),
        );
      } catch (error, stack) {
        errors.add('smoke:$target failed: $error\n$stack');
        break;
      }
    }

    return ExerciseTrace(
      seed: config.seed,
      host: config.host,
      mode: 'smoke',
      initialRoute: config.initialRoute,
      viewport: config.viewport.toJson(),
      themeRecipe: config.themeRecipeId,
      actionBudget: config.actionBudget,
      actions: steps,
      errors: [...errors, ...oracle.materialMessages],
    );
  }

  /// Runs CRAWL: deterministic bounded sequential exploration.
  static Future<ExerciseTrace> runCrawl({
    required WidgetTester tester,
    required HostExerciseConfig config,
    required ExerciseRunCallbacks callbacks,
    required ExerciseErrorCollector oracle,
  }) async {
    applyViewport(tester, config.viewport);
    await callbacks.resetAndPump();
    await pumpAndEnforce(tester, oracle, 'crawl-reset:${config.host}');

    final steps = <ExerciseStep>[];
    final errors = <String>[];
    final visited = <String>{};

    for (var i = 0; i < config.actionBudget; i++) {
      final routeBefore = callbacks.currentRoute();
      final discovered = ExerciseActionDiscovery.discover(
        tester,
        config: config,
      );
      if (discovered.isEmpty) {
        steps.add(
          ExerciseStep(
            index: i,
            target: '<no-actions>',
            action: 'noop',
            routeBefore: routeBefore,
            routeAfter: routeBefore,
            stateMarker: 'candidates=0',
          ),
        );
        break;
      }
      final next = discovered.firstWhere(
        (c) => !visited.contains(c.id),
        orElse: () => discovered.first,
      );
      visited.add(next.id);
      final stateMarker = 'candidates=${discovered.length}';
      try {
        final finder = ExerciseActionDiscovery.resolveFinder(tester, next.id);
        if (finder == null || finder.evaluate().isEmpty) {
          // Exploration signal, not a defect: below-fold content,
          // post-navigation state, or collapsed sections hide targets.
          // Recorded as a skip step so the trace stays honest.
          steps.add(
            ExerciseStep(
              index: i,
              target: next.id,
              action: 'skip-unreachable',
              routeBefore: routeBefore,
              routeAfter: routeBefore,
              stateMarker: stateMarker,
            ),
          );
          continue;
        }
        await tester.tap(finder.first);
        await pumpAndEnforce(tester, oracle, 'crawl:${next.id}');
        steps.add(
          ExerciseStep(
            index: i,
            target: next.id,
            action: next.kind.name,
            routeBefore: routeBefore,
            routeAfter: callbacks.currentRoute(),
            stateMarker: stateMarker,
          ),
        );
      } catch (error, stack) {
        errors.add('crawl:${next.id} failed: $error\n$stack');
        break;
      }
    }

    return ExerciseTrace(
      seed: config.seed,
      host: config.host,
      mode: 'crawl',
      initialRoute: config.initialRoute,
      viewport: config.viewport.toJson(),
      themeRecipe: config.themeRecipeId,
      actionBudget: config.actionBudget,
      actions: steps,
      errors: [...errors, ...oracle.materialMessages],
    );
  }

  /// Runs FUZZ: seeded reproducible random walk over SAFE actions.
  static Future<ExerciseTrace> runFuzz({
    required WidgetTester tester,
    required HostExerciseConfig config,
    required ExerciseRunCallbacks callbacks,
    required ExerciseErrorCollector oracle,
  }) async {
    applyViewport(tester, config.viewport);
    await callbacks.resetAndPump();
    await pumpAndEnforce(tester, oracle, 'fuzz-reset:${config.host}');

    final random = Random(config.seed);
    final steps = <ExerciseStep>[];
    final errors = <String>[];

    for (var i = 0; i < config.actionBudget; i++) {
      final routeBefore = callbacks.currentRoute();
      final discovered = ExerciseActionDiscovery.discover(
        tester,
        config: config,
      );
      if (discovered.isEmpty) break;
      final next = discovered[random.nextInt(discovered.length)];
      final stateMarker =
          'candidates=${discovered.length} pick=${discovered.indexOf(next)}';
      try {
        final finder = ExerciseActionDiscovery.resolveFinder(tester, next.id);
        if (finder == null || finder.evaluate().isEmpty) {
          steps.add(
            ExerciseStep(
              index: i,
              target: next.id,
              action: 'skip-unreachable',
              routeBefore: routeBefore,
              routeAfter: routeBefore,
              stateMarker: stateMarker,
            ),
          );
          continue;
        }
        await tester.tap(finder.first);
        await pumpAndEnforce(tester, oracle, 'fuzz:${next.id}');
        steps.add(
          ExerciseStep(
            index: i,
            target: next.id,
            action: next.kind.name,
            routeBefore: routeBefore,
            routeAfter: callbacks.currentRoute(),
            stateMarker: stateMarker,
          ),
        );
      } catch (error, stack) {
        errors.add('fuzz:${next.id} failed: $error\n$stack');
        break;
      }
    }

    return ExerciseTrace(
      seed: config.seed,
      host: config.host,
      mode: 'fuzz',
      initialRoute: config.initialRoute,
      viewport: config.viewport.toJson(),
      themeRecipe: config.themeRecipeId,
      actionBudget: config.actionBudget,
      actions: steps,
      errors: [...errors, ...oracle.materialMessages],
    );
  }

  /// Replays an ordered [trace] deterministically. Fails when a recorded
  /// target is unreachable or any step throws — a failing fuzz trace must
  /// replay exactly.
  static Future<ExerciseTrace> replayTrace({
    required WidgetTester tester,
    required HostExerciseConfig config,
    required ExerciseRunCallbacks callbacks,
    required ExerciseErrorCollector oracle,
    required ExerciseTrace trace,
  }) async {
    applyViewport(tester, config.viewport);
    await callbacks.resetAndPump();
    await pumpAndEnforce(tester, oracle, 'replay-reset:${config.host}');

    final steps = <ExerciseStep>[];
    final errors = <String>[];

    for (final recorded in trace.actions) {
      // Skip non-actions recorded during exploration (below-fold or
      // state-hidden targets). Replay covers performed actions only.
      if (recorded.action == 'skip-unreachable' || recorded.action == 'noop') {
        steps.add(
          ExerciseStep(
            index: recorded.index,
            target: recorded.target,
            action: recorded.action,
            routeBefore: callbacks.currentRoute(),
            routeAfter: callbacks.currentRoute(),
            stateMarker: 'replay-skipped',
          ),
        );
        continue;
      }
      final routeBefore = callbacks.currentRoute();
      try {
        final finder = ExerciseActionDiscovery.resolveFinder(
          tester,
          recorded.target,
        );
        if (finder == null || finder.evaluate().isEmpty) {
          errors.add('replay target unreachable: ${recorded.target}');
          break;
        }
        await tester.tap(finder.first);
        await pumpAndEnforce(tester, oracle, 'replay:${recorded.target}');
        steps.add(
          ExerciseStep(
            index: recorded.index,
            target: recorded.target,
            action: recorded.action,
            routeBefore: routeBefore,
            routeAfter: callbacks.currentRoute(),
            stateMarker: 'replay',
          ),
        );
      } catch (error, stack) {
        errors.add('replay:${recorded.target} failed: $error\n$stack');
        break;
      }
    }

    return ExerciseTrace(
      seed: trace.seed,
      host: trace.host,
      mode: '${trace.mode}-replay',
      initialRoute: trace.initialRoute,
      viewport: trace.viewport,
      themeRecipe: trace.themeRecipe,
      actionBudget: trace.actionBudget,
      actions: steps,
      errors: [...errors, ...oracle.materialMessages],
      replayCommand: ExerciseTraceWriter.replayCommand(
        host: trace.host,
        mode: trace.mode,
        seed: trace.seed,
        tracePath: '<original-trace-path>',
      ),
    );
  }
}
