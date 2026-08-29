// Golden tests for DSStatusDot — renders all 15 operational states.
//
// Each state is rendered at default 8px size on the obsidian background.
// Animated states (running, exposed) are pumped at a single frame to
// capture a deterministic snapshot.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_status_dot_golden_test.dart
//   flutter test test/goldens/ds_status_dot_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Wraps a widget in a MaterialApp with obsidian background for consistent
/// golden rendering.
Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: child),
    ),
  );
}

void main() {
  group('DSStatusDot golden — operational states', () {
    for (final entry in _allStates) {
      testWidgets('renders ${entry.label} state', (tester) async {
        await tester.pumpWidget(_inApp(entry.builder()));
        // For animated dots, pump a single frame to get a deterministic
        // mid-animation snapshot rather than waiting for settle.
        if (entry.animated) {
          await tester.pump(const Duration(milliseconds: 500));
        }
        await expectLater(
          find.byType(DSStatusDot),
          matchesGoldenFile('goldens/status_dot_${entry.label}.png'),
        );
      });
    }
  });

  group('DSStatusDot golden — enlarged for visibility', () {
    testWidgets('renders all 15 states in a grid (16px)', (tester) async {
      await tester.pumpWidget(
        _inApp(
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final entry in _allStates)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    entry.builder(size: 16),
                    const SizedBox(height: 4),
                    Text(
                      entry.label,
                      style: const TextStyle(
                        color: DSColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
      // Pump one frame for animated dots
      await tester.pump(const Duration(milliseconds: 500));
      await expectLater(
        find.byType(Wrap),
        matchesGoldenFile('goldens/status_dot_all_states_grid.png'),
      );
    });
  });
}

/// Metadata for each golden case: stable PNG label, builder, animated flag.
class _StateEntry {
  final String label;
  final DSStatusDot Function({double size, bool animated}) builder;
  final bool animated;

  const _StateEntry({
    required this.label,
    required this.builder,
    this.animated = false,
  });
}

/// Basic semantic constructors (not part of [DSOperationalState]).
///
/// Keep [DSStatusDot.error] here so the historical `status_dot_error.png`
/// master remains the basic semantic constructor (no tooltip wrapper).
const _basicSemanticStates = <_StateEntry>[
  _StateEntry(label: 'success', builder: DSStatusDot.success),
  _StateEntry(label: 'warning', builder: DSStatusDot.warning),
  _StateEntry(label: 'error', builder: DSStatusDot.error),
  _StateEntry(label: 'info', builder: DSStatusDot.info),
  _StateEntry(label: 'neutral', builder: DSStatusDot.neutral),
];

/// Named-constructor mapping for each [DSOperationalState] so golden PNG
/// masters stay pixel-stable while the matrix is enum-driven.
DSStatusDot _namedOperationalDot(DSOperationalState state, {double size = 8}) {
  switch (state) {
    case DSOperationalState.pending:
      return DSStatusDot.pending(size: size);
    case DSOperationalState.running:
      return DSStatusDot.running(size: size);
    case DSOperationalState.approved:
      return DSStatusDot.approved(size: size);
    case DSOperationalState.rejected:
      return DSStatusDot.rejected(size: size);
    case DSOperationalState.promoted:
      return DSStatusDot.promoted(size: size);
    case DSOperationalState.archived:
      return DSStatusDot.archived(size: size);
    case DSOperationalState.healthy:
      return DSStatusDot.healthy(size: size);
    case DSOperationalState.degraded:
      return DSStatusDot.degraded(size: size);
    case DSOperationalState.error:
      // Prefer basic semantic master for the shared `error` PNG label.
      return DSStatusDot.error(size: size);
    case DSOperationalState.disabled:
      return DSStatusDot.disabled(size: size);
    case DSOperationalState.unverified:
      return DSStatusDot.unverified(size: size);
    case DSOperationalState.exposed:
      return DSStatusDot.exposed(size: size);
    case DSOperationalState.redacted:
      return DSStatusDot.redacted(size: size);
    case DSOperationalState.stale:
      return DSStatusDot.stale(size: size);
    case DSOperationalState.excluded:
      return DSStatusDot.excluded(size: size);
  }
}

/// Operational matrix derived from [DSOperationalState.values].
///
/// [DSOperationalState.error] is omitted to avoid clobbering the basic
/// `error` golden label; color parity is covered by [DSStatusDot.error].
final _allStates = <_StateEntry>[
  ..._basicSemanticStates,
  for (final state in DSOperationalState.values)
    if (state != DSOperationalState.error)
      _StateEntry(
        label: state.name,
        builder: ({double size = 8, bool animated = false}) =>
            _namedOperationalDot(state, size: size),
        animated:
            state == DSOperationalState.running ||
            state == DSOperationalState.exposed,
      ),
];
