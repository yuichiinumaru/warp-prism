import 'package:flutter/material.dart';

// =============================================================================
// Models — Terminal Workspace (Task 1517 / O-21)
// =============================================================================

/// Layout modes for the terminal workspace.
enum DSTerminalLayoutMode {
  /// Single focused pane shown at a time using tab selectors.
  tabs,

  /// Panes laid out side-by-side using split pane divider(s).
  splitHorizontal,

  /// Panes laid out top-to-bottom using split pane divider(s).
  splitVertical,
}

/// Data model representing a single Mock Terminal Pane.
@immutable
class DSTerminalPane {
  /// Unique identifier for this terminal pane.
  final String id;

  /// Display title shown in the pane header / tab description.
  final String title;

  /// Optional leading icon.
  final IconData? icon;

  /// Scrollback history line items (mock console outputs).
  final List<String> history;

  /// Optional badge count representing unread activity / error alerts.
  final int? badgeCount;

  const DSTerminalPane({
    required this.id,
    required this.title,
    this.icon,
    this.history = const [],
    this.badgeCount,
  });

  /// Creates a copy of this pane with optional overrides.
  DSTerminalPane copyWith({
    String? id,
    String? title,
    IconData? icon,
    List<String>? history,
    int? badgeCount,
  }) {
    return DSTerminalPane(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      history: history ?? this.history,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSTerminalPane &&
        other.id == id &&
        other.title == title &&
        other.icon == icon &&
        other.badgeCount == badgeCount &&
        _listEquals(other.history, history);
  }

  @override
  int get hashCode =>
      Object.hash(id, title, icon, badgeCount, Object.hashAll(history));

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Controller managing the state of a [DSTerminalWorkspace].
///
/// Fixture-only: no PTY, no xterm.js, no process spawn. Hosts own this
/// controller and dispose it when the workspace unmounts.
class DSTerminalWorkspaceController extends ChangeNotifier {
  final List<DSTerminalPane> _panes;
  String? _focusedPaneId;
  DSTerminalLayoutMode _layoutMode;

  DSTerminalWorkspaceController({
    required List<DSTerminalPane> panes,
    String? focusedPaneId,
    this._layoutMode = DSTerminalLayoutMode.splitHorizontal,
  }) : _panes = List.of(panes),
       _focusedPaneId =
           focusedPaneId ?? (panes.isEmpty ? null : panes.first.id);

  /// Unmodifiable list of active terminal panes.
  List<DSTerminalPane> get panes => List.unmodifiable(_panes);

  /// ID of the currently focused terminal pane.
  String? get focusedPaneId => _focusedPaneId;

  /// Current layout mode (tabs, horizontal split, vertical split).
  DSTerminalLayoutMode get layoutMode => _layoutMode;

  /// Switches active keyboard/visual focus to pane [paneId].
  void focusPane(String paneId) {
    if (_focusedPaneId == paneId) return;
    _focusedPaneId = paneId;
    notifyListeners();
  }

  /// Changes the layout mode configuration.
  void setLayoutMode(DSTerminalLayoutMode mode) {
    if (_layoutMode == mode) return;
    _layoutMode = mode;
    notifyListeners();
  }

  /// Appends a new terminal pane to the workspace.
  void addPane(DSTerminalPane pane, {bool focus = true}) {
    _panes.add(pane);
    if (focus) {
      _focusedPaneId = pane.id;
    }
    notifyListeners();
  }

  /// Closes the pane matching [paneId], transferring focus if it was active.
  void closePane(String paneId) {
    final idx = _panes.indexWhere((p) => p.id == paneId);
    if (idx == -1) return;
    _panes.removeAt(idx);
    if (_focusedPaneId == paneId) {
      _focusedPaneId = _panes.isEmpty ? null : _panes.first.id;
    }
    notifyListeners();
  }

  /// Appends a line item to the history stream of pane [paneId].
  void addHistoryLine(String paneId, String line) {
    final idx = _panes.indexWhere((p) => p.id == paneId);
    if (idx == -1) return;
    final pane = _panes[idx];
    final newHistory = List<String>.from(pane.history)..add(line);
    _panes[idx] = pane.copyWith(history: newHistory);
    notifyListeners();
  }

  /// Clears the scrollback history buffer for pane [paneId].
  void clearHistory(String paneId) {
    final idx = _panes.indexWhere((p) => p.id == paneId);
    if (idx == -1) return;
    _panes[idx] = _panes[idx].copyWith(history: const []);
    notifyListeners();
  }
}
