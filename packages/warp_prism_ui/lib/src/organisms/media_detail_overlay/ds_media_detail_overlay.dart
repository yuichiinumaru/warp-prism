import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Fixture media item for [DSMediaDetailOverlay].
///
/// Placeholder-only — no streaming engines, no network image loads in the
/// default fixture path. Use [placeholderColor] / [placeholderIcon] for the
/// visual body (Task 1523 / O-27).
@immutable
class DSMediaDetailItem {
  /// Stable media identity.
  final String id;

  /// Primary title shown in the caption bar.
  final String title;

  /// Optional secondary caption / metadata line.
  final String? caption;

  /// Solid placeholder fill (fixture-safe visual).
  final Color? _placeholderColor;
  Color get placeholderColor => _placeholderColor ?? DSColors.obsidianElevated;

  /// Optional center icon for the placeholder frame.
  final IconData? placeholderIcon;

  /// Optional kind tag (e.g. `"imagery"`, `"cctv-frame"`).
  final String? kind;

  const DSMediaDetailItem({
    required this.id,
    required this.title,
    this.caption,
    Color? placeholderColor,
    this.placeholderIcon = Icons.image_outlined,
    this.kind,
  }) : _placeholderColor = placeholderColor;

  DSMediaDetailItem copyWith({
    String? id,
    String? title,
    String? caption,
    Color? placeholderColor,
    IconData? placeholderIcon,
    String? kind,
    bool clearCaption = false,
    bool clearIcon = false,
    bool clearKind = false,
  }) {
    return DSMediaDetailItem(
      id: id ?? this.id,
      title: title ?? this.title,
      caption: clearCaption ? null : (caption ?? this.caption),
      placeholderColor: placeholderColor ?? this.placeholderColor,
      placeholderIcon: clearIcon
          ? null
          : (placeholderIcon ?? this.placeholderIcon),
      kind: clearKind ? null : (kind ?? this.kind),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMediaDetailItem &&
        other.id == id &&
        other.title == title &&
        other.caption == caption &&
        other.placeholderColor == placeholderColor &&
        other.placeholderIcon == placeholderIcon &&
        other.kind == kind;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, caption, placeholderColor, placeholderIcon, kind);
}

// =============================================================================
// Fixtures
// =============================================================================

/// Fixture catalog for gallery + tests (Task 1523 / O-27).
abstract final class DSMediaDetailFixtures {
  /// Multi-item media set for next/prev demos.
  static List<DSMediaDetailItem> defaultItems() => [
    DSMediaDetailItem(
      id: 'media-region-1',
      title: 'Region overview · Alpha sector',
      caption: 'Fixture still · SAR prep frame 01',
      placeholderColor: DSColors.obsidianActive,
      placeholderIcon: Icons.map_outlined,
      kind: 'imagery',
    ),
    DSMediaDetailItem(
      id: 'media-region-2',
      title: 'Perimeter cam · North gate',
      caption: 'Placeholder CCTV frame · not a live stream',
      placeholderColor: DSColors.glassOverlay,
      placeholderIcon: Icons.videocam_outlined,
      kind: 'cctv-frame',
    ),
    DSMediaDetailItem(
      id: 'media-region-3',
      title: 'Evidence still · Container bay',
      caption: 'Static review plate · read-only mock',
      placeholderColor: DSColors.obsidianHover,
      placeholderIcon: Icons.photo_outlined,
      kind: 'evidence',
    ),
  ];

  /// Single-item fixture.
  static List<DSMediaDetailItem> singleItem() => [
    DSMediaDetailItem(
      id: 'media-single',
      title: 'Solo fixture still',
      caption: 'No next/prev when only one item',
      placeholderColor: DSColors.obsidianActive,
      kind: 'imagery',
    ),
  ];
}

// =============================================================================
// Widget
// =============================================================================

/// ASW Observatory Organism — Media Detail Overlay
///
/// Lightbox-style glass overlay for fixture media review. Placeholder frames
/// only — **no** hls.js, WebRTC, or live CCTV stacks (Task 1523 / O-27).
///
/// Contract:
/// - Host owns open/close; mount this widget when open.
/// - Multi-item sets enable previous/next chrome when `items.length > 1`.
/// - Escape + dismiss call [onClose]; arrows navigate when multi-item.
class DSMediaDetailOverlay extends StatefulWidget {
  /// Semantics / test key for the panel.
  static const Key panelRegionKey = Key('ds-media-detail-overlay-panel');

  /// Semantics / test key for dismiss.
  static const Key dismissKey = Key('ds-media-detail-overlay-dismiss');

  /// Semantics / test key for previous.
  static const Key previousKey = Key('ds-media-detail-overlay-previous');

  /// Semantics / test key for next.
  static const Key nextKey = Key('ds-media-detail-overlay-next');

  /// Semantics / test key for empty state.
  static const Key emptyKey = Key('ds-media-detail-overlay-empty');

  /// Semantics / test key for the placeholder frame.
  static const Key mediaFrameKey = Key('ds-media-detail-overlay-frame');

  /// Semantics / test key for the backdrop.
  static const Key backdropKey = Key('ds-media-detail-overlay-backdrop');

  /// Media items (fixture placeholders).
  final List<DSMediaDetailItem> items;

  /// Initial index when multi-item.
  final int initialIndex;

  /// Called when the overlay should close.
  final VoidCallback? onClose;

  /// Called when the active index changes via next/prev.
  final ValueChanged<int>? onIndexChanged;

  /// Whether backdrop tap dismisses.
  final bool dismissOnBackdrop;

  /// Max content width.
  final double maxWidth;

  /// Max content height.
  final double maxHeight;

  const DSMediaDetailOverlay({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onClose,
    this.onIndexChanged,
    this.dismissOnBackdrop = true,
    this.maxWidth = 720,
    this.maxHeight = 560,
  });

  @override
  State<DSMediaDetailOverlay> createState() => _DSMediaDetailOverlayState();
}

class _DSMediaDetailOverlayState extends State<DSMediaDetailOverlay> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = _clampIndex(widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant DSMediaDetailOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Host changed the intended start index → honor the new initial.
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = _clampIndex(widget.initialIndex);
      return;
    }
    // Item set mutated (length or identity) → preserve operator position when
    // still valid; only clamp so a shrink cannot leave a stale out-of-range
    // index. Do **not** snap back to initialIndex on append/prepend — that
    // would discard in-overlay next/prev navigation state.
    if (oldWidget.items.length != widget.items.length ||
        !identical(oldWidget.items, widget.items)) {
      _index = _clampIndex(_index);
    }
  }

  int _clampIndex(int value) {
    if (widget.items.isEmpty) return 0;
    if (value < 0) return 0;
    if (value >= widget.items.length) return widget.items.length - 1;
    return value;
  }

  void _close() => widget.onClose?.call();

  void _goTo(int next) {
    if (widget.items.isEmpty) return;
    final clamped = _clampIndex(next);
    if (clamped == _index) return;
    setState(() => _index = clamped);
    widget.onIndexChanged?.call(_index);
  }

  void _previous() => _goTo(_index - 1);

  void _next() => _goTo(_index + 1);

  bool get _canPrevious => widget.items.length > 1 && _index > 0;

  bool get _canNext =>
      widget.items.length > 1 && _index < widget.items.length - 1;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _canPrevious) {
      _previous();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight && _canNext) {
      _next();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items.isEmpty
        ? null
        : widget.items[_clampIndex(_index)];
    final title = item?.title ?? 'Media detail';

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Material(
        color: DSColors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GestureDetector(
                key: DSMediaDetailOverlay.backdropKey,
                behavior: HitTestBehavior.opaque,
                onTap: widget.dismissOnBackdrop ? _close : null,
                child: ColoredBox(
                  color: DSColors.obsidianDeep.withValues(alpha: 0.78),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: widget.maxWidth,
                  maxHeight: widget.maxHeight,
                ),
                // Modal a11y: named scoped route for AT (host-owned mount).
                child: Semantics(
                  container: true,
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  label: title,
                  child: DSGlassPanel.modal(
                    key: DSMediaDetailOverlay.panelRegionKey,
                    padding: EdgeInsets.zero,
                    // Parent ConstrainedBox supplies a finite maxHeight; flex
                    // the media frame so 16:10 AspectRatio cannot overflow the
                    // header + caption chrome under tight desktop bounds.
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(title),
                        if (item == null)
                          _buildEmpty()
                        else ...[
                          Flexible(child: _buildFrame(item)),
                          _buildCaptionBar(item),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.md,
        DSSpacing.sm,
        DSSpacing.sm,
      ),
      child: Row(
        children: [
          DSIcon(
            Icons.photo_library_outlined,
            color: DSColors.accentBlue,
            size: 20,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.labelLarge(
              title,
              color: DSColors.textPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.items.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: DSSpacing.sm),
              child: DSText.labelSmall(
                '${_index + 1} / ${widget.items.length}',
                color: DSColors.textTertiary,
              ),
            ),
          Semantics(
            key: DSMediaDetailOverlay.dismissKey,
            label: 'Close media detail',
            button: true,
            excludeSemantics: true,
            child: SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: IconButton(
                onPressed: _close,
                tooltip: 'Close media detail',
                icon: const DSIcon.small(
                  DSIcons.close,
                  color: DSColors.textTertiary,
                ),
                padding: EdgeInsets.zero,
                splashRadius: kMinInteractiveDimension / 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      key: DSMediaDetailOverlay.emptyKey,
      padding: EdgeInsets.all(DSSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSIcon(
            Icons.image_not_supported_outlined,
            color: DSColors.textTertiary,
            size: 40,
          ),
          SizedBox(height: DSSpacing.md),
          DSText.bodySmall('No media items', color: DSColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildFrame(DSMediaDetailItem item) {
    // Layout contract: under a Flexible parent the frame receives a finite
    // maxHeight. Prefer width-driven 16:10 when it fits; otherwise fill the
    // allotted height (FittedBox would letterbox content — here the
    // placeholder is solid fill so a looser aspect is acceptable).
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final maxH = constraints.maxHeight;
          // Ideal 16:10 height for full width.
          final idealH = maxW.isFinite ? maxW * 10 / 16 : maxH;
          final useHeight = maxH.isFinite && idealH > maxH ? maxH : idealH;
          final useWidth = maxW.isFinite ? maxW : useHeight * 16 / 10;

          return Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: useWidth,
              height: useHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    key: DSMediaDetailOverlay.mediaFrameKey,
                    decoration: BoxDecoration(
                      color: item.placeholderColor,
                      borderRadius: BorderRadius.circular(DSRadii.sm),
                      border: Border.all(color: DSColors.borderDefault),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.placeholderIcon != null)
                            DSIcon(
                              item.placeholderIcon!,
                              color: DSColors.textTertiary,
                              size: 48,
                            ),
                          const SizedBox(height: DSSpacing.sm),
                          DSText.labelSmall(
                            item.kind ?? 'placeholder',
                            color: DSColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.items.length > 1) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _NavButton(
                        buttonKey: DSMediaDetailOverlay.previousKey,
                        semanticLabel: 'Previous media',
                        icon: Icons.chevron_left,
                        enabled: _canPrevious,
                        onPressed: _canPrevious ? _previous : null,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _NavButton(
                        buttonKey: DSMediaDetailOverlay.nextKey,
                        semanticLabel: 'Next media',
                        icon: Icons.chevron_right,
                        enabled: _canNext,
                        onPressed: _canNext ? _next : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaptionBar(DSMediaDetailItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.md,
        DSSpacing.lg,
        DSSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSText.bodyMedium(item.title, color: DSColors.textPrimary),
          if (item.caption != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            DSText.bodySmall(item.caption!, color: DSColors.textTertiary),
          ],
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final Key buttonKey;
  final String semanticLabel;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;

  const _NavButton({
    required this.buttonKey,
    required this.semanticLabel,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: buttonKey,
      label: semanticLabel,
      button: true,
      enabled: enabled,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xs),
        child: Material(
          color: DSColors.obsidianElevated.withValues(alpha: 0.85),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: Icon(
                icon,
                color: enabled ? DSColors.textPrimary : DSColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
