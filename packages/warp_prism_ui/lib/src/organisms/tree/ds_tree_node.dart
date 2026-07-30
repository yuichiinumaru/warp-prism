import 'package:flutter/material.dart';

import '../../tokens/tokens.dart';

/// Immutable hierarchical node for [DSTree] / [PrismTree].
///
/// Contract:
/// - [id] must be unique within a single tree instance.
/// - [children] may be empty (leaf). Nested depth is unbounded.
/// - [status] optionally drives a [DSStatusDot] via operational vocabulary.
/// - [meta] is trailing secondary text (counts, paths, short labels).
/// - When [expandable] is null, expandability follows `children.isNotEmpty`.
///   Force [expandable] true for lazy-load placeholders with empty children;
///   force false to suppress a caret even when children exist.
@immutable
class DSTreeNode {
  /// Stable unique identifier within the tree.
  final String id;

  /// Primary label shown on the row.
  final String label;

  /// Nested child nodes. Empty list = leaf (unless [expandable] is forced).
  final List<DSTreeNode> children;

  /// Optional operational status for a status dot.
  final DSOperationalState? status;

  /// Optional trailing meta text (e.g. `"3 accounts"`, `"/mcp"`).
  final String? meta;

  /// Optional leading icon; when null, no icon slot is rendered.
  final IconData? icon;

  /// Override expandability. Null means "expandable iff children non-empty".
  final bool? expandable;

  const DSTreeNode({
    required this.id,
    required this.label,
    this.children = const <DSTreeNode>[],
    this.status,
    this.meta,
    this.icon,
    this.expandable,
  });

  /// Whether this node currently has child nodes.
  bool get hasChildren => children.isNotEmpty;

  /// Whether the row should show an expand/collapse caret.
  bool get isExpandable => expandable ?? hasChildren;

  /// Shallow copy with selective field overrides.
  DSTreeNode copyWith({
    String? id,
    String? label,
    List<DSTreeNode>? children,
    DSOperationalState? status,
    String? meta,
    IconData? icon,
    bool? expandable,
    bool clearStatus = false,
    bool clearMeta = false,
    bool clearIcon = false,
    bool clearExpandable = false,
  }) {
    return DSTreeNode(
      id: id ?? this.id,
      label: label ?? this.label,
      children: children ?? this.children,
      status: clearStatus ? null : (status ?? this.status),
      meta: clearMeta ? null : (meta ?? this.meta),
      icon: clearIcon ? null : (icon ?? this.icon),
      expandable: clearExpandable ? null : (expandable ?? this.expandable),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSTreeNode &&
        other.id == id &&
        other.label == label &&
        other.status == status &&
        other.meta == meta &&
        other.icon == icon &&
        other.expandable == expandable &&
        _listEquals(other.children, children);
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    status,
    meta,
    icon,
    expandable,
    Object.hashAll(children),
  );

  static bool _listEquals(List<DSTreeNode> a, List<DSTreeNode> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
