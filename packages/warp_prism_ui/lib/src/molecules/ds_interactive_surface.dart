import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/tokens.dart';

/// Shared interactive surface for molecule primitives.
///
/// Provides a single contract for:
/// - semantic `button` / `enabled` / `selected` flags
/// - keyboard focus + Enter/Space activation when [onTap] is set
/// - visible focus ring when keyboard-focused
/// - minimum 48×48 interactive target when interactive
/// - click cursor only when interactive
///
/// Non-interactive surfaces (`onTap == null`) remain non-buttons and
/// do not claim focus or enabled state.
class DSInteractiveSurface extends StatefulWidget {
  final String semanticLabel;
  final String? semanticValue;
  final bool selected;
  final VoidCallback? onTap;
  final bool excludeChildSemantics;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final Duration? animationDuration;

  /// When non-null, the decorated surface expands to max constraints and
  /// positions [child] within itself. Leave null to shrink-wrap (default).
  ///
  /// A non-null alignment on [AnimatedContainer]/[Container] forces expansion
  /// under bounded constraints — avoid defaulting this for compact chips.
  final AlignmentGeometry? alignment;
  final FocusNode? focusNode;
  final Widget child;

  const DSInteractiveSurface({
    super.key,
    required this.semanticLabel,
    required this.child,
    this.semanticValue,
    this.selected = false,
    this.onTap,
    this.excludeChildSemantics = false,
    this.padding,
    this.decoration,
    this.animationDuration,
    this.alignment,
    this.focusNode,
  });

  @override
  State<DSInteractiveSurface> createState() => _DSInteractiveSurfaceState();
}

class _DSInteractiveSurfaceState extends State<DSInteractiveSurface> {
  bool _isFocused = false;

  bool get _isInteractive => widget.onTap != null;

  void _activate() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.excludeChildSemantics
        ? ExcludeSemantics(child: widget.child)
        : widget.child;

    final needsChrome =
        widget.decoration != null || widget.padding != null || _isFocused;
    final decorated = needsChrome
        ? AnimatedContainer(
            duration: widget.animationDuration ?? Duration.zero,
            alignment: widget.alignment,
            padding: widget.padding,
            decoration: _resolveDecoration(),
            child: content,
          )
        : content;

    return Semantics(
      label: widget.semanticLabel,
      value: widget.semanticValue,
      button: _isInteractive,
      enabled: _isInteractive,
      selected: widget.selected,
      explicitChildNodes: !widget.excludeChildSemantics,
      child: FocusableActionDetector(
        enabled: _isInteractive,
        focusNode: widget.focusNode,
        onShowFocusHighlight: (focused) {
          if (!_isInteractive) return;
          setState(() => _isFocused = focused);
        },
        shortcuts: _isInteractive
            ? const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
                SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              }
            : const <ShortcutActivator, Intent>{},
        actions: _isInteractive
            ? <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    _activate();
                    return null;
                  },
                ),
              }
            : const <Type, Action<Intent>>{},
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: MouseRegion(
            cursor: _isInteractive
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: ConstrainedBox(
              constraints: _isInteractive
                  ? const BoxConstraints(minWidth: 48, minHeight: 48)
                  : const BoxConstraints(),
              child: decorated,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration? _resolveDecoration() {
    final base = widget.decoration;
    if (!_isFocused) return base;

    final focusBorder = Border.all(
      color: DSColors.focusRing,
      width: 2,
    );

    if (base == null) {
      return BoxDecoration(border: focusBorder);
    }

    return base.copyWith(border: focusBorder);
  }
}
