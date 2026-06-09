import 'package:flutter/foundation.dart';
import 'ds_tab.dart';

/// ASW Observatory Organism — Tab Controller
///
/// Manages the list of open tabs, the active tab index, and tab
/// lifecycle operations (add, close, select).
///
/// Usage:
/// ```dart
/// final controller = DSTabController(tabs: [
///   DSTab(id: 'a', label: 'Agent Alpha', content: (_) => AgentView()),
///   DSTab(id: 'b', label: 'Skill Editor', closable: true, content: (_) => SkillEditor()),
/// ]);
/// controller.addListener(() => setState(() {}));
/// ```
///
/// The controller is a [ChangeNotifier] so it integrates naturally with
/// `AnimatedBuilder` or any widget that rebuilds on notify.
class DSTabController extends ChangeNotifier {
  List<DSTab> _tabs;
  int _activeIndex;

  /// Creates a controller with an initial list of [tabs] and optional
  /// [activeIndex] (defaults to 0 if tabs is non-empty).
  DSTabController({
    required List<DSTab> tabs,
    int activeIndex = 0,
  })  : _tabs = List.of(tabs),
        _activeIndex = tabs.isEmpty ? 0 : activeIndex.clamp(0, tabs.length - 1);

  // ---------------------------------------------------------------------------
  // READ-ONLY ACCESSORS
  // ---------------------------------------------------------------------------

  /// Unmodifiable view of the current tab list.
  List<DSTab> get tabs => List.unmodifiable(_tabs);

  /// Currently active tab index. Guaranteed in-range when tabs is non-empty.
  int get activeIndex => _activeIndex;

  /// The currently active tab, or `null` when [tabs] is empty.
  DSTab? get activeTab => _tabs.isEmpty ? null : _tabs[_activeIndex];

  /// Whether any tabs are open.
  bool get hasTabs => _tabs.isNotEmpty;

  /// Number of open tabs.
  int get length => _tabs.length;

  // ---------------------------------------------------------------------------
  // MUTATIONS
  // ---------------------------------------------------------------------------

  /// Selects the tab at [index].
  ///
  /// No-op if [index] is out of range or already active.
  void select(int index) {
    if (index < 0 || index >= _tabs.length) return;
    if (index == _activeIndex) return;
    _activeIndex = index;
    notifyListeners();
  }

  /// Selects the tab with the given [id].
  ///
  /// No-op if no tab with [id] exists.
  void selectById(String id) {
    final index = _tabs.indexWhere((t) => t.id == id);
    if (index == -1) return;
    select(index);
  }

  /// Appends [tab] to the end of the tab list and optionally selects it.
  ///
  /// If [selectNew] is true (default), the newly added tab becomes active.
  void add(DSTab tab, {bool selectNew = true}) {
    _tabs.add(tab);
    if (selectNew) {
      _activeIndex = _tabs.length - 1;
    }
    notifyListeners();
  }

  /// Inserts [tab] at [index] and optionally selects it.
  void insert(int index, DSTab tab, {bool selectNew = true}) {
    final clampedIndex = index.clamp(0, _tabs.length);
    _tabs.insert(clampedIndex, tab);
    if (selectNew) {
      _activeIndex = clampedIndex;
    } else if (_activeIndex >= clampedIndex) {
      // Shift active index to keep it pointing at the same tab.
      _activeIndex++;
    }
    notifyListeners();
  }

  /// Closes the tab at [index].
  ///
  /// - If the closed tab was active and tabs remain, the nearest tab
  ///   becomes active (prefers the tab to the right, then left).
  /// - If the closed tab was before the active tab, the active index
  ///   shifts left to stay on the same tab.
  /// - No-op if [index] is out of range.
  void close(int index) {
    if (index < 0 || index >= _tabs.length) return;
    _tabs.removeAt(index);

    if (_tabs.isEmpty) {
      _activeIndex = 0;
    } else if (index < _activeIndex) {
      _activeIndex--;
    } else if (index == _activeIndex) {
      // Prefer the tab that slid into this position (right neighbor),
      // otherwise fall back to the last tab.
      _activeIndex = _activeIndex.clamp(0, _tabs.length - 1);
    }
    notifyListeners();
  }

  /// Closes the tab with the given [id].
  void closeById(String id) {
    final index = _tabs.indexWhere((t) => t.id == id);
    if (index != -1) close(index);
  }

  /// Replaces the entire tab list and resets active index.
  void setTabs(List<DSTab> tabs, {int activeIndex = 0}) {
    _tabs = List.of(tabs);
    _activeIndex = tabs.isEmpty ? 0 : activeIndex.clamp(0, tabs.length - 1);
    notifyListeners();
  }

  /// Replaces the tab at [index] with [tab].
  ///
  /// No-op if [index] is out of range.
  void replace(int index, DSTab tab) {
    if (index < 0 || index >= _tabs.length) return;
    _tabs[index] = tab;
    notifyListeners();
  }
}
