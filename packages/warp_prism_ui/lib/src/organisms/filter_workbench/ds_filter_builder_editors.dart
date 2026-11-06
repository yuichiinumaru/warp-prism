/// EXPERIMENTAL (Task 1860, F-12): per-type predicate editors for
/// [DSFilterBuilder].
///
/// Dumb editors: field label + value in, normalized string values out.
/// No filter semantics, no timers, no wall-clock. Composition only over
/// [DSFilterChipGroup]; all styling from tokens.
///
/// Lifecycle: EXPERIMENTAL — no barrel export, no `Prism*` alias.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_text.dart';
import '../../molecules/ds_filter_chip_group.dart';
import '../../tokens/tokens.dart';
import 'ds_filter_builder_model.dart';

// =============================================================================
// Text editor
// =============================================================================

/// Free-text predicate editor. Emits `[text]` (or `[]` when empty).
class DSFilterTextEditor extends StatefulWidget {
  /// Current raw values; reads `values.firstOrNull`.
  final List<String> values;

  /// Field label used for semantics.
  final String fieldLabel;

  /// Placeholder hint.
  final String placeholder;

  /// Called with normalized values on every keystroke.
  final ValueChanged<List<String>> onChanged;

  const DSFilterTextEditor({
    super.key,
    required this.values,
    required this.fieldLabel,
    required this.onChanged,
    this.placeholder = 'Enter value…',
  });

  /// Stable key for tests per predicate id.
  static Key keyFor(String predicateId) =>
      Key('ds-filter-1860-text-$predicateId');

  @override
  State<DSFilterTextEditor> createState() => _DSFilterTextEditorState();
}

class _DSFilterTextEditorState extends State<DSFilterTextEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.values.isEmpty ? '' : widget.values.first,
    );
    _focusNode = FocusNode(debugLabel: 'filter-1860-text-${widget.fieldLabel}');
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(covariant DSFilterTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.values.isEmpty ? '' : widget.values.first;
    if (next != _controller.text) _controller.text = next;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: widget.fieldLabel,
      child: AnimatedContainer(
        duration: DSMotion.fast,
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.input),
          border: Border.all(
            color: _focused ? DSColors.focusRing : DSColors.borderSubtle,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
        alignment: Alignment.centerLeft,
        child: Material(
          type: MaterialType.transparency,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (v) => widget.onChanged(v.isEmpty ? const [] : [v]),
            style: DSTypography.bodyMedium.copyWith(
              color: DSColors.textPrimary,
            ),
            cursorColor: DSColors.accentBlue,
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
      ),
    );
  }
}

// =============================================================================
// Number editor
// =============================================================================

/// Numeric predicate editor. Emits `[raw]` verbatim; shows a helper error
/// when the text is not a number. Parsing stays caller-side.
class DSFilterNumberEditor extends StatefulWidget {
  /// Current raw values; reads `values.firstOrNull`.
  final List<String> values;

  /// Field label used for semantics.
  final String fieldLabel;

  /// Called with normalized values on every keystroke.
  final ValueChanged<List<String>> onChanged;

  const DSFilterNumberEditor({
    super.key,
    required this.values,
    required this.fieldLabel,
    required this.onChanged,
  });

  /// Stable key for tests per predicate id.
  static Key keyFor(String predicateId) =>
      Key('ds-filter-1860-number-$predicateId');

  @override
  State<DSFilterNumberEditor> createState() => _DSFilterNumberEditorState();
}

class _DSFilterNumberEditorState extends State<DSFilterNumberEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.values.isEmpty ? '' : widget.values.first,
    );
    _focusNode = FocusNode(
      debugLabel: 'filter-1860-number-${widget.fieldLabel}',
    );
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(covariant DSFilterNumberEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.values.isEmpty ? '' : widget.values.first;
    if (next != _controller.text) _controller.text = next;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _valid {
    final text = _controller.text;
    if (text.isEmpty) return true;
    return double.tryParse(text) != null;
  }

  @override
  Widget build(BuildContext context) {
    final border = !_valid
        ? DSColors.statusError
        : (_focused ? DSColors.focusRing : DSColors.borderSubtle);
    return Semantics(
      textField: true,
      label: widget.fieldLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: DSMotion.fast,
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: DSColors.obsidianElevated,
              borderRadius: BorderRadius.circular(DSRadii.input),
              border: Border.all(color: border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
            alignment: Alignment.centerLeft,
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  setState(() {});
                  final v = _controller.text;
                  widget.onChanged(v.isEmpty ? const [] : [v]);
                },
                style: DSTypography.bodyMedium.copyWith(
                  color: DSColors.textPrimary,
                ),
                cursorColor: DSColors.accentBlue,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: DSTypography.bodyMedium.copyWith(
                    color: DSColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          if (!_valid) ...[
            const SizedBox(height: DSSpacing.xxs),
            DSText.labelSmall('Enter a number', color: DSColors.statusError),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Enum (chip) editor — composition over DSFilterChipGroup
// =============================================================================

/// Chip predicate editor for enum fields. Single-select emits `[value]` (or
/// `[]`); multi-select emits the selected set in catalog order.
class DSFilterEnumEditor extends StatelessWidget {
  /// Current raw values.
  final List<String> values;

  /// Field label used for semantics.
  final String fieldLabel;

  /// Catalog options for this field.
  final List<DSFilterBuilderOption> options;

  /// False for single-select, true for multi-select.
  final bool allowMultiple;

  /// Called with normalized values on toggle.
  final ValueChanged<List<String>> onChanged;

  const DSFilterEnumEditor({
    super.key,
    required this.values,
    required this.fieldLabel,
    required this.options,
    required this.allowMultiple,
    required this.onChanged,
  });

  /// Stable key for tests per predicate id.
  static Key keyFor(String predicateId) =>
      Key('ds-filter-1860-enum-$predicateId');

  @override
  Widget build(BuildContext context) {
    final selected = values.toSet();
    final chipOptions = [
      for (final o in options) DSFilterOption(value: o.value, label: o.label),
    ];
    return Semantics(
      label: fieldLabel,
      explicitChildNodes: true,
      child: DSFilterChipGroup(
        options: chipOptions,
        selected: selected,
        allowMultiple: allowMultiple,
        onToggle: (value) {
          if (!allowMultiple) {
            onChanged(selected.contains(value) ? const [] : [value]);
            return;
          }
          final next = Set<String>.from(selected);
          if (next.contains(value)) {
            next.remove(value);
          } else {
            next.add(value);
          }
          // Emit in catalog order for stable enumeration.
          onChanged([
            for (final o in options)
              if (next.contains(o.value)) o.value,
          ]);
        },
      ),
    );
  }
}

// =============================================================================
// Boolean editor
// =============================================================================

/// Toggle predicate editor. Emits `['true']` when on, `[]` when off.
class DSFilterBooleanEditor extends StatelessWidget {
  /// Current raw values; on when containing `'true'`.
  final List<String> values;

  /// Field label used for semantics.
  final String fieldLabel;

  /// Called with normalized values on toggle.
  final ValueChanged<List<String>> onChanged;

  const DSFilterBooleanEditor({
    super.key,
    required this.values,
    required this.fieldLabel,
    required this.onChanged,
  });

  /// Stable key for tests per predicate id.
  static Key keyFor(String predicateId) =>
      Key('ds-filter-1860-bool-$predicateId');

  bool get _on => values.contains('true');

  @override
  Widget build(BuildContext context) {
    final on = _on;
    return Semantics(
      toggled: on,
      button: true,
      label: fieldLabel,
      excludeSemantics: true,
      child: FocusableActionDetector(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onChanged(on ? const [] : const ['true']);
              return null;
            },
          ),
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onChanged(on ? const [] : const ['true']),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
              decoration: BoxDecoration(
                color: on
                    ? DSColors.accentBlue.withValues(alpha: 0.12)
                    : DSColors.obsidianElevated,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: Border.all(
                  color: on ? DSColors.focusRing : DSColors.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    on
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank,
                    size: 20,
                    color: on ? DSColors.accentBlue : DSColors.textTertiary,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: DSText.labelMedium(
                      on ? 'Enabled' : 'Disabled',
                      color: on ? DSColors.accentBlue : DSColors.textSecondary,
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
