/// EXPERIMENTAL (Task 1860, F-12): [DSToolbarPanel] framework —
///
/// button → popover → typed panel → reanchor.
///
/// A toolbar button opens a popover listing typed panels; choosing one swaps
/// the popover for the typed panel; closing (Done / scrim / Escape)
/// reanchors: focus returns to the button and [onReanchored] fires with the
/// last panel id. No timers, no wall-clock, no hidden surfaces.
///
/// Lifecycle: EXPERIMENTAL — no barrel export, no `Prism*` alias.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

/// Framework phases for [DSToolbarPanel].
enum DSToolbarPanelPhase {
  /// Only the anchor button is visible.
  closed,

  /// The popover with the typed-panel list is open.
  popover,

  /// A typed panel is open in place of the popover.
  typedPanel,
}

/// One typed panel entry offered by the popover.
class DSToolbarPanelOption {
  /// Stable panel identity handed to [DSToolbarPanel.panelBuilder].
  final String id;

  /// Human-readable label.
  final String label;

  /// Leading icon.
  final IconData icon;

  const DSToolbarPanelOption({
    required this.id,
    required this.label,
    this.icon = Icons.tune,
  });
}

/// Toolbar button → popover → typed panel → reanchor framework.
///
/// The caller supplies [options] and builds each typed panel via
/// [panelBuilder]; the framework owns phase transitions, Escape/scrim
/// dismissal, and focus reanchor. The overlay is portal-based so open/close
/// stays declarative and deterministic under `flutter_tester` (no timers,
/// no post-frame callbacks).
class DSToolbarPanel extends StatefulWidget {
  /// Anchor button label.
  final String buttonLabel;

  /// Typed panels offered by the popover.
  final List<DSToolbarPanelOption> options;

  /// Builds the typed panel for [panelId]. The builder receives a `close`
  /// callback it should wire to its Done action.
  final Widget Function(
    BuildContext context,
    String panelId,
    VoidCallback close,
  )
  panelBuilder;

  /// Fires on every phase transition.
  final ValueChanged<DSToolbarPanelPhase>? onPhaseChanged;

  /// Fires on reanchor (panel/popover close) with the last open panel id
  /// (null when the popover closed without choosing).
  final ValueChanged<String?>? onReanchored;

  /// Semantic label for the anchor button.
  final String buttonSemanticLabel;

  const DSToolbarPanel({
    super.key,
    required this.buttonLabel,
    required this.options,
    required this.panelBuilder,
    this.onPhaseChanged,
    this.onReanchored,
    this.buttonSemanticLabel = 'Open toolbar panel',
  });

  /// Stable keys for tests and semantic tooling.
  static const Key buttonKey = Key('ds-filter-1860-toolbar-button');
  static const Key popoverKey = Key('ds-filter-1860-toolbar-popover');
  static const Key scrimKey = Key('ds-filter-1860-toolbar-scrim');

  /// Typed-panel region key by panel id.
  static Key typedPanelKey(String panelId) =>
      Key('ds-filter-1860-typed-panel-$panelId');

  /// Popover option key by panel id.
  static Key optionKey(String panelId) =>
      Key('ds-filter-1860-toolbar-option-$panelId');

  @override
  State<DSToolbarPanel> createState() => _DSToolbarPanelState();
}

class _DSToolbarPanelState extends State<DSToolbarPanel> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final FocusNode _buttonFocus = FocusNode(
    debugLabel: 'filter-1860-toolbar-button',
  );
  final FocusNode _overlayFocus = FocusNode(
    debugLabel: 'filter-1860-toolbar-overlay',
  );
  DSToolbarPanelPhase _phase = DSToolbarPanelPhase.closed;
  String? _panelId;
  String? _lastPanelId;

  /// Current framework phase (test-readable).
  DSToolbarPanelPhase get phase => _phase;

  @override
  void dispose() {
    _buttonFocus.dispose();
    _overlayFocus.dispose();
    super.dispose();
  }

  void _setPhase(DSToolbarPanelPhase next, {String? panelId}) {
    setState(() {
      _phase = next;
      _panelId = panelId;
      if (panelId != null) _lastPanelId = panelId;
    });
    widget.onPhaseChanged?.call(next);
    if (next == DSToolbarPanelPhase.closed) {
      if (_portal.isShowing) _portal.hide();
      // Reanchor: focus returns to the anchor button and the host is told
      // which typed panel was last open (null = popover dismissed).
      _buttonFocus.requestFocus();
      widget.onReanchored?.call(_lastPanelId);
    } else {
      if (!_portal.isShowing) _portal.show();
      _overlayFocus.requestFocus();
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_phase != DSToolbarPanelPhase.closed) {
        _setPhase(DSToolbarPanelPhase.closed);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (identical(node, _buttonFocus) &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.arrowDown)) {
      _setPhase(DSToolbarPanelPhase.popover);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) {
          if (_phase == DSToolbarPanelPhase.closed) {
            return const SizedBox.shrink();
          }
          return Stack(
            children: [
              Positioned.fill(
                child: MouseRegion(
                  cursor: SystemMouseCursors.basic,
                  child: GestureDetector(
                    key: DSToolbarPanel.scrimKey,
                    onTap: () => _setPhase(DSToolbarPanelPhase.closed),
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 8),
                child: Focus(
                  focusNode: _overlayFocus,
                  onKeyEvent: _handleKey,
                  child: _phase == DSToolbarPanelPhase.popover
                      ? _PopoverCard(
                          options: widget.options,
                          onPick: (id) => _setPhase(
                            DSToolbarPanelPhase.typedPanel,
                            panelId: id,
                          ),
                          onClose: () => _setPhase(DSToolbarPanelPhase.closed),
                        )
                      : _TypedPanelCard(
                          panelId: _panelId ?? '',
                          builder: widget.panelBuilder,
                          onClose: () => _setPhase(DSToolbarPanelPhase.closed),
                        ),
                ),
              ),
            ],
          );
        },
        child: Semantics(
          button: true,
          enabled: true,
          label: widget.buttonSemanticLabel,
          excludeSemantics: true,
          child: Focus(
            focusNode: _buttonFocus,
            onKeyEvent: _handleKey,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                key: DSToolbarPanel.buttonKey,
                onTap: () => _setPhase(DSToolbarPanelPhase.popover),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: kMinInteractiveDimension,
                    minHeight: kMinInteractiveDimension,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
                  decoration: BoxDecoration(
                    color: _phase == DSToolbarPanelPhase.closed
                        ? DSColors.obsidianElevated
                        : DSColors.obsidianHover,
                    borderRadius: BorderRadius.circular(DSRadii.md),
                    border: Border.all(
                      color: _phase == DSToolbarPanelPhase.closed
                          ? DSColors.borderSubtle
                          : DSColors.focusRing,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.tune,
                        size: 16,
                        color: DSColors.textSecondary,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        widget.buttonLabel,
                        style: DSTypography.labelMedium.copyWith(
                          color: DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopoverCard extends StatelessWidget {
  final List<DSToolbarPanelOption> options;
  final ValueChanged<String> onPick;
  final VoidCallback onClose;

  const _PopoverCard({
    required this.options,
    required this.onPick,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: DSToolbarPanel.popoverKey,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: 'Toolbar panels',
        child: DSGlassPanel.modal(
          padding: const EdgeInsets.all(DSSpacing.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0) const SizedBox(height: DSSpacing.xs),
                  _OptionRow(option: options[i], onPick: onPick),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final DSToolbarPanelOption option;
  final ValueChanged<String> onPick;

  const _OptionRow({required this.option, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: 'Open ${option.label} panel',
      excludeSemantics: true,
      child: FocusableActionDetector(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onPick(option.id);
              return null;
            },
          ),
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            key: DSToolbarPanel.optionKey(option.id),
            onTap: () => onPick(option.id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSColors.obsidianElevated,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: Border.all(color: DSColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(option.icon, size: 18, color: DSColors.textSecondary),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: DSText.labelMedium(
                      option.label,
                      color: DSColors.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: DSColors.textTertiary,
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

class _TypedPanelCard extends StatelessWidget {
  final String panelId;
  final Widget Function(BuildContext, String, VoidCallback) builder;
  final VoidCallback onClose;

  const _TypedPanelCard({
    required this.panelId,
    required this.builder,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: DSToolbarPanel.typedPanelKey(panelId),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: 'Typed panel $panelId',
        child: DSGlassPanel.modal(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
            child: builder(context, panelId, onClose),
          ),
        ),
      ),
    );
  }
}
