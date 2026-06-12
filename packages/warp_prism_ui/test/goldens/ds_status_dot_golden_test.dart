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

/// Wraps a widget in a MaterialApp with obsidian background for consistent
/// golden rendering.
Widget _inApp(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
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

/// Metadata for each operational state: label, builder, animated flag.
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

/// All 15 operational states plus 5 basic semantic constructors.
const _allStates = <_StateEntry>[
  // Basic semantic constructors
  _StateEntry(label: 'success', builder: DSStatusDot.success),
  _StateEntry(label: 'warning', builder: DSStatusDot.warning),
  _StateEntry(label: 'error', builder: DSStatusDot.error),
  _StateEntry(label: 'info', builder: DSStatusDot.info),
  _StateEntry(label: 'neutral', builder: DSStatusDot.neutral),
  // Lifecycle
  _StateEntry(label: 'pending', builder: DSStatusDot.pending),
  _StateEntry(label: 'running', builder: DSStatusDot.running, animated: true),
  _StateEntry(label: 'approved', builder: DSStatusDot.approved),
  _StateEntry(label: 'rejected', builder: DSStatusDot.rejected),
  _StateEntry(label: 'promoted', builder: DSStatusDot.promoted),
  _StateEntry(label: 'archived', builder: DSStatusDot.archived),
  // Health
  _StateEntry(label: 'healthy', builder: DSStatusDot.healthy),
  _StateEntry(label: 'degraded', builder: DSStatusDot.degraded),
  _StateEntry(label: 'disabled', builder: DSStatusDot.disabled),
  // Verification
  _StateEntry(label: 'unverified', builder: DSStatusDot.unverified),
  _StateEntry(label: 'exposed', builder: DSStatusDot.exposed, animated: true),
  _StateEntry(label: 'redacted', builder: DSStatusDot.redacted),
  // Governance
  _StateEntry(label: 'stale', builder: DSStatusDot.stale),
  _StateEntry(label: 'excluded', builder: DSStatusDot.excluded),
];
