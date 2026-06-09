import 'package:flutter/widgets.dart';

/// ASW Observatory Organism — Tab Data Model
///
/// Immutable data object representing a single tab in [DSTabBar].
///
/// Each tab carries:
/// - A unique [id] for stable identity across reorder/close operations.
/// - A display [label] rendered in the tab header.
/// - An optional leading [icon].
/// - An optional [badgeCount] for unread/error indicators.
/// - A [closable] flag controlling the X button visibility.
/// - A [content] builder for the tab body rendered by [DSTabView].
class DSTab {
  /// Unique identifier for this tab — used for close/select operations.
  final String id;

  /// Short display label shown in the tab header.
  final String label;

  /// Optional leading icon displayed before the label.
  final IconData? icon;

  /// Optional badge count shown as a pill on the tab header.
  /// `null` means no badge; `0` means no badge (dot hidden).
  final int? badgeCount;

  /// Whether the tab header shows a close (X) button.
  final bool closable;

  /// Builder for the tab's content body.
  /// Called by [DSTabView] when the tab is active.
  final WidgetBuilder content;

  const DSTab({
    required this.id,
    required this.label,
    this.icon,
    this.badgeCount,
    this.closable = false,
    required this.content,
  });

  /// Creates a copy of this tab with optional overrides.
  DSTab copyWith({
    String? id,
    String? label,
    IconData? icon,
    int? badgeCount,
    bool? closable,
    WidgetBuilder? content,
  }) {
    return DSTab(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      badgeCount: badgeCount ?? this.badgeCount,
      closable: closable ?? this.closable,
      content: content ?? this.content,
    );
  }
}
