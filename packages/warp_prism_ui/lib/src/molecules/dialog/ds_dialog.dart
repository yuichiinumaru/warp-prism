import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/atoms.dart';
import '../../tokens/tokens.dart';
import '../ds_interactive_surface.dart';

/// Modal dialog sizes.
enum DSDialogSize {
  /// Small modal dialog (360px max width).
  sm,
  /// Medium modal dialog (520px max width).
  md,

  /// Large modal dialog (720px max width).
  lg,

  /// Fullscreen modal dialog (margin-inset viewport).
  fullscreen,
}

/// Action item for [DSDialog] footers.
class DSDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final IconData? icon;
  final bool enabled;
  final bool isLoading;

  const DSDialogAction({
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.md,
    this.icon,
    this.enabled = true,
    this.isLoading = false,
  });

  /// Factory for secondary/cancel action.
  factory DSDialogAction.cancel({
    String label = 'Cancel',
    VoidCallback? onPressed,
  }) =>
      DSDialogAction(
        label: label,
        onPressed: onPressed,
        variant: DSButtonVariant.secondary,
      );

  /// Factory for primary/confirm action.
  factory DSDialogAction.confirm({
    String label = 'Confirm',
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
  }) =>
      DSDialogAction(
        label: label,
        onPressed: onPressed,
        variant: DSButtonVariant.primary,
        icon: icon,
        isLoading: isLoading,
      );

  /// Factory for danger action.
  factory DSDialogAction.danger({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
  }) =>
      DSDialogAction(
        label: label,
        onPressed: onPressed,
        variant: DSButtonVariant.danger,
        icon: icon,
        isLoading: isLoading,
      );
}

/// ASW Observatory Molecule - Modal Dialog
///
/// Obsidian glass styled modal dialog with scrim backdrop, focus trap,
/// slot-based content, header, action buttons footer, and ESC key dismiss.
class DSDialog extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget? content;
  final List<DSDialogAction> actions;
  final bool dismissible;
  final DSDialogSize size;
  final VoidCallback? onDismiss;
  final WidgetBuilder? customHeader;
  final WidgetBuilder? customFooter;

  const DSDialog({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.content,
    this.actions = const [],
    this.dismissible = true,
    this.size = DSDialogSize.md,
    this.onDismiss,
    this.customHeader,
    this.customFooter,
  });

  /// Static helper to display a [DSDialog] or custom modal in a popup route.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String barrierLabel = 'Dismiss dialog',
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? DSColors.obsidianDeep.withValues(alpha: 0.7),
      barrierLabel: barrierLabel,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      transitionDuration: DSMotion.normal,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: DSMotion.enter,
          reverseCurve: DSMotion.exit,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<DSDialog> createState() => _DSDialogState();
}

class _DSDialogState extends State<DSDialog> {
  late final FocusScopeNode _dialogScope;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _dialogScope = FocusScopeNode();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _dialogScope.dispose();
    super.dispose();
  }

  double _getMaxWidth(DSDialogSize size, double viewportWidth) {
    switch (size) {
      case DSDialogSize.sm:
        return 360.0;
      case DSDialogSize.md:
        return 520.0;
      case DSDialogSize.lg:
        return 720.0;
      case DSDialogSize.fullscreen:
        return viewportWidth - (DSSpacing.xl * 2);
    }
  }

  double _getMaxHeight(DSDialogSize size, double viewportHeight) {
    switch (size) {
      case DSDialogSize.sm:
      case DSDialogSize.md:
      case DSDialogSize.lg:
        return viewportHeight * 0.85;
      case DSDialogSize.fullscreen:
        return viewportHeight - (DSSpacing.xl * 2);
    }
  }

  void _handleDismiss(BuildContext context) {
    if (widget.dismissible) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
      Navigator.of(context).maybePop();
    }
  }

  void _handleEnterAction(BuildContext context) {
    if (widget.actions.isEmpty) return;
    // Find primary or first enabled action
    final primaryAction = widget.actions.firstWhere(
      (a) => a.variant == DSButtonVariant.primary && a.enabled && a.onPressed != null,
      orElse: () => widget.actions.firstWhere(
        (a) => a.enabled && a.onPressed != null,
        orElse: () => widget.actions.first,
      ),
    );
    if (primaryAction.enabled && primaryAction.onPressed != null) {
      primaryAction.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewportWidth = mediaQuery.size.width;
    final viewportHeight = mediaQuery.size.height;

    final maxWidth = _getMaxWidth(widget.size, viewportWidth);
    final maxHeight = _getMaxHeight(widget.size, viewportHeight);

    Widget header = const SizedBox.shrink();
    if (widget.customHeader != null) {
      header = widget.customHeader!(context);
    } else if (widget.title != null || widget.subtitle != null || widget.icon != null) {
      header = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              DSIcon(widget.icon!, color: DSColors.accentCyan, size: 20),
              const SizedBox(width: DSSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null)
                    DSText.headingSmall(
                      widget.title!,
                      color: DSColors.textPrimary,
                    ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: DSSpacing.xxs),
                    DSText.bodySmall(
                      widget.subtitle!,
                      color: DSColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
            if (widget.dismissible) ...[
              const SizedBox(width: DSSpacing.sm),
              DSInteractiveSurface(
                semanticLabel: 'Close dialog',
                onTap: () => _handleDismiss(context),
                child: Container(
                  padding: const EdgeInsets.all(DSSpacing.xs),
                  decoration: BoxDecoration(
                    color: DSColors.transparent,
                    borderRadius: BorderRadius.circular(DSRadii.button),
                  ),
                  child: const DSIcon(
                    DSIcons.close,
                    color: DSColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    Widget footer = const SizedBox.shrink();
    if (widget.customFooter != null) {
      footer = widget.customFooter!(context);
    } else if (widget.actions.isNotEmpty) {
      footer = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: widget.actions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(left: DSSpacing.sm),
              child: DSButton(
                label: action.label,
                onPressed: action.onPressed,
                variant: action.variant,
                size: action.size,
                icon: action.icon,
                enabled: action.enabled,
                isLoading: action.isLoading,
              ),
            );
          }).toList(),
        ),
      );
    }

    return FocusScope(
      node: _dialogScope,
      autofocus: true,
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): () {
            _handleDismiss(context);
          },
          const SingleActivator(LogicalKeyboardKey.enter): () {
            _handleEnterAction(context);
          },
        },
        child: FocusTraversalGroup(
          child: Center(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: DSGlassPanel.modal(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      if (widget.content != null)
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(DSSpacing.lg),
                            child: widget.content!,
                          ),
                        ),
                      footer,
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

/// Top-level helper for showing a [DSDialog].
Future<T?> showPrismDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String barrierLabel = 'Dismiss dialog',
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return DSDialog.show<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}
