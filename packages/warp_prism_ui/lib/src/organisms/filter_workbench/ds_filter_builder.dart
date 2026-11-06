/// EXPERIMENTAL (Task 1860, F-12): [DSFilterBuilder] organism — nested
/// AND/OR groups, per-type editors, debounce-commit + explicit flush.
///
/// Anchored on the partial [DSFilterWorkbench] seam: the field catalog is
/// derived from workbench sections via [fieldsFromSections] (extend, never
/// fork). Composition only over [DSFilterChipGroup] (+ tokens/atoms);
/// no new table, grid, board, list, or tree primitive.
///
/// Debounce: edits update the draft immediately (`onChanged`); commit is
/// debounced through [DSFilterDebounceController] with a bounded single-shot
/// timer, the Apply button, or an explicit [DSFilterBuilderController.flush].
/// Tests drive the controller with an injected clock and never wait.
///
/// Lifecycle: EXPERIMENTAL — no barrel export, no `Prism*` alias.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_text.dart';
import '../../molecules/ds_filter_chip_group.dart';
import '../../tokens/tokens.dart';
import 'ds_filter_builder_editors.dart';
import 'ds_filter_builder_model.dart';
import 'ds_filter_workbench.dart';

export 'ds_filter_builder_model.dart' show DSFilterClock, dsFilterSystemClock;

/// Maps a [DSFilterWorkbench] schema to builder fields.
///
/// Anchor extension (never a fork): `multiSelect` → `enumMulti`,
/// `singleSelect` → `enumSingle`, `text` → `text`, `boolean` → `boolean`.
/// Both basic and advanced criteria are included.
List<DSFilterField> fieldsFromSections(List<DSFilterSection> sections) {
  final out = <DSFilterField>[];
  for (final section in sections) {
    for (final criterion in section.criteria) {
      final kind = switch (criterion.kind) {
        DSFilterCriterionKind.multiSelect => DSFilterEditorKind.enumMulti,
        DSFilterCriterionKind.singleSelect => DSFilterEditorKind.enumSingle,
        DSFilterCriterionKind.text => DSFilterEditorKind.text,
        DSFilterCriterionKind.boolean => DSFilterEditorKind.boolean,
      };
      out.add(
        DSFilterField(
          id: criterion.id,
          label: criterion.label,
          editorKind: kind,
          options: [
            for (final o in criterion.options)
              DSFilterBuilderOption(value: o.value, label: o.label),
          ],
          helperText: criterion.helperText,
        ),
      );
    }
  }
  return out;
}

/// External handle for an explicit debounce flush.
///
/// A parent (or test) holding the same controller passed to [DSFilterBuilder]
/// can commit the pending draft synchronously via [flush] — no waiting.
class DSFilterBuilderController {
  DSFilterDebounceController? _debounce;
  bool Function()? _flushHook;

  /// Commits any pending draft edit immediately. Returns true when a
  /// commit happened. Never waits.
  bool flush() => _flushHook?.call() ?? false;

  /// True while a draft edit awaits commit.
  bool get hasPending => _debounce?.hasPending ?? false;

  void _attach(DSFilterDebounceController debounce, bool Function() flushHook) {
    _debounce = debounce;
    _flushHook = flushHook;
  }

  void _detach() {
    _debounce = null;
    _flushHook = null;
  }
}

/// Nested AND/OR filter builder with per-type editors and debounce-commit.
///
/// Value contract: the caller supplies [fields]; evaluation of the committed
/// [DSFilterBuilderSnapshot] stays caller-side.
class DSFilterBuilder extends StatefulWidget {
  /// Caller-supplied field catalog (see [fieldsFromSections]).
  final List<DSFilterField> fields;

  /// Seed tree for uncontrolled mode.
  final DSFilterGroup initialTree;

  /// Controlled tree. When non-null, the parent drives the tree.
  final DSFilterGroup? tree;

  /// Panel title.
  final String title;

  /// Called on every draft edit with the current tree.
  final ValueChanged<DSFilterGroup>? onChanged;

  /// Called on debounce/Apply/flush commit with an immutable snapshot.
  final ValueChanged<DSFilterBuilderSnapshot>? onCommit;

  /// Called when Clear empties the tree.
  final VoidCallback? onClear;

  /// Debounce delay for auto-commit after the last edit.
  final Duration commitDelay;

  /// Injectable clock for the debounce controller.
  final DSFilterClock clock;

  /// Optional external controller for explicit flush.
  final DSFilterBuilderController? controller;

  /// Whether to wrap the panel in [DSGlassPanel.elevated].
  final bool wrapInGlass;

  /// Apply button label.
  final String applyLabel;

  /// Clear button label.
  final String clearLabel;

  const DSFilterBuilder({
    super.key,
    required this.fields,
    required this.initialTree,
    this.tree,
    this.title = 'Filter builder',
    this.onChanged,
    this.onCommit,
    this.onClear,
    this.commitDelay = const Duration(milliseconds: 350),
    this.clock = dsFilterSystemClock,
    this.controller,
    this.wrapInGlass = true,
    this.applyLabel = 'Apply',
    this.clearLabel = 'Clear',
  });

  /// Stable keys for tests and semantic tooling.
  static const Key panelKey = Key('ds-filter-1860-builder');
  static const Key applyButtonKey = Key('ds-filter-1860-apply');
  static const Key clearButtonKey = Key('ds-filter-1860-clear');
  static const Key summaryKey = Key('ds-filter-1860-summary');
  static const Key emptyStateKey = Key('ds-filter-1860-empty');

  /// Group region key by group id.
  static Key groupKey(String groupId) => Key('ds-filter-1860-group-$groupId');

  /// Predicate row key by predicate id.
  static Key predicateKey(String predicateId) =>
      Key('ds-filter-1860-predicate-$predicateId');

  /// Operator toggle key by group id.
  static Key operatorKey(String groupId) =>
      Key('ds-filter-1860-operator-$groupId');

  /// Add-predicate affordance key by group id.
  static Key addKeyFor(String groupId) => Key('ds-filter-1860-add-$groupId');

  /// Field-pick affordance key by group + field id.
  static Key fieldPickKey(String groupId, String fieldId) =>
      Key('ds-filter-1860-pick-$groupId-$fieldId');

  /// Add-subgroup affordance key by group id.
  static Key addGroupKeyFor(String groupId) =>
      Key('ds-filter-1860-add-group-$groupId');

  /// Remove-predicate affordance key by predicate id.
  static Key removeKeyFor(String predicateId) =>
      Key('ds-filter-1860-remove-$predicateId');

  /// Workspace semantic label.
  static const String panelSemanticLabel = 'Filter builder';

  @override
  State<DSFilterBuilder> createState() => _DSFilterBuilderState();
}

class _DSFilterBuilderState extends State<DSFilterBuilder> {
  late DSFilterGroup _internalTree;
  late DSFilterDebounceController _debounce;
  bool _ownsDebounce = false;
  Timer? _timer;
  int _idCounter = 0;
  DSFilterBuilderSnapshot? _lastCommitted;

  bool get _controlled => widget.tree != null;

  DSFilterGroup get _tree => _controlled ? widget.tree! : _internalTree;

  DSFilterField? _fieldFor(String fieldId) {
    for (final f in widget.fields) {
      if (f.id == fieldId) return f;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _internalTree = widget.initialTree;
    _debounce = DSFilterDebounceController(
      commitDelay: widget.commitDelay,
      clock: widget.clock,
    );
    _ownsDebounce = true;
    widget.controller?._attach(_debounce, flushCommit);
  }

  @override
  void didUpdateWidget(covariant DSFilterBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(_debounce, flushCommit);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller?._detach();
    if (_ownsDebounce) _debounce.dispose();
    super.dispose();
  }

  void _emitTree(DSFilterGroup next) {
    if (!_controlled) {
      setState(() => _internalTree = next);
    } else {
      setState(() {});
    }
    widget.onChanged?.call(next);
    _debounce.markEditedNow();
    _armTimer();
  }

  void _armTimer() {
    _timer?.cancel();
    if (widget.commitDelay == Duration.zero) {
      _timer = Timer(Duration.zero, _commitIfDue);
    } else {
      _timer = Timer(widget.commitDelay, _commitIfDue);
    }
  }

  void _commitIfDue() {
    if (!mounted) return;
    // The bounded single-shot timer armed in [_armTimer] is itself the due
    // signal: its expiry means the debounce window elapsed. Flush
    // unconditionally so widget behavior stays deterministic under fakeAsync
    // elapse (where a wall-clock re-check would never observe the elapsed
    // fake time). Pure-Dart consumers keep clock-checked edges via
    // [DSFilterDebounceController.commitIfDue].
    if (_debounce.flush()) {
      _emitCommit();
    }
  }

  /// Explicit flush entry point (also reachable via [DSFilterBuilderController]).
  bool flushCommit() {
    _timer?.cancel();
    if (!mounted) return false;
    if (_debounce.flush()) {
      _emitCommit();
      return true;
    }
    return false;
  }

  void _emitCommit() {
    final snapshot = DSFilterBuilderSnapshot(
      root: _tree,
      revision: _debounce.revision,
    );
    _lastCommitted = snapshot;
    widget.onCommit?.call(snapshot);
  }

  void _onApply() {
    _timer?.cancel();
    if (_debounce.flush()) {
      _emitCommit();
    } else if (_lastCommitted?.root != _tree) {
      _emitCommit();
    } else if (_lastCommitted == null) {
      _emitCommit();
    }
  }

  void _onClear() {
    _timer?.cancel();
    _debounce.cancel();
    const cleared = DSFilterGroup(id: 'root');
    if (!_controlled) {
      setState(() => _internalTree = cleared);
    }
    widget.onChanged?.call(cleared);
    widget.onClear?.call();
  }

  // -- tree mutations ------------------------------------------------------

  DSFilterGroup _updateGroup(
    DSFilterGroup group,
    String targetId,
    DSFilterGroup Function(DSFilterGroup) update,
  ) {
    if (group.id == targetId) return update(group);
    var changed = false;
    final subgroups = [
      for (final sub in group.subgroups)
        () {
          final next = _updateGroup(sub, targetId, update);
          if (!identical(next, sub)) changed = true;
          return next;
        }(),
    ];
    return changed ? group.copyWith(subgroups: subgroups) : group;
  }

  bool _containsGroup(DSFilterGroup group, String targetId) {
    if (group.id == targetId) return true;
    for (final sub in group.subgroups) {
      if (_containsGroup(sub, targetId)) return true;
    }
    return false;
  }

  void _addPredicate(String groupId, DSFilterField field) {
    if (!_containsGroup(_tree, groupId)) return;
    final predicate = DSFilterPredicate(
      id: 'p-${_idCounter++}-${field.id}',
      fieldId: field.id,
    );
    _emitTree(
      _updateGroup(
        _tree,
        groupId,
        (g) => g.copyWith(predicates: [...g.predicates, predicate]),
      ),
    );
  }

  void _removePredicate(String groupId, String predicateId) {
    if (!_containsGroup(_tree, groupId)) return;
    _emitTree(
      _updateGroup(
        _tree,
        groupId,
        (g) => g.copyWith(
          predicates: [
            for (final p in g.predicates)
              if (p.id != predicateId) p,
          ],
        ),
      ),
    );
  }

  void _setPredicateValues(
    String groupId,
    String predicateId,
    List<String> values,
  ) {
    if (!_containsGroup(_tree, groupId)) return;
    _emitTree(
      _updateGroup(
        _tree,
        groupId,
        (g) => g.copyWith(
          predicates: [
            for (final p in g.predicates)
              if (p.id == predicateId) p.copyWith(values: values) else p,
          ],
        ),
      ),
    );
  }

  void _toggleOperator(String groupId) {
    if (!_containsGroup(_tree, groupId)) return;
    _emitTree(
      _updateGroup(
        _tree,
        groupId,
        (g) => g.copyWith(
          operator: g.operator == DSFilterGroupOperator.and
              ? DSFilterGroupOperator.or
              : DSFilterGroupOperator.and,
        ),
      ),
    );
  }

  void _addSubgroup(String groupId) {
    if (!_containsGroup(_tree, groupId)) return;
    final subgroup = DSFilterGroup(id: 'g-${_idCounter++}');
    _emitTree(
      _updateGroup(
        _tree,
        groupId,
        (g) => g.copyWith(subgroups: [...g.subgroups, subgroup]),
      ),
    );
  }

  // -- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tree = _tree;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(title: widget.title, activeCount: tree.predicateCount),
                const SizedBox(height: DSSpacing.sm),
                _SummaryStrip(
                  tree: tree,
                  fields: widget.fields,
                  onRemove: _removePredicateInTree,
                ),
                const SizedBox(height: DSSpacing.sm),
                _GroupView(
                  group: tree,
                  depth: 0,
                  fields: widget.fields,
                  fieldFor: _fieldFor,
                  onToggleOperator: _toggleOperator,
                  onAddPredicate: _addPredicate,
                  onRemovePredicate: _removePredicate,
                  onSetValues: _setPredicateValues,
                  onAddSubgroup: _addSubgroup,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        _Footer(
          applyLabel: widget.applyLabel,
          clearLabel: widget.clearLabel,
          onApply: _onApply,
          onClear: _onClear,
        ),
      ],
    );

    final wrapped = widget.wrapInGlass
        ? DSGlassPanel.elevated(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: body,
          )
        : Padding(padding: const EdgeInsets.all(DSSpacing.md), child: body);

    return Semantics(
      key: DSFilterBuilder.panelKey,
      container: true,
      explicitChildNodes: true,
      label: DSFilterBuilder.panelSemanticLabel,
      child: wrapped,
    );
  }

  void _removePredicateInTree(String predicateId) {
    final host = _findHost(_tree, predicateId);
    if (host == null) return;
    _removePredicate(host, predicateId);
  }

  String? _findHost(DSFilterGroup group, String predicateId) {
    for (final p in group.predicates) {
      if (p.id == predicateId) return group.id;
    }
    for (final sub in group.subgroups) {
      final found = _findHost(sub, predicateId);
      if (found != null) return found;
    }
    return null;
  }
}

class _Header extends StatelessWidget {
  final String title;
  final int activeCount;

  const _Header({required this.title, required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: DSText.labelLarge(title, color: DSColors.textPrimary)),
        Semantics(
          label: '$activeCount active filters',
          child: DSText.labelSmall(
            '$activeCount active',
            color: DSColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Active-predicate summary composed over [DSFilterChipGroup]: tapping a
/// chip removes that predicate.
class _SummaryStrip extends StatelessWidget {
  final DSFilterGroup tree;
  final List<DSFilterField> fields;
  final ValueChanged<String> onRemove;

  const _SummaryStrip({
    required this.tree,
    required this.fields,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final entries = _collect(tree);
    if (entries.isEmpty) return const SizedBox.shrink();
    String labelFor(DSFilterPredicate p) {
      var name = p.fieldId;
      for (final f in fields) {
        if (f.id == p.fieldId) {
          name = f.label;
          break;
        }
      }
      final values = p.values.isEmpty ? 'any' : p.values.join(', ');
      return '$name: $values';
    }

    return KeyedSubtree(
      key: DSFilterBuilder.summaryKey,
      child: Semantics(
        label: 'Active filters',
        explicitChildNodes: true,
        child: DSFilterChipGroup(
          options: [
            for (final p in entries)
              DSFilterOption(value: p.id, label: labelFor(p)),
          ],
          selected: {for (final p in entries) p.id},
          allowMultiple: true,
          onToggle: onRemove,
        ),
      ),
    );
  }

  List<DSFilterPredicate> _collect(DSFilterGroup group) {
    final out = <DSFilterPredicate>[...group.predicates];
    for (final sub in group.subgroups) {
      out.addAll(_collect(sub));
    }
    return out;
  }
}

class _EmptyTree extends StatelessWidget {
  /// Only the root group owns the stable empty-state key; nested empty
  /// groups render a keyless hint so keys stay unique.
  final bool keyed;

  const _EmptyTree({this.keyed = true});

  @override
  Widget build(BuildContext context) {
    final hint = const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: DSSpacing.lg),
        child: DSText.labelMedium(
          'No filters yet — add one below',
          color: DSColors.textTertiary,
        ),
      ),
    );
    if (!keyed) return hint;
    return KeyedSubtree(key: DSFilterBuilder.emptyStateKey, child: hint);
  }
}

class _GroupView extends StatelessWidget {
  final DSFilterGroup group;
  final int depth;
  final List<DSFilterField> fields;
  final DSFilterField? Function(String fieldId) fieldFor;
  final ValueChanged<String> onToggleOperator;
  final void Function(String groupId, DSFilterField field) onAddPredicate;
  final void Function(String groupId, String predicateId) onRemovePredicate;
  final void Function(String groupId, String predicateId, List<String> values)
  onSetValues;
  final ValueChanged<String> onAddSubgroup;

  const _GroupView({
    required this.group,
    required this.depth,
    required this.fields,
    required this.fieldFor,
    required this.onToggleOperator,
    required this.onAddPredicate,
    required this.onRemovePredicate,
    required this.onSetValues,
    required this.onAddSubgroup,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _OperatorRow(group: group, onToggle: onToggleOperator),
        const SizedBox(height: DSSpacing.xs),
        if (group.predicates.isEmpty && group.subgroups.isEmpty)
          _EmptyTree(keyed: depth == 0),
        for (final predicate in group.predicates) ...[
          _PredicateRow(
            groupId: group.id,
            predicate: predicate,
            field: fieldFor(predicate.fieldId),
            onRemove: onRemovePredicate,
            onSetValues: onSetValues,
          ),
          const SizedBox(height: DSSpacing.xs),
        ],
        for (final subgroup in group.subgroups)
          Padding(
            padding: const EdgeInsets.only(left: DSSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: DSColors.borderSubtle.withValues(alpha: 0.7),
                  ),
                ),
              ),
              padding: const EdgeInsets.only(left: DSSpacing.sm),
              child: _GroupView(
                group: subgroup,
                depth: depth + 1,
                fields: fields,
                fieldFor: fieldFor,
                onToggleOperator: onToggleOperator,
                onAddPredicate: onAddPredicate,
                onRemovePredicate: onRemovePredicate,
                onSetValues: onSetValues,
                onAddSubgroup: onAddSubgroup,
              ),
            ),
          ),
        _AddRow(
          group: group,
          fields: fields,
          onAddPredicate: onAddPredicate,
          onAddSubgroup: onAddSubgroup,
        ),
      ],
    );

    return KeyedSubtree(
      key: DSFilterBuilder.groupKey(group.id),
      child: content,
    );
  }
}

class _OperatorRow extends StatelessWidget {
  final DSFilterGroup group;
  final ValueChanged<String> onToggle;

  const _OperatorRow({required this.group, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final selected = {
      group.operator == DSFilterGroupOperator.and ? 'and' : 'or',
    };
    return KeyedSubtree(
      key: DSFilterBuilder.operatorKey(group.id),
      child: Semantics(
        label: 'Group operator for ${group.id}',
        explicitChildNodes: true,
        child: DSFilterChipGroup(
          options: const [
            DSFilterOption(value: 'and', label: 'AND'),
            DSFilterOption(value: 'or', label: 'OR'),
          ],
          selected: selected,
          allowMultiple: false,
          onToggle: (_) => onToggle(group.id),
        ),
      ),
    );
  }
}

class _PredicateRow extends StatelessWidget {
  final String groupId;
  final DSFilterPredicate predicate;
  final DSFilterField? field;
  final void Function(String groupId, String predicateId) onRemove;
  final void Function(String groupId, String predicateId, List<String> values)
  onSetValues;

  const _PredicateRow({
    required this.groupId,
    required this.predicate,
    required this.field,
    required this.onRemove,
    required this.onSetValues,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = field;
    return KeyedSubtree(
      key: DSFilterBuilder.predicateKey(predicate.id),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: resolved?.label ?? predicate.fieldId,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: DSText.labelSmall(
                    resolved?.label ?? predicate.fieldId,
                    color: DSColors.textSecondary,
                  ),
                ),
                _RemoveHit(
                  key: DSFilterBuilder.removeKeyFor(predicate.id),
                  semanticLabel:
                      'Remove filter ${resolved?.label ?? predicate.fieldId}',
                  onTap: () => onRemove(groupId, predicate.id),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            if (resolved == null)
              const DSText.labelSmall(
                'Missing field definition',
                color: DSColors.textTertiary,
              )
            else
              _EditorFor(
                field: resolved,
                predicate: predicate,
                onSetValues: (values) =>
                    onSetValues(groupId, predicate.id, values),
              ),
            if (resolved?.helperText != null) ...[
              const SizedBox(height: DSSpacing.xxs),
              DSText.labelSmall(
                resolved!.helperText!,
                color: DSColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditorFor extends StatelessWidget {
  final DSFilterField field;
  final DSFilterPredicate predicate;
  final ValueChanged<List<String>> onSetValues;

  const _EditorFor({
    required this.field,
    required this.predicate,
    required this.onSetValues,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.editorKind) {
      case DSFilterEditorKind.text:
        return DSFilterTextEditor(
          key: DSFilterTextEditor.keyFor(predicate.id),
          values: predicate.values,
          fieldLabel: field.label,
          onChanged: onSetValues,
        );
      case DSFilterEditorKind.number:
        return DSFilterNumberEditor(
          key: DSFilterNumberEditor.keyFor(predicate.id),
          values: predicate.values,
          fieldLabel: field.label,
          onChanged: onSetValues,
        );
      case DSFilterEditorKind.enumSingle:
        return DSFilterEnumEditor(
          key: DSFilterEnumEditor.keyFor(predicate.id),
          values: predicate.values,
          fieldLabel: field.label,
          options: field.options,
          allowMultiple: false,
          onChanged: onSetValues,
        );
      case DSFilterEditorKind.enumMulti:
        return DSFilterEnumEditor(
          key: DSFilterEnumEditor.keyFor(predicate.id),
          values: predicate.values,
          fieldLabel: field.label,
          options: field.options,
          allowMultiple: true,
          onChanged: onSetValues,
        );
      case DSFilterEditorKind.boolean:
        return DSFilterBooleanEditor(
          key: DSFilterBooleanEditor.keyFor(predicate.id),
          values: predicate.values,
          fieldLabel: field.label,
          onChanged: onSetValues,
        );
    }
  }
}

class _AddRow extends StatelessWidget {
  final DSFilterGroup group;
  final List<DSFilterField> fields;
  final void Function(String groupId, DSFilterField field) onAddPredicate;
  final ValueChanged<String> onAddSubgroup;

  const _AddRow({
    required this.group,
    required this.fields,
    required this.onAddPredicate,
    required this.onAddSubgroup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: DSSpacing.xs,
          runSpacing: DSSpacing.xs,
          children: [
            _AddHit(
              key: DSFilterBuilder.addGroupKeyFor(group.id),
              label: '+ Group',
              semanticLabel: 'Add nested group to ${group.id}',
              onTap: () => onAddSubgroup(group.id),
            ),
            for (final field in fields)
              _AddHit(
                key: DSFilterBuilder.fieldPickKey(group.id, field.id),
                label: '+ ${field.label}',
                semanticLabel: 'Add ${field.label} filter to ${group.id}',
                onTap: () => onAddPredicate(group.id, field),
              ),
          ],
        ),
        // Stable add affordance per group for tests that seed custom trees.
        SizedBox(key: DSFilterBuilder.addKeyFor(group.id), height: 0, width: 0),
      ],
    );
  }
}

class _AddHit extends StatefulWidget {
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;

  const _AddHit({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  State<_AddHit> createState() => _AddHitState();
}

class _AddHitState extends State<_AddHit> {
  late final FocusNode _focusNode;
  bool _highlight = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'filter-1860-add');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (f) => setState(() => _highlight = f),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _highlight = true),
          onExit: (_) => setState(() => _highlight = false),
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              constraints: const BoxConstraints(
                minWidth: kMinInteractiveDimension,
                minHeight: kMinInteractiveDimension,
              ),
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _highlight ? DSColors.obsidianHover : Colors.transparent,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: Border.all(
                  color: _highlight
                      ? DSColors.focusRing
                      : DSColors.borderSubtle,
                ),
              ),
              child: Text(
                widget.label,
                style: DSTypography.labelMedium.copyWith(
                  color: DSColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveHit extends StatelessWidget {
  final String semanticLabel;
  final VoidCallback onTap;

  const _RemoveHit({
    super.key,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: FocusableActionDetector(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onTap();
              return null;
            },
          ),
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: kMinInteractiveDimension,
                minHeight: kMinInteractiveDimension,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                size: 18,
                color: DSColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String applyLabel;
  final String clearLabel;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const _Footer({
    required this.applyLabel,
    required this.clearLabel,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap (not Row+Spacer): at narrow widths / large text scale the two
    // actions stack instead of overflowing (Task 1860 host proof at
    // 195px logical + 2x text). Single-line rendering is unchanged when
    // both buttons fit.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: DSSpacing.xs,
      children: [
        _FooterButton(
          key: DSFilterBuilder.clearButtonKey,
          label: clearLabel,
          semanticLabel: 'Clear filters',
          emphasized: false,
          onPressed: onClear,
        ),
        _FooterButton(
          key: DSFilterBuilder.applyButtonKey,
          label: applyLabel,
          semanticLabel: 'Apply filters',
          emphasized: true,
          onPressed: onApply,
        ),
      ],
    );
  }
}

class _FooterButton extends StatefulWidget {
  final String label;
  final String semanticLabel;
  final bool emphasized;
  final VoidCallback onPressed;

  const _FooterButton({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.emphasized,
    required this.onPressed,
  });

  @override
  State<_FooterButton> createState() => _FooterButtonState();
}

class _FooterButtonState extends State<_FooterButton> {
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'filter-1860-footer-${widget.label}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = _hovered || _focused;
    final bg = widget.emphasized
        ? (highlight
              ? DSColors.accentBlue.withValues(alpha: 0.28)
              : DSColors.accentBlue.withValues(alpha: 0.18))
        : (highlight ? DSColors.obsidianHover : DSColors.obsidianElevated);
    final border = _focused
        ? DSColors.focusRing
        : (widget.emphasized ? DSColors.focusRing : DSColors.borderSubtle);

    return Semantics(
      button: true,
      enabled: true,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (f) => setState(() => _focused = f),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onPressed();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onPressed,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              constraints: const BoxConstraints(
                minWidth: kMinInteractiveDimension,
                minHeight: kMinInteractiveDimension,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: Border.all(color: border),
              ),
              child: Text(
                widget.label,
                style: DSTypography.labelMedium.copyWith(
                  color: widget.emphasized
                      ? DSColors.accentBlue
                      : DSColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
