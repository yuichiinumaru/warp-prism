import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../models/exercise_action.dart';
import '../models/host_config.dart';
import '../safety/action_policy.dart';

/// Semantic-first action discovery (v1).
///
/// Preference order (strongest identity first):
/// 1. Flutter semantics / tappable actions (`Semantics` with button flag —
///    the contract `DSInteractiveSurface` provides for every Prism
///    interactive chrome).
/// 2. Stable widget/test keys.
/// 3. Shared Warp Prism interaction primitives surfaced as tappables.
/// 4. Route registry targets supplied by the host adapter (smoke paths).
///
/// Explicitly NOT v1: computer vision, arbitrary pixel-coordinate clicking,
/// learned exploration, giant symbolic state machines, exhaustive
/// application-model checking.
class ExerciseActionDiscovery {
  static const int maxCandidatesPerScreen = 80;

  /// Discovers eligible SAFE candidates in the current tree, sorted by
  /// stable id for deterministic crawl/fuzz ordering.
  static List<ExerciseCandidate> discover(
    WidgetTester tester, {
    HostExerciseConfig? config,
    bool includeStatefulLocal = false,
  }) {
    final found = <String, ExerciseCandidate>{};

    void add(ExerciseCandidate candidate) {
      if (found.containsKey(candidate.id)) return;
      final resolved = ExerciseActionPolicy.resolve(candidate);
      if (resolved.safety == ActionSafety.externalOrDestructive) return;
      if (resolved.safety == ActionSafety.statefulLocal &&
          !includeStatefulLocal) {
        return;
      }
      if (config != null && !config.isEligible(resolved)) return;
      found[resolved.id] = resolved;
    }

    // 1. Semantics button nodes (covers DSInteractiveSurface interactive
    // path: Semantics(label, button: true, enabled: true)).
    final semanticsFinder = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Semantics &&
          (widget.properties.button == true) &&
          widget.key == null,
    );
    for (final element in semanticsFinder.evaluate()) {
      final widget = element.widget as Semantics;
      final label = widget.properties.label?.trim() ?? '';
      if (label.isEmpty) continue;
      final value = widget.properties.value?.trim() ?? '';
      final id = value.isEmpty ? 'sem:$label' : 'sem:$label=$value';
      add(
        ExerciseCandidate(id: id, label: label, kind: ExerciseActionKind.tap),
      );
      if (found.length >= maxCandidatesPerScreen) break;
    }

    // 2. Keyed tappables (stable keys beat labels for replay).
    final keyedFinder = find.byWidgetPredicate(
      (Widget widget) => widget.key != null && _isTappableWidget(widget),
    );
    for (final element in keyedFinder.evaluate()) {
      final keyString = _keyToString(element.widget.key!);
      if (keyString.isEmpty) continue;
      final semanticLabel =
          _ancestorSemanticsLabel(element) ??
          element.widget.runtimeType.toString();
      add(
        ExerciseCandidate(
          id: 'key:$keyString',
          label: semanticLabel,
          kind: ExerciseActionKind.tap,
        ),
      );
      if (found.length >= maxCandidatesPerScreen) break;
    }

    // 3. Unkeyed material/Prism tappables with resolvable semantics.
    final tappableFinder = find.byWidgetPredicate(_isTappableWidget);
    for (final element in tappableFinder.hitTestable().evaluate()) {
      final widget = element.widget;
      if (widget.key != null) continue; // already covered above
      final label = _ancestorSemanticsLabel(element);
      if (label == null || label.isEmpty) {
        continue; // skip unstable anonymous taps in v1
      }
      add(
        ExerciseCandidate(
          id: 'sem:$label',
          label: label,
          kind: ExerciseActionKind.tap,
        ),
      );
      if (found.length >= maxCandidatesPerScreen) break;
    }

    final sorted = found.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    return sorted;
  }

  /// Resolves a candidate id back to a live [Finder] for the current tree.
  ///
  /// Returns null when the target is not currently reachable (new state
  /// reveals new actions — the crawler records the miss and continues).
  static Finder? resolveFinder(WidgetTester tester, String candidateId) {
    if (candidateId.startsWith('key:')) {
      final raw = candidateId.substring(4);
      // Keys are stored via _keyToString; match ValueKey/Key string values.
      final byValue = find.byWidgetPredicate(
        (Widget widget) =>
            widget.key != null && _keyToString(widget.key!) == raw,
      );
      if (byValue.evaluate().isNotEmpty) return byValue.hitTestable();
      return null;
    }
    if (candidateId.startsWith('sem:')) {
      final label = candidateId.substring(4).split('=').first;
      final bySemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics && widget.properties.label == label,
      );
      if (bySemantics.evaluate().isNotEmpty) {
        // Tap the interactive descendant when the Semantics node itself
        // is not hit-testable (DSInteractiveSurface wraps content).
        return find
            .descendant(
              of: bySemantics,
              matching: find.byWidgetPredicate(_isTappableWidget),
            )
            .hitTestable();
      }
      final byText = find.text(label).hitTestable();
      if (byText.evaluate().isNotEmpty) return byText;
      final byTooltip = find.byTooltip(label).hitTestable();
      if (byTooltip.evaluate().isNotEmpty) return byTooltip;
      return null;
    }
    return null;
  }

  static bool _isTappableWidget(Widget widget) {
    if (widget is IconButton) return widget.onPressed != null;
    if (widget is TextButton) return widget.onPressed != null;
    if (widget is ElevatedButton) return widget.onPressed != null;
    if (widget is OutlinedButton) return widget.onPressed != null;
    if (widget is FilledButton) return widget.onPressed != null;
    if (widget is InkWell) return widget.onTap != null;
    if (widget is GestureDetector) return widget.onTap != null;
    if (widget is ListTile) return widget.onTap != null;
    if (widget is Checkbox) return widget.onChanged != null;
    if (widget is Switch) return widget.onChanged != null;
    // Radio.onChanged is deprecated post-3.32; type presence implies
    // a selection control rendered by the host.
    if (widget is Radio) return true;
    if (widget is DropdownButton) return true;
    if (widget is PopupMenuButton) return true;
    if (widget is Tab) return true;
    return false;
  }

  static String _keyToString(Key key) {
    final text = key.toString();
    // Key('catalog-nav-gallery') -> catalog-nav-gallery
    final match = RegExp(r'''Key\(['"]?(.*?)['"]?\)''').firstMatch(text);
    if (match != null) return match.group(1) ?? '';
    // [<'catalog-nav-gallery'>] -> catalog-nav-gallery
    final bracket = RegExp(r"\[<'(.*?)'>\]").firstMatch(text);
    if (bracket != null) return bracket.group(1) ?? '';
    return text;
  }

  static String? _ancestorSemanticsLabel(Element element) {
    var current = element;
    var depth = 0;
    while (depth < 8) {
      final parent = _parentElement(current);
      if (parent == null) return null;
      final widget = parent.widget;
      if (widget is Semantics) {
        final label = widget.properties.label?.trim() ?? '';
        if (label.isNotEmpty) return label;
      }
      current = parent;
      depth++;
    }
    return null;
  }

  static Element? _parentElement(Element element) {
    Element? parent;
    element.visitAncestorElements((Element ancestor) {
      parent = ancestor;
      return false;
    });
    return parent;
  }
}
