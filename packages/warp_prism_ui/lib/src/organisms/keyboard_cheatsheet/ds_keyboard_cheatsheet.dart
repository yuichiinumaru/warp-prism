import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Single shortcut row for [DSKeyboardCheatsheet].
@immutable
class DSKeyboardShortcut {
  /// Stable identity within its group.
  final String id;

  /// Ordered keycap labels (e.g. `['Ctrl', 'K']`).
  final List<String> keys;

  /// Human-readable action description.
  final String description;

  const DSKeyboardShortcut({
    required this.id,
    required this.keys,
    required this.description,
  });

  DSKeyboardShortcut copyWith({
    String? id,
    List<String>? keys,
    String? description,
  }) {
    return DSKeyboardShortcut(
      id: id ?? this.id,
      keys: keys ?? this.keys,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSKeyboardShortcut &&
        other.id == id &&
        other.description == description &&
        _listEquals(other.keys, keys);
  }

  @override
  int get hashCode => Object.hash(id, description, Object.hashAll(keys));
}

/// Named group of [DSKeyboardShortcut] rows.
@immutable
class DSKeyboardShortcutGroup {
  /// Stable group identity.
  final String id;

  /// Group header label.
  final String title;

  /// Shortcuts in display order.
  final List<DSKeyboardShortcut> shortcuts;

  const DSKeyboardShortcutGroup({
    required this.id,
    required this.title,
    this.shortcuts = const <DSKeyboardShortcut>[],
  });

  DSKeyboardShortcutGroup copyWith({
    String? id,
    String? title,
    List<DSKeyboardShortcut>? shortcuts,
  }) {
    return DSKeyboardShortcutGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      shortcuts: shortcuts ?? this.shortcuts,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSKeyboardShortcutGroup &&
        other.id == id &&
        other.title == title &&
        _listEquals(other.shortcuts, shortcuts);
  }

  @override
  int get hashCode => Object.hash(id, title, Object.hashAll(shortcuts));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// =============================================================================
// Fixtures
// =============================================================================

/// Fixture catalog for gallery + tests (Task 1522 / O-24).
abstract final class DSKeyboardCheatsheetFixtures {
  /// Default Observatory operator shortcut groups.
  static List<DSKeyboardShortcutGroup> defaultGroups() => const [
    DSKeyboardShortcutGroup(
      id: 'navigation',
      title: 'Navigation',
      shortcuts: [
        DSKeyboardShortcut(
          id: 'cmd-palette',
          keys: ['Ctrl', 'K'],
          description: 'Open command palette',
        ),
        DSKeyboardShortcut(
          id: 'cheatsheet',
          keys: ['?'],
          description: 'Toggle keyboard cheatsheet',
        ),
        DSKeyboardShortcut(
          id: 'focus-search',
          keys: ['/'],
          description: 'Focus entity locate search',
        ),
      ],
    ),
    DSKeyboardShortcutGroup(
      id: 'stage',
      title: 'Stage',
      shortcuts: [
        DSKeyboardShortcut(
          id: 'fit-stage',
          keys: ['Ctrl', '0'],
          description: 'Fit stage to view',
        ),
        DSKeyboardShortcut(
          id: 'toggle-layers',
          keys: ['L'],
          description: 'Toggle layer control panel',
        ),
        DSKeyboardShortcut(
          id: 'toggle-legend',
          keys: ['G'],
          description: 'Toggle map legend',
        ),
      ],
    ),
    DSKeyboardShortcutGroup(
      id: 'workspace',
      title: 'Workspace',
      shortcuts: [
        DSKeyboardShortcut(
          id: 'escape',
          keys: ['Esc'],
          description: 'Close overlay / dismiss panel',
        ),
        DSKeyboardShortcut(
          id: 'refresh',
          keys: ['Ctrl', 'R'],
          description: 'Refresh fixture workspace snapshot',
        ),
      ],
    ),
  ];

  /// Compact single-group fixture for tests.
  static List<DSKeyboardShortcutGroup> minimalGroups() => const [
    DSKeyboardShortcutGroup(
      id: 'core',
      title: 'Core',
      shortcuts: [
        DSKeyboardShortcut(id: 'help', keys: ['?'], description: 'Show help'),
        DSKeyboardShortcut(
          id: 'close',
          keys: ['Esc'],
          description: 'Close overlay',
        ),
      ],
    ),
  ];
}

// =============================================================================
// Widget
// =============================================================================

/// ASW Observatory Organism — Keyboard Cheatsheet Overlay
///
/// Modal glass overlay listing fixture keyboard shortcut groups with keycap
/// chips. Host owns open/close; this widget is the open surface only.
///
/// Contract (Task 1522 / O-24):
/// - Read-only fixture shortcuts — no key-binding engine.
/// - Escape and dismiss button call [onClose].
/// - Backdrop tap dismisses when [dismissOnBackdrop] is true.
/// - Distinct from [DSCommandPalette] (commands vs reference key map).
class DSKeyboardCheatsheet extends StatelessWidget {
  /// Semantics / test key for the panel region.
  static const Key panelRegionKey = Key('ds-keyboard-cheatsheet-panel');

  /// Semantics / test key for the dismiss control.
  static const Key dismissKey = Key('ds-keyboard-cheatsheet-dismiss');

  /// Semantics / test key for the backdrop.
  static const Key backdropKey = Key('ds-keyboard-cheatsheet-backdrop');

  /// Row key for a shortcut id.
  static Key shortcutRowKey(String id) => Key('ds-keyboard-cheatsheet-row-$id');

  /// Grouped shortcuts to display.
  final List<DSKeyboardShortcutGroup> groups;

  /// Called when the overlay should close.
  final VoidCallback? onClose;

  /// Overlay title.
  final String title;

  /// Whether tapping the scrim dismisses the overlay.
  final bool dismissOnBackdrop;

  /// Max panel width.
  final double maxWidth;

  const DSKeyboardCheatsheet({
    super.key,
    required this.groups,
    this.onClose,
    this.title = 'Keyboard shortcuts',
    this.dismissOnBackdrop = true,
    this.maxWidth = 480,
  });

  void _close() => onClose?.call();

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              _close();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Material(
            color: DSColors.transparent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Scrim
                Positioned.fill(
                  child: GestureDetector(
                    key: backdropKey,
                    behavior: HitTestBehavior.opaque,
                    onTap: dismissOnBackdrop ? _close : null,
                    child: ColoredBox(
                      color: DSColors.obsidianDeep.withValues(alpha: 0.72),
                    ),
                  ),
                ),
                // Centered panel
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    // Modal a11y: scopesRoute + namesRoute so AT focus treats
                    // the cheatsheet as a named dialog surface (host-owned
                    // mount; not a ModalRoute).
                    child: Semantics(
                      container: true,
                      scopesRoute: true,
                      namesRoute: true,
                      explicitChildNodes: true,
                      label: title,
                      child: DSGlassPanel.modal(
                        key: panelRegionKey,
                        padding: EdgeInsets.zero,
                        // Avoid Flexible+mainAxisSize.min: size to content with
                        // a hard maxHeight so the panel stays intrinsic and
                        // never depends on flex free-space allocation.
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 420),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  DSSpacing.lg,
                                  DSSpacing.sm,
                                  DSSpacing.lg,
                                  DSSpacing.lg,
                                ),
                                child: groups.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: DSSpacing.xl,
                                        ),
                                        child: DSText.bodySmall(
                                          'No shortcuts configured',
                                          color: DSColors.textTertiary,
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          for (final group in groups) ...[
                                            _buildGroup(group),
                                            const SizedBox(
                                              height: DSSpacing.md,
                                            ),
                                          ],
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.md,
        DSSpacing.sm,
        DSSpacing.sm,
      ),
      child: Row(
        children: [
          const DSIcon(
            Icons.keyboard_alt_outlined,
            color: DSColors.accentCyan,
            size: 20,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.labelLarge(title, color: DSColors.textPrimary),
          ),
          Semantics(
            key: dismissKey,
            label: 'Dismiss keyboard cheatsheet',
            button: true,
            excludeSemantics: true,
            child: SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: IconButton(
                onPressed: _close,
                tooltip: 'Dismiss keyboard cheatsheet',
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

  Widget _buildGroup(DSKeyboardShortcutGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DSText.labelSmall(
          group.title.toUpperCase(),
          color: DSColors.textTertiary,
        ),
        const SizedBox(height: DSSpacing.xs),
        for (final shortcut in group.shortcuts)
          _ShortcutRow(shortcut: shortcut),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final DSKeyboardShortcut shortcut;

  const _ShortcutRow({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    final keysLabel = shortcut.keys.join(' + ');
    return Semantics(
      container: true,
      label: '$keysLabel: ${shortcut.description}',
      child: Padding(
        key: DSKeyboardCheatsheet.shortcutRowKey(shortcut.id),
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: ExcludeSemantics(
                child: DSText.bodySmall(
                  shortcut.description,
                  color: DSColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            ExcludeSemantics(
              child: Wrap(
                spacing: DSSpacing.xxs,
                children: [
                  for (var i = 0; i < shortcut.keys.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: DSText.labelSmall(
                          '+',
                          color: DSColors.textTertiary,
                        ),
                      ),
                    _Keycap(label: shortcut.keys[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Keycap extends StatelessWidget {
  final String label;

  const _Keycap({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(color: DSColors.borderDefault),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: DSText.labelSmall(label, color: DSColors.textPrimary),
    );
  }
}
