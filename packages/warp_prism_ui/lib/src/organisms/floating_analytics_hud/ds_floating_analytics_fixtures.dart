import 'package:flutter/material.dart';

import '../../molecules/ds_metric_tile.dart';
import '../../tokens/tokens.dart';
import 'ds_floating_analytics_models.dart';

// =============================================================================
// Fixtures
// =============================================================================

/// Shared fixture catalog for gallery / tests (Task 1514 / O-09).
///
/// Mock metrics only — no live network, no MapLibre, no telemetry adapters.
abstract final class DSFloatingAnalyticsFixtures {
  /// Default multi-section analytics fixture used by gallery demos.
  static List<DSFloatingAnalyticsSection> defaultSections() => const [
    DSFloatingAnalyticsSection(
      id: 'throughput',
      title: 'Throughput',
      badge: 'OPS',
      metrics: [
        DSFloatingAnalyticsMetric(
          id: 'req-rate',
          label: 'Req/s',
          value: '1.2k',
          icon: Icons.speed,
          color: DSColors.accentCyan,
          trend: DSTrend.up,
          subtitle: 'rolling 60s',
        ),
        DSFloatingAnalyticsMetric(
          id: 'p95',
          label: 'P95',
          value: '84 ms',
          icon: Icons.timer_outlined,
          color: DSColors.accentViolet,
          trend: DSTrend.flat,
          health: DSMetricTileHealth.healthy,
        ),
        DSFloatingAnalyticsMetric(
          id: 'error-rate',
          label: 'Errors',
          value: '0.4%',
          icon: Icons.error_outline,
          color: DSColors.statusWarning,
          trend: DSTrend.down,
          health: DSMetricTileHealth.degraded,
          subtitle: 'vs baseline',
        ),
      ],
    ),
    DSFloatingAnalyticsSection(
      id: 'coverage',
      title: 'Coverage',
      badge: 'MAP',
      metrics: [
        DSFloatingAnalyticsMetric(
          id: 'agents-live',
          label: 'Agents',
          value: '24',
          icon: Icons.smart_toy_outlined,
          color: DSColors.accentCyan,
          subtitle: 'healthy 22',
        ),
        DSFloatingAnalyticsMetric(
          id: 'feeds',
          label: 'Feeds',
          value: '12',
          icon: Icons.rss_feed,
          color: DSColors.accentGold,
          health: DSMetricTileHealth.healthy,
        ),
        DSFloatingAnalyticsMetric(
          id: 'stale',
          label: 'Stale',
          value: '3',
          icon: Icons.hourglass_empty,
          color: DSColors.statusWarning,
          health: DSMetricTileHealth.degraded,
          subtitle: 'proof age',
        ),
      ],
    ),
    DSFloatingAnalyticsSection(
      id: 'cost',
      title: 'Cost window',
      badge: 'FIN',
      metrics: [
        DSFloatingAnalyticsMetric(
          id: 'tokens',
          label: 'Tokens',
          value: '48.2k',
          icon: Icons.token_outlined,
          color: DSColors.accentViolet,
          trend: DSTrend.up,
        ),
        DSFloatingAnalyticsMetric(
          id: 'spend',
          label: 'Spend',
          value: r'$12.40',
          icon: Icons.payments_outlined,
          color: DSColors.accentGold,
          subtitle: 'session',
        ),
      ],
    ),
  ];

  /// Compact two-section fixture for focused widget tests.
  static List<DSFloatingAnalyticsSection> minimalSections() => const [
    DSFloatingAnalyticsSection(
      id: 'core',
      title: 'Core',
      metrics: [
        DSFloatingAnalyticsMetric(id: 'm1', label: 'Alpha', value: '10'),
        DSFloatingAnalyticsMetric(
          id: 'm2',
          label: 'Beta',
          value: '20',
          health: DSMetricTileHealth.healthy,
        ),
      ],
    ),
    DSFloatingAnalyticsSection(
      id: 'aux',
      title: 'Aux',
      metrics: [
        DSFloatingAnalyticsMetric(
          id: 'm3',
          label: 'Gamma',
          value: '30',
          trend: DSTrend.up,
        ),
      ],
    ),
  ];
}
