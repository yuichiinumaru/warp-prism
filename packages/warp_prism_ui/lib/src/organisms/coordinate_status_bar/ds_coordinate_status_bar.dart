import 'package:flutter/material.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_status_dot.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Feed health band for [DSCoordinateFeedHealth] chips.
enum DSCoordinateFeedStatus {
  /// Feed healthy / live.
  healthy,

  /// Feed degraded but usable.
  degraded,

  /// Feed offline / failed.
  offline,

  /// Status unknown.
  unknown,
}

/// Single feed health chip for [DSCoordinateStatusBar].
@immutable
class DSCoordinateFeedHealth {
  /// Stable feed identity (e.g. `"agents"`, `"telemetry"`).
  final String id;

  /// Short label shown beside the status dot.
  final String label;

  /// Health band.
  final DSCoordinateFeedStatus status;

  /// Optional count badge (e.g. active sources).
  final int? count;

  /// Optional tooltip / secondary detail.
  final String? detail;

  const DSCoordinateFeedHealth({
    required this.id,
    required this.label,
    this.status = DSCoordinateFeedStatus.unknown,
    this.count,
    this.detail,
  });

  DSCoordinateFeedHealth copyWith({
    String? id,
    String? label,
    DSCoordinateFeedStatus? status,
    int? count,
    String? detail,
    bool clearCount = false,
    bool clearDetail = false,
  }) {
    return DSCoordinateFeedHealth(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
      count: clearCount ? null : (count ?? this.count),
      detail: clearDetail ? null : (detail ?? this.detail),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSCoordinateFeedHealth &&
        other.id == id &&
        other.label == label &&
        other.status == status &&
        other.count == count &&
        other.detail == detail;
  }

  @override
  int get hashCode => Object.hash(id, label, status, count, detail);
}

// =============================================================================
// Fixtures
// =============================================================================

/// Shared fixture catalog for gallery / tests (Task 1509).
abstract final class DSCoordinateStatusFixtures {
  /// Default lat/lon for demos (SF bay-ish).
  static const double defaultLatitude = 37.774929;
  static const double defaultLongitude = -122.419418;

  static const String defaultPlaceLabel = 'Mission District · SF';

  static const String defaultStyleLabel = 'obsidian-night';

  static const List<DSCoordinateFeedHealth> defaultFeeds =
      <DSCoordinateFeedHealth>[
        DSCoordinateFeedHealth(
          id: 'agents',
          label: 'Agents',
          status: DSCoordinateFeedStatus.healthy,
          count: 24,
          detail: 'Live telemetry',
        ),
        DSCoordinateFeedHealth(
          id: 'skills',
          label: 'Skills',
          status: DSCoordinateFeedStatus.degraded,
          count: 8,
          detail: '2 sources lagging',
        ),
        DSCoordinateFeedHealth(
          id: 'alerts',
          label: 'Alerts',
          status: DSCoordinateFeedStatus.offline,
          count: 0,
          detail: 'Fixture offline',
        ),
      ];
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Coordinate Status Bar
///
/// Read-only centered glass strip for stage chrome: pointer coordinates,
/// optional reverse-geocode / place label, style preset tag, and multi-feed
/// health micro-status chips. Fixture-first — no MapLibre, no live geocoder.
///
/// EPIC-15 O-12 / Task 1509.
class DSCoordinateStatusBar extends StatelessWidget {
  /// WGS84 latitude to display (read-only).
  final double? latitude;

  /// WGS84 longitude to display (read-only).
  final double? longitude;

  /// Decimal places for lat/lon formatting. Defaults to 5.
  final int coordinatePrecision;

  /// Optional place / reverse-geocode label.
  final String? placeLabel;

  /// Optional map style / preset tag.
  final String? styleLabel;

  /// Optional secondary metric (e.g. solar elevation, zoom).
  final String? secondaryMetric;

  /// Feed health chips.
  final List<DSCoordinateFeedHealth> feeds;

  /// Whether to wrap content in [DSGlassPanel].
  final bool wrapInGlass;

  /// Compact density for dense HUD bottoms.
  final bool dense;

  /// Placeholder when coordinates are null.
  final String missingCoordinatesLabel;

  /// Semantic label for the bar region.
  final String semanticLabel;

  const DSCoordinateStatusBar({
    super.key,
    this.latitude,
    this.longitude,
    this.coordinatePrecision = 5,
    this.placeLabel,
    this.styleLabel,
    this.secondaryMetric,
    this.feeds = const <DSCoordinateFeedHealth>[],
    this.wrapInGlass = true,
    this.dense = false,
    this.missingCoordinatesLabel = '— · —',
    this.semanticLabel = 'Coordinate status bar',
  });

  // --- Stable keys ---

  static const Key panelRegionKey = Key('ds-coordinate-status-bar');
  static const Key coordinatesKey = Key('ds-coordinate-status-coords');
  static const Key placeLabelKey = Key('ds-coordinate-status-place');
  static const Key styleLabelKey = Key('ds-coordinate-status-style');
  static const Key feedsRowKey = Key('ds-coordinate-status-feeds');

  static Key feedChipKey(String feedId) =>
      Key('ds-coordinate-status-feed-$feedId');

  /// Formats a lat/lon pair for mono display.
  static String formatCoordinates({
    required double? latitude,
    required double? longitude,
    int precision = 5,
    String missingLabel = '— · —',
  }) {
    if (latitude == null || longitude == null) return missingLabel;
    final lat = latitude.abs().toStringAsFixed(precision);
    final lon = longitude.abs().toStringAsFixed(precision);
    final latH = latitude >= 0 ? 'N' : 'S';
    final lonH = longitude >= 0 ? 'E' : 'W';
    return '$lat°$latH  $lon°$lonH';
  }

  /// Status-dot color for a feed health band.
  static Color statusColor(DSCoordinateFeedStatus status) {
    switch (status) {
      case DSCoordinateFeedStatus.healthy:
        return DSColors.statusSuccess;
      case DSCoordinateFeedStatus.degraded:
        return DSColors.statusWarning;
      case DSCoordinateFeedStatus.offline:
        return DSColors.statusError;
      case DSCoordinateFeedStatus.unknown:
        return DSColors.textTertiary;
    }
  }

  /// Default human label for a feed health band.
  static String statusLabel(DSCoordinateFeedStatus status) {
    switch (status) {
      case DSCoordinateFeedStatus.healthy:
        return 'healthy';
      case DSCoordinateFeedStatus.degraded:
        return 'degraded';
      case DSCoordinateFeedStatus.offline:
        return 'offline';
      case DSCoordinateFeedStatus.unknown:
        return 'unknown';
    }
  }

  static String feedSemanticLabel(DSCoordinateFeedHealth feed) {
    final count = feed.count != null ? ', count ${feed.count}' : '';
    final detail = feed.detail != null ? ', ${feed.detail}' : '';
    return '${feed.label}, ${statusLabel(feed.status)}$count$detail';
  }

  String get _coordsText => formatCoordinates(
    latitude: latitude,
    longitude: longitude,
    precision: coordinatePrecision,
    missingLabel: missingCoordinatesLabel,
  );

  @override
  Widget build(BuildContext context) {
    final pad = dense
        ? const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xxs,
          )
        : const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.xs,
          );

    final body = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _metric(
            key: coordinatesKey,
            label: 'POS',
            value: _coordsText,
            mono: true,
            accent: DSColors.accentCyan,
          ),
          if (placeLabel != null && placeLabel!.isNotEmpty) ...[
            _divider(),
            _metric(
              key: placeLabelKey,
              label: 'LOC',
              value: placeLabel!,
              mono: false,
            ),
          ],
          if (styleLabel != null && styleLabel!.isNotEmpty) ...[
            _divider(),
            _metric(
              key: styleLabelKey,
              label: 'STYLE',
              value: styleLabel!,
              mono: true,
              accent: DSColors.accentViolet,
            ),
          ],
          if (secondaryMetric != null && secondaryMetric!.isNotEmpty) ...[
            _divider(),
            _metric(label: 'MET', value: secondaryMetric!, mono: true),
          ],
          if (feeds.isNotEmpty) ...[
            _divider(),
            KeyedSubtree(
              key: feedsRowKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < feeds.length; i++) ...[
                    if (i > 0) const SizedBox(width: DSSpacing.sm),
                    _FeedChip(feed: feeds[i]),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );

    final content = widgetWrap(body, pad);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      readOnly: true,
      child: KeyedSubtree(key: panelRegionKey, child: content),
    );
  }

  Widget widgetWrap(Widget body, EdgeInsetsGeometry pad) {
    if (wrapInGlass) {
      return DSGlassPanel(padding: pad, radius: DSRadii.full, child: body);
    }
    return Padding(padding: pad, child: body);
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
      child: Container(width: 1, height: 18, color: DSColors.borderSubtle),
    );
  }

  Widget _metric({
    Key? key,
    required String label,
    required String value,
    required bool mono,
    Color? accent,
  }) {
    return KeyedSubtree(
      key: key,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSText.labelSmall(label, color: DSColors.textTertiary),
          const SizedBox(width: DSSpacing.xxs),
          if (mono)
            DSText.code(value, color: accent ?? DSColors.textPrimary)
          else
            DSText.labelSmall(value, color: accent ?? DSColors.textSecondary),
        ],
      ),
    );
  }
}

class _FeedChip extends StatelessWidget {
  final DSCoordinateFeedHealth feed;

  const _FeedChip({required this.feed});

  @override
  Widget build(BuildContext context) {
    final color = DSCoordinateStatusBar.statusColor(feed.status);
    final countText = feed.count != null ? ' ${feed.count}' : '';

    return Semantics(
      label: DSCoordinateStatusBar.feedSemanticLabel(feed),
      child: KeyedSubtree(
        key: DSCoordinateStatusBar.feedChipKey(feed.id),
        child: Tooltip(
          message:
              feed.detail ??
              '${feed.label}: ${DSCoordinateStatusBar.statusLabel(feed.status)}',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSStatusDot(
                color: color,
                size: 7,
                // Avoid infinite animation in widget tests / reduced motion.
                animated: false,
              ),
              const SizedBox(width: DSSpacing.xxs),
              DSText.labelSmall(
                '${feed.label}$countText',
                color: DSColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
