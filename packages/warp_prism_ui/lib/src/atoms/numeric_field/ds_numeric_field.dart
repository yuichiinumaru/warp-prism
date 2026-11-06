import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ds_icon.dart';
import '../ds_text.dart';
import '../text_field/ds_text_field.dart';

// =============================================================================
// NUMERIC 1881 — NUMERIC FIELD (EXPERIMENTAL)
// =============================================================================
//
// EXPERIMENTAL atom precursor of `PrismNumericField` (Task 1881, F-14).
//
// Donor shape (FigCraft B3, read-only inspiration — state machine, not code):
// `field_math.rs:8-43` (Typed/relative/div-zero/format bounds),
// `widgets.rs:20-133` (Lead/Set-vs-Scrub/commit/quantum/modifier rates/
// release-frame), `field_tests.rs:18-52` (parse table).
//
// Shared commit invariant (consumed read-only from F-07 / Task 1874, donor B1
// `right.rs:26-57`): one-gesture-one-history-step, live-vs-committed typed as
// `Set|Scrub`. This file does not relitigate that invariant; it types this
// atom's commits with it. Live `Scrub(v, false)` events are previews for the
// future host to coalesce; the terminal `Scrub(v, true)` closes the gesture.
// The release frame moves nothing: the terminal value always equals the last
// live value.
//
// Lifecycle: EXPERIMENTAL. Intentionally **not** exported from any barrel and
// without a `Prism*` alias until the promotion task wires the public surface
// (layer-contracts §9, MISSION §6).
//
// Presentation-only seam: parse, format, and quantum arrive injected. Exact
// domain arithmetic (arbitrary-precision integers, divisor-normalised
// fractions, timebase quantisation, calibration) stays product-local and
// must never appear in this file. This file imports
// no `warp_prism_interaction`, no bindings, no FRB, no IO: scrub mechanics
// live in presentation and read only synchronous framework keyboard state.
// Rendering is deterministic: no wall-clock, no timers, no randomness, no
// animation drivers.

/// Typed commit emitted by [DSNumericField] (Task 1881, F-14).
///
/// Carries the F-07 shared commit invariant in the value type: a committed
/// history step is a [NumericSet]; a live label-scrub preview is a
/// [NumericScrub] whose [NumericScrub.ended] flag closes the gesture.
sealed class NumericCommit {
  /// Typed commit: [NumericSet] or [NumericScrub].
  const NumericCommit();
}

/// Committed a new value (submit, or an empty-field `+v` settle).
///
/// The future host applies this as exactly one history step.
final class NumericSet extends NumericCommit {
  /// The committed value in caller units.
  final double value;

  /// Committed value [value] in caller units.
  const NumericSet(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NumericSet && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NumericSet($value)';
}

/// Live scrub preview (dragging the lead label).
///
/// [ended] is true exactly once per gesture, on the terminal event, and the
/// terminal value always equals the last live value (release-frame no-op).
final class NumericScrub extends NumericCommit {
  /// The scrubbed value in caller units.
  final double value;

  /// True only on the terminal event closing the gesture.
  final bool ended;

  /// Scrub preview of [value]; [ended] closes the gesture.
  const NumericScrub(this.value, this.ended);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NumericScrub && other.value == value && other.ended == ended);

  @override
  int get hashCode => Object.hash(value, ended);

  @override
  String toString() => 'NumericScrub($value, ended: $ended)';
}

/// What typed text means: a value, or an edit relative to the current value.
///
/// Pure-Dart port of the donor `Typed`/`Rel` shape (`field_math.rs:8-43`)
/// without any domain coupling: magnitudes are caller-unit doubles, never
/// exact fractions, timestamps, or calibrated quantities.
sealed class NumericTypedEdit {
  /// A typed edit: absolute [NumericValue] or relative add/mul/div.
  const NumericTypedEdit();

  /// Applies this edit to [current], or null when it is not a number
  /// any more (division by zero, non-finite result).
  double? applyTo(double current);
}

/// Absolute value edit (`12`, `10+5`, `12px`).
final class NumericValue extends NumericTypedEdit {
  /// Absolute value in caller units.
  final double value;

  /// Absolute value edit of [value] caller units.
  const NumericValue(this.value);

  @override
  double? applyTo(double current) => value.isFinite ? value : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NumericValue && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NumericValue($value)';
}

/// Relative addition (`+10`, `+ 2*3`).
final class NumericAdd extends NumericTypedEdit {
  /// Amount to add in caller units.
  final double amount;

  /// Relative addition of [amount] caller units.
  const NumericAdd(this.amount);

  @override
  double? applyTo(double current) {
    final v = current + amount;
    return v.isFinite ? v : null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NumericAdd && other.amount == amount);

  @override
  int get hashCode => amount.hashCode;

  @override
  String toString() => 'NumericAdd($amount)';
}

/// Relative multiplication (`*2`, `50%` of the value).
final class NumericMul extends NumericTypedEdit {
  /// Factor to multiply by.
  final double factor;

  /// Relative multiplication by [factor].
  const NumericMul(this.factor);

  @override
  double? applyTo(double current) {
    final v = current * factor;
    return v.isFinite ? v : null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NumericMul && other.factor == factor);

  @override
  int get hashCode => factor.hashCode;

  @override
  String toString() => 'NumericMul($factor)';
}

/// Relative division (`/4`). Division by zero is not a number (null).
final class NumericDiv extends NumericTypedEdit {
  /// Divisor to divide by. Zero yields null (fail-closed, never infinity).
  final double divisor;

  /// Relative division by [divisor].
  const NumericDiv(this.divisor);

  @override
  double? applyTo(double current) {
    if (divisor == 0.0) return null;
    final v = current / divisor;
    return v.isFinite ? v : null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NumericDiv && other.divisor == divisor);

  @override
  int get hashCode => divisor.hashCode;

  @override
  String toString() => 'NumericDiv($divisor)';
}

/// What a numeric field's lead (label) shows.
///
/// Donor `Lead` shape (`widgets.rs:20-133`): the lead doubles as the
/// accessible name. `Text('W')` announces as `Width`; an icon lead carries
/// the field's name for screen readers because an icon alone does not say
/// which property it is.
sealed class DSNumericLead {
  /// A numeric-field lead label with an accessible-name convention.
  const DSNumericLead();

  /// The field's name for screen readers (`W` is `Width`).
  String get resolvedName;

  /// Visible lead text (`''` when the lead shows no text).
  String get shortLabel;
}

/// Text lead (`W`, `X`, `Opacity`).
final class DSNumericLeadText extends DSNumericLead {
  /// Visible lead text.
  final String text;

  /// Text lead showing [text].
  const DSNumericLeadText(this.text);

  @override
  String get resolvedName {
    switch (text) {
      case 'W':
        return 'Width';
      case 'H':
        return 'Height';
      case 'X':
        return 'X';
      case 'Y':
        return 'Y';
      default:
        return text;
    }
  }

  @override
  String get shortLabel => text;
}

/// Icon lead with the field's accessible [name].
final class DSNumericLeadIcon extends DSNumericLead {
  /// Icon shown in the lead slot.
  final IconData icon;

  /// Accessible field name (an icon does not say which property it is).
  final String name;

  /// Icon lead showing [icon] named [name] for screen readers.
  const DSNumericLeadIcon(this.icon, this.name);

  @override
  String get resolvedName => name;

  @override
  String get shortLabel => '';
}

/// No visible lead, only a name for screen readers.
final class DSNumericLeadNamed extends DSNumericLead {
  /// Accessible field name.
  final String name;

  /// Named-only lead (the visible label sits beside the field).
  const DSNumericLeadNamed(this.name);

  @override
  String get resolvedName => name;

  @override
  String get shortLabel => '';
}

/// No lead at all.
final class DSNumericLeadNone extends DSNumericLead {
  /// Leadless field.
  const DSNumericLeadNone();

  @override
  String get resolvedName => '';

  @override
  String get shortLabel => '';
}

/// Injected numeric parser seam (Task 1881, F-14).
///
/// Parses [text] into a typed edit. [percentUnit] is true when the field
/// shows a percentage, so a trailing `%` is the unit rather than a relative
/// edit. Returns null for text that is not a number someone typed
/// (fail-closed: the widget keeps the old value and emits nothing).
typedef DSNumericParse =
    NumericTypedEdit? Function(String text, bool percentUnit);

/// Injected numeric formatter seam (Task 1881, F-14).
///
/// Renders [value] verbatim for the field text and readout. Same input must
/// yield same output (deterministic, caller-owned formatting).
typedef DSNumericFormat = String Function(double value);

/// How far a scrub of [dx] points moves a value whose field steps by [step].
///
/// One step a point, ten with Shift, a tenth with Alt (fine). Shift+Alt
/// together falls through to 1× (donor `scrub_amount` rule). Non-finite or
/// non-positive steps move nothing (fail-closed).
double numericScrubAmount(double dx, double step, bool shift, bool alt) {
  if (!dx.isFinite || !step.isFinite || step <= 0.0) return 0.0;
  return dx *
      step *
      switch ((shift, alt)) {
        (true, false) => 10.0,
        (false, true) => 0.1,
        _ => 1.0,
      };
}

/// Quantum governing a scrub stretch: tenths under Alt, whole steps above.
///
/// Donor rule: `if alt { step * 0.1 } else { step }`.
double numericQuantumFor(double step, bool alt) => alt ? step * 0.1 : step;

/// The value a scrub that began at [from] and moved [amount] shows.
///
/// Whole steps of [quantum] away from where it began, so repeated fractional
/// additions never accumulate float dust. Non-positive, non-finite, or NaN
/// inputs keep [from] (fail-closed).
double numericScrubbed(double from, double amount, double quantum) {
  if (!from.isFinite || !amount.isFinite) return from;
  if (!quantum.isFinite || quantum <= 0.0) return from;
  return numericStepped(from, (amount / quantum).roundToDouble(), quantum);
}

/// [from] moved [steps] steps of [step], without float dust (`0.1 + 0.2`).
///
/// Non-finite results keep [from].
double numericStepped(double from, double steps, double step) {
  final v = from + steps * step;
  if (!v.isFinite) return from;
  return (v * 1e6).round() / 1e6;
}

/// Settles a typed [edit] against the field's current value.
///
/// Donor `Edit::settled` rule: absolute edits apply always; relative edits
/// apply per-layer from each layer's own value; with no value (`null`, the
/// `Mixed` case) only `+v` settles to `v` — every other relative edit is
/// nothing (null, fail-closed).
double? numericSettled(NumericTypedEdit? edit, double? current) {
  if (edit == null) return null;
  if (edit is NumericValue) return edit.value.isFinite ? edit.value : null;
  if (current == null || !current.isFinite) {
    return edit is NumericAdd && edit.amount.isFinite ? edit.amount : null;
  }
  return edit.applyTo(current);
}

/// Evaluates [text] for a field showing [current] (`null` = Mixed).
///
/// Every unit reads as a unit; without a value `+4` is 4. Uses the reference
/// parser with percentage-unit semantics, mirroring the donor `eval`.
double? dsNumericEval(String text, double? current) =>
    numericSettled(dsNumericReferenceParse(text, true), current);

/// Reference parser fake (Task 1881, F-14 — EXPERIMENTAL).
///
/// Pure-Dart port of the donor `parse` (`field_math.rs:118-145`): numbers,
/// `+ - * /` arithmetic with brackets and precedence, decimal commas, unit
/// suffixes (letters, `°`, `%`-as-unit in percentage fields), leading
/// `+`/`*`/`/` relative edits, and the `%` duality (`50%` halves the value,
/// `+10%` adds a tenth, `-10%` removes a tenth; in a percentage field `%`
/// is the unit). Bounds: 256 chars, 32 nesting depth. Division by zero,
/// non-finite results, and trailing garbage are null — never an exception.
NumericTypedEdit? dsNumericReferenceParse(String text, bool percentUnit) {
  const maxLen = 256;
  const maxDepth = 32;
  final trimmed = text.trim();
  if (trimmed.isEmpty || trimmed.length > maxLen) return null;
  var body = trimmed;
  var sawPercent = false;
  if (!percentUnit && body.endsWith('%')) {
    sawPercent = true;
    body = body.substring(0, body.length - 1).trim();
  }
  String? lead;
  var rest = body;
  if (body.isNotEmpty) {
    final first = body[0];
    if (first == '+' || first == '*' || first == '/') {
      lead = first;
      rest = body.substring(1);
    }
  }
  final parser = _NumericParser(
    rest,
    percentUnit: percentUnit,
    maxDepth: maxDepth,
  );
  final parsed = parser.parseSum(0);
  if (parsed == null || !parser.atEnd) return null;
  final value = parsed;
  if (!sawPercent) {
    return switch (lead) {
      null => NumericValue(value),
      '+' => NumericAdd(value),
      '*' => NumericMul(value),
      _ => NumericDiv(value),
    };
  }
  // `50%` of the value; a typed minus lives in `value` (`-10%` removes a
  // tenth); `+10%` adds a tenth.
  if (lead == null) {
    if (body.startsWith('-')) return NumericMul(1.0 + value / 100.0);
    return NumericMul(value / 100.0);
  }
  return switch (lead) {
    '+' => NumericMul(1.0 + value / 100.0),
    '*' => NumericMul(value / 100.0),
    _ => NumericDiv(value / 100.0),
  };
}

/// Reference formatter fake (Task 1881, F-14 — EXPERIMENTAL).
///
/// Port of the donor `fmt_num`: non-finite renders as empty (fail-closed,
/// never `Infinity`/`NaN` text); otherwise rounded to two decimals with
/// integral values rendered without a fraction.
String dsNumericReferenceFormat(double value) {
  if (!value.isFinite) return '';
  final rounded = (value * 100.0).round() / 100.0;
  final whole = rounded.round();
  if ((rounded - whole).abs() < 1e-9) return '$whole';
  return '$rounded';
}

/// Accumulates one label-scrub gesture across modifier-rate stretches.
///
/// Each stretch counts at its own rate (modifiers may change mid-gesture),
/// mirroring the donor `scrub` accumulation. One instance per field: scrub
/// state is never shared, so editing one field never mutates its siblings.
class NumericScrubSession {
  /// Accumulated caller-unit travel across stretches.
  double _amount = 0.0;

  /// Accumulated caller-unit travel across stretches.
  double get amount => _amount;

  /// Creates an empty scrub session.
  NumericScrubSession();

  /// Adds a pointer stretch of [dx] points at the given modifier rates.
  void addStretch(double dx, double step, bool shift, bool alt) {
    final delta = numericScrubAmount(dx, step, shift, alt);
    final next = _amount + delta;
    _amount = next.isFinite ? next : _amount;
  }

  /// Resolves the live value from scrub origin [from] at [quantum].
  double resolve(double from, double quantum) =>
      numericScrubbed(from, _amount, quantum);

  /// True when the pointer has not travelled (a click, not a drag).
  bool get isUnmoved => _amount == 0.0;

  /// Forgets accumulated travel (gesture start).
  void reset() {
    _amount = 0.0;
  }
}

/// EXPERIMENTAL numeric field atom (Task 1881, F-14).
///
/// One gesture, one typed commit: text submits resolve through the injected
/// [parse] seam and settle via [numericSettled] into [NumericSet]; lead-label
/// drags accumulate a [NumericScrubSession] and emit live [NumericScrub]
/// previews plus exactly one terminal `ended` event. The release frame moves
/// nothing — the terminal value always equals the last live value — and a
/// press that does not move emits nothing. Invalid text fails closed: the
/// field restores the last value text and emits nothing.
///
/// Null [value] renders as `Mixed` (multi-selection with no single value).
/// Scrubbing a `Mixed` field is a no-op (nothing to scrub from).
///
/// Lifecycle: EXPERIMENTAL. No barrel export, no `Prism` alias.
class DSNumericField extends StatefulWidget {
  /// Lead label carrying the accessible name ([DSNumericLead]).
  final DSNumericLead lead;

  /// Current value in caller units, or null for `Mixed`.
  final double? value;

  /// Caller-unit travel per scrub point (must be finite and > 0 to scrub).
  final double step;

  /// Snap quantum in caller units, or null for the donor rule
  /// ([numericQuantumFor]: tenths under Alt, whole steps otherwise).
  final double? quantum;

  /// True when the field shows a percentage (`%` is the unit, not relative).
  final bool percentUnit;

  /// Injected parser seam. Defaults to the reference fake.
  final DSNumericParse parse;

  /// Injected formatter seam. Defaults to the reference fake.
  final DSNumericFormat format;

  /// Fired for every typed commit ([NumericSet]) and scrub event
  /// ([NumericScrub], live plus one terminal).
  final ValueChanged<NumericCommit>? onCommit;

  /// Whether user interaction is enabled.
  final bool enabled;

  /// Controller for external text management.
  final TextEditingController? controller;

  /// Helper text displayed below the field.
  final String? helperText;

  /// Custom error message.
  final String? errorText;

  /// Creates an EXPERIMENTAL numeric field.
  const DSNumericField({
    super.key,
    this.lead = const DSNumericLeadNone(),
    this.value,
    this.step = 1.0,
    this.quantum,
    this.percentUnit = false,
    this.parse = dsNumericReferenceParse,
    this.format = dsNumericReferenceFormat,
    this.onCommit,
    this.enabled = true,
    this.controller,
    this.helperText,
    this.errorText,
  });

  @override
  State<DSNumericField> createState() => _DSNumericFieldState();
}

class _DSNumericFieldState extends State<DSNumericField> {
  late TextEditingController _effectiveController;
  final NumericScrubSession _session = NumericScrubSession();
  double? _scrubBase;
  double? _lastLive;
  bool _scrubbing = false;

  String _textFor(double? value) =>
      value == null ? 'Mixed' : widget.format(value);

  @override
  void initState() {
    super.initState();
    _effectiveController =
        widget.controller ??
        TextEditingController(text: _textFor(widget.value));
  }

  @override
  void didUpdateWidget(DSNumericField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _effectiveController.dispose();
      }
      _effectiveController =
          widget.controller ??
          TextEditingController(text: _textFor(widget.value));
    } else if (widget.value != oldWidget.value && !_scrubbing) {
      _effectiveController.text = _textFor(widget.value);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  void _handleSubmitted(String raw) {
    if (!widget.enabled) return;
    final next = numericSettled(
      widget.parse(raw, widget.percentUnit),
      widget.value,
    );
    if (next == null || !next.isFinite) {
      // Fail-closed: invalid text restores the last value text and commits
      // nothing.
      setState(() {
        _effectiveController.text = _textFor(widget.value);
      });
      return;
    }
    setState(() {
      _effectiveController.text = widget.format(next);
    });
    widget.onCommit?.call(NumericSet(next));
  }

  void _handleScrubStart(DragStartDetails details) {
    if (!widget.enabled) return;
    final base = widget.value;
    if (base == null || !base.isFinite) return;
    if (!widget.step.isFinite || widget.step <= 0.0) return;
    _session.reset();
    _scrubBase = base;
    _lastLive = base;
    _scrubbing = true;
  }

  void _handleScrubUpdate(DragUpdateDetails details) {
    if (!_scrubbing) return;
    final base = _scrubBase;
    if (base == null) return;
    final pressed = HardwareKeyboard.instance;
    final shift = pressed.isShiftPressed;
    final alt = pressed.isAltPressed;
    _session.addStretch(details.delta.dx, widget.step, shift, alt);
    final quantum = widget.quantum ?? numericQuantumFor(widget.step, alt);
    final live = _session.resolve(base, quantum);
    if (live == _lastLive) return;
    _lastLive = live;
    setState(() {
      _effectiveController.text = widget.format(live);
    });
    widget.onCommit?.call(NumericScrub(live, false));
  }

  void _handleScrubEnd() {
    if (!_scrubbing) return;
    _scrubbing = false;
    // Release-frame no-op: the terminal event reuses the last live value
    // verbatim — the release frame itself moves nothing. An unmoved press
    // (a click on the lead) commits nothing.
    if (_session.isUnmoved) {
      _scrubBase = null;
      return;
    }
    final terminal = _lastLive;
    _scrubBase = null;
    if (terminal == null) return;
    setState(() {
      _effectiveController.text = widget.format(terminal);
    });
    widget.onCommit?.call(NumericScrub(terminal, true));
  }

  @override
  Widget build(BuildContext context) {
    final resolvedName = widget.lead.resolvedName;
    final semanticsLabel = resolvedName.isEmpty
        ? 'Numeric field'
        : resolvedName;
    final shortLabel = widget.lead.shortLabel;

    Widget? leadWidget;
    final lead = widget.lead;
    if (lead is DSNumericLeadIcon) {
      leadWidget = DSIcon.small(lead.icon, semanticLabel: null);
    } else if (shortLabel.isNotEmpty) {
      leadWidget = DSText.labelMedium(shortLabel);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadWidget != null)
          Semantics(
            label: '$semanticsLabel scrub label',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: _handleScrubStart,
              onHorizontalDragUpdate: _handleScrubUpdate,
              onHorizontalDragEnd: (_) => _handleScrubEnd(),
              onHorizontalDragCancel: _handleScrubEnd,
              child: SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: leadWidget,
                ),
              ),
            ),
          ),
        DSTextField(
          controller: _effectiveController,
          enabled: widget.enabled,
          hint: widget.value == null ? 'Mixed' : null,
          helperText: widget.helperText,
          errorText: widget.errorText,
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          semanticsLabel: semanticsLabel,
          onSubmitted: _handleSubmitted,
        ),
      ],
    );
  }
}

/// Recursive-descent parser backing [dsNumericReferenceParse].
///
/// Mirrors the donor `Parser` (`field_math.rs:45-113`): sums of products of
/// factors (numbers with units, bracketed sums, negation). ASCII digits only
/// (a decimal comma reads as a decimal point); unit letters, `°`, and `%`
/// where it is the unit are skipped after numbers.
class _NumericParser {
  /// Source text after lead/percent splitting.
  final String source;

  /// Whether `%` after a number is its unit.
  final bool percentUnit;

  /// Maximum bracket nesting depth.
  final int maxDepth;

  /// Current cursor into [source].
  int cursor = 0;

  /// Parser over [source] with [%] unit handling [percentUnit].
  _NumericParser(
    this.source, {
    required this.percentUnit,
    required this.maxDepth,
  });

  /// True when only whitespace remains.
  bool get atEnd {
    _skipSpace();
    return cursor >= source.length;
  }

  void _skipSpace() {
    while (cursor < source.length) {
      final unit = source.codeUnitAt(cursor);
      if (unit == 0x09 ||
          unit == 0x0A ||
          unit == 0x0B ||
          unit == 0x0C ||
          unit == 0x0D ||
          unit == 0x20 ||
          unit == 0xA0) {
        cursor++;
      } else {
        return;
      }
    }
  }

  bool _eat(String char) {
    _skipSpace();
    if (cursor < source.length && source[cursor] == char) {
      cursor++;
      return true;
    }
    return false;
  }

  /// Parses sums and differences of products.
  double? parseSum(int depth) {
    var value = parseProduct(depth);
    if (value == null) return null;
    while (true) {
      if (_eat('+')) {
        final rhs = parseProduct(depth);
        if (rhs == null) return null;
        value = value! + rhs;
      } else if (_eat('-')) {
        final rhs = parseProduct(depth);
        if (rhs == null) return null;
        value = value! - rhs;
      } else {
        return value!.isFinite ? value : null;
      }
    }
  }

  /// Parses products and quotients of factors.
  double? parseProduct(int depth) {
    var value = parseFactor(depth);
    if (value == null) return null;
    while (true) {
      if (_eat('*')) {
        final rhs = parseFactor(depth);
        if (rhs == null) return null;
        value = value! * rhs;
      } else if (_eat('/')) {
        final divisor = parseFactor(depth);
        if (divisor == null) return null;
        if (divisor == 0.0) return null;
        value = value! / divisor;
      } else {
        return value;
      }
    }
  }

  /// Parses a number with its unit, a bracketed sum, or either negated.
  double? parseFactor(int depth) {
    if (depth > maxDepth) return null;
    if (_eat('-')) {
      final inner = parseFactor(depth + 1);
      return inner == null ? null : -inner;
    }
    if (_eat('(')) {
      final inner = parseSum(depth + 1);
      if (inner == null) return null;
      if (!_eat(')')) return null;
      return inner;
    }
    final digits = StringBuffer();
    while (cursor < source.length) {
      final unit = source.codeUnitAt(cursor);
      final isDigit = unit >= 0x30 && unit <= 0x39;
      if (isDigit || unit == 0x2E || unit == 0x2C) {
        digits.writeCharCode(unit == 0x2C ? 0x2E : unit);
        cursor++;
      } else {
        break;
      }
    }
    if (digits.isEmpty) return null;
    final parsed = double.tryParse(digits.toString());
    if (parsed == null || !parsed.isFinite) return null;
    // The unit: letters (px, pt, ms, x), a degree sign, and a percent sign
    // where that is one.
    while (cursor < source.length) {
      final unit = source.codeUnitAt(cursor);
      final isLetter =
          (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A);
      if (isLetter || unit == 0xB0 || (unit == 0x25 && percentUnit)) {
        cursor++;
      } else {
        break;
      }
    }
    return parsed;
  }
}
