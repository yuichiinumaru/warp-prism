import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/atoms.dart';
import '../../tokens/tokens.dart';

/// ASW Observatory Organism - Theme Editor
///
/// Gives tooling and catalog users live visual control over Black Obsidian DS color roles.
///
/// Token overrides are applied dynamically via [PrismTokenRegistry].
/// Production runtime code does not mutate token state.
class PrismThemeEditor extends StatefulWidget {
  /// Width when hosted as a side panel.
  final double? width;

  /// Callback fired when any token color role is updated.
  final VoidCallback? onChanged;

  /// Optional close callback for slideout or modal hosting.
  final VoidCallback? onClose;

  const PrismThemeEditor({super.key, this.width, this.onChanged, this.onClose});

  @override
  State<PrismThemeEditor> createState() => _PrismThemeEditorState();
}

class _PrismThemeEditorState extends State<PrismThemeEditor> {
  final Map<PrismColorRole, TextEditingController> _controllers = {};
  final Map<PrismColorRole, String?> _errors = {};
  final PrismTokenRegistry _registry = PrismTokenRegistry.instance;

  @override
  void initState() {
    super.initState();
    _registry.addListener(_onRegistryChanged);
    _syncControllersFromRegistry();
  }

  @override
  void dispose() {
    _registry.removeListener(_onRegistryChanged);
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onRegistryChanged() {
    _syncControllersFromRegistry();
    widget.onChanged?.call();
  }

  void _syncControllersFromRegistry() {
    for (final role in PrismColorRole.values) {
      final color = _registry.getColor(role);
      final hex = PrismTokenRegistry.colorToHex(color);
      final controller = _controllers.putIfAbsent(
        role,
        () => TextEditingController(text: hex),
      );
      if (controller.text != hex) {
        controller.text = hex;
        _errors[role] = null;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onHexSubmitted(PrismColorRole role, String input) {
    final parsed = PrismTokenRegistry.parseHex(input);
    if (parsed != null) {
      setState(() {
        _errors[role] = null;
      });
      _registry.setColor(role, parsed);
    } else {
      setState(() {
        _errors[role] = 'Invalid hex (use #RGB, #RRGGBB, #AARRGGBB)';
      });
    }
  }

  void _showExportDialog(BuildContext context) {
    final snippet = _registry.generateBakeBackSnippet();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: DSColors.obsidianElevated,
          title: Row(
            children: [
              const Icon(
                Icons.code_outlined,
                color: DSColors.accentCyan,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.sm),
              const Expanded(
                child: DSText.headingSmall(
                  'Bake-Back Code Snippet',
                  color: DSColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: DSColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DSText.bodyMedium(
                  'Copy this generated snippet to update Task 1800 contract or token defaults:',
                  color: DSColors.textSecondary,
                ),
                const SizedBox(height: DSSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: Container(
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: DSColors.obsidianDeep,
                      borderRadius: BorderRadius.circular(DSRadii.md),
                      border: Border.all(color: DSColors.borderDefault),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        snippet,
                        style: DSTypography.codeSmall.copyWith(
                          color: DSColors.accentCyan,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            DSButton(
              label: 'Copy to Clipboard',
              variant: DSButtonVariant.primary,
              icon: Icons.copy_outlined,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: snippet));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bake-back snippet copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
            DSButton(
              label: 'Close',
              variant: DSButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Accent & Focus', 'Surfaces', 'Borders'];

    return SizedBox(
      width: widget.width ?? 360,
      child: DSGlassPanel(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: DSColors.obsidianBase,
                border: Border(
                  bottom: BorderSide(color: DSColors.borderDefault),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: DSColors.accentBlue,
                    size: 20,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  const Expanded(
                    child: DSText.headingSmall(
                      'Prism Theme Editor',
                      color: DSColors.textPrimary,
                    ),
                  ),
                  if (_registry.hasOverrides)
                    DSBadge(
                      label: '${_registry.currentOverrides.length} modified',
                      color: DSColors.accentGold,
                    ),
                  if (widget.onClose != null) ...[
                    const SizedBox(width: DSSpacing.xs),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: DSColors.textSecondary,
                      ),
                      onPressed: widget.onClose,
                    ),
                  ],
                ],
              ),
            ),

            // Convergence banner instructions
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              color: DSColors.obsidianElevated,
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: DSColors.accentCyan,
                    size: 16,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  const Expanded(
                    child: DSText.bodySmall(
                      'Iterate live in the Catalog gallery, then click Export Snippet to bake back approved hex values.',
                      color: DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const DSDivider(),

            // Toolbar controls (Export, Reset)
            Padding(
              padding: const EdgeInsets.all(DSSpacing.sm),
              child: Wrap(
                spacing: DSSpacing.xs,
                runSpacing: DSSpacing.xs,
                children: [
                  DSButton(
                    label: 'Export Snippet',
                    variant: DSButtonVariant.primary,
                    size: DSButtonSize.sm,
                    icon: Icons.output_outlined,
                    onPressed: () => _showExportDialog(context),
                  ),
                  DSButton(
                    label: 'Reset Defaults',
                    variant: DSButtonVariant.secondary,
                    size: DSButtonSize.sm,
                    icon: Icons.restart_alt_outlined,
                    onPressed: _registry.hasOverrides
                        ? () {
                            _registry.reset();
                            _syncControllersFromRegistry();
                          }
                        : null,
                  ),
                ],
              ),
            ),

            const DSDivider(),

            // Presets row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DSText.labelSmall(
                    'Quick Accent Presets',
                    color: DSColors.textTertiary,
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Wrap(
                    spacing: DSSpacing.xs,
                    runSpacing: DSSpacing.xs,
                    children: [
                      _PresetChip(
                        label: 'Obsidian Blue',
                        color: const Color(0xFF2F81FF),
                        onTap: () {
                          _registry.setColor(
                            PrismColorRole.accentBlue,
                            const Color(0xFF2F81FF),
                          );
                          _registry.setColor(
                            PrismColorRole.accentBlueMuted,
                            const Color(0xFF1D64D8),
                          );
                          _registry.setColor(
                            PrismColorRole.accentBlueDim,
                            const Color(0xFF114299),
                          );
                          _registry.setColor(
                            PrismColorRole.focusRing,
                            const Color(0x802F81FF),
                          );
                        },
                      ),
                      _PresetChip(
                        label: 'CyberCore Teal',
                        color: const Color(0xFF00FFCC),
                        onTap: () {
                          _registry.setColor(
                            PrismColorRole.accentBlue,
                            const Color(0xFF00FFCC),
                          );
                          _registry.setColor(
                            PrismColorRole.accentBlueMuted,
                            const Color(0xFF00CC99),
                          );
                          _registry.setColor(
                            PrismColorRole.accentBlueDim,
                            const Color(0xFF00664D),
                          );
                          _registry.setColor(
                            PrismColorRole.focusRing,
                            const Color(0x8000FFCC),
                          );
                        },
                      ),
                      _PresetChip(
                        label: 'Protoss Gold',
                        color: const Color(0xFFFFB800),
                        onTap: () {
                          _registry.setColor(
                            PrismColorRole.accentBlue,
                            const Color(0xFFFFB800),
                          );
                          _registry.setColor(
                            PrismColorRole.accentBlueMuted,
                            const Color(0xFFCC9400),
                          );
                          _registry.setColor(
                            PrismColorRole.accentBlueDim,
                            const Color(0xFF997000),
                          );
                          _registry.setColor(
                            PrismColorRole.focusRing,
                            const Color(0x80FFB800),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const DSDivider(),

            // Editable roles grouped by category
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(DSSpacing.sm),
                children: [
                  for (final category in categories) ...[
                    DSText.labelLarge(
                      category.toUpperCase(),
                      color: DSColors.textTertiary,
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    ...PrismColorRole.values
                        .where((r) => r.category == category)
                        .map((role) => _buildRoleEditor(role)),
                    const SizedBox(height: DSSpacing.md),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleEditor(PrismColorRole role) {
    final currentColor = _registry.getColor(role);
    final isOverridden = _registry.currentOverrides.containsKey(role);
    final controller = _controllers[role]!;
    final error = _errors[role];

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: DSColors.obsidianBase,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(
          color: isOverridden ? DSColors.accentGold : DSColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Color preview swatch
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(DSRadii.xs),
                  border: Border.all(color: DSColors.borderDefault),
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: DSText.labelMedium(
                  role.label,
                  color: DSColors.textPrimary,
                ),
              ),
              // Per-role copy hex action
              Semantics(
                button: true,
                label: 'Copy hex for ${role.label}',
                child: SizedBox(
                  width: kMinInteractiveDimension,
                  height: kMinInteractiveDimension,
                  child: IconButton(
                    key: ValueKey('copy-hex-${role.key}'),
                    icon: const Icon(
                      Icons.content_copy_outlined,
                      size: 16,
                      color: DSColors.textSecondary,
                    ),
                    tooltip: 'Copy hex value',
                    onPressed: () {
                      final hex = PrismTokenRegistry.colorToHex(currentColor);
                      Clipboard.setData(ClipboardData(text: hex));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied $hex for ${role.label}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (isOverridden)
                Semantics(
                  button: true,
                  label: 'Reset ${role.label} to default',
                  child: SizedBox(
                    width: kMinInteractiveDimension,
                    height: kMinInteractiveDimension,
                    child: IconButton(
                      key: ValueKey('reset-role-${role.key}'),
                      icon: const Icon(
                        Icons.restore,
                        size: 16,
                        color: DSColors.accentGold,
                      ),
                      tooltip: 'Reset role to default',
                      onPressed: () {
                        _registry.resetRole(role);
                        _syncControllersFromRegistry();
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          DSText.bodySmall(role.description, color: DSColors.textTertiary),
          const SizedBox(height: DSSpacing.xs),
          Row(
            children: [
              Expanded(
                child: DSTextField(
                  controller: controller,
                  hint: '#RRGGBB or #AARRGGBB',
                  onChanged: (val) => _onHexSubmitted(role, val),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 2),
            DSText.bodySmall(error, color: DSColors.statusError),
          ],
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Apply $label preset',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kMinInteractiveDimension,
          minHeight: kMinInteractiveDimension,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSRadii.chip),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.xs + 2,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: DSColors.obsidianElevated,
              borderRadius: BorderRadius.circular(DSRadii.chip),
              border: Border.all(color: DSColors.borderDefault),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                DSText.labelSmall(label, color: DSColors.textPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
