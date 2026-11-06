import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../tokens/tokens.dart';

/// ASW Observatory Organism — Page Shell
///
/// In-content page chrome for CyberCore/admin-style pages:
/// leading icon well + title + optional subtitle + actions + optional toolbar
/// + body slot.
///
/// **Not** app chrome. Do not confuse with [DSShell], [DSTopbar], or
/// [DSSidebar], which own the application frame (sidebar / topbar / content
/// region). [DSPageShell] lives *inside* the content region.
///
/// Contract:
/// - [title] always renders; long titles ellipsize (`maxLines: 1`).
/// - [subtitle], [leading], [actions], and [toolbar] are optional slots.
/// - Empty [actions] and a null [toolbar] must not crash layout.
/// - No routing, prefs, or product coupling — slots only.
/// - Parent must provide a bounded height when [child] should fill
///   remaining space (uses [Expanded]).
class DSPageShell extends StatelessWidget {
  /// Page title shown in the header band.
  final String title;

  /// Optional secondary line under the title.
  final String? subtitle;

  /// Optional leading widget (typically a tone-colored icon well).
  ///
  /// When null, no leading slot is reserved.
  final Widget? leading;

  /// Optional trailing action widgets (buttons, menus, chips).
  ///
  /// Null or empty both mean "no actions strip".
  final List<Widget>? actions;

  /// Optional full-width toolbar row under the title row
  /// (filters, search, period controls, etc.).
  final Widget? toolbar;

  /// Page body content. Expanded to fill remaining vertical space.
  final Widget child;

  /// Accent color for the default icon well border wash when [leading]
  /// is provided by the caller as a raw icon via [DSPageShell.icon].
  /// Defaults to [DSColors.accentBlue].
  final Color? accentColor;

  /// Padding applied around the body [child]. Defaults to page inset.
  final EdgeInsetsGeometry? contentPadding;

  /// When false, body content is horizontally constrained to a desktop
  /// reading width. Header and toolbar remain full-bleed.
  final bool fluid;

  /// Max content width when [fluid] is false.
  static const double constrainedContentWidth = 960;

  const DSPageShell({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.actions,
    this.toolbar,
    this.accentColor,
    this.contentPadding,
    this.fluid = true,
  });

  /// Convenience constructor that wraps [icon] in a tone-colored icon well.
  factory DSPageShell.icon({
    Key? key,
    required String title,
    required Widget child,
    required IconData icon,
    String? subtitle,
    List<Widget>? actions,
    Widget? toolbar,
    Color? accentColor,
    EdgeInsetsGeometry? contentPadding,
    bool fluid = true,
  }) {
    final tone = accentColor ?? DSColors.accentBlue;
    return DSPageShell(
      key: key,
      title: title,
      subtitle: subtitle,
      actions: actions,
      toolbar: toolbar,
      accentColor: tone,
      contentPadding: contentPadding,
      fluid: fluid,
      leading: _IconWell(icon: icon, tone: tone),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyPadding = contentPadding ?? const EdgeInsets.all(DSSpacing.lg);
    final hasActions = actions != null && actions!.isNotEmpty;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Page: $title',
      child: ColoredBox(
        color: DSColors.obsidianDeep,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(
              title: title,
              subtitle: subtitle,
              leading: leading,
              actions: hasActions ? actions : null,
            ),
            if (toolbar != null) ...[
              const DSDivider.subtle(),
              Semantics(
                label: 'Page toolbar',
                container: true,
                explicitChildNodes: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.lg,
                    vertical: DSSpacing.sm,
                  ),
                  child: toolbar!,
                ),
              ),
            ],
            const DSDivider.subtle(),
            Expanded(
              child: Padding(
                padding: bodyPadding,
                child: fluid
                    ? child
                    : Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: constrainedContentWidth,
                          ),
                          child: child,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header band: leading + title/subtitle + actions.
class _PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;

  const _PageHeader({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: subtitle == null ? title : '$title. $subtitle',
      child: Container(
        constraints: const BoxConstraints(minHeight: DSSpacing.topbarHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        decoration: BoxDecoration(color: DSColors.obsidianBase),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: DSSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DSText.headingMedium(
                    title,
                    color: DSColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: DSSpacing.xxs),
                    DSText.bodySmall(
                      subtitle!,
                      color: DSColors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (actions != null) ...[
              const SizedBox(width: DSSpacing.md),
              Semantics(
                label: 'Page actions',
                container: true,
                explicitChildNodes: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: DSSpacing.xs),
                      actions![i],
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tone-colored icon well used by [DSPageShell.icon].
class _IconWell extends StatelessWidget {
  final IconData icon;
  final Color tone;

  const _IconWell({required this.icon, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
      ),
      child: DSIcon(
        icon,
        color: tone,
        iconSize: DSIconSize.medium,
        semanticLabel: null,
      ),
    );
  }
}
