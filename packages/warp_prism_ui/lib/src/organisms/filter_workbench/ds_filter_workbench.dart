import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../molecules/ds_filter_chip_group.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Kind of interactive control for a [DSFilterCriterion].
enum DSFilterCriterionKind {
  /// Multi-select chips ([DSFilterChipGroup]). Value: [Set<String>].
  multiSelect,

  /// Single-select chips. Value: [String] or null.
  singleSelect,

  /// Free-text field. Value: [String].
  text,

  /// On/off toggle. Value: [bool].
  boolean,
}

/// A single filter field definition within a [DSFilterSection].
///
/// Fixture-friendly: definitions are pure data — no live backends.
class DSFilterCriterion {
  /// Stable criterion identity used as the values map key.
  final String id;

  /// Human-readable field label.
  final String label;

  /// Control kind.
  final DSFilterCriterionKind kind;

  /// Options for [DSFilterCriterionKind.multiSelect] /
  /// [DSFilterCriterionKind.singleSelect]. Ignored for text/boolean.
  final List<DSFilterOption> options;

  /// Placeholder for text criteria.
  final String? placeholder;

  /// When true, criterion is shown only in the advanced section / modal.
  final bool advanced;

  /// Optional helper line under the control.
  final String? helperText;

  const DSFilterCriterion({
    required this.id,
    required this.label,
    required this.kind,
    this.options = const [],
    this.placeholder,
    this.advanced = false,
    this.helperText,
  });
}

/// Named group of related [DSFilterCriterion] fields.
class DSFilterSection {
  /// Stable section identity.
  final String id;

  /// Section header title.
  final String title;

  /// Optional short description under the title.
  final String? description;

  /// Criteria rendered under this section.
  final List<DSFilterCriterion> criteria;

  const DSFilterSection({
    required this.id,
    required this.title,
    this.description,
    this.criteria = const [],
  });
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Filter Workbench
///
/// Structured multi-section filter panel beyond a lone [DSFilterChipGroup]:
/// sectioned criteria, draft values, **Apply** / **Clear**, and an optional
/// **Advanced** surface (expandable section and/or modal dialog).
///
/// Value map contract (keyed by [DSFilterCriterion.id]):
/// - multiSelect → [Set<String>]
/// - singleSelect → [String]?
/// - text → [String]
/// - boolean → [bool]
///
/// Selection:
/// - Uncontrolled (default): seed from [initialValues]; organism owns draft.
/// - Controlled: pass [values] on every rebuild; parent owns draft state.
///
/// Fixture/read-only ADS surface — no product-route coupling.
class DSFilterWorkbench extends StatefulWidget {
  /// Panel title shown in the header.
  final String title;

  /// Optional subtitle under the title.
  final String? subtitle;

  /// Sectioned filter schema. Empty list → empty-state surface.
  final List<DSFilterSection> sections;

  /// Controlled draft values. When non-null, parent drives the draft map.
  final Map<String, Object?>? values;

  /// Seed values for uncontrolled mode.
  final Map<String, Object?> initialValues;

  /// Called on every draft edit with an immutable copy of the draft map.
  final ValueChanged<Map<String, Object?>>? onChanged;

  /// Called when Apply is pressed with the current draft values.
  final ValueChanged<Map<String, Object?>>? onApply;

  /// Called when Clear/Reset is pressed (after draft is emptied).
  final VoidCallback? onReset;

  /// Whether to wrap the panel in [DSGlassPanel.elevated]. Defaults to true.
  final bool wrapInGlass;

  /// Show a quick [DSFilterChipGroup] bar composed from the first non-advanced
  /// multi-select criterion (if any). Defaults to true.
  final bool showQuickChips;

  /// Show an expandable Advanced section for criteria marked [DSFilterCriterion.advanced].
  final bool showAdvancedSection;

  /// When true, an Advanced button opens a modal dialog for advanced criteria.
  final bool enableAdvancedModal;

  /// Initially expand the advanced section (section mode only).
  final bool initiallyAdvancedExpanded;

  /// Apply button label.
  final String applyLabel;

  /// Clear / reset button label.
  final String clearLabel;

  /// Advanced affordance label.
  final String advancedLabel;

  const DSFilterWorkbench({
    super.key,
    this.title = 'Filters',
    this.subtitle,
    required this.sections,
    this.values,
    this.initialValues = const {},
    this.onChanged,
    this.onApply,
    this.onReset,
    this.wrapInGlass = true,
    this.showQuickChips = true,
    this.showAdvancedSection = true,
    this.enableAdvancedModal = true,
    this.initiallyAdvancedExpanded = false,
    this.applyLabel = 'Apply',
    this.clearLabel = 'Clear',
    this.advancedLabel = 'Advanced',
  });

  /// Stable keys for tests and semantic tooling.
  static const Key panelKey = Key('ds-filter-workbench');
  static const Key applyButtonKey = Key('ds-filter-workbench-apply');
  static const Key clearButtonKey = Key('ds-filter-workbench-clear');
  static const Key advancedButtonKey = Key('ds-filter-workbench-advanced');
  static const Key advancedSectionKey = Key(
    'ds-filter-workbench-advanced-section',
  );
  static const Key advancedModalKey = Key('ds-filter-workbench-advanced-modal');
  static const Key advancedModalCloseKey = Key(
    'ds-filter-workbench-advanced-modal-close',
  );
  static const Key advancedModalCancelKey = Key(
    'ds-filter-workbench-advanced-modal-cancel',
  );
  static const Key advancedModalDoneKey = Key(
    'ds-filter-workbench-advanced-modal-done',
  );
  static const Key emptyStateKey = Key('ds-filter-workbench-empty');
  static const Key quickChipsKey = Key('ds-filter-workbench-quick-chips');

  /// Criterion control key by criterion id.
  static Key criterionKey(String criterionId) =>
      Key('ds-filter-workbench-criterion-$criterionId');

  /// Section region key by section id.
  static Key sectionKey(String sectionId) =>
      Key('ds-filter-workbench-section-$sectionId');

  /// Workspace semantic label.
  static const String panelSemanticLabel = 'Filter workbench';

  /// Apply control semantic label.
  static const String applySemanticLabel = 'Apply filters';

  /// Clear control semantic label.
  static const String clearSemanticLabel = 'Clear filters';

  /// Advanced open control semantic label.
  static const String advancedSemanticLabel = 'Open advanced filters';

  /// Returns a shallow-immutable copy suitable for callbacks.
  static Map<String, Object?> copyValues(Map<String, Object?> source) {
    final out = <String, Object?>{};
    for (final entry in source.entries) {
      final v = entry.value;
      if (v is Set<String>) {
        out[entry.key] = Set<String>.unmodifiable(v);
      } else if (v is List<String>) {
        out[entry.key] = List<String>.unmodifiable(v);
      } else {
        out[entry.key] = v;
      }
    }
    return Map<String, Object?>.unmodifiable(out);
  }

  /// Read multi-select set from a values map (accepts [Set] or [List]).
  static Set<String> readStringSet(Map<String, Object?> values, String id) {
    final v = values[id];
    if (v is Set<String>) return v;
    if (v is Set) return v.map((e) => e.toString()).toSet();
    if (v is List<String>) return v.toSet();
    if (v is List) return v.map((e) => e.toString()).toSet();
    if (v is String && v.isNotEmpty) return {v};
    return const {};
  }

  /// Read single-select string.
  static String? readString(Map<String, Object?> values, String id) {
    final v = values[id];
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }

  /// Read boolean (defaults false).
  static bool readBool(Map<String, Object?> values, String id) {
    final v = values[id];
    if (v is bool) return v;
    if (v is String) return v == 'true' || v == '1';
    return false;
  }

  @override
  State<DSFilterWorkbench> createState() => _DSFilterWorkbenchState();
}

class _DSFilterWorkbenchState extends State<DSFilterWorkbench> {
  late Map<String, Object?> _internalValues;
  late bool _advancedExpanded;

  bool get _controlled => widget.values != null;

  Map<String, Object?> get _draft {
    if (_controlled) return widget.values!;
    return _internalValues;
  }

  @override
  void initState() {
    super.initState();
    _internalValues = Map<String, Object?>.from(widget.initialValues);
    _advancedExpanded = widget.initiallyAdvancedExpanded;
  }

  @override
  void didUpdateWidget(covariant DSFilterWorkbench oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controlled &&
        widget.initialValues != oldWidget.initialValues &&
        widget.values == null) {
      // Only re-seed uncontrolled when initialValues identity changes and
      // parent is not driving values.
      // Intentionally do not clobber user edits mid-session unless parent
      // replaces initialValues (rare). Skip auto-reset.
    }
  }

  List<DSFilterCriterion> get _allCriteria {
    final out = <DSFilterCriterion>[];
    for (final section in widget.sections) {
      out.addAll(section.criteria);
    }
    return out;
  }

  List<DSFilterCriterion> get _basicCriteria =>
      _allCriteria.where((c) => !c.advanced).toList(growable: false);

  List<DSFilterCriterion> get _advancedCriteria =>
      _allCriteria.where((c) => c.advanced).toList(growable: false);

  bool get _hasSchema => _allCriteria.isNotEmpty;

  bool get _hasAdvanced => _advancedCriteria.isNotEmpty;

  DSFilterCriterion? get _quickMultiSelect {
    for (final c in _basicCriteria) {
      if (c.kind == DSFilterCriterionKind.multiSelect && c.options.isNotEmpty) {
        return c;
      }
    }
    return null;
  }

  void _emitChanged(Map<String, Object?> next) {
    if (!_controlled) {
      setState(() => _internalValues = next);
    }
    widget.onChanged?.call(DSFilterWorkbench.copyValues(next));
  }

  void _setValue(String id, Object? value) {
    final next = Map<String, Object?>.from(_draft);
    if (value == null ||
        (value is String && value.isEmpty) ||
        (value is Set && value.isEmpty) ||
        (value is bool && value == false)) {
      // Keep false booleans explicit so toggles round-trip; only drop empty
      // collections / null / empty strings.
      if (value is bool) {
        next[id] = false;
      } else {
        next.remove(id);
      }
    } else {
      next[id] = value;
    }
    _emitChanged(next);
  }

  void _toggleMulti(String id, String option, {required bool allowMultiple}) {
    if (!allowMultiple) {
      final current = DSFilterWorkbench.readString(_draft, id);
      _setValue(id, current == option ? null : option);
      return;
    }
    final current = Set<String>.from(
      DSFilterWorkbench.readStringSet(_draft, id),
    );
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    _setValue(id, current.isEmpty ? null : current);
  }

  void _onApply() {
    widget.onApply?.call(DSFilterWorkbench.copyValues(_draft));
  }

  void _onClear() {
    final next = <String, Object?>{};
    if (!_controlled) {
      setState(() => _internalValues = next);
    }
    widget.onChanged?.call(DSFilterWorkbench.copyValues(next));
    widget.onReset?.call();
  }

  Future<void> _openAdvancedModal() async {
    if (!_hasAdvanced) return;
    final draftSnapshot = Map<String, Object?>.from(_draft);

    final result = await showDialog<Map<String, Object?>>(
      context: context,
      barrierColor: DSColors.obsidianDeep.withValues(alpha: 0.72),
      builder: (ctx) {
        return _AdvancedFilterDialog(
          title: widget.advancedLabel,
          criteria: _advancedCriteria,
          initialValues: draftSnapshot,
        );
      },
    );

    if (!mounted || result == null) return;

    // Merge advanced ids from dialog result into current draft.
    final next = Map<String, Object?>.from(_draft);
    for (final c in _advancedCriteria) {
      if (result.containsKey(c.id)) {
        final v = result[c.id];
        if (v == null ||
            (v is String && v.isEmpty) ||
            (v is Set && v.isEmpty)) {
          next.remove(c.id);
        } else {
          next[c.id] = v;
        }
      } else {
        next.remove(c.id);
      }
    }
    _emitChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    // Header scrolls with criteria so large text scales cannot make
    // fixed chrome (header + footer) exceed the host height. Footer stays
    // pinned for Apply/Clear reachability when space remains.
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  showAdvancedButton:
                      widget.enableAdvancedModal && _hasAdvanced,
                  advancedLabel: widget.advancedLabel,
                  onAdvanced: _openAdvancedModal,
                ),
                const SizedBox(height: DSSpacing.sm),
                if (!_hasSchema)
                  const SizedBox(height: 160, child: _EmptySchema())
                else
                  _buildScrollBodyContent(),
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
      key: DSFilterWorkbench.panelKey,
      container: true,
      explicitChildNodes: true,
      label: DSFilterWorkbench.panelSemanticLabel,
      child: wrapped,
    );
  }

  /// Criteria stack without its own scroll view (outer panel owns scrolling).
  Widget _buildScrollBodyContent() {
    final quick = widget.showQuickChips ? _quickMultiSelect : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (quick != null) ...[
          KeyedSubtree(
            key: DSFilterWorkbench.quickChipsKey,
            child: _CriterionBlock(
              criterion: quick,
              values: _draft,
              onToggleMulti: (opt) =>
                  _toggleMulti(quick.id, opt, allowMultiple: true),
              onSetValue: (v) => _setValue(quick.id, v),
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          const _Hairline(),
          const SizedBox(height: DSSpacing.md),
        ],
        for (var i = 0; i < widget.sections.length; i++) ...[
          if (i > 0) const SizedBox(height: DSSpacing.md),
          _SectionBlock(
            section: widget.sections[i],
            values: _draft,
            includeAdvanced: false,
            // Avoid duplicating the quick-chip criterion in its section.
            excludeCriterionIds: {if (quick != null) quick.id},
            onToggleMulti: _toggleMulti,
            onSetValue: _setValue,
          ),
        ],
        if (widget.showAdvancedSection && _hasAdvanced) ...[
          const SizedBox(height: DSSpacing.md),
          const _Hairline(),
          const SizedBox(height: DSSpacing.sm),
          _AdvancedExpandable(
            expanded: _advancedExpanded,
            label: widget.advancedLabel,
            count: _advancedCriteria.length,
            onToggle: () =>
                setState(() => _advancedExpanded = !_advancedExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _advancedCriteria.length; i++) ...[
                  if (i > 0) const SizedBox(height: DSSpacing.sm),
                  _CriterionBlock(
                    criterion: _advancedCriteria[i],
                    values: _draft,
                    onToggleMulti: (opt) => _toggleMulti(
                      _advancedCriteria[i].id,
                      opt,
                      allowMultiple:
                          _advancedCriteria[i].kind ==
                          DSFilterCriterionKind.multiSelect,
                    ),
                    onSetValue: (v) => _setValue(_advancedCriteria[i].id, v),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// Sub-widgets
// =============================================================================

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showAdvancedButton;
  final String advancedLabel;
  final VoidCallback onAdvanced;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.showAdvancedButton,
    required this.advancedLabel,
    required this.onAdvanced,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSText.labelLarge(title, color: DSColors.textPrimary),
              if (subtitle != null) ...[
                const SizedBox(height: DSSpacing.xxs),
                DSText.labelSmall(subtitle!, color: DSColors.textTertiary),
              ],
            ],
          ),
        ),
        if (showAdvancedButton)
          _WorkbenchButton(
            key: DSFilterWorkbench.advancedButtonKey,
            label: advancedLabel,
            semanticLabel: DSFilterWorkbench.advancedSemanticLabel,
            emphasized: false,
            onPressed: onAdvanced,
            icon: Icons.tune,
          ),
      ],
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
    return Row(
      children: [
        _WorkbenchButton(
          key: DSFilterWorkbench.clearButtonKey,
          label: clearLabel,
          semanticLabel: DSFilterWorkbench.clearSemanticLabel,
          emphasized: false,
          onPressed: onClear,
        ),
        const Spacer(),
        _WorkbenchButton(
          key: DSFilterWorkbench.applyButtonKey,
          label: applyLabel,
          semanticLabel: DSFilterWorkbench.applySemanticLabel,
          emphasized: true,
          onPressed: onApply,
        ),
      ],
    );
  }
}

class _EmptySchema extends StatelessWidget {
  const _EmptySchema();

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: DSFilterWorkbench.emptyStateKey,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSIcon(
              Icons.filter_alt_off_outlined,
              color: DSColors.textTertiary.withValues(alpha: 0.7),
              size: 36,
            ),
            const SizedBox(height: DSSpacing.sm),
            const DSText.labelMedium(
              'No filter criteria defined',
              color: DSColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final DSFilterSection section;
  final Map<String, Object?> values;
  final bool includeAdvanced;
  final Set<String> excludeCriterionIds;
  final void Function(String id, String option, {required bool allowMultiple})
  onToggleMulti;
  final void Function(String id, Object? value) onSetValue;

  const _SectionBlock({
    required this.section,
    required this.values,
    required this.includeAdvanced,
    this.excludeCriterionIds = const {},
    required this.onToggleMulti,
    required this.onSetValue,
  });

  @override
  Widget build(BuildContext context) {
    final criteria = section.criteria
        .where(
          (c) =>
              (includeAdvanced || !c.advanced) &&
              !excludeCriterionIds.contains(c.id),
        )
        .toList(growable: false);

    if (criteria.isEmpty) {
      return const SizedBox.shrink();
    }

    return KeyedSubtree(
      key: DSFilterWorkbench.sectionKey(section.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DSText.labelMedium(section.title, color: DSColors.textSecondary),
          if (section.description != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            DSText.labelSmall(
              section.description!,
              color: DSColors.textTertiary,
            ),
          ],
          const SizedBox(height: DSSpacing.sm),
          for (var i = 0; i < criteria.length; i++) ...[
            if (i > 0) const SizedBox(height: DSSpacing.sm),
            _CriterionBlock(
              criterion: criteria[i],
              values: values,
              onToggleMulti: (opt) => onToggleMulti(
                criteria[i].id,
                opt,
                allowMultiple:
                    criteria[i].kind == DSFilterCriterionKind.multiSelect,
              ),
              onSetValue: (v) => onSetValue(criteria[i].id, v),
            ),
          ],
        ],
      ),
    );
  }
}

class _CriterionBlock extends StatelessWidget {
  final DSFilterCriterion criterion;
  final Map<String, Object?> values;
  final ValueChanged<String> onToggleMulti;
  final ValueChanged<Object?> onSetValue;

  const _CriterionBlock({
    required this.criterion,
    required this.values,
    required this.onToggleMulti,
    required this.onSetValue,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: DSFilterWorkbench.criterionKey(criterion.id),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: criterion.label,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSText.labelSmall(criterion.label, color: DSColors.textSecondary),
            const SizedBox(height: DSSpacing.xs),
            _buildControl(),
            if (criterion.helperText != null) ...[
              const SizedBox(height: DSSpacing.xxs),
              DSText.labelSmall(
                criterion.helperText!,
                color: DSColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControl() {
    switch (criterion.kind) {
      case DSFilterCriterionKind.multiSelect:
        final selected = DSFilterWorkbench.readStringSet(values, criterion.id);
        return DSFilterChipGroup(
          options: criterion.options,
          selected: selected,
          allowMultiple: true,
          onToggle: onToggleMulti,
        );
      case DSFilterCriterionKind.singleSelect:
        final selected = DSFilterWorkbench.readString(values, criterion.id);
        return DSFilterChipGroup(
          options: criterion.options,
          selected: selected == null ? const {} : {selected},
          allowMultiple: false,
          onToggle: onToggleMulti,
        );
      case DSFilterCriterionKind.text:
        return _TextCriterionField(
          value: DSFilterWorkbench.readString(values, criterion.id) ?? '',
          placeholder: criterion.placeholder ?? 'Enter value…',
          label: criterion.label,
          onChanged: (v) => onSetValue(v),
        );
      case DSFilterCriterionKind.boolean:
        final on = DSFilterWorkbench.readBool(values, criterion.id);
        return _BooleanCriterionRow(
          label: criterion.label,
          value: on,
          onChanged: (v) => onSetValue(v),
        );
    }
  }
}

class _TextCriterionField extends StatefulWidget {
  final String value;
  final String placeholder;
  final String label;
  final ValueChanged<String> onChanged;

  const _TextCriterionField({
    required this.value,
    required this.placeholder,
    required this.label,
    required this.onChanged,
  });

  @override
  State<_TextCriterionField> createState() => _TextCriterionFieldState();
}

class _TextCriterionFieldState extends State<_TextCriterionField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode(debugLabel: 'filter-text-${widget.label}');
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(covariant _TextCriterionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = _focused
        ? DSColors.accentCyan.withValues(alpha: 0.5)
        : DSColors.borderSubtle;

    return Semantics(
      textField: true,
      label: widget.label,
      child: AnimatedContainer(
        duration: DSMotion.fast,
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.input),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
        alignment: Alignment.centerLeft,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          style: DSTypography.bodyMedium.copyWith(color: DSColors.textPrimary),
          cursorColor: DSColors.accentCyan,
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: widget.placeholder,
            hintStyle: DSTypography.bodyMedium.copyWith(
              color: DSColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BooleanCriterionRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BooleanCriterionRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      button: true,
      label: label,
      excludeSemantics: true,
      child: FocusableActionDetector(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onChanged(!value);
              return null;
            },
          ),
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onChanged(!value),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
              decoration: BoxDecoration(
                color: value
                    ? DSColors.accentCyan.withValues(alpha: 0.12)
                    : DSColors.obsidianElevated,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: Border.all(
                  color: value
                      ? DSColors.accentCyan.withValues(alpha: 0.45)
                      : DSColors.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    value
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank,
                    size: 20,
                    color: value ? DSColors.accentCyan : DSColors.textTertiary,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: DSText.labelMedium(
                      value ? 'Enabled' : 'Disabled',
                      color: value
                          ? DSColors.accentCyan
                          : DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdvancedExpandable extends StatelessWidget {
  final bool expanded;
  final String label;
  final int count;
  final VoidCallback onToggle;
  final Widget child;

  const _AdvancedExpandable({
    required this.expanded,
    required this.label,
    required this.count,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: DSFilterWorkbench.advancedSectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: expanded,
            label: '$label, $count fields',
            excludeSemantics: true,
            child: FocusableActionDetector(
              actions: <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    onToggle();
                    return null;
                  },
                ),
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: kMinInteractiveDimension,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          expanded ? Icons.expand_more : Icons.chevron_right,
                          size: 20,
                          color: DSColors.textSecondary,
                        ),
                        const SizedBox(width: DSSpacing.xs),
                        DSText.labelMedium(
                          label,
                          color: DSColors.textSecondary,
                        ),
                        const SizedBox(width: DSSpacing.xs),
                        DSText.labelSmall(
                          '($count)',
                          color: DSColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (expanded) ...[const SizedBox(height: DSSpacing.sm), child],
        ],
      ),
    );
  }
}

class _AdvancedFilterDialog extends StatefulWidget {
  final String title;
  final List<DSFilterCriterion> criteria;
  final Map<String, Object?> initialValues;

  const _AdvancedFilterDialog({
    required this.title,
    required this.criteria,
    required this.initialValues,
  });

  @override
  State<_AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends State<_AdvancedFilterDialog> {
  late Map<String, Object?> _local;

  @override
  void initState() {
    super.initState();
    _local = Map<String, Object?>.from(widget.initialValues);
  }

  void _setValue(String id, Object? value) {
    setState(() {
      if (value == null ||
          (value is String && value.isEmpty) ||
          (value is Set && value.isEmpty)) {
        if (value is bool) {
          _local[id] = false;
        } else {
          _local.remove(id);
        }
      } else {
        _local[id] = value;
      }
    });
  }

  void _toggleMulti(String id, String option, {required bool allowMultiple}) {
    if (!allowMultiple) {
      final current = DSFilterWorkbench.readString(_local, id);
      _setValue(id, current == option ? null : option);
      return;
    }
    final current = Set<String>.from(
      DSFilterWorkbench.readStringSet(_local, id),
    );
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    _setValue(id, current.isEmpty ? null : current);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xxl,
        vertical: DSSpacing.xxxl,
      ),
      child: KeyedSubtree(
        key: DSFilterWorkbench.advancedModalKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
          child: DSGlassPanel.modal(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DSText.headingSmall(
                        widget.title,
                        color: DSColors.textPrimary,
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Close advanced filters',
                      child: _IconHit(
                        key: DSFilterWorkbench.advancedModalCloseKey,
                        icon: Icons.close,
                        tooltip: 'Close',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < widget.criteria.length; i++) ...[
                          if (i > 0) const SizedBox(height: DSSpacing.sm),
                          _CriterionBlock(
                            criterion: widget.criteria[i],
                            values: _local,
                            onToggleMulti: (opt) => _toggleMulti(
                              widget.criteria[i].id,
                              opt,
                              allowMultiple:
                                  widget.criteria[i].kind ==
                                  DSFilterCriterionKind.multiSelect,
                            ),
                            onSetValue: (v) =>
                                _setValue(widget.criteria[i].id, v),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DSSpacing.md),
                Row(
                  children: [
                    _WorkbenchButton(
                      key: DSFilterWorkbench.advancedModalCancelKey,
                      label: 'Cancel',
                      semanticLabel: 'Cancel advanced filters',
                      emphasized: false,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _WorkbenchButton(
                      key: DSFilterWorkbench.advancedModalDoneKey,
                      label: 'Done',
                      semanticLabel: 'Confirm advanced filters',
                      emphasized: true,
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(DSFilterWorkbench.copyValues(_local)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkbenchButton extends StatefulWidget {
  final String label;
  final String semanticLabel;
  final bool emphasized;
  final VoidCallback onPressed;
  final IconData? icon;

  const _WorkbenchButton({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.emphasized,
    required this.onPressed,
    this.icon,
  });

  @override
  State<_WorkbenchButton> createState() => _WorkbenchButtonState();
}

class _WorkbenchButtonState extends State<_WorkbenchButton> {
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'filter-btn-${widget.label}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emphasized = widget.emphasized;
    final highlight = _hovered || _focused;
    final bg = emphasized
        ? (highlight
              ? DSColors.accentCyan.withValues(alpha: 0.28)
              : DSColors.accentCyan.withValues(alpha: 0.18))
        : (highlight ? DSColors.obsidianHover : DSColors.obsidianElevated);
    final border = emphasized
        ? DSColors.accentCyan.withValues(alpha: _focused ? 0.8 : 0.5)
        : (_focused
              ? DSColors.accentCyan.withValues(alpha: 0.45)
              : DSColors.borderSubtle);
    final fg = emphasized ? DSColors.accentCyan : DSColors.textSecondary;

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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 16, color: fg),
                    const SizedBox(width: DSSpacing.xs),
                  ],
                  Text(
                    widget.label,
                    style: DSTypography.labelMedium.copyWith(color: fg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconHit extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconHit({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_IconHit> createState() => _IconHitState();
}

class _IconHitState extends State<_IconHit> {
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'filter-icon-hit');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = _hovered || _focused;
    return Semantics(
      button: true,
      enabled: true,
      label: widget.tooltip,
      excludeSemantics: true,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (f) => setState(() => _focused = f),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Tooltip(
          message: widget.tooltip,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: DSMotion.fast,
                constraints: const BoxConstraints(
                  minWidth: kMinInteractiveDimension,
                  minHeight: kMinInteractiveDimension,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: highlight
                      ? DSColors.obsidianHover
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(DSRadii.sm),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: highlight
                      ? DSColors.accentCyan
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

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: DSColors.borderSubtle.withValues(alpha: 0.6),
    );
  }
}
