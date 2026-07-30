import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../molecules/ds_metric_tile.dart';

// =============================================================================
// Models
// =============================================================================

/// One metric cell hosted inside a [DSFloatingAnalyticsSection].
///
/// Domain-agnostic fixture model — maps cleanly onto [DSMetricTile] /
/// [DSMetricTileCompact]. No live telemetry adapters.
@immutable
class DSFloatingAnalyticsMetric {
  /// Stable identity within a section.
  final String id;

  /// Metric label (e.g. `"P95 latency"`).
  final String label;

  /// Primary display value (e.g. `"84 ms"`).
  final String value;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional accent color (overridden by [health] when set).
  final Color? color;

  /// Optional secondary line.
  final String? subtitle;

  /// Optional trend indicator.
  final DSTrend? trend;

  /// Optional operational health accent.
  final DSMetricTileHealth? health;

  const DSFloatingAnalyticsMetric({
    required this.id,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.subtitle,
    this.trend,
    this.health,
  });

  DSFloatingAnalyticsMetric copyWith({
    String? id,
    String? label,
    String? value,
    IconData? icon,
    Color? color,
    String? subtitle,
    DSTrend? trend,
    DSMetricTileHealth? health,
    bool clearIcon = false,
    bool clearColor = false,
    bool clearSubtitle = false,
    bool clearTrend = false,
    bool clearHealth = false,
  }) {
    return DSFloatingAnalyticsMetric(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
      icon: clearIcon ? null : (icon ?? this.icon),
      color: clearColor ? null : (color ?? this.color),
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      trend: clearTrend ? null : (trend ?? this.trend),
      health: clearHealth ? null : (health ?? this.health),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSFloatingAnalyticsMetric &&
        other.id == id &&
        other.label == label &&
        other.value == value &&
        other.icon == icon &&
        other.color == color &&
        other.subtitle == subtitle &&
        other.trend == trend &&
        other.health == health;
  }

  @override
  int get hashCode =>
      Object.hash(id, label, value, icon, color, subtitle, trend, health);
}

/// Named group of metrics for [DSFloatingAnalyticsHud].
@immutable
class DSFloatingAnalyticsSection {
  /// Stable identity within the HUD.
  final String id;

  /// Section header label.
  final String title;

  /// Metrics rendered inside this section.
  final List<DSFloatingAnalyticsMetric> metrics;

  /// Optional short badge (e.g. `"LIVE"`, `"FIXTURE"`).
  final String? badge;

  const DSFloatingAnalyticsSection({
    required this.id,
    required this.title,
    required this.metrics,
    this.badge,
  });

  DSFloatingAnalyticsSection copyWith({
    String? id,
    String? title,
    List<DSFloatingAnalyticsMetric>? metrics,
    String? badge,
    bool clearBadge = false,
  }) {
    return DSFloatingAnalyticsSection(
      id: id ?? this.id,
      title: title ?? this.title,
      metrics: metrics ?? this.metrics,
      badge: clearBadge ? null : (badge ?? this.badge),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSFloatingAnalyticsSection &&
        other.id == id &&
        other.title == title &&
        other.badge == badge &&
        listEquals(other.metrics, metrics);
  }

  @override
  int get hashCode => Object.hash(id, title, badge, Object.hashAll(metrics));
}
