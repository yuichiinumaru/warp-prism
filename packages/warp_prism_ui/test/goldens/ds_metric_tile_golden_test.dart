// Golden tests for DSMetricTile — renders metric tiles with health states,
// trend indicators, and the compact variant.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_metric_tile_golden_test.dart
//   flutter test test/goldens/ds_metric_tile_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_metric_tile.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: child),
    ),
  );
}

/// Fixed-width wrapper so metric tiles render at a consistent width.
Widget _fixedWidth(Widget child, {double width = 220}) {
  return SizedBox(width: width, child: child);
}

void main() {
  group('DSMetricTile golden — default and health states', () {
    testWidgets('renders default metric tile (cyan accent)', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _fixedWidth(
            const DSMetricTile(
              label: 'Agents Online',
              value: '42',
              icon: Icons.smart_toy,
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSMetricTile),
        matchesGoldenFile('goldens/metric_tile_default.png'),
      );
    });

    testWidgets('renders healthy state', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _fixedWidth(
            const DSMetricTile(
              label: 'Uptime',
              value: '99.9%',
              icon: Icons.check_circle,
              health: DSMetricTileHealth.healthy,
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSMetricTile),
        matchesGoldenFile('goldens/metric_tile_healthy.png'),
      );
    });

    testWidgets('renders degraded state with status dot', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _fixedWidth(
            const DSMetricTile(
              label: 'Latency',
              value: '320ms',
              icon: Icons.speed,
              health: DSMetricTileHealth.degraded,
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSMetricTile),
        matchesGoldenFile('goldens/metric_tile_degraded.png'),
      );
    });

    testWidgets('renders error state with animated dot', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _fixedWidth(
            const DSMetricTile(
              label: 'Failures',
              value: '7',
              icon: Icons.error,
              health: DSMetricTileHealth.error,
            ),
          ),
        ),
      );
      // Pump one frame for animated dot
      await tester.pump(const Duration(milliseconds: 500));
      await expectLater(
        find.byType(DSMetricTile),
        matchesGoldenFile('goldens/metric_tile_error.png'),
      );
    });

    testWidgets('renders disabled state', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _fixedWidth(
            const DSMetricTile(
              label: 'Archived Jobs',
              value: '0',
              icon: Icons.block,
              health: DSMetricTileHealth.disabled,
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSMetricTile),
        matchesGoldenFile('goldens/metric_tile_disabled.png'),
      );
    });
  });

  group('DSMetricTile golden — trend indicators', () {
    testWidgets('renders upward trend', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _fixedWidth(
            const DSMetricTile(
              label: 'Throughput',
              value: '128/s',
              trend: DSTrend.up,
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSMetricTile),
        matchesGoldenFile('goldens/metric_tile_trend_up.png'),
      );
    });

    testWidgets('renders downward trend', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _fixedWidth(
            const DSMetricTile(
              label: 'Memory',
              value: '2.1 GB',
              trend: DSTrend.down,
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSMetricTile),
        matchesGoldenFile('goldens/metric_tile_trend_down.png'),
      );
    });

    testWidgets('renders flat trend', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _fixedWidth(
            const DSMetricTile(
              label: 'Connections',
              value: '12',
              trend: DSTrend.flat,
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSMetricTile),
        matchesGoldenFile('goldens/metric_tile_trend_flat.png'),
      );
    });
  });

  group('DSMetricTile golden — subtitle', () {
    testWidgets('renders with subtitle', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _fixedWidth(
            const DSMetricTile(
              label: 'Tasks',
              value: '156',
              icon: Icons.task,
              subtitle: 'Last updated 3m ago',
              trend: DSTrend.up,
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSMetricTile),
        matchesGoldenFile('goldens/metric_tile_with_subtitle.png'),
      );
    });
  });

  group('DSMetricTile golden — compact variant', () {
    testWidgets('renders compact metric tile', (tester) async {
      await tester.pumpWidget(
        _inApp(const DSMetricTileCompact(label: 'CPU', value: '45%')),
      );
      await expectLater(
        find.byType(DSMetricTileCompact),
        matchesGoldenFile('goldens/metric_tile_compact_default.png'),
      );
    });

    testWidgets('renders compact metric tile with health', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSMetricTileCompact(
            label: 'Disk',
            value: '92%',
            health: DSMetricTileHealth.degraded,
          ),
        ),
      );
      await expectLater(
        find.byType(DSMetricTileCompact),
        matchesGoldenFile('goldens/metric_tile_compact_degraded.png'),
      );
    });
  });
}
