import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/tokens.dart';
import '../../atoms/atoms.dart';

// =============================================================================
// DATA MODEL
// =============================================================================

/// Category for grouping commands in the palette.
enum DSCommandCategory {
  /// Navigate to a page or route.
  navigate,

  /// Run an action or trigger a callback.
  run,

  /// Recently used commands.
  recent,
}

/// A command definition for the command palette.
///
/// Each command has an [id], human-readable [label], optional [description],
/// an [icon], a [category] for grouping, and one or both of [onExecute]
/// (callback) and [route] (navigation target).
class DSCommand {
  /// Unique identifier for this command.
  final String id;

  /// Human-readable label shown in the palette.
  final String label;

  /// Optional description or subtitle.
  final String? description;

  /// Icon displayed alongside the label.
  final IconData icon;

  /// Category for grouping.
  final DSCommandCategory category;

  /// Callback invoked when the command is executed.
  final VoidCallback? onExecute;

  /// Optional route path for navigation commands.
  final String? route;

  /// Keyboard shortcut hint displayed in the item (e.g., "Ctrl+N").
  final String? shortcut;

  /// Disabled reason propagated from IDS eligibility (Task 1870, F-03).
  ///
  /// Null ⇒ the command dispatches normally. Non-null ⇒ the item renders
  /// disabled-with-reason (never hidden, never dispatching): the reason is
  /// shown beneath the label and announced to assistive technology, and
  /// activation routes to [DSCommandPalette.onDisabledCommand] instead of
  /// [onExecute]. Presentation-only: IDS owns the eligibility outcome; this
  /// field only carries its rendered reason.
  final String? disabledReason;

  const DSCommand({
    required this.id,
    required this.label,
    this.description,
    this.icon = Icons.arrow_forward,
    this.category = DSCommandCategory.navigate,
    this.onExecute,
    this.route,
    this.shortcut,
    this.disabledReason,
  });

  /// True when the command may dispatch ([disabledReason] == null).
  bool get isEnabled => disabledReason == null;
}

// =============================================================================
// MAIN PALETTE WIDGET
// =============================================================================

/// ASW Observatory Organism — Command Palette
///
/// A keyboard-driven overlay for power-user navigation. Opens with
/// `Cmd+K` (macOS) / `Ctrl+K` (Linux/Windows). Supports fuzzy text
/// matching, category grouping, keyboard navigation (arrows + Enter +
/// Escape), and action execution hooks.
///
/// Contract:
/// - Renders as a centered modal overlay with [DSGlassPanel.modal] styling.
/// - Does NOT manage its own visibility — call [showDSCommandPalette] or
///   embed [DSCommandPalette] inside an [Overlay] / [Stack].
/// - Uses only DS tokens, atoms, and molecules — no external dependencies.
/// - Auto-focuses the search field on open.
class DSCommandPalette extends StatefulWidget {
  /// Registered commands.
  final List<DSCommand> commands;

  /// Called when a command is executed. Receives the selected command.
  final ValueChanged<DSCommand>? onExecute;

  /// Called when a disabled-with-reason command is activated (tap or Enter).
  ///
  /// Receives the refused command; its [DSCommand.disabledReason] explains
  /// why dispatch was refused. A disabled activation never invokes
  /// [onExecute] nor the command's own [DSCommand.onExecute].
  final ValueChanged<DSCommand>? onDisabledCommand;

  /// Called when the palette should close (Escape or backdrop tap).
  final VoidCallback? onClose;

  /// Initial search query.
  final String? initialQuery;

  /// Placeholder text for the search field.
  final String placeholder;

  const DSCommandPalette({
    super.key,
    required this.commands,
    this.onExecute,
    this.onDisabledCommand,
    this.onClose,
    this.initialQuery,
    this.placeholder = 'Type a command...',
  });

  @override
  State<DSCommandPalette> createState() => _DSCommandPaletteState();
}

class _DSCommandPaletteState extends State<DSCommandPalette> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _query = '';
  int _selectedIndex = 0;
  DSCommandCategory? _activeCategory;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _focusNode = FocusNode();
    _query = widget.initialQuery ?? '';

    // Auto-focus after the first frame so the text field is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Filtering & grouping
  // ---------------------------------------------------------------------------

  /// Simple fuzzy match: case-insensitive substring. Tokens separated by
  /// spaces are all required (AND logic) but can appear in any order.
  bool _matchesQuery(DSCommand cmd, String query) {
    if (query.isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    final labelLower = cmd.label.toLowerCase();
    final descLower = cmd.description?.toLowerCase() ?? '';

    // Split into tokens — all must match somewhere.
    final tokens = lowerQuery.split(RegExp(r'\s+'));
    for (final token in tokens) {
      if (token.isEmpty) continue;
      if (!labelLower.contains(token) && !descLower.contains(token)) {
        return false;
      }
    }
    return true;
  }

  List<DSCommand> get _filteredCommands {
    return widget.commands.where((cmd) {
      if (_activeCategory != null && cmd.category != _activeCategory) {
        return false;
      }
      return _matchesQuery(cmd, _query);
    }).toList();
  }

  /// Group filtered commands by category, preserving category order.
  Map<DSCommandCategory, List<DSCommand>> get _groupedCommands {
    final filtered = _filteredCommands;
    final map = <DSCommandCategory, List<DSCommand>>{};
    for (final cat in DSCommandCategory.values) {
      final items = filtered.where((c) => c.category == cat).toList();
      if (items.isNotEmpty) {
        map[cat] = items;
      }
    }
    return map;
  }

  /// Flat list of all visible commands (for keyboard navigation index).
  List<DSCommand> get _flatFiltered => _filteredCommands;

  // ---------------------------------------------------------------------------
  // Interaction handlers
  // ---------------------------------------------------------------------------

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      _selectedIndex = 0;
    });
  }

  void _onCategoryTap(DSCommandCategory? category) {
    setState(() {
      _activeCategory = (_activeCategory == category) ? null : category;
      _selectedIndex = 0;
    });
  }

  void _executeCommand(DSCommand cmd) {
    if (!cmd.isEnabled) {
      widget.onDisabledCommand?.call(cmd);
      return;
    }
    widget.onExecute?.call(cmd);
    cmd.onExecute?.call();
    widget.onClose?.call();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final flat = _flatFiltered;
    if (flat.isEmpty) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onClose?.call();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % flat.length;
      });
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + flat.length) % flat.length;
      });
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _executeCommand(flat[_selectedIndex]);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onClose?.call();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedCommands;
    final flat = _flatFiltered;

    // Material is required for TextField/InkWell even when shown via a raw
    // PageRoute without a Scaffold (showDSCommandPalette).
    return Material(
      type: MaterialType.transparency,
      child: Focus(
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          // Tap backdrop closes.
          onTap: widget.onClose,
          child: Container(
            color: DSColors.black.withValues(alpha: 0.4),
            child: Center(
              child: GestureDetector(
                // Prevent taps inside the panel from closing.
                onTap: () {},
                child: _Panel(
                  controller: _controller,
                  focusNode: _focusNode,
                  placeholder: widget.placeholder,
                  onQueryChanged: _onQueryChanged,
                  grouped: grouped,
                  flat: flat,
                  selectedIndex: _selectedIndex,
                  activeCategory: _activeCategory,
                  onCategoryTap: _onCategoryTap,
                  onCommandTap: _executeCommand,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PANEL SHELL
// =============================================================================

class _Panel extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final ValueChanged<String> onQueryChanged;
  final Map<DSCommandCategory, List<DSCommand>> grouped;
  final List<DSCommand> flat;
  final int selectedIndex;
  final DSCommandCategory? activeCategory;
  final ValueChanged<DSCommandCategory?> onCategoryTap;
  final ValueChanged<DSCommand> onCommandTap;

  const _Panel({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.onQueryChanged,
    required this.grouped,
    required this.flat,
    required this.selectedIndex,
    required this.activeCategory,
    required this.onCategoryTap,
    required this.onCommandTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSRadii.modal),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: DSColors.glassOverlay.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(DSRadii.modal),
              border: Border.all(
                color: DSColors.borderDefault.withValues(alpha: 0.6),
              ),
              boxShadow: DSShadows.elevation4,
            ),
            // Use max height so Expanded list gets a real flex budget;
            // mainAxisSize.min + Expanded overflowed after a11y chip growth.
            child: SizedBox(
              height: 480,
              child: Column(
                children: [
                  _SearchField(
                    controller: controller,
                    focusNode: focusNode,
                    placeholder: placeholder,
                    onChanged: onQueryChanged,
                  ),
                  _CategoryChips(active: activeCategory, onTap: onCategoryTap),
                  const Divider(height: 1, color: DSColors.borderSubtle),
                  Expanded(
                    child: _ResultsList(
                      grouped: grouped,
                      flat: flat,
                      selectedIndex: selectedIndex,
                      onCommandTap: onCommandTap,
                    ),
                  ),
                  _FooterHint(resultCount: flat.length),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SEARCH FIELD
// =============================================================================

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.lg,
        DSSpacing.lg,
        DSSpacing.sm,
      ),
      child: Row(
        children: [
          DSIcon(Icons.search, color: DSColors.accentBlue, size: 20),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: DSTypography.bodyLarge.copyWith(
                color: DSColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: DSTypography.bodyLarge.copyWith(
                  color: DSColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Keyboard shortcut hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: DSColors.obsidianHover,
              borderRadius: BorderRadius.circular(DSRadii.xs),
              border: Border.all(color: DSColors.borderSubtle),
            ),
            child: const DSText.labelSmall('ESC', color: DSColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CATEGORY CHIPS
// =============================================================================

class _CategoryChips extends StatelessWidget {
  final DSCommandCategory? active;
  final ValueChanged<DSCommandCategory?> onTap;

  const _CategoryChips({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
      ).copyWith(bottom: DSSpacing.sm),
      child: Row(
        children: [
          _CatChip(
            label: 'All',
            icon: Icons.list,
            isActive: active == null,
            onTap: () => onTap(null),
          ),
          const SizedBox(width: DSSpacing.xs),
          _CatChip(
            label: 'Navigate',
            icon: Icons.open_in_new,
            isActive: active == DSCommandCategory.navigate,
            onTap: () => onTap(DSCommandCategory.navigate),
          ),
          const SizedBox(width: DSSpacing.xs),
          _CatChip(
            label: 'Run',
            icon: Icons.play_arrow,
            isActive: active == DSCommandCategory.run,
            onTap: () => onTap(DSCommandCategory.run),
          ),
          const SizedBox(width: DSSpacing.xs),
          _CatChip(
            label: 'Recent',
            icon: Icons.history,
            isActive: active == DSCommandCategory.recent,
            onTap: () => onTap(DSCommandCategory.recent),
          ),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _CatChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? DSColors.accentBlue.withValues(alpha: 0.15)
        : DSColors.transparent;
    final border = isActive ? DSColors.focusRing : DSColors.borderSubtle;
    final fg = isActive ? DSColors.accentBlue : DSColors.textTertiary;

    return Semantics(
      button: true,
      selected: isActive,
      label: '$label category filter',
      child: Material(
        color: DSColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSRadii.chip),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(DSRadii.chip),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: fg),
                      const SizedBox(width: DSSpacing.xs),
                      DSText.labelSmall(label, color: fg),
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

// =============================================================================
// RESULTS LIST
// =============================================================================

class _ResultsList extends StatelessWidget {
  final Map<DSCommandCategory, List<DSCommand>> grouped;
  final List<DSCommand> flat;
  final int selectedIndex;
  final ValueChanged<DSCommand> onCommandTap;

  const _ResultsList({
    required this.grouped,
    required this.flat,
    required this.selectedIndex,
    required this.onCommandTap,
  });

  @override
  Widget build(BuildContext context) {
    if (flat.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(DSSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSIcon(Icons.search_off, color: DSColors.textTertiary, size: 32),
              SizedBox(height: DSSpacing.sm),
              DSText.bodyMedium(
                'No matching commands',
                color: DSColors.textTertiary,
              ),
            ],
          ),
        ),
      );
    }

    // Non-lazy children: command palettes are small (<50 items) and tests /
    // keyboard nav expect all category headers to be mounted in the tree.
    final items = _buildItems();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
      children: items,
    );
  }

  List<Widget> _buildItems() {
    final items = <Widget>[];
    var flatIndex = 0;

    for (final entry in grouped.entries) {
      // Category header
      items.add(_CategoryHeader(category: entry.key));

      for (final cmd in entry.value) {
        final isSelected = flatIndex == selectedIndex;
        items.add(
          _CommandItem(
            command: cmd,
            isSelected: isSelected,
            onTap: () => onCommandTap(cmd),
          ),
        );
        flatIndex++;
      }
    }

    return items;
  }
}

class _CategoryHeader extends StatelessWidget {
  final DSCommandCategory category;

  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.sm,
        DSSpacing.lg,
        DSSpacing.xs,
      ),
      child: DSText.labelSmall(
        _labelFor(category),
        color: DSColors.textTertiary,
      ),
    );
  }

  String _labelFor(DSCommandCategory cat) {
    switch (cat) {
      case DSCommandCategory.navigate:
        return 'NAVIGATE';
      case DSCommandCategory.run:
        return 'RUN';
      case DSCommandCategory.recent:
        return 'RECENT';
    }
  }
}

// =============================================================================
// COMMAND ITEM
// =============================================================================

class _CommandItem extends StatelessWidget {
  final DSCommand command;
  final bool isSelected;
  final VoidCallback onTap;

  const _CommandItem({
    required this.command,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? DSColors.accentBlue.withValues(alpha: 0.08)
        : DSColors.transparent;
    final borderColor = isSelected ? DSColors.focusRing : DSColors.transparent;
    final enabled = command.isEnabled;
    final iconColor = enabled
        ? (isSelected ? DSColors.accentBlue : DSColors.textSecondary)
        : DSColors.textDisabled;

    final semanticLabel = StringBuffer(command.label);
    final description = command.description;
    if (description != null && description.isNotEmpty) {
      semanticLabel.write('. $description');
    }
    final disabledReason = command.disabledReason;
    if (!enabled && disabledReason != null && disabledReason.isNotEmpty) {
      semanticLabel.write('. Disabled: $disabledReason');
    }

    return Semantics(
      button: true,
      enabled: enabled,
      selected: isSelected,
      label: semanticLabel.toString(),
      child: Material(
        color: DSColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSRadii.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: 1,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(DSRadii.sm),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  // Icon
                  DSIcon(command.icon, color: iconColor, size: 18),
                  const SizedBox(width: DSSpacing.md),
                  // Label + description + disabled reason
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DSText.labelLarge(
                          command.label,
                          color: enabled
                              ? (isSelected
                                    ? DSColors.textPrimary
                                    : DSColors.textSecondary)
                              : DSColors.textDisabled,
                        ),
                        if (command.description != null) ...[
                          const SizedBox(height: 1),
                          DSText.bodySmall(
                            command.description!,
                            color: DSColors.textTertiary,
                            maxLines: 1,
                          ),
                        ],
                        // Disabled-reason propagation: visible reason line,
                        // never hidden. Presentation only — no visual restyle
                        // beyond this line (Task 1870).
                        if (!enabled &&
                            disabledReason != null &&
                            disabledReason.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          DSText.bodySmall(
                            disabledReason,
                            color: DSColors.textDisabled,
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Shortcut hint
                  if (command.shortcut != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DSColors.obsidianHover,
                        borderRadius: BorderRadius.circular(DSRadii.xs),
                        border: Border.all(color: DSColors.borderSubtle),
                      ),
                      child: DSText.labelSmall(
                        command.shortcut!,
                        color: DSColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FOOTER HINT
// =============================================================================

class _FooterHint extends StatelessWidget {
  final int resultCount;

  const _FooterHint({required this.resultCount});

  String get _countText {
    if (resultCount <= 0) return '';
    return resultCount == 1 ? '1 result' : '$resultCount results';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DSColors.borderSubtle)),
      ),
      child: Row(
        children: [
          const _KeyHint(icon: Icons.arrow_upward, label: ''),
          const SizedBox(width: 2),
          const _KeyHint(icon: Icons.arrow_downward, label: ''),
          const SizedBox(width: DSSpacing.xs),
          const DSText.labelSmall('navigate', color: DSColors.textDisabled),
          const SizedBox(width: DSSpacing.md),
          const _KeyHint(label: '↵'),
          const SizedBox(width: DSSpacing.xs),
          const DSText.labelSmall('select', color: DSColors.textDisabled),
          const SizedBox(width: DSSpacing.md),
          const _KeyHint(label: 'esc'),
          const SizedBox(width: DSSpacing.xs),
          const DSText.labelSmall('close', color: DSColors.textDisabled),
          if (resultCount > 0) ...[
            const Spacer(),
            DSText.labelSmall(_countText, color: DSColors.textDisabled),
          ],
        ],
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  final IconData? icon;
  final String label;

  const _KeyHint({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: DSColors.obsidianHover,
        borderRadius: BorderRadius.circular(DSRadii.xs),
        border: Border.all(color: DSColors.borderSubtle),
      ),
      child: icon != null
          ? Icon(icon, size: 12, color: DSColors.textTertiary)
          : DSText.labelSmall(label, color: DSColors.textTertiary),
    );
  }
}

// =============================================================================
// SHOW HELPER
// =============================================================================

/// Shows the [DSCommandPalette] as a modal overlay on the nearest [Navigator].
///
/// Returns a future that completes when the palette is dismissed.
Future<void> showDSCommandPalette(
  BuildContext context, {
  required List<DSCommand> commands,
  ValueChanged<DSCommand>? onExecute,
  ValueChanged<DSCommand>? onDisabledCommand,
  String? initialQuery,
  String placeholder = 'Type a command...',
}) {
  return Navigator.of(context).push(
    _CommandPaletteRoute(
      commands: commands,
      onExecute: onExecute,
      onDisabledCommand: onDisabledCommand,
      initialQuery: initialQuery,
      placeholder: placeholder,
    ),
  );
}

class _CommandPaletteRoute extends PageRouteBuilder<void> {
  final List<DSCommand> commands;
  final ValueChanged<DSCommand>? onExecute;
  final ValueChanged<DSCommand>? onDisabledCommand;
  final String? initialQuery;
  final String placeholder;

  _CommandPaletteRoute({
    required this.commands,
    this.onExecute,
    this.onDisabledCommand,
    this.initialQuery,
    this.placeholder = 'Type a command...',
  }) : super(
         opaque: false,
         barrierDismissible: true,
         barrierColor: Colors.transparent,
         transitionDuration: DSMotion.normal,
         reverseTransitionDuration: DSMotion.fast,
         pageBuilder: (context, animation, secondaryAnimation) {
           return DSCommandPalette(
             commands: commands,
             onExecute: onExecute,
             onDisabledCommand: onDisabledCommand,
             onClose: () => Navigator.of(context).pop(),
             initialQuery: initialQuery,
             placeholder: placeholder,
           );
         },
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(
             opacity: CurvedAnimation(parent: animation, curve: DSMotion.enter),
             child: ScaleTransition(
               scale: Tween<double>(begin: 0.97, end: 1.0).animate(
                 CurvedAnimation(parent: animation, curve: DSMotion.emphasized),
               ),
               child: child,
             ),
           );
         },
       );
}

// =============================================================================
// KEYBOARD SHORTCUT WIDGET
// =============================================================================

/// Wraps a child widget and listens for `Cmd+K` / `Ctrl+K` to trigger
/// the command palette via [showDSCommandPalette].
///
/// Place this at the top of the widget tree (above [MaterialApp] or
/// inside the [Scaffold] body) to capture the shortcut globally.
///
/// ```dart
/// DSCommandPaletteShortcut(
///   commands: myCommands,
///   child: MyPageContent(),
/// )
/// ```
class DSCommandPaletteShortcut extends StatefulWidget {
  final Widget child;
  final List<DSCommand> commands;
  final ValueChanged<DSCommand>? onExecute;
  final String placeholder;

  const DSCommandPaletteShortcut({
    super.key,
    required this.child,
    required this.commands,
    this.onExecute,
    this.placeholder = 'Type a command...',
  });

  @override
  State<DSCommandPaletteShortcut> createState() =>
      _DSCommandPaletteShortcutState();
}

class _DSCommandPaletteShortcutState extends State<DSCommandPaletteShortcut> {
  bool _isOpen = false;
  final FocusNode _focusNode = FocusNode(
    debugLabel: 'DSCommandPaletteShortcut',
  );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _openPalette() {
    if (_isOpen) return;
    _isOpen = true;
    showDSCommandPalette(
      context,
      commands: widget.commands,
      onExecute: widget.onExecute,
      placeholder: widget.placeholder,
    ).then((_) {
      // Guard against dispose during modal lifecycle (F2).
      if (!mounted) return;
      setState(() {
        _isOpen = false;
      });
      // Reclaim key capture after the modal route pops focus away.
      _focusNode.requestFocus();
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Cmd+K (macOS) or Ctrl+K (other platforms)
    final isMod =
        (HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed);
    if (isMod && event.logicalKey == LogicalKeyboardKey.keyK) {
      _openPalette();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: widget.child,
    );
  }
}
