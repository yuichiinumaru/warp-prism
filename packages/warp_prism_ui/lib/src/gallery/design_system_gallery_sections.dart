/// Design System Gallery — reusable section builders.
///
/// Each static method returns a widget tree that showcases one atomic layer
/// (tokens, atoms, molecules, organisms, templates) in a consistent card
/// layout.  The gallery page composes these sections into a scrollable list.
library;

import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';
import '../organisms/organisms.dart';

/// Section builders for the Design System Gallery.
///
/// All methods are pure — they take no state and return a widget.
/// This file exists to keep [DesignSystemGalleryPage] readable while
/// exposing every DS surface for visual verification.
abstract class DSGallerySections {
  // ---------------------------------------------------------------------------
  // TOKENS
  // ---------------------------------------------------------------------------
  /// Color swatches for obsidian backgrounds, accents, and status colors.
  static Widget buildTokensSection() {
    return _SectionCard(
      title: 'Tokens',
      subtitle: 'Colors · Typography · Spacing · Radii · Shadows · Motion',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorSwatches(),
          const SizedBox(height: DSSpacing.lg),
          _buildTypographySamples(),
          const SizedBox(height: DSSpacing.lg),
          _buildSpacingScale(),
          const SizedBox(height: DSSpacing.lg),
          _buildRadiiScale(),
          const SizedBox(height: DSSpacing.lg),
          _buildShadowSamples(),
          const SizedBox(height: DSSpacing.lg),
          _buildMotionSamples(),
        ],
      ),
    );
  }

  static Widget _buildColorSwatches() {
    const swatches = <_SwatchDef>[
      _SwatchDef('obsidianDeep', DSColors.obsidianDeep),
      _SwatchDef('obsidianBase', DSColors.obsidianBase),
      _SwatchDef('obsidianElevated', DSColors.obsidianElevated),
      _SwatchDef('accentCyan', DSColors.accentCyan),
      _SwatchDef('accentViolet', DSColors.accentViolet),
      _SwatchDef('accentGold', DSColors.accentGold),
      _SwatchDef('statusSuccess', DSColors.statusSuccess),
      _SwatchDef('statusWarning', DSColors.statusWarning),
      _SwatchDef('statusError', DSColors.statusError),
      _SwatchDef('statusInfo', DSColors.statusInfo),
      _SwatchDef('textPrimary', DSColors.textPrimary),
      _SwatchDef('textSecondary', DSColors.textSecondary),
      _SwatchDef('textTertiary', DSColors.textTertiary),
      _SwatchDef('borderSubtle', DSColors.borderSubtle),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DSText.labelLarge('Color Palette', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.sm),
        Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
          children: swatches.map((s) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(DSRadii.md),
                    border: Border.all(color: DSColors.borderSubtle),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 64,
                  child: DSText.labelSmall(
                    s.label,
                    color: DSColors.textTertiary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildTypographySamples() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText.labelLarge('Typography', color: DSColors.textSecondary),
        SizedBox(height: DSSpacing.sm),
        DSText.displaySmall('Display Small'),
        DSText.headingLarge('Heading Large'),
        DSText.headingMedium('Heading Medium'),
        DSText.headingSmall('Heading Small'),
        DSText.bodyLarge('Body Large — primary reading text'),
        DSText.bodyMedium('Body Medium — secondary text'),
        DSText.bodySmall('Body Small — captions and metadata'),
        DSText.labelLarge('Label Large'),
        DSText.labelMedium('Label Medium'),
        DSText.labelSmall('Label Small'),
        DSText(
          '42.0',
          variant: DSTextVariant.numericLarge,
          color: DSColors.accentCyan,
        ),
      ],
    );
  }

  static Widget _buildSpacingScale() {
    final scale = <_ScaleDef>[
      const _ScaleDef('xxs', DSSpacing.xxs),
      const _ScaleDef('xs', DSSpacing.xs),
      const _ScaleDef('sm', DSSpacing.sm),
      const _ScaleDef('md', DSSpacing.md),
      const _ScaleDef('lg', DSSpacing.lg),
      const _ScaleDef('xl', DSSpacing.xl),
      const _ScaleDef('xxl', DSSpacing.xxl),
      const _ScaleDef('xxxl', DSSpacing.xxxl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DSText.labelLarge('Spacing Scale', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.sm),
        ...scale.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: DSText.labelSmall(
                    s.label,
                    color: DSColors.textTertiary,
                  ),
                ),
                Container(
                  width: s.value * 3,
                  height: 12,
                  decoration: BoxDecoration(
                    color: DSColors.accentCyan.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(DSRadii.xs),
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                DSText.labelSmall('${s.value}px', color: DSColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildRadiiScale() {
    final scale = <_ScaleDef>[
      const _ScaleDef('none', DSRadii.none),
      const _ScaleDef('xs', DSRadii.xs),
      const _ScaleDef('sm', DSRadii.sm),
      const _ScaleDef('md', DSRadii.md),
      const _ScaleDef('lg', DSRadii.lg),
      const _ScaleDef('xl', DSRadii.xl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DSText.labelLarge('Radii Scale', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.sm),
        Wrap(
          spacing: DSSpacing.md,
          runSpacing: DSSpacing.sm,
          children: scale
              .map(
                (r) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DSColors.obsidianElevated,
                        borderRadius: BorderRadius.circular(r.value),
                        border: Border.all(color: DSColors.accentViolet),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DSText.labelSmall(r.label, color: DSColors.textTertiary),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static Widget _buildShadowSamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DSText.labelLarge('Shadows', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.sm),
        Wrap(
          spacing: DSSpacing.lg,
          runSpacing: DSSpacing.sm,
          children: [
            _shadowBox('elevation1', DSShadows.elevation1),
            _shadowBox('elevation2', DSShadows.elevation2),
            _shadowBox('elevation3', DSShadows.elevation3),
            _shadowBox('elevation4', DSShadows.elevation4),
          ],
        ),
      ],
    );
  }

  static Widget _shadowBox(String label, List<BoxShadow> shadows) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 48,
          decoration: BoxDecoration(
            color: DSColors.obsidianElevated,
            borderRadius: BorderRadius.circular(DSRadii.md),
            boxShadow: shadows,
          ),
        ),
        const SizedBox(height: 4),
        DSText.labelSmall(label, color: DSColors.textTertiary),
      ],
    );
  }

  static Widget _buildMotionSamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DSText.labelLarge('Motion', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.sm),
        DSText.bodySmall(
          'fast: ${DSMotion.fast.inMilliseconds}ms · '
          'normal: ${DSMotion.normal.inMilliseconds}ms · '
          'slow: ${DSMotion.slow.inMilliseconds}ms',
          color: DSColors.textTertiary,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ATOMS
  // ---------------------------------------------------------------------------
  static Widget buildAtomsSection() {
    return _SectionCard(
      title: 'Atoms',
      subtitle:
          'DSText · DSIcon · DSBadge · DSChip · DSButton · DSCheckbox · DSSwitch · DSStatusDot · DSDivider · DSGlowBorder · DSGlassPanel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text variants
          const DSText.labelLarge('Text Variants', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const DSText.headingMedium('Heading Medium'),
          const DSText.bodyMedium('Body medium text'),
          const DSText.labelSmall('Label small'),
          const SizedBox(height: DSSpacing.md),

          // Buttons
          const DSText.labelLarge('Buttons', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const _ButtonDemo(),
          const SizedBox(height: DSSpacing.md),

          // Checkboxes
          const DSText.labelLarge('Checkboxes', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.lg,
            runSpacing: DSSpacing.sm,
            children: [
              DSCheckbox(
                value: false,
                onChanged: (_) {},
                label: 'Unchecked',
              ),
              DSCheckbox(
                value: true,
                onChanged: (_) {},
                label: 'Checked',
              ),
              DSCheckbox(
                value: null,
                tristate: true,
                onChanged: (_) {},
                label: 'Indeterminate',
              ),
              const DSCheckbox(
                value: false,
                enabled: false,
                onChanged: null,
                label: 'Disabled',
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // Switches
          const DSText.labelLarge('Switches', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const _SwitchDemo(),
          const SizedBox(height: DSSpacing.md),

          // Text Fields
          const DSText.labelLarge('Text Fields', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const _TextFieldDemo(),
          const SizedBox(height: DSSpacing.md),

          // Icons
          DSText.labelLarge('Icons', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.sm,
            children: [
              DSIcon(DSIcons.agent, color: DSColors.assetAgent),
              DSIcon(DSIcons.skill, color: DSColors.assetSkill),
              DSIcon(DSIcons.workflow, color: DSColors.assetWorkflow),
              DSIcon(DSIcons.task, color: DSColors.assetTask),
              DSIcon(DSIcons.graph, color: DSColors.accentCyan),
              DSIcon(DSIcons.success, color: DSColors.statusSuccess),
              DSIcon(DSIcons.warning, color: DSColors.statusWarning),
              DSIcon(DSIcons.error, color: DSColors.statusError),
            ],
          ),
          SizedBox(height: DSSpacing.md),

          // Badges
          DSText.labelLarge('Badges', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            children: [
              DSBadge.count(3, color: DSColors.accentCyan),
              DSBadge.count(42, color: DSColors.accentViolet),
              DSBadge.count(7, color: DSColors.statusWarning),
            ],
          ),
          SizedBox(height: DSSpacing.md),

          // Chips
          DSText.labelLarge('Chips', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            children: [
              DSChip(label: 'Agent', color: DSColors.assetAgent),
              DSChip(label: 'Skill', color: DSColors.assetSkill),
              DSChip(label: 'Workflow', color: DSColors.assetWorkflow),
            ],
          ),
          SizedBox(height: DSSpacing.md),

          // Status dots
          DSText.labelLarge('Status Dots', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            children: [
              DSStatusDot.success(tooltip: 'Success'),
              DSStatusDot.warning(tooltip: 'Warning'),
              DSStatusDot.error(tooltip: 'Error'),
              DSStatusDot.info(tooltip: 'Info'),
            ],
          ),
          SizedBox(height: DSSpacing.md),

          // Dividers
          DSText.labelLarge('Dividers', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          DSDivider.subtle(),
          SizedBox(height: DSSpacing.sm),
          DSDivider.glow(),

          SizedBox(height: DSSpacing.md),

          // Glass panels
          DSText.labelLarge('Glass Panels', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          DSGlassPanelSimple(
            padding: EdgeInsets.all(DSSpacing.md),
            child: DSText.bodyMedium(
              'GlassPanelSimple — no blur, perf-safe',
              color: DSColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOLECULES
  // ---------------------------------------------------------------------------
  static Widget buildMoleculesSection() {
    return _SectionCard(
      title: 'Molecules',
      subtitle:
          'DSSearchBar · DSFilterChipGroup · DSAccordion · DSDialog · DSAssetCard · DSTaskCard · DSTimelineMarker · DSStateSurface · DSShimmer · DSSkeletonCard · DSSkeletonTableRows · DSSkeletonTextLine',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          DSText.labelLarge('Search Bar', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          SizedBox(
            width: 560,
            child: DSSearchBar(placeholder: 'Search assets...'),
          ),
          SizedBox(height: DSSpacing.lg),

          // Select / Dropdown
          DSText.labelLarge('Select / Dropdown (DSSelect)', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.md,
            children: [
              SizedBox(
                width: 260,
                child: DSSelect<String>(
                  label: 'Environment',
                  value: 'prod',
                  options: const [
                    DSSelectItem(value: 'dev', label: 'Development', icon: Icons.developer_mode),
                    DSSelectItem(value: 'staging', label: 'Staging', icon: Icons.cloud_queue),
                    DSSelectItem(value: 'prod', label: 'Production', icon: Icons.cloud_done),
                    DSSelectItem(value: 'deprecated', label: 'Legacy Cluster', disabled: true),
                  ],
                ),
              ),
              SizedBox(
                width: 260,
                child: DSSelect<String>(
                  label: 'Searchable Select',
                  searchable: true,
                  placeholder: 'Choose provider...',
                  options: const [
                    DSSelectItem(value: 'anthropic', label: 'Anthropic Claude'),
                    DSSelectItem(value: 'openai', label: 'OpenAI GPT-4o'),
                    DSSelectItem(value: 'google', label: 'Google Gemini Pro'),
                  ],
                ),
              ),
              SizedBox(
                width: 260,
                child: DSSelect<String>(
                  label: 'Error State',
                  value: null,
                  errorText: 'Selection is required',
                  options: const [
                    DSSelectItem(value: '1', label: 'Option 1'),
                  ],
                ),
              ),
              SizedBox(
                width: 260,
                child: DSSelect<String>(
                  label: 'Disabled Select',
                  enabled: false,
                  value: 'dev',
                  options: const [
                    DSSelectItem(value: 'dev', label: 'Development'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DSSpacing.lg),

          // Filter chips
          DSText.labelLarge('Filter Chip Group', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          DSFilterChipGroup(
            options: [
              DSFilterOption(value: 'agent', label: 'Agent', count: 5),
              DSFilterOption(value: 'skill', label: 'Skill', count: 12),
              DSFilterOption(value: 'workflow', label: 'Workflow', count: 3),
            ],
            selected: {'agent'},
          ),
          SizedBox(height: DSSpacing.lg),

          // Accordion / Collapsible
          DSText.labelLarge('Accordion (Single & Multi-Expand)', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          SizedBox(
            width: 560,
            child: DSAccordion(
              items: [
                DSAccordionItem(
                  title: 'Section 1: General Settings',
                  subtitle: 'Basic configuration flags',
                  icon: Icons.tune,
                  defaultOpen: true,
                  content: DSText.bodyMedium('General configuration panel content.'),
                ),
                DSAccordionItem(
                  title: 'Section 2: Security & Permissions',
                  subtitle: 'Access control and secret policies',
                  icon: Icons.shield,
                  content: DSText.bodyMedium('Security credentials and permissions settings.'),
                ),
                DSAccordionItem(
                  title: 'Section 3: Disabled Capabilities',
                  subtitle: 'Inactive integration block',
                  icon: Icons.block,
                  disabled: true,
                  content: DSText.bodyMedium('This content is inaccessible.'),
                ),
                DSAccordionItem(
                  title: 'Section 4: Empty Section',
                  subtitle: 'No body provided',
                  icon: Icons.inbox,
                  content: null,
                ),
              ],
            ),
          ),
          SizedBox(height: DSSpacing.lg),

          // Modal Dialog (DSDialog / PrismDialog)
          DSText.labelLarge('Modal Dialog (DSDialog / PrismDialog)', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          Builder(
            builder: (context) {
              return Wrap(
                spacing: DSSpacing.md,
                runSpacing: DSSpacing.md,
                children: [
                  DSButton(
                    label: 'Show Confirmation Dialog',
                    icon: Icons.help_outline,
                    onPressed: () {
                      DSDialog.show<bool>(
                        context: context,
                        builder: (ctx) => DSDialog(
                          title: 'Confirm Agent Deletion',
                          subtitle: 'This action cannot be undone.',
                          icon: Icons.warning_amber_outlined,
                          size: DSDialogSize.sm,
                          content: const DSText.bodyMedium(
                            'Are you sure you want to permanently delete agent "Architect"? All execution context will be unlinked.',
                          ),
                          actions: [
                            DSDialogAction.cancel(
                              onPressed: () => Navigator.of(ctx).pop(false),
                            ),
                            DSDialogAction.danger(
                              label: 'Delete Agent',
                              onPressed: () => Navigator.of(ctx).pop(true),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  DSButton(
                    label: 'Show Form Modal (Medium)',
                    icon: Icons.edit_note,
                    variant: DSButtonVariant.secondary,
                    onPressed: () {
                      DSDialog.show(
                        context: context,
                        builder: (ctx) => DSDialog(
                          title: 'Edit Workspace Metadata',
                          subtitle: 'Configure core ASW parameters',
                          icon: Icons.tune,
                          size: DSDialogSize.md,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const DSText.labelMedium('Workspace Name', color: DSColors.textSecondary),
                              const SizedBox(height: DSSpacing.xs),
                              DSTextField(
                                controller: TextEditingController(text: 'warp-prism'),
                                hint: 'Enter workspace name',
                              ),
                              const SizedBox(height: DSSpacing.md),
                              const DSText.labelMedium('Description', color: DSColors.textSecondary),
                              const SizedBox(height: DSSpacing.xs),
                              DSTextField(
                                controller: TextEditingController(text: 'ASW Observatory prototype'),
                                maxLines: 3,
                              ),
                            ],
                          ),
                          actions: [
                            DSDialogAction.cancel(
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            DSDialogAction.confirm(
                              label: 'Save Changes',
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  DSButton(
                    label: 'Show Large Info Dialog',
                    icon: Icons.info_outline,
                    variant: DSButtonVariant.outline,
                    onPressed: () {
                      DSDialog.show(
                        context: context,
                        builder: (ctx) => DSDialog(
                          title: 'Agent System Workspace Overview',
                          subtitle: 'Read-only observatory context',
                          icon: Icons.hub_outlined,
                          size: DSDialogSize.lg,
                          content: const DSText.bodyMedium(
                            'This Warp Prism observatory surfaces a read-only projection of the Agent System Workspace: agents, skills, workflows, tasks, changelog, and dependency graphs. '
                            'Use the map to locate assets, the operate lane to follow task state, and the history lane to trace workspace evolution. '
                            'Governance diagnostics report stale, orphan, and canonicality signals. '
                            'No backend writes, runtime mutation, or live orchestration are performed by this prototype surface.',
                          ),
                          actions: [
                            DSDialogAction.confirm(
                              label: 'Acknowledge',
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  DSButton(
                    label: 'Show Fullscreen Dialog',
                    icon: Icons.fullscreen,
                    variant: DSButtonVariant.ghost,
                    onPressed: () {
                      DSDialog.show(
                        context: context,
                        builder: (ctx) => DSDialog(
                          title: 'Full Detail Inspector',
                          subtitle: 'Full-viewport modal surface',
                          icon: Icons.aspect_ratio,
                          size: DSDialogSize.fullscreen,
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const DSText.bodyMedium(
                                  'Fullscreen dialogs reserve the entire viewport minus an outer margin. '
                                  'They are intended for long-form detail, multi-section forms, or bulk review flows.',
                                ),
                                const SizedBox(height: DSSpacing.lg),
                                const DSText.labelMedium('Section A — Summary', color: DSColors.textSecondary),
                                const SizedBox(height: DSSpacing.xs),
                                const DSText.bodySmall(
                                  'Fixture summary content. Replace with live detail widgets in production.',
                                  color: DSColors.textSecondary,
                                ),
                                const SizedBox(height: DSSpacing.md),
                                const DSText.labelMedium('Section B — Provenance', color: DSColors.textSecondary),
                                const SizedBox(height: DSSpacing.xs),
                                const DSText.bodySmall(
                                  'Provenance pill rows and timeline markers compose here when wired.',
                                  color: DSColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            DSDialogAction.cancel(
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            DSDialogAction.confirm(
                              label: 'Done',
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          SizedBox(height: DSSpacing.lg),

          // Metric tile
          DSText.labelLarge('Metric Tile', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          SizedBox(
            width: 200,
            child: DSMetricTile(
              label: 'Total Assets',
              value: '47',
              icon: Icons.hub_outlined,
              color: DSColors.accentCyan,
            ),
          ),
          SizedBox(height: DSSpacing.lg),

          // Provenance pill
          DSText.labelLarge('Provenance Pill', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            children: [
              DSProvenancePill(canonicality: 'parentcanonical'),
              DSProvenancePill(canonicality: 'childlocal'),
              DSProvenancePill(canonicality: 'generated'),
              DSProvenancePill(canonicality: 'mock'),
            ],
          ),
          SizedBox(height: DSSpacing.lg),

          // State surfaces
          DSText.labelLarge('State Surfaces', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          DSStateSurface.empty(
            icon: Icons.inbox_outlined,
            title: 'No assets loaded',
            subtitle: 'The workspace will populate once assets are parsed',
            compact: true,
          ),
          SizedBox(height: DSSpacing.sm),
          DSStateSurface.loading(title: 'Loading workspace...', compact: true),
          SizedBox(height: DSSpacing.sm),
          DSStateSurface.error(
            title: 'Failed to parse workspace',
            subtitle: 'Unexpected token at line 42',
            compact: true,
          ),
          SizedBox(height: DSSpacing.sm),
          DSStateSurface.disabled(title: 'Feature disabled', compact: true),
          SizedBox(height: DSSpacing.sm),
          DSStateSurface.stale(title: 'Data outdated', compact: true),
          SizedBox(height: DSSpacing.sm),
          DSStateSurface.degraded(
            title: 'Partial data available',
            compact: true,
          ),
          SizedBox(height: DSSpacing.sm),
          DSStateSurface.excluded(
            title: 'Filtered out by governance',
            compact: true,
          ),
          SizedBox(height: DSSpacing.lg),

          // Shimmer
          DSText.labelLarge(
            'Shimmer (base animation)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          DSShimmer(width: 200, height: 16),
          SizedBox(height: DSSpacing.sm),
          DSShimmer(width: 48, height: 48, borderRadius: DSRadii.full),
          SizedBox(height: DSSpacing.lg),

          // Skeleton Text Line
          DSText.labelLarge(
            'Skeleton Text Line',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          DSSkeletonTextLine(widthFactor: 1.0),
          SizedBox(height: DSSpacing.xs),
          DSSkeletonTextLine(widthFactor: 0.7),
          SizedBox(height: DSSpacing.xs),
          DSSkeletonTextLine(widthFactor: 0.4),
          SizedBox(height: DSSpacing.lg),

          // Skeleton Card
          DSText.labelLarge('Skeleton Card', color: DSColors.textSecondary),
          SizedBox(height: DSSpacing.sm),
          SizedBox(width: 560, child: DSSkeletonCard()),
          SizedBox(height: DSSpacing.lg),

          // Skeleton Table Rows
          DSText.labelLarge(
            'Skeleton Table Rows (3 rows)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          DSSkeletonTableRows(rowCount: 3, columnWidths: [0.25, 0.45, 0.3]),
          SizedBox(height: DSSpacing.lg),
          DSText.labelLarge(
            'Skeleton Table Rows (5 rows)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          DSSkeletonTableRows(
            rowCount: 5,
            columnWidths: [0.15, 0.35, 0.35, 0.15],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OPERATIONAL STATES
  // ---------------------------------------------------------------------------
  /// Gallery section showcasing all 15 [DSOperationalState] values with
  /// their canonical colors, icons, status dots, and badges.
  static Widget buildOperationalStatesSection() {
    return _SectionCard(
      title: 'Operational States',
      subtitle:
          '15-state vocabulary: lifecycle · health · verification · governance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Lifecycle states ──
          const DSText.labelLarge('Lifecycle', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.sm,
            children: [
              for (final state in [
                DSOperationalState.pending,
                DSOperationalState.running,
                DSOperationalState.approved,
                DSOperationalState.rejected,
                DSOperationalState.promoted,
                DSOperationalState.archived,
              ])
                _OperationalStateTile(state: state),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // ── Health states ──
          const DSText.labelLarge('Health', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.sm,
            children: [
              for (final state in [
                DSOperationalState.healthy,
                DSOperationalState.degraded,
                DSOperationalState.error,
                DSOperationalState.disabled,
              ])
                _OperationalStateTile(state: state),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // ── Verification states ──
          const DSText.labelLarge(
            'Verification',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.sm,
            children: [
              for (final state in [
                DSOperationalState.unverified,
                DSOperationalState.exposed,
                DSOperationalState.redacted,
              ])
                _OperationalStateTile(state: state),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // ── Governance states ──
          const DSText.labelLarge('Governance', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.sm,
            children: [
              for (final state in [
                DSOperationalState.stale,
                DSOperationalState.excluded,
              ])
                _OperationalStateTile(state: state),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // ── Badge showcase ──
          const DSText.labelLarge(
            'Operational Badges',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: DSOperationalState.values
                .map((s) => DSBadge.operational(s))
                .toList(),
          ),
          const SizedBox(height: DSSpacing.lg),

          // ── Status dot showcase ──
          const DSText.labelLarge(
            'Operational Status Dots',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.sm,
            children: DSOperationalState.values
                .map((s) => DSStatusDot.operational(s))
                .toList(),
          ),
          const SizedBox(height: DSSpacing.lg),

          // ── Behavioral contract summary ──
          const DSText.labelLarge(
            'Behavioral Contracts',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const _BehavioralContractTable(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ORGANISMS
  // ---------------------------------------------------------------------------
  static Widget buildOrganismsSection() {
    return _SectionCard(
      title: 'Organisms',
      subtitle:
          'DSShell · DSSidebar · DSTopbar · DSLaneBoard · DSTimeline · '
          'DSDetailInspector · DSStoryPanel · DSGraphCanvas · DSCodeBlock · '
          'DSMarkdownRenderer · DSErrorBoundary · DSFallbackView · DSTabBar · '
          'DSSplitPane · '
          '(EPIC-15 / EPIC-16 families → dedicated registry sections)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EPIC-15 / EPIC-16 live under family registry sections
          // (Tasks 1519 + 1613) — see Section index TOC chips.
          const DSText.bodySmall(
            'EPIC-15 Map HUD / layers / intel / stage chrome / recon / ops / '
            'terminal organisms and EPIC-16 content chrome / transcript / '
            'CyberCore ops / workflow organisms are registered as dedicated '
            'gallery families below Organisms — use the Section index TOC chips.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.lg),

          // Breadcrumbs organism preview
          const DSText.labelLarge(
            'DSBreadcrumbs / PrismBreadcrumbs',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const _BreadcrumbsDemo(),
          const SizedBox(height: DSSpacing.lg),

          // Sidebar preview
          const DSText.labelLarge(
            'DSSidebar (collapsed preview)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSSidebar(
              items: [
                DSSidebarItem(
                  id: 'overview',
                  label: 'Overview',
                  icon: Icons.dashboard_outlined,
                ),
                DSSidebarItem(
                  id: 'map',
                  label: 'Map',
                  icon: Icons.hub_outlined,
                ),
                DSSidebarItem(
                  id: 'operate',
                  label: 'Operate',
                  icon: Icons.play_circle_outline,
                ),
                DSSidebarItem(
                  id: 'history',
                  label: 'History',
                  icon: Icons.history_outlined,
                ),
                DSSidebarItem(
                  id: 'governance',
                  label: 'Governance',
                  icon: Icons.shield_outlined,
                ),
              ],
              selectedId: 'map',
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSTopbar preview
          const DSText.labelLarge('DSTopbar', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const DSTopbar(
            title: 'Map Workspace',
            breadcrumbs: ['Home', 'Map', 'Agent Alpha'],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Lane board preview
          const DSText.labelLarge(
            'DSLaneBoard (sample lanes)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSLaneBoard(
              lanes: [
                DSLane(
                  id: '01-open',
                  label: 'Open',
                  tasks: [
                    DSLaneTask(
                      id: 1,
                      title: 'Align organism APIs',
                      priority: 'high',
                    ),
                    DSLaneTask(
                      id: 2,
                      title: 'Create gallery route',
                      priority: 'medium',
                    ),
                  ],
                ),
                DSLane(
                  id: '02-doing',
                  label: 'Doing',
                  tasks: [
                    DSLaneTask(
                      id: 3,
                      title: 'Build data layer',
                      priority: 'high',
                    ),
                  ],
                ),
                DSLane(id: '03-review', label: 'Review', tasks: []),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Timeline preview
          const DSText.labelLarge('DSTimeline', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSTimeline(
              entries: [
                DSTimelineEntry(
                  id: '1',
                  date: '2025-06-01',
                  title: 'Project initialized',
                  type: 'feature',
                  project: 'warp-prism',
                ),
                DSTimelineEntry(
                  id: '2',
                  date: '2025-06-03',
                  title: 'Design system tokens created',
                  type: 'feature',
                  project: 'warp-prism',
                ),
                DSTimelineEntry(
                  id: '3',
                  date: '2025-06-05',
                  title: 'Organisms aligned with templates',
                  type: 'refactor',
                  project: 'warp-prism',
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Story panel preview
          const DSText.labelLarge(
            'DSStoryPanel',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSStoryPanel(
            title: 'Workspace Health',
            subtitle: 'Current state of the design system',
            icon: Icons.insights_outlined,
            accentColor: DSColors.accentCyan,
            insights: [
              DSStoryInsight(
                text: 'All token contracts verified',
                detail: 'Colors, typography, spacing, radii, shadows, motion',
                value: '100%',
                color: DSColors.statusSuccess,
              ),
              DSStoryInsight(
                text: 'Organisms and templates aligned',
                detail: 'No compile-breaking API drift detected',
                value: 'PASS',
                color: DSColors.accentCyan,
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Graph canvas preview — empty state
          const DSText.labelLarge(
            'DSGraphCanvas (empty state)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSGraphCanvas(nodes: [], edges: []),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Graph canvas preview — force-directed layout with sample data
          const DSText.labelLarge(
            'DSGraphCanvas (force-directed layout)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSGraphCanvas(
              nodes: [
                GraphNode(id: 'agent-1', label: 'Builder', type: 'agent'),
                GraphNode(id: 'skill-1', label: 'Analyze', type: 'skill'),
                GraphNode(id: 'skill-2', label: 'Refactor', type: 'skill'),
                GraphNode(id: 'wf-1', label: 'CI/CD', type: 'workflow'),
                GraphNode(id: 'task-1', label: 'Task 1117', type: 'task'),
                GraphNode(id: 'doc-1', label: 'ADS Spec', type: 'doc'),
              ],
              edges: const [
                GraphEdge(
                  sourceId: 'agent-1',
                  targetId: 'skill-1',
                  edgeType: 'uses',
                ),
                GraphEdge(
                  sourceId: 'agent-1',
                  targetId: 'skill-2',
                  edgeType: 'uses',
                ),
                GraphEdge(
                  sourceId: 'skill-1',
                  targetId: 'wf-1',
                  edgeType: 'triggers',
                ),
                GraphEdge(
                  sourceId: 'skill-2',
                  targetId: 'task-1',
                  edgeType: 'references',
                ),
                GraphEdge(
                  sourceId: 'wf-1',
                  targetId: 'doc-1',
                  edgeType: 'references',
                ),
              ],
              enablePhysics: false,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Error Boundary
          const DSText.labelLarge(
            'DSErrorBoundary (with retry)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSErrorBoundary(
            child: DSGlassPanelSimple(
              padding: EdgeInsets.all(DSSpacing.md),
              child: DSText.bodyMedium(
                'Protected content — an error in this area will not crash the app.',
                color: DSColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          // Show a pre-crashed boundary to demonstrate the fallback view
          const _ErrorBoundaryDemo(),
          const SizedBox(height: DSSpacing.lg),

          // Command palette preview
          const DSText.labelLarge(
            'DSCommandPalette (trigger with Cmd+K)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          _CommandPalettePreview(),
          const SizedBox(height: DSSpacing.lg),

          // Log viewer preview
          const DSText.labelLarge('DSLogViewer', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSLogViewer(
              entries: [
                DSLogEntry(
                  id: 'lv-1',
                  timestamp: DateTime(2026, 6, 8, 10, 0, 1),
                  severity: DSLogSeverity.info,
                  source: 'agent-alpha',
                  message: 'Workflow execution started for task T009',
                ),
                DSLogEntry(
                  id: 'lv-2',
                  timestamp: DateTime(2026, 6, 8, 10, 0, 3),
                  severity: DSLogSeverity.debug,
                  source: 'mcp-server',
                  message: 'Tool invocation: read_file(path: lib/main.dart)',
                ),
                DSLogEntry(
                  id: 'lv-3',
                  timestamp: DateTime(2026, 6, 8, 10, 0, 5),
                  severity: DSLogSeverity.warning,
                  source: 'governance',
                  message:
                      'Stale index detected: skill/prompt-engineering has not been updated in 14 days',
                ),
                DSLogEntry(
                  id: 'lv-4',
                  timestamp: DateTime(2026, 6, 8, 10, 0, 8),
                  severity: DSLogSeverity.error,
                  source: 'agent-beta',
                  message:
                      'Failed to parse workspace manifest: unexpected token at line 42',
                  detail:
                      'FormatException: Unexpected token at line 42, column 7\n  at parseYaml (package:yaml/yaml.dart:128)\n  at WorkspaceParser.parse (lib/parser.dart:67)\n  at main (bin/main.dart:12)',
                ),
                DSLogEntry(
                  id: 'lv-5',
                  timestamp: DateTime(2026, 6, 8, 10, 0, 10),
                  severity: DSLogSeverity.critical,
                  source: 'system',
                  message:
                      'Circuit breaker open: MCP server connection pool exhausted',
                  detail:
                      'StateError: No healthy connections available\nConnection pool: max=10, active=10, degraded=3\nRetry after: 30s',
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSTabBar preview
          const DSText.labelLarge(
            'DSTabBar (3 closeable tabs with badges)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          _TabBarDemo(),
          const SizedBox(height: DSSpacing.lg),

          // DSTabBar overflow preview
          const DSText.labelLarge(
            'DSTabBar (10 tabs — scrollable overflow)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          _TabBarOverflowDemo(),
          const SizedBox(height: DSSpacing.lg),

          // DSSplitPane horizontal preview
          const DSText.labelLarge(
            'DSSplitPane (horizontal, draggable)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: _SplitPaneDemo(axis: Axis.horizontal),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSSplitPane vertical preview
          const DSText.labelLarge(
            'DSSplitPane (vertical, draggable)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: _SplitPaneDemo(axis: Axis.vertical),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSCodeBlock — JSON config
          const DSText.labelLarge(
            'DSCodeBlock (JSON config)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSCodeBlock(
            source:
                '{\n'
                '  "name": "warp-prism",\n'
                '  "version": "0.1.0",\n'
                '  "dependencies": {\n'
                '    "flutter": ">=3.12.0"\n'
                '  },\n'
                '  "publish_to": "none"\n'
                '}',
            language: 'json',
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSCodeBlock — YAML skill config
          const DSText.labelLarge(
            'DSCodeBlock (YAML skill config)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSCodeBlock(
            source:
                'name: analyze-workspace\n'
                'description: >\n'
                '  Parses the workspace manifest and indexes\n'
                '  all agents, skills, and workflows.\n'
                'version: 1.2.0\n'
                'triggers:\n'
                '  - file_change: "workspace.yaml"\n'
                '  - manual: true\n'
                'timeout: 30s',
            language: 'yaml',
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSCodeBlock — Dart snippet
          const DSText.labelLarge(
            'DSCodeBlock (Dart snippet)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSCodeBlock(
            source:
                "import 'package:flutter/material.dart';\n"
                '\n'
                'class AgentWidget extends StatelessWidget {\n'
                '  final String name;\n'
                '  const AgentWidget({super.key, required this.name});\n'
                '\n'
                '  @override\n'
                '  Widget build(BuildContext context) {\n'
                '    return Text(name);\n'
                '  }\n'
                '}',
            language: 'dart',
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSCodeBlock — unknown language fallback
          const DSText.labelLarge(
            'DSCodeBlock (auto-detect fallback)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSCodeBlock(
            source:
                '# Just a plain text block\n'
                'with no special language hints\n'
                'so it renders as plain text.',
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSCodeBlock — without line numbers
          const DSText.labelLarge(
            'DSCodeBlock (no line numbers)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSCodeBlock(
            source: '{ "status": "ok", "count": 42 }',
            language: 'json',
            showLineNumbers: false,
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSMarkdownRenderer — task description
          const DSText.labelLarge(
            'DSMarkdownRenderer (task description)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSGlassPanelSimple(
            padding: EdgeInsets.all(DSSpacing.lg),
            child: DSMarkdownRenderer(
              data:
                  '## Task 1121: Code Block And Markdown Renderer\n'
                  '\n'
                  '**Objective**: Implement reusable DS organisms for syntax-highlighted '
                  'code display and inline markdown rendering.\n'
                  '\n'
                  '### Subtasks\n'
                  '\n'
                  '- Evaluate candidate packages\n'
                  '- Implement `DSCodeBlock` with language detection\n'
                  '- Implement `DSMarkdownRenderer` with block types\n'
                  '- Add gallery entries and widget tests\n'
                  '\n'
                  '> These components enable CyberCore to display agent profiles, '
                  'skill definitions, and MCP server configs.\n'
                  '\n'
                  'See [Task 1105](docs/tasks/1105) for token policy.',
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSMarkdownRenderer — agent profile
          const DSText.labelLarge(
            'DSMarkdownRenderer (agent profile)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSGlassPanelSimple(
            padding: EdgeInsets.all(DSSpacing.lg),
            child: DSMarkdownRenderer(
              data:
                  '# Agent Alpha\n'
                  '\n'
                  '**Role**: Workspace Builder\n'
                  '**Status**: Active\n'
                  '\n'
                  'Agent Alpha is responsible for *scaffolding*, *analyzing*, and '
                  '`refactoring` workspace assets.\n'
                  '\n'
                  '## Capabilities\n'
                  '\n'
                  '1. Parse workspace manifests\n'
                  '2. Generate design system components\n'
                  '3. Validate governance rules\n'
                  '\n'
                  '```json\n'
                  '{\n'
                  '  "agent": "alpha",\n'
                  '  "version": "2.1.0",\n'
                  '  "skills": ["analyze", "build", "validate"]\n'
                  '}\n'
                  '```',
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DRAG AND DROP
  // ---------------------------------------------------------------------------
  /// Drag-and-drop interactivity — demonstrates DSDraggableCard and
  /// DSDropTarget within DSLaneBoard.  Shows: cross-lane drag, empty
  /// lane drop target, and insertion indicator.
  static Widget buildDragAndDropSection() {
    return const _SectionCard(
      title: 'Drag & Drop Task Board',
      subtitle:
          'DSDraggableCard · DSDropTarget · reorder · move · visual feedback',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSText.bodySmall(
            'Long-press a card to drag it. Drop on another lane to move. '
            'Drop within the same lane to reorder. The cyan line shows insertion position.',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.lg),

          // Interactive board: 3 lanes, one empty
          DSText.labelLarge(
            'Interactive Board (long-press to drag)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 800, child: _DragDropDemo()),
          SizedBox(height: DSSpacing.lg),

          // Visual feedback documentation
          DSGlassPanelSimple(
            padding: EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelLarge(
                  'Visual Feedback',
                  color: DSColors.accentCyan,
                ),
                SizedBox(height: DSSpacing.xs),
                DSText.bodySmall(
                  '• Drag origin: card renders at 20% opacity (ghost placeholder)\n'
                  '• Drag feedback: card under pointer at 80% opacity + cyan glow\n'
                  '• Drop zone: border animates to accentCyan at 30% opacity when hovered\n'
                  '• Insertion indicator: 2px cyan line at the computed drop index\n'
                  '• Long-press delay: 200ms (DSMotion.normal) to avoid tap conflict',
                  color: DSColors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACCESSIBILITY & FOCUS STATES
  // ---------------------------------------------------------------------------
  /// Accessibility baseline — demonstrates focus indicators, keyboard
  /// activation, and semantic labels across interactive DS components.
  static Widget buildAccessibilitySection() {
    return _SectionCard(
      title: 'Accessibility & Focus States',
      subtitle:
          'Keyboard focus rings · Enter/Space activation · Semantic labels · WCAG contrast',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Focus ring demonstration
          const DSText.labelLarge(
            'Focus Ring Pattern',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'All interactive DS components use a 2px accentCyan border at 50% opacity '
            'when focused via keyboard.  This is the project-wide focus indicator.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.md),

          // Focusable chips — keyboard demo
          const DSText.labelLarge(
            'Focusable Chips (Tab + Enter/Space)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: [
              DSChip(label: 'Agent', color: DSColors.assetAgent, onTap: () {}),
              DSChip(
                label: 'Skill',
                color: DSColors.assetSkill,
                selected: true,
                onTap: () {},
              ),
              DSChip(
                label: 'Workflow',
                color: DSColors.assetWorkflow,
                onTap: () {},
              ),
              const DSChip(label: 'Disabled', enabled: false),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Focusable filter chip group
          const DSText.labelLarge(
            'Focusable Filter Chips',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSFilterChipGroup(
            options: [
              DSFilterOption(value: 'agent', label: 'Agent', count: 5),
              DSFilterOption(value: 'skill', label: 'Skill', count: 12),
              DSFilterOption(value: 'workflow', label: 'Workflow', count: 3),
            ],
            selected: {'skill'},
          ),
          const SizedBox(height: DSSpacing.lg),

          // Sidebar focus states
          const DSText.labelLarge(
            'Sidebar Navigation (focusable items)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSSidebar(
              items: [
                DSSidebarItem(
                  id: 'overview',
                  label: 'Overview',
                  icon: Icons.dashboard_outlined,
                ),
                DSSidebarItem(
                  id: 'map',
                  label: 'Map',
                  icon: Icons.hub_outlined,
                ),
                DSSidebarItem(
                  id: 'operate',
                  label: 'Operate',
                  icon: Icons.play_circle_outline,
                ),
              ],
              selectedId: 'map',
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Topbar actions focus
          const DSText.labelLarge(
            'Topbar Actions (focusable buttons)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Row(
            children: [
              DSTopbarAction(
                icon: Icons.notifications_outlined,
                tooltip: 'Notifications',
                onTap: () {},
              ),
              const SizedBox(width: DSSpacing.xs),
              DSTopbarAction(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Semantic status colors
          const DSText.labelLarge(
            'Semantic Status Colors (WCAG AA)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.sm,
            children: [
              _StatusSample('Success', DSColors.statusSuccess),
              _StatusSample('Warning', DSColors.statusWarning),
              _StatusSample('Error', DSColors.statusError),
              _StatusSample('Info', DSColors.statusInfo),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // Contrast documentation
          const DSGlassPanelSimple(
            padding: EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelLarge('Contrast Rules', color: DSColors.accentCyan),
                SizedBox(height: DSSpacing.xs),
                DSText.bodySmall(
                  '• textPrimary on obsidianDeep: WCAG AAA (>= 7:1)\n'
                  '• textSecondary on obsidianDeep: WCAG AA  (>= 4.5:1)\n'
                  '• textTertiary on obsidianDeep: WCAG AA  (>= 4.5:1)\n'
                  '• Status colors on obsidianDeep: WCAG AA large (>= 3:1)\n'
                  '• Focus ring: accentCyan at 50% opacity, 2px border\n'
                  '• Keyboard: Tab traverses, Enter/Space activates',
                  color: DSColors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEMPLATES
  // ---------------------------------------------------------------------------
  /// Toast notification variants — severity levels, action button, and
  /// stacking behavior. Demonstrates [DSToast] and [DSToastManager] contracts.
  static Widget buildToastsSection() {
    return _SectionCard(
      title: 'Toasts',
      subtitle: 'DSToast · DSToastSeverity · DSToastEntry · DSToastManager',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Severity variants (static render — no overlay needed)
          const DSText.labelLarge(
            'Severity Variants',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildSeverityRow(),
          const SizedBox(height: DSSpacing.lg),

          // Toast with action button
          const DSText.labelLarge(
            'With Action Button',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSToast(
            entry: DSToastEntry(
              id: 'gallery-action',
              severity: DSToastSeverity.warning,
              title: 'Stale proofs detected',
              message: '3 tasks have proofs older than 7 days',
              actionLabel: 'Review',
              duration: Duration.zero,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Toast with long message
          const DSText.labelLarge(
            'Long Message',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSToast(
            entry: DSToastEntry(
              id: 'gallery-long',
              severity: DSToastSeverity.info,
              title: 'Workspace sync complete',
              message:
                  'Parsed 47 assets, 12 workflows, 89 tasks, and 156 changelog '
                  'entries. All graph edges normalized.',
              duration: Duration.zero,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Stacking preview (static column showing 3 toasts)
          const DSText.labelLarge(
            'Stacking Preview (3 toasts)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DSToast(
                entry: DSToastEntry(
                  id: 'stack-1',
                  severity: DSToastSeverity.error,
                  title: 'Parse failed',
                  message: 'Malformed YAML in skill definition',
                  duration: Duration.zero,
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              DSToast(
                entry: DSToastEntry(
                  id: 'stack-2',
                  severity: DSToastSeverity.warning,
                  title: 'Orphan skills found',
                  message: '2 skills are not referenced by any workflow',
                  actionLabel: 'View',
                  duration: Duration.zero,
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              DSToast(
                entry: DSToastEntry(
                  id: 'stack-3',
                  severity: DSToastSeverity.success,
                  title: 'Graph edges normalized',
                  duration: Duration.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Auto-dismiss note
          const DSText.labelLarge(
            'Auto-Dismiss',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'Toasts auto-dismiss after a configurable duration (default 4s). '
            'Hover pauses the timer. Use DSToastManager.of(context).show(entry) '
            'to display toasts with auto-dismiss and overlay stacking.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.lg),

          // Risk toast variant (Task 1522 / O-28) — same manager, risk chrome.
          const DSText.labelLarge(
            'Risk Variant (DSToastEntry.risk · single manager)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.xs),
          const DSText.labelSmall(
            'Maps DSToastRiskTier → operational/risk colors; not a second stack',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSToast(
            entry: DSToastEntry.risk(
              id: 'gallery-risk-high',
              riskTier: DSToastRiskTier.high,
              riskRegion: 'Sector-7',
              title: 'Perimeter breach score elevated',
              message: 'Fixture geo risk — review watchlist pins',
              actionLabel: 'Locate',
              duration: Duration.zero,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          DSToast(
            entry: DSToastEntry.risk(
              id: 'gallery-risk-moderate',
              riskTier: DSToastRiskTier.moderate,
              riskRegion: 'Bay corridor',
              title: 'Stale feed risk',
              message: 'Telemetry lag exceeds governance window',
              duration: Duration.zero,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSeverityRow() {
    final severities = [
      DSToastEntry(
        id: 'gallery-info',
        severity: DSToastSeverity.info,
        title: 'Workspace parsing',
        message: 'Loading mock workspace assets...',
        duration: Duration.zero,
      ),
      DSToastEntry(
        id: 'gallery-success',
        severity: DSToastSeverity.success,
        title: 'Task completed',
        message: 'All proofs verified',
        duration: Duration.zero,
      ),
      DSToastEntry(
        id: 'gallery-warning',
        severity: DSToastSeverity.warning,
        title: 'Missing dependency',
        message: 'Task 0512 references unresolved graph layout',
        duration: Duration.zero,
      ),
      DSToastEntry(
        id: 'gallery-error',
        severity: DSToastSeverity.error,
        title: 'Parse error',
        message: 'Unexpected token in YAML frontmatter',
        duration: Duration.zero,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: severities
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: DSToast(entry: e),
            ),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // DATA TABLE
  // ---------------------------------------------------------------------------
  /// Data table catalog — demonstrates sort, pagination, cell renderers,
  /// operational states, selection, empty/loading/error states.
  static Widget buildDataTableSection() {
    return _SectionCard(
      title: 'DSDataTable',
      subtitle:
          'Sortable · Paginated · Cell Renderers · Operational States · Virtual Scroll',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sortable table with operational state cells
          const DSText.labelLarge(
            'Sortable Table with Status Cells',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSDataTable(
              columns: [
                DSDataColumn(id: 'id', label: 'ID', width: 60),
                DSDataColumn(id: 'name', label: 'Name', sortable: true),
                DSDataColumn(
                  id: 'status',
                  label: 'Status',
                  sortable: true,
                  cellRenderer: _galleryStatusCell,
                ),
                DSDataColumn(id: 'type', label: 'Type'),
              ],
              rows: [
                DSDataRow(
                  id: '1',
                  cells: {
                    'id': '001',
                    'name': 'Agent Alpha',
                    'status': DSOperationalState.running,
                    'type': 'Agent',
                  },
                ),
                DSDataRow(
                  id: '2',
                  cells: {
                    'id': '002',
                    'name': 'Skill Parser',
                    'status': DSOperationalState.healthy,
                    'type': 'Skill',
                  },
                ),
                DSDataRow(
                  id: '3',
                  cells: {
                    'id': '003',
                    'name': 'Build Workflow',
                    'status': DSOperationalState.degraded,
                    'type': 'Workflow',
                  },
                ),
                DSDataRow(
                  id: '4',
                  cells: {
                    'id': '004',
                    'name': 'Deploy Pipeline',
                    'status': DSOperationalState.error,
                    'type': 'Workflow',
                  },
                ),
                DSDataRow(
                  id: '5',
                  cells: {
                    'id': '005',
                    'name': 'Auth Rule',
                    'status': DSOperationalState.stale,
                    'type': 'Rule',
                  },
                ),
              ],
              paginated: false,
              showPagination: false,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Paginated table
          const DSText.labelLarge(
            'Paginated Table',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSDataTable(
              columns: const [
                DSDataColumn(id: 'name', label: 'Name', sortable: true),
                DSDataColumn(id: 'role', label: 'Role'),
                DSDataColumn(id: 'status', label: 'Status', sortable: true),
              ],
              rows: List.generate(
                50,
                (i) => DSDataRow(
                  id: '$i',
                  cells: {
                    'name':
                        'Entity ${String.fromCharCode(65 + (i % 26))}${i ~/ 26}',
                    'role': ['Agent', 'Skill', 'Workflow', 'Tool'][i % 4],
                    'status': DSOperationalState
                        .values[i % DSOperationalState.values.length]
                        .label,
                  },
                ),
              ),
              currentPage: 0,
              pageSize: 10,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Empty state
          const DSText.labelLarge('Empty State', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSDataTable(
              columns: [
                DSDataColumn(id: 'name', label: 'Name'),
                DSDataColumn(id: 'value', label: 'Value'),
              ],
              rows: [],
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Loading state
          const DSText.labelLarge(
            'Loading State',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSDataTable(
              columns: [
                DSDataColumn(id: 'name', label: 'Name'),
                DSDataColumn(id: 'value', label: 'Value'),
              ],
              loading: true,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Error state
          const DSText.labelLarge('Error State', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSDataTable(
              columns: [
                DSDataColumn(id: 'name', label: 'Name'),
                DSDataColumn(id: 'value', label: 'Value'),
              ],
              errorMessage: 'Connection timed out after 30s',
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Operational state vocabulary
          const DSText.labelLarge(
            'Operational State Vocabulary',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: DSOperationalState.values.map((state) {
              return DSStatusCell(state: state);
            }).toList(),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Secret cell
          const DSText.labelLarge('Secret Cell', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const DSSecretCell(
            maskedValue: '••••••••••••abc1',
            // Demo-only placeholder — deliberately non-secret-shaped (no sk- prefix).
            fullValue: 'demo-secret-value-abc1',
          ),
          const SizedBox(height: DSSpacing.lg),

          // Actions cell
          const DSText.labelLarge(
            'Actions Cell',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSActionsCell(
            actions: [
              DSActionItem(icon: DSIcons.edit, tooltip: 'Edit', onTap: () {}),
              DSActionItem(icon: DSIcons.copy, tooltip: 'Copy', onTap: () {}),
              DSActionItem(
                icon: DSIcons.delete,
                tooltip: 'Delete',
                onTap: () {},
                color: DSColors.statusError,
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Selectable table
          const DSText.labelLarge(
            'Selectable Table',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 800,
            child: DSDataTable(
              columns: [
                DSDataColumn(id: 'name', label: 'Name'),
                DSDataColumn(id: 'kind', label: 'Kind'),
              ],
              rows: [
                DSDataRow(
                  id: 's1',
                  cells: {'name': 'Agent Alpha', 'kind': 'Agent'},
                ),
                DSDataRow(
                  id: 's2',
                  cells: {'name': 'Parser Skill', 'kind': 'Skill'},
                ),
                DSDataRow(
                  id: 's3',
                  cells: {'name': 'Build Flow', 'kind': 'Workflow'},
                ),
              ],
              selectable: true,
              paginated: false,
              showPagination: false,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Filter toolbar composition (SearchBar + FilterChipGroup)
          const DSText.labelLarge(
            'Filter Toolbar Integration',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.xs),
          const DSText.bodySmall(
            'DSDataTable.toolbar composes DSSearchBar + DSFilterChipGroup. '
            'Parent owns filter state and passes filtered rows.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSDataTable(
              columns: const [
                DSDataColumn(id: 'name', label: 'Name', sortable: true),
                DSDataColumn(id: 'kind', label: 'Kind'),
                DSDataColumn(id: 'status', label: 'Status'),
              ],
              rows: const [
                DSDataRow(
                  id: 'f1',
                  cells: {
                    'name': 'Agent Alpha',
                    'kind': 'Agent',
                    'status': 'Running',
                  },
                ),
                DSDataRow(
                  id: 'f2',
                  cells: {
                    'name': 'Parser Skill',
                    'kind': 'Skill',
                    'status': 'Healthy',
                  },
                ),
                DSDataRow(
                  id: 'f3',
                  cells: {
                    'name': 'Build Flow',
                    'kind': 'Workflow',
                    'status': 'Pending',
                  },
                ),
              ],
              paginated: false,
              showPagination: false,
              toolbar: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DSSearchBar(
                    placeholder: 'Search registry…',
                    showFilter: false,
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  DSFilterChipGroup(
                    options: const [
                      DSFilterOption(value: 'all', label: 'All'),
                      DSFilterOption(value: 'agent', label: 'Agents'),
                      DSFilterOption(value: 'skill', label: 'Skills'),
                      DSFilterOption(value: 'workflow', label: 'Workflows'),
                    ],
                    selected: const {'all'},
                    onToggle: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Status cell renderer for gallery examples.
  static Widget _galleryStatusCell(
    BuildContext context,
    dynamic value,
    int rowIndex,
  ) {
    if (value is DSOperationalState) {
      return DSStatusCell(state: value);
    }
    return DSText.bodySmall(
      value?.toString() ?? '',
      color: DSColors.textTertiary,
    );
  }

  // ---------------------------------------------------------------------------
  // VIRTUAL SCROLL
  // ---------------------------------------------------------------------------
  /// Virtual scroll catalog — demonstrates DSVirtualList and DSVirtualGrid
  /// at 1K, 5K, and 10K item scales with fixed and variable extent.
  static Widget buildVirtualScrollSection() {
    return _SectionCard(
      title: 'Virtual Scroll',
      subtitle:
          'DSVirtualList · DSVirtualGrid · 10K+ viewport-virtualized items',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DSVirtualList — 1K fixed-height items
          const DSText.labelLarge(
            'DSVirtualList — 1,000 fixed-height items',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'Fixed 48px extent with O(1) scroll offset computation. '
            'Scroll to verify smooth rendering.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSVirtualList(
              itemCount: 1000,
              config: DSVirtualScrollConfig.fixed,
              semanticLabel: '1,000 fixed-height items',
              itemBuilder: (context, index) {
                return Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: DSColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const DSIcon.small(
                        DSIcons.task,
                        color: DSColors.accentCyan,
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      DSText.bodyMedium(
                        'MCP Server ${String.fromCharCode(65 + (index % 26))}${index ~/ 26}',
                        color: DSColors.textPrimary,
                      ),
                      const Spacer(),
                      DSText.labelSmall(
                        'Item $index',
                        color: DSColors.textTertiary,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSVirtualList — 5K variable-height items
          const DSText.labelLarge(
            'DSVirtualList — 5,000 variable-height items',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'No itemExtent — falls back to standard variable-height layout. '
            'Still virtualized (only visible + cached items are built).',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSVirtualList(
              itemCount: 5000,
              config: DSVirtualScrollConfig.variable,
              semanticLabel: '5,000 variable-height items',
              itemBuilder: (context, index) {
                // Alternate between 1-line and 2-line items.
                final hasSubtitle = index % 3 == 0;
                return ListTile(
                  dense: true,
                  leading: const DSIcon.small(
                    DSIcons.agent,
                    color: DSColors.assetAgent,
                  ),
                  title: DSText.bodyMedium(
                    'Agent ${String.fromCharCode(65 + (index % 26))}${index ~/ 26}',
                    color: DSColors.textPrimary,
                  ),
                  subtitle: hasSubtitle
                      ? DSText.bodySmall(
                          'Variable height item at index $index',
                          color: DSColors.textTertiary,
                        )
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSVirtualList — 10K fixed-height items with item count indicator
          const DSText.labelLarge(
            'DSVirtualList — 10,000 fixed-height items',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'High-cache config (500px cache, keep-alives off) for fast '
            'scrollbar drags. Only the visible window + cache is built '
            '(not a claimed 16ms/60fps harness proof).',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSVirtualList(
              itemCount: 10000,
              config: DSVirtualScrollConfig.highCache,
              semanticLabel: '10,000 fixed-height items',
              itemBuilder: (context, index) {
                return Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: DSColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      DSIcon.small(
                        DSIcons.task,
                        color: index % 7 == 0
                            ? DSColors.statusWarning
                            : DSColors.accentCyan,
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      Expanded(
                        child: DSText.bodyMedium(
                          'Audit Log Entry #${index + 1}',
                          color: DSColors.textPrimary,
                        ),
                      ),
                      DSText(
                        '2026-06-${(index % 28 + 1).toString().padLeft(2, '0')}',
                        variant: DSTextVariant.numericSmall,
                        color: DSColors.textTertiary,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSVirtualGrid — 1K items
          const DSText.labelLarge(
            'DSVirtualGrid — 1,000 items (4 columns)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSVirtualGrid(
              itemCount: 1000,
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              semanticLabel: '1,000 grid items',
              itemBuilder: (context, index) {
                return DSGlassPanelSimple(
                  padding: const EdgeInsets.all(DSSpacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const DSIcon(
                        DSIcons.agent,
                        color: DSColors.accentCyan,
                        size: 24,
                      ),
                      const SizedBox(height: DSSpacing.xs),
                      DSText.labelSmall(
                        'Card $index',
                        color: DSColors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSVirtualGrid — 5K items
          const DSText.labelLarge(
            'DSVirtualGrid — 5,000 items (3 columns)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSVirtualGrid(
              itemCount: 5000,
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              semanticLabel: '5,000 grid items',
              itemBuilder: (context, index) {
                return DSGlassPanelSimple(
                  padding: const EdgeInsets.all(DSSpacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const DSIcon(
                        DSIcons.graph,
                        color: DSColors.accentViolet,
                        size: 20,
                      ),
                      const SizedBox(height: DSSpacing.xs),
                      DSText.labelSmall(
                        'Dashboard Tile $index',
                        color: DSColors.textPrimary,
                      ),
                      DSText.labelSmall(
                        '${(index * 7) % 100}%',
                        color: DSColors.accentCyan,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Integration note: DSVirtualList + DSDataTable
          const DSText.labelLarge(
            'DSDataTable + DSVirtualList integration',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'DSDataTable accepts a virtualScrollConfig parameter. When provided '
            'and paginated=false, the table body renders using DSVirtualList '
            'with explicit itemExtent for O(1) scroll offset computation. '
            'This is the recommended configuration for tables with 1K+ rows.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 800,
            child: DSDataTable(
              columns: const [
                DSDataColumn(id: 'id', label: 'ID', width: 60),
                DSDataColumn(id: 'name', label: 'Name', sortable: true),
                DSDataColumn(id: 'type', label: 'Type'),
                DSDataColumn(id: 'rows', label: 'Rows'),
              ],
              rows: List.generate(
                1000,
                (i) => DSDataRow(
                  id: '$i',
                  cells: {
                    'id': '${i + 1}',
                    'name':
                        'MCP Server ${String.fromCharCode(65 + (i % 26))}${i ~/ 26}',
                    'type': ['Tool', 'Resource', 'Prompt'][i % 3],
                    'rows': '${(i * 13) % 5000}',
                  },
                ),
              ),
              paginated: false,
              showPagination: false,
              virtualScrollConfig: const DSVirtualScrollConfig(
                itemExtent: 48.0,
                cacheExtent: 250.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEALTH DASHBOARD
  // ---------------------------------------------------------------------------
  /// Health dashboard components — health cards, uptime bars, sparklines,
  /// and the responsive status grid. Demonstrates the complete health
  /// monitoring surface for CyberCore system dashboards.
  static Widget buildHealthDashboardSection() {
    return _SectionCard(
      title: 'Health Dashboard',
      subtitle: 'DSHealthCard · DSUptimeBar · DSSparkline · DSStatusGrid',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DSSparkline variants
          const DSText.labelLarge(
            'DSSparkline — 20 data points',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 40,
            child: DSSparkline(
              data: List.generate(
                20,
                (i) => 50 + 30 * (i % 3 == 0 ? 1 : -0.5) + i * 1.5,
              ),
              color: DSColors.accentCyan,
              semanticLabel: 'Demo sparkline: 20 data points',
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          const DSText.labelLarge(
            'DSSparkline — 100 data points (with dots)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 40,
            child: DSSparkline(
              data: List.generate(
                100,
                (i) => 50 + 20 * (0.5 - (i - 50).abs() / 50) + (i % 7) * 2.0,
              ),
              color: DSColors.accentViolet,
              showDots: false,
              semanticLabel: 'Demo sparkline: 100 data points',
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          const DSText.labelLarge(
            'DSSparkline — empty data',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 32,
            child: DSSparkline(
              data: [],
              semanticLabel: 'Demo sparkline: no data',
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSUptimeBar at various thresholds
          const DSText.labelLarge(
            'DSUptimeBar — threshold coloring',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(height: 24, child: DSUptimeBar(uptimePercent: 0.995)),
          const SizedBox(height: DSSpacing.sm),
          const DSText.labelSmall(
            '99.5% — green (>99%)',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.md),
          const SizedBox(height: 24, child: DSUptimeBar(uptimePercent: 0.97)),
          const SizedBox(height: DSSpacing.sm),
          const DSText.labelSmall(
            '97% — amber (>95%)',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.md),
          const SizedBox(height: 24, child: DSUptimeBar(uptimePercent: 0.80)),
          const SizedBox(height: DSSpacing.sm),
          const DSText.labelSmall(
            '80% — red (<=95%)',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSHealthCard examples
          const DSText.labelLarge(
            'DSHealthCard — various states',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.md,
            children: [
              SizedBox(
                width: 260,
                child: DSHealthCard(
                  serviceName: 'MCP Server Alpha',
                  operationalState: DSOperationalState.healthy,
                  latency: const Duration(milliseconds: 42),
                  uptimePercent: 0.9995,
                  trendData: List.generate(20, (i) => 30 + (i % 5) * 8.0),
                  lastCheck: DateTime.now().subtract(
                    const Duration(minutes: 2),
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                child: DSHealthCard(
                  serviceName: 'Agent Parser',
                  operationalState: DSOperationalState.degraded,
                  latency: const Duration(milliseconds: 230),
                  uptimePercent: 0.97,
                  trendData: List.generate(
                    20,
                    (i) => 80 + (i > 10 ? 40 : 0) + (i % 3) * 5.0,
                  ),
                  lastCheck: DateTime.now().subtract(
                    const Duration(minutes: 15),
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                child: DSHealthCard(
                  serviceName: 'Build Pipeline',
                  operationalState: DSOperationalState.error,
                  latency: const Duration(seconds: 5),
                  uptimePercent: 0.82,
                  lastCheck: DateTime.now().subtract(const Duration(hours: 1)),
                ),
              ),
              const SizedBox(
                width: 260,
                child: DSHealthCard(
                  serviceName: 'Auth Service',
                  operationalState: DSOperationalState.disabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSStatusGrid — 12 mock services with interactive filter demo.
          // Embed mode: gallery page is the outer scroll surface.
          // Primary-surface dashboards use embedInScrollView:false (default)
          // so GridView.builder owns lazy scroll for 50+ services.
          const DSText.labelLarge(
            'DSStatusGrid / PrismStatusGrid — 12 mock services + filter',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.labelSmall(
            'Tap filter chips to toggle states. Gallery uses embedInScrollView; '
            'production health screens keep the default primary scrollable grid.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const _HealthStatusGridDemo(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EPIC-15 family sections (Task 1519) — Map HUD / OSINT / terminal discoverability
  // ---------------------------------------------------------------------------

  /// EPIC-15 family — Map HUD Layout (Task 1519).
  static Widget buildEpic15HudSection() {
    return const _SectionCard(
      title: 'Map HUD Layout',
      subtitle: 'PrismMapHudWorkspace · PrismToolStripSlideout',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PrismMapHudWorkspace / DSMapHudWorkspace (Task 1501)
          DSText.labelLarge(
            'PrismMapHudWorkspace (stage + multi-region HUD)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 480, child: _MapHudWorkspaceDemo()),
          SizedBox(height: DSSpacing.lg),

          // PrismToolStripSlideout / DSToolStripSlideout (Task 1502)
          DSText.labelLarge(
            'PrismToolStripSlideout (exclusive icon strip + slideout)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 360, child: _ToolStripSlideoutDemo()),
          SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  /// EPIC-15 family — Layers & Filters (Task 1519).
  static Widget buildEpic15LayersFiltersSection() {
    return const _SectionCard(
      title: 'Layers & Filters',
      subtitle: 'PrismLayerControlPanel · PrismFilterWorkbench',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PrismLayerControlPanel / DSLayerControlPanel (Task 1503)
          DSText.labelLarge(
            'PrismLayerControlPanel (groups · counts · freshness · master)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 420, width: 320, child: _LayerControlPanelDemo()),
          SizedBox(height: DSSpacing.lg),

          // PrismFilterWorkbench / DSFilterWorkbench (Task 1504)
          DSText.labelLarge(
            'PrismFilterWorkbench (sections · apply/clear · advanced)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          // Taller/wider demo host so header + sticky footer + glass padding remain
          // within bounds at 2.0 text scale (catalog high-text-scale overflow proof).
          SizedBox(height: 720, width: 480, child: _FilterWorkbenchDemo()),
          SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  /// EPIC-15 family — Intel & Locate (Task 1519).
  static Widget buildEpic15IntelSection() {
    return const _SectionCard(
      title: 'Intel & Locate',
      subtitle: 'PrismEntityIntelPanel · PrismEntityLocateSearch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PrismEntityIntelPanel / DSEntityIntelPanel (Task 1505)
          DSText.labelLarge(
            'PrismEntityIntelPanel (dossier registry · multi-type)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 480, width: 360, child: _EntityIntelPanelDemo()),
          SizedBox(height: DSSpacing.lg),

          // PrismEntityLocateSearch / DSEntityLocateSearch (Task 1506)
          DSText.labelLarge(
            'PrismEntityLocateSearch (multi-corpus locate ≠ command palette)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 420, width: 420, child: _EntityLocateSearchDemo()),
          SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  /// EPIC-15 family — Time, Status & Stage Chrome (Task 1519).
  static Widget buildEpic15StageChromeSection() {
    return const _SectionCard(
      title: 'Time, Status & Stage Chrome',
      subtitle:
          'PrismTimeMachineScrubber · PrismStatusTicker · PrismWatchlistDock · PrismCoordinateStatusBar · PrismMapLegend',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PrismTimeMachineScrubber / DSTimeMachineScrubber (Task 1507)
          // Density + playback — distinct from PrismTimeline event list.
          DSText.labelLarge(
            'PrismTimeMachineScrubber (density · playhead · transport)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'Temporal control surface — pair with PrismTimeline for event lists',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 180, width: 640, child: _TimeMachineScrubberDemo()),
          SizedBox(height: DSSpacing.lg),

          // PrismStatusTicker / DSStatusTicker (Task 1508)
          // Rotating + marquee fixture feed strip — not StatusGrid / toast.
          DSText.labelLarge(
            'PrismStatusTicker (rotate · marquee · severity)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'Continuous status chrome — reduced motion shows static strip',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 120, width: 640, child: _StatusTickerDemo()),
          SizedBox(height: DSSpacing.lg),

          // Stage chrome pack (Task 1509) — Watchlist + Coord bar + Map legend
          // Stand-alone demos; composition into MapHudWorkspace is optional soft-dep.
          DSText.labelLarge(
            'Stage chrome pack (Watchlist · Coord bar · Map legend)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'EPIC-15 O-11 / O-12 / O-13 — fixture-only stage chrome',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 520, width: 720, child: _StageChromePackDemo()),
          SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  /// EPIC-15 family — CyberCore Recon & AI (Task 1519).
  static Widget buildEpic15CyberCoreReconSection() {
    return const _SectionCard(
      title: 'CyberCore Recon & AI',
      subtitle: 'PrismOsintWorkbench · PrismAiAnalystPanel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PrismOsintWorkbench / DSOsintWorkbench (Task 1510 / O-08)
          // Tabbed recon: tools + query + history + results + map handoff.
          // Fixture-only — no live OSINT APIs / API keys / MapLibre.
          DSText.labelLarge(
            'PrismOsintWorkbench (tabs · query · history · map handoff)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'Fixture recon only — no live OSINT APIs, keys, or MapLibre; '
            'mode contract (not OsintPanel megafile structure)',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 520, width: 640, child: _OsintWorkbenchDemo()),
          SizedBox(height: DSSpacing.lg),

          // PrismAiAnalystPanel / DSAiAnalystPanel (Task 1511 / O-15)
          // Fixture-first chat/intel — no live model keys or network.
          DSText.labelLarge(
            'PrismAiAnalystPanel (fixture chat · scripted replies)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'Fixture-only policy — no live Gemini/keys; composer uses scripted adapter',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 520, width: 420, child: _AiAnalystPanelDemo()),
          SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  /// EPIC-15 family — Stage & Relations (Task 1519).
  static Widget buildEpic15StageRelationsSection() {
    return _SectionCard(
      title: 'Stage & Relations',
      subtitle: 'PrismMapCanvasStage · PrismEntityRelationCard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PrismMapCanvasStage / DSMapCanvasStage (Task 1512 / O-17)
          // Contract only: layer registry · selection bus · popup factory.
          // Placeholder canvas — NOT MapLibre / react-map-gl.
          const DSText.labelLarge(
            'PrismMapCanvasStage (layer registry · selection · popup)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.xs),
          const DSText.labelSmall(
            'Contract + fake stage only — no MapLibre engine; tap markers for selection/popup',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(height: 420, width: 720, child: _MapCanvasStageDemo()),
          const SizedBox(height: DSSpacing.lg),

          // PrismEntityRelationCard — task relations
          const DSText.labelLarge(
            'PrismEntityRelationCard',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            width: 560,
            child: DSEntityRelationCard(
              title: 'Agent Alpha Relations',
              subtitle: 'Agent connections in workspace-root',
              type: 'agent',
              nodes: [
                GraphNode(
                  id: 'agent-alpha',
                  label: 'Agent Alpha',
                  type: 'agent',
                ),
                GraphNode(
                  id: 'skill-analyze',
                  label: 'Analyze Workspace',
                  type: 'skill',
                ),
                GraphNode(
                  id: 'skill-build',
                  label: 'Build Component',
                  type: 'skill',
                ),
                GraphNode(id: 'task-1513', label: 'Task 1513', type: 'task'),
                GraphNode(
                  id: 'doc-constitution',
                  label: 'AGENTS.md',
                  type: 'doc',
                ),
              ],
              edges: const [
                GraphEdge(
                  sourceId: 'agent-alpha',
                  targetId: 'skill-analyze',
                  edgeType: 'uses',
                ),
                GraphEdge(
                  sourceId: 'agent-alpha',
                  targetId: 'skill-build',
                  edgeType: 'uses',
                ),
                GraphEdge(
                  sourceId: 'agent-alpha',
                  targetId: 'task-1513',
                  edgeType: 'references',
                ),
                GraphEdge(
                  sourceId: 'task-1513',
                  targetId: 'doc-constitution',
                  edgeType: 'references',
                ),
              ],
              onInspectEntity: () {},
              onExpandGraph: () {},
              onLegendTap: (type) {},
            ),
          ),
        ],
      ),
    );
  }

  /// EPIC-15 family — Ops Pack (Task 1519).
  static Widget buildEpic15OpsSection() {
    return const _SectionCard(
      title: 'Ops Pack',
      subtitle:
          'PrismFloatingAnalyticsHud · PrismOpsControlCluster · PrismConnectorPanel · PrismViewPresets · PrismWorkspaceShareCard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PrismFloatingAnalyticsHud / DSFloatingAnalyticsHud (Task 1514 / O-09)
          // Draggable minimizable multi-section overlay — plain stage host.
          DSText.labelLarge(
            'PrismFloatingAnalyticsHud (drag · minimize · multi-section)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'EPIC-15 O-09 — fixture metrics over plain stage (no MapLibre / live telemetry)',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 420, width: 720, child: _FloatingAnalyticsHudDemo()),
          SizedBox(height: DSSpacing.lg),

          // PrismOpsControlCluster + PrismConnectorPanel (Task 1515 / O-16 + O-20)
          // Ops launchers + generic minimizable connector chrome — no domain clones.
          DSText.labelLarge(
            'PrismOpsControlCluster + PrismConnectorPanel (ops · chrome)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'EPIC-15 O-16 / O-20 — fixture launchers + generic body slot; '
            'prefer connector chrome over Shodan/SCM/radio one-offs',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 360, width: 720, child: _OpsConnectorPackDemo()),
          SizedBox(height: DSSpacing.lg),

          // PrismViewPresets / DSViewPresets (Task 1516 / O-18)
          DSText.labelLarge(
            'PrismViewPresets (named camera/layer preset grid)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'EPIC-15 O-18 — fixture preset tiles grid',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(width: 720, child: _ViewPresetsDemo()),
          SizedBox(height: DSSpacing.lg),

          // PrismWorkspaceShareCard / DSWorkspaceShareCard (Task 1516 / O-19)
          DSText.labelLarge(
            'PrismWorkspaceShareCard (read-only share summary)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'EPIC-15 O-19 — read-only view-state summary & clipboard share',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(width: 480, child: _WorkspaceShareCardDemo()),
          SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  /// EPIC-15 family — Terminal (Task 1519).
  static Widget buildEpic15TerminalSection() {
    return const _SectionCard(
      title: 'Terminal',
      subtitle: 'PrismTerminalWorkspace · PrismAgentShellPanel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PrismTerminalWorkspace / DSTerminalWorkspace (Task 1517 / O-21)
          DSText.labelLarge(
            'PrismTerminalWorkspace (multi-pane sovereign console shell)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'EPIC-15 O-21 — fixture multi-pane tab/split workspace (not a real PTY)',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 480, width: 720, child: _TerminalWorkspaceDemo()),
          SizedBox(height: DSSpacing.lg),

          // PrismAgentShellPanel / DSAgentShellPanel (Task 1518 / O-22)
          DSText.labelLarge(
            'PrismAgentShellPanel (read-only transcript panel)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'EPIC-15 O-22 — read-only terminal transcript from fixtures',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 380, width: 720, child: _AgentShellPanelDemo()),
          SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EPIC-16 FAMILY SECTIONS (Task 1613 registration)
  // ---------------------------------------------------------------------------

  /// Content chrome family — C-01 PageShell + C-02 Tree.
  static Widget buildContentChromeSection() {
    return _SectionCard(
      title: 'Content Chrome',
      subtitle: 'PrismPageShell · PrismTree',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page shell preview (content chrome ≠ app shell) — Task 1602 / C-01
          const DSText.labelLarge(
            'PrismPageShell (Providers fixture)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 280,
            child: DSPageShell.icon(
              title: 'Providers',
              subtitle: 'Fixture demo — LLM accounts and model health',
              icon: Icons.cloud_outlined,
              accentColor: DSColors.accentCyan,
              actions: const [
                DSBadge(label: '12 active', color: DSColors.statusSuccess),
              ],
              toolbar: const Row(
                children: [
                  Expanded(
                    child: DSText.bodySmall(
                      'Filter · All regions · Healthy only',
                      color: DSColors.textTertiary,
                    ),
                  ),
                  DSChip(label: 'Refresh'),
                ],
              ),
              child: const DSGlassPanelSimple(
                padding: EdgeInsets.all(DSSpacing.md),
                child: DSText.bodyMedium(
                  'Page body slot — compose tables, inspectors, or ops matrices here. '
                  'PrismPageShell is content chrome only (≠ PrismShell / PrismTopbar).',
                  color: DSColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Tree preview (hierarchical content control ≠ sidebar) — Task 1603 / C-02
          const DSText.labelLarge(
            'PrismTree (Providers → accounts → models fixture)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          // Bounded demo viewport: tree rows (minHeight 40) + glass padding exceed
          // a short fixed height when several nodes are expanded. Scroll the fixture
          // so gallery smoke and high text-scale catalog proofs never overflow.
          const SizedBox(
            height: 280,
            child: DSGlassPanelSimple(
              padding: EdgeInsets.symmetric(vertical: DSSpacing.sm),
              child: SingleChildScrollView(
                child: DSTree(
                  semanticLabel: 'Provider tree',
                  selectedId: 'acct-main',
                  initiallyExpandedIds: {
                    'prov-openai',
                    'acct-main',
                    'prov-anthropic',
                  },
                  nodes: [
                    DSTreeNode(
                      id: 'prov-openai',
                      label: 'OpenAI',
                      icon: Icons.cloud_outlined,
                      status: DSOperationalState.healthy,
                      meta: '2 accounts',
                      children: [
                        DSTreeNode(
                          id: 'acct-main',
                          label: 'main-prod',
                          status: DSOperationalState.healthy,
                          meta: 'us-east',
                          children: [
                            DSTreeNode(
                              id: 'model-gpt4o',
                              label: 'gpt-4o',
                              status: DSOperationalState.healthy,
                              meta: 'chat',
                            ),
                            DSTreeNode(
                              id: 'model-o1',
                              label: 'o1-mini',
                              status: DSOperationalState.degraded,
                              meta: 'reason',
                            ),
                          ],
                        ),
                        DSTreeNode(
                          id: 'acct-dev',
                          label: 'dev-sandbox',
                          status: DSOperationalState.stale,
                          meta: 'eu-west',
                          children: [
                            DSTreeNode(
                              id: 'model-gpt4o-mini',
                              label: 'gpt-4o-mini',
                              status: DSOperationalState.healthy,
                            ),
                          ],
                        ),
                      ],
                    ),
                    DSTreeNode(
                      id: 'prov-anthropic',
                      label: 'Anthropic',
                      icon: Icons.psychology_outlined,
                      status: DSOperationalState.degraded,
                      meta: '1 account',
                      children: [
                        DSTreeNode(
                          id: 'acct-claude',
                          label: 'claude-prod',
                          status: DSOperationalState.running,
                          meta: 'us-west',
                          children: [
                            DSTreeNode(
                              id: 'model-sonnet',
                              label: 'claude-sonnet-4',
                              status: DSOperationalState.healthy,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Agent transcript family — C-03–C-06.
  static Widget buildAgentTranscriptSection() {
    return _SectionCard(
      title: 'Agent Transcript',
      subtitle:
          'PrismAgentTranscript · PrismToolCallCard · '
          'PrismMessageStatusHistory · PrismArtifactWorkbench',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agent transcript preview (chat multi-role ≠ agent shell / log viewer)
          // Task 1604 / C-03 — fixture-only, no live model calls
          const DSText.labelLarge(
            'PrismAgentTranscript (fixture multi-role session)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 420,
            child: DSGlassPanelSimple(
              padding: EdgeInsets.zero,
              child: DSAgentTranscript(
                semanticLabel: 'Fixture agent conversation',
                showTimestamps: true,
                renderMarkdown: true,
                messages: dsAgentTranscriptFixtureMessages(),
                footer: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSSpacing.lg,
                    vertical: DSSpacing.sm,
                  ),
                  child: DSText.bodySmall(
                    'Composer disabled — read-only fixture transcript '
                    '(≠ PrismAgentShellPanel / PrismLogViewer).',
                    color: DSColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Tool call card (DeepChat-style tool blocks) — Task 1605 / C-04
          const DSText.labelLarge(
            'PrismToolCallCard (fixture success + error)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSToolCallCard(
            data: dsToolCallSuccessFixture(),
            initiallyExpanded: true,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSToolCallCard(
            data: dsToolCallErrorFixture(),
            initiallyExpanded: true,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSToolCallCard(data: dsToolCallRunningFixture()),
          const SizedBox(height: DSSpacing.lg),

          // Message status history strip — Task 1605 / C-05
          const DSText.labelLarge(
            'PrismMessageStatusHistory (pipeline steps)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DSText.labelSmall(
                  'Success trail (horizontal)',
                  color: DSColors.textTertiary,
                ),
                const SizedBox(height: DSSpacing.sm),
                DSMessageStatusHistory(
                  steps: dsMessageStatusHistorySuccessFixture(),
                ),
                const SizedBox(height: DSSpacing.md),
                const DSText.labelSmall(
                  'In progress (horizontal)',
                  color: DSColors.textTertiary,
                ),
                const SizedBox(height: DSSpacing.sm),
                DSMessageStatusHistory(
                  steps: dsMessageStatusHistoryRunningFixture(),
                ),
                const SizedBox(height: DSSpacing.md),
                const DSText.labelSmall(
                  'Error path (vertical)',
                  color: DSColors.textTertiary,
                ),
                const SizedBox(height: DSSpacing.sm),
                DSMessageStatusHistory(
                  direction: Axis.vertical,
                  steps: dsMessageStatusHistoryErrorFixture(),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Composition: tool card + status strip inside transcript custom blocks
          // Task 1605 soft-compose with 1604
          const DSText.labelLarge(
            'Transcript + ToolCall + StatusHistory (composed fixture)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 460,
            child: DSGlassPanelSimple(
              padding: EdgeInsets.zero,
              child: DSAgentTranscript(
                semanticLabel: 'Composed tool-call conversation',
                showTimestamps: true,
                renderMarkdown: true,
                messages: [
                  DSAgentMessage.text(
                    id: 'comp-user-1',
                    role: DSAgentRole.user,
                    text: 'Check OpenAI main-prod health.',
                    timestamp: DateTime.utc(2026, 7, 10, 15, 0, 0),
                    authorLabel: 'Operator',
                  ),
                  DSAgentMessage(
                    id: 'comp-asst-1',
                    role: DSAgentRole.assistant,
                    timestamp: DateTime.utc(2026, 7, 10, 15, 0, 12),
                    authorLabel: 'Prism Analyst',
                    blocks: [
                      const DSAgentMessageBlock.text(
                        'Running a fixture health check…',
                      ),
                      DSAgentMessageBlock.custom(
                        DSMessageStatusHistory(
                          steps: dsMessageStatusHistorySuccessFixture(),
                          compact: true,
                        ),
                        label: 'status',
                      ),
                      DSAgentMessageBlock.custom(
                        DSToolCallCard(
                          data: dsToolCallSuccessFixture(id: 'comp-tool-1'),
                          initiallyExpanded: true,
                        ),
                        label: 'tool',
                      ),
                      const DSAgentMessageBlock.text(
                        'main-prod is **healthy** (fixture result).',
                      ),
                    ],
                  ),
                ],
                footer: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSSpacing.lg,
                    vertical: DSSpacing.sm,
                  ),
                  child: DSText.bodySmall(
                    'Composed via DSAgentMessageBlock.custom — fixtures only.',
                    color: DSColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Artifact workbench (list + multi-type preview) — Task 1606 / C-06
          const DSText.labelLarge(
            'PrismArtifactWorkbench (code · markdown · text fixtures)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 420,
            child: DSArtifactWorkbench(
              title: 'Session artifacts',
              subtitle: 'Fixture-only — no network artifact loading',
              artifacts: dsArtifactWorkbenchFixtures(),
              initialSelectedId: 'art-md-1',
              useSplitPane: true,
            ),
          ),
        ],
      ),
    );
  }

  /// CyberCore ops family — C-07–C-10.
  static Widget buildCyberCoreOpsSection() {
    return _SectionCard(
      title: 'CyberCore Ops',
      subtitle:
          'PrismProviderHealthMatrix · PrismMcpCapabilityInspector · '
          'PrismTimingWaterfall · PrismTrafficInspector',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider health matrix (CyberCore ops grid ≠ DSStatusGrid)
          // Task 1607 / C-07 — fixture-only, no live provider pings
          const DSText.labelLarge(
            'PrismProviderHealthMatrix (OpenAI / Anthropic fixture)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: DSProviderHealthMatrix(
              semanticLabel: 'Fixture provider health matrix',
              selectedCellId: 'openai-dev-sandbox',
              providers: dsProviderHealthMatrixFixtureProviders(),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'Fixture providers only — no API keys or live health endpoints '
            '(≠ PrismStatusGrid flat service dashboard).',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.lg),

          // MCP capability inspector (CyberCore ops) — Task 1608 / C-08
          // Fixture-only tools/resources/prompts; no live MCP transport
          const DSText.labelLarge(
            'PrismMcpCapabilityInspector (tools · resources · prompts fixture)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 440,
            child: DSMcpCapabilityInspector(
              title: 'MCP Capabilities',
              subtitle: 'filesystem — fixture server',
              connectionStatus: 'connected',
              capabilities: dsMcpCapabilityInspectorStandardCapabilities(),
              tools: dsMcpCapabilityInspectorFixtureTools(),
              resources: dsMcpCapabilityInspectorFixtureResources(),
              prompts: dsMcpCapabilityInspectorFixturePrompts(),
              initialSelection: const DSMcpCapabilitySelection(
                kind: DSMcpCapabilityKind.tools,
                id: 'tool-list-dir',
              ),
              useSplitPane: true,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'Capability-gated tabs (tools/resources/prompts) — fixtures only, '
            'no live MCP JSON-RPC or ALLOW/BLOCK mutation panels.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.lg),

          // Timing waterfall (CyberCore ops C-09) — Task 1609
          // Pure Flutter bars; no Recharts / chart engines
          const DSText.labelLarge(
            'PrismTimingWaterfall (fixture spans)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.sm),
            child: DSTimingWaterfall(
              semanticLabel: 'Fixture timing waterfall',
              selectedSpanId: 'span-ttfb',
              spans: dsTimingWaterfallFixtureSpans(),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'Fixture spans only — pure Flutter layout (no Recharts).',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.lg),

          // Traffic inspector (CyberCore ops C-10) — Task 1609 pack
          // List + detail tabs; embeds waterfall on Timing tab
          const DSText.labelLarge(
            'PrismTrafficInspector (list + detail fixtures)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 420,
            child: DSTrafficInspector(
              title: 'Traffic',
              subtitle: 'Fixture-only — no live MITM capture',
              initialSelectedId: 'req-chat-001',
              requests: dsTrafficInspectorFixtureRequests(),
              useSplitPane: true,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'Fixture request IDs only — no proxy backends or network deps.',
            color: DSColors.textTertiary,
          ),
        ],
      ),
    );
  }

  /// Workflow / execution family — C-11 + C-12 (Tasks 1610–1611 delivered).
  static Widget buildWorkflowExecutionSection() {
    return _SectionCard(
      title: 'Workflow & Execution',
      subtitle: 'PrismWorkflowCanvasStage · PrismExecutionConsole',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workflow canvas stage (C-11 / Task 1610) — DAG contract, not map stage
          const DSText.labelLarge(
            'PrismWorkflowCanvasStage (ingest → route → respond fixture)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 360,
            child: _WorkflowCanvasStageDemo(), // const ctor; stateful selection
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'Workflow DAG stage contract only — not PrismMapCanvasStage (geo). '
            'No MapLibre, no force-graph JS, fixture selection bus only.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.lg),

          // Execution console (workflow execution C-12) — Task 1611
          // Run-grouped fixture stream + structured output; no PTY / shell
          const DSText.labelLarge(
            'PrismExecutionConsole (grouped run fixtures + output panel)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 420,
            child: DSExecutionConsole(
              title: 'Execution',
              subtitle: 'Fixture stream only — no PTY / workflow exec',
              initialSelectedRunGroupId: 'run-transform',
              lines: dsExecutionConsoleFixtureLines(),
              runGroups: dsExecutionConsoleFixtureRunGroups(),
              showOutputPanel: true,
              useSplitPane: true,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSText.bodySmall(
            'Run-grouped execution log + structured output slot '
            '(≠ PrismLogViewer / TerminalWorkspace / AgentShellPanel). '
            'Append via PrismExecutionConsoleController for stream simulation.',
            color: DSColors.textTertiary,
          ),
        ],
      ),
    );
  }

  static Widget buildTemplatesSection() {
    return const _SectionCard(
      title: 'Templates',
      subtitle: 'MasterDetailTemplate · CanvasTemplate · TimelineTemplate',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSText.bodyMedium(
            'Templates compose organisms into full-page layouts. '
            'They are demonstrated at the route level — the gallery page itself '
            'proves the template contract by being a living instance.',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.md),
          _TemplatePreview(
            name: 'MasterDetailTemplate',
            description:
                'Sidebar + topbar + master list + detail inspector. '
                'Responsive: side-by-side ≥1200px, overlay 800-1199px, '
                'full-screen <800px.',
          ),
          SizedBox(height: DSSpacing.sm),
          _TemplatePreview(
            name: 'CanvasTemplate',
            description:
                'Sidebar + topbar + full-bleed graph canvas + floating controls + '
                'overlay inspector panel.',
          ),
          SizedBox(height: DSSpacing.sm),
          _TemplatePreview(
            name: 'TimelineTemplate',
            description:
                'Sidebar + topbar + chronological timeline entries + detail panel. '
                'Side-by-side ≥1000px.',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EPIC-15 optional Wave I polish (Tasks 1522 / 1523)
  // ---------------------------------------------------------------------------
  /// Optional Wave I pack: keyboard cheatsheet, scale measure bar, media
  /// detail overlay. Risk toast variant lives under [buildToastsSection].
  static Widget buildEpic15OptionalPolishSection() {
    return const _SectionCard(
      title: 'Optional Wave I Polish',
      subtitle:
          'PrismKeyboardCheatsheet · PrismScaleMeasureBar · '
          'PrismMediaDetailOverlay · risk toast (see Toasts)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSText.labelLarge(
            'PrismScaleMeasureBar (molecule · read-only map chrome)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'O-26 — fixture label/segments only; not zoom math / MapLibre',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          DSScaleMeasureBar(
            label: DSScaleMeasureBarFixtures.defaultLabel,
            segments: DSScaleMeasureBarFixtures.defaultSegments,
            caption: 'Fixture scale',
          ),
          SizedBox(height: DSSpacing.sm),
          DSScaleMeasureBar(
            label: DSScaleMeasureBarFixtures.kilometerLabel,
            segments: DSScaleMeasureBarFixtures.kilometerSegments,
            barWidth: 160,
            accentColor: DSColors.accentGold,
          ),
          SizedBox(height: DSSpacing.lg),

          DSText.labelLarge(
            'PrismKeyboardCheatsheet (O-24 · open/close overlay)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'Fixture shortcut groups — distinct from command palette',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 360, width: 640, child: _KeyboardCheatsheetDemo()),
          SizedBox(height: DSSpacing.lg),

          DSText.labelLarge(
            'PrismMediaDetailOverlay (O-27 · placeholder lightbox)',
            color: DSColors.textSecondary,
          ),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'Fixture media only — no streaming engines / hls / WebRTC',
            color: DSColors.textTertiary,
          ),
          SizedBox(height: DSSpacing.sm),
          SizedBox(height: 420, width: 720, child: _MediaDetailOverlayDemo()),
          SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }
}

// =============================================================================
// PRIVATE HELPERS
// =============================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DSGlassPanelSimple(
      padding: const EdgeInsets.all(DSSpacing.xl),
      borderColor: DSColors.borderDefault,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSText.headingMedium(title),
          const SizedBox(height: DSSpacing.xs),
          DSText.bodySmall(subtitle, color: DSColors.textTertiary),
          const SizedBox(height: DSSpacing.lg),
          const DSDivider.subtle(),
          const SizedBox(height: DSSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _SwatchDef {
  final String label;
  final Color color;
  const _SwatchDef(this.label, this.color);
}

class _ScaleDef {
  final String label;
  final double value;
  const _ScaleDef(this.label, this.value);
}

class _StatusSample extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusSample(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DSStatusDot(color: color, tooltip: label),
        const SizedBox(width: DSSpacing.xs),
        DSText.labelMedium(label, color: color),
      ],
    );
  }
}

class _ErrorBoundaryDemo extends StatelessWidget {
  const _ErrorBoundaryDemo();

  @override
  Widget build(BuildContext context) {
    // Demonstrates the fallback view by directly rendering it
    // (an actual error boundary catching a real exception would need
    // a widget that throws during build, which is hard to demo in a gallery).
    return const DSFallbackView(
      error: 'Simulated panel crash: StateError("No element")',
      title: 'Panel Render Error',
    );
  }
}

class _DragDropDemo extends StatefulWidget {
  const _DragDropDemo();

  @override
  State<_DragDropDemo> createState() => _DragDropDemoState();
}

class _DragDropDemoState extends State<_DragDropDemo> {
  late List<DSLane> _lanes;

  @override
  void initState() {
    super.initState();
    _lanes = [
      const DSLane(
        id: '01-open',
        label: 'Open',
        tasks: [
          DSLaneTask(
            id: 101,
            title: 'Define provider contracts',
            priority: 'P1',
          ),
          DSLaneTask(id: 102, title: 'Wire mock data sources', priority: 'P2'),
          DSLaneTask(id: 103, title: 'Create gallery route', priority: 'P2'),
        ],
      ),
      const DSLane(
        id: '02-doing',
        label: 'Doing',
        tasks: [
          DSLaneTask(id: 201, title: 'Build data layer', priority: 'P0'),
          DSLaneTask(id: 202, title: 'Implement graph canvas', priority: 'P1'),
        ],
      ),
      const DSLane(id: '03-review', label: 'Review', tasks: []),
    ];
  }

  void _handleReorder(DSDragReorderEvent event) {
    if (!mounted) return;
    setState(() {
      final laneIdx = _lanes.indexWhere((l) => l.id == event.laneId);
      if (laneIdx < 0) return;
      final lane = _lanes[laneIdx];
      final tasks = List<DSLaneTask>.from(lane.tasks);
      final task = tasks.removeAt(event.oldIndex);
      // Adjust newIndex if moving downward (remove shifts indices)
      final insertAt = event.newIndex > event.oldIndex
          ? event.newIndex - 1
          : event.newIndex;
      tasks.insert(insertAt.clamp(0, tasks.length), task);
      _lanes[laneIdx] = DSLane(id: lane.id, label: lane.label, tasks: tasks);
    });
  }

  void _handleMove(DSDragMoveEvent event) {
    if (!mounted) return;
    setState(() {
      final srcIdx = _lanes.indexWhere((l) => l.id == event.sourceLaneId);
      final tgtIdx = _lanes.indexWhere((l) => l.id == event.targetLaneId);
      if (srcIdx < 0 || tgtIdx < 0) return;

      final srcLane = _lanes[srcIdx];
      final tgtLane = _lanes[tgtIdx];
      final srcTasks = List<DSLaneTask>.from(srcLane.tasks);
      final tgtTasks = List<DSLaneTask>.from(tgtLane.tasks);

      final taskIdx = srcTasks.indexWhere((t) => t.id == event.taskId);
      if (taskIdx < 0) return;

      final task = srcTasks.removeAt(taskIdx);
      final insertAt = event.targetIndex.clamp(0, tgtTasks.length);
      tgtTasks.insert(insertAt, task);

      _lanes[srcIdx] = DSLane(
        id: srcLane.id,
        label: srcLane.label,
        tasks: srcTasks,
      );
      _lanes[tgtIdx] = DSLane(
        id: tgtLane.id,
        label: tgtLane.label,
        tasks: tgtTasks,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DSLaneBoard(
      lanes: _lanes,
      onReorder: _handleReorder,
      onMove: _handleMove,
    );
  }
}

/// Tile displaying a single operational state with icon, label, and dot.
class _OperationalStateTile extends StatelessWidget {
  final DSOperationalState state;

  const _OperationalStateTile({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: state.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: state.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSStatusDot(color: state.color, tooltip: state.label),
          const SizedBox(width: DSSpacing.xs),
          DSIcon(state.icon, color: state.color, size: 16),
          const SizedBox(width: DSSpacing.xs),
          DSText.labelMedium(state.label, color: state.color),
        ],
      ),
    );
  }
}

/// Table displaying behavioral contracts for all operational states.
class _BehavioralContractTable extends StatelessWidget {
  const _BehavioralContractTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DSColors.borderSubtle),
        borderRadius: BorderRadius.circular(DSRadii.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            color: DSColors.obsidianHover,
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DSText.labelSmall(
                    'State',
                    color: DSColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: DSText.labelSmall(
                    'Actions',
                    color: DSColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: DSText.labelSmall(
                    'Terminal',
                    color: DSColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: DSText.labelSmall(
                    'Warning',
                    color: DSColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: DSText.labelSmall(
                    'Severity',
                    color: DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // State rows
          for (final state in DSOperationalState.values)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.xs,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: DSColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        DSStatusDot(color: state.color),
                        const SizedBox(width: DSSpacing.xs),
                        DSText.labelSmall(state.label, color: state.color),
                      ],
                    ),
                  ),
                  Expanded(
                    child: DSText.labelSmall(
                      state.allowsActions ? 'Yes' : 'No',
                      color: state.allowsActions
                          ? DSColors.statusSuccess
                          : DSColors.textDisabled,
                    ),
                  ),
                  Expanded(
                    child: DSText.labelSmall(
                      state.isTerminal ? 'Yes' : 'No',
                      color: state.isTerminal
                          ? DSColors.statusWarning
                          : DSColors.textTertiary,
                    ),
                  ),
                  Expanded(
                    child: DSText.labelSmall(
                      state.showsWarning ? 'Yes' : 'No',
                      color: state.showsWarning
                          ? DSColors.statusWarning
                          : DSColors.textTertiary,
                    ),
                  ),
                  Expanded(
                    child: DSText.labelSmall(
                      state.severity.name,
                      color: _severityColor(state.severity),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Color _severityColor(DSOperationalSeverity severity) {
    switch (severity) {
      case DSOperationalSeverity.info:
        return DSColors.statusInfo;
      case DSOperationalSeverity.success:
        return DSColors.statusSuccess;
      case DSOperationalSeverity.warning:
        return DSColors.statusWarning;
      case DSOperationalSeverity.error:
        return DSColors.statusError;
      case DSOperationalSeverity.critical:
        return DSColors.statusError;
    }
  }
}

// =============================================================================
// TAB BAR & SPLIT PANE DEMOS
// =============================================================================

/// Interactive demo for DSTabBar with 3 closeable tabs and badges.
class _TabBarDemo extends StatefulWidget {
  @override
  State<_TabBarDemo> createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<_TabBarDemo> {
  late DSTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DSTabController(
      tabs: [
        DSTab(
          id: 'agents',
          label: 'Agents',
          icon: DSIcons.agent,
          badgeCount: 5,
          closable: true,
          content: (_) => const _DemoPane(
            label: 'Agents',
            color: DSColors.assetAgent,
            icon: DSIcons.agent,
          ),
        ),
        DSTab(
          id: 'skills',
          label: 'Skills',
          icon: DSIcons.skill,
          badgeCount: 12,
          closable: true,
          content: (_) => const _DemoPane(
            label: 'Skills',
            color: DSColors.assetSkill,
            icon: DSIcons.skill,
          ),
        ),
        DSTab(
          id: 'tasks',
          label: 'Tasks',
          icon: DSIcons.task,
          closable: true,
          content: (_) => const _DemoPane(
            label: 'Tasks',
            color: DSColors.assetTask,
            icon: DSIcons.task,
          ),
        ),
      ],
    );
    _controller.addListener(_onTabControllerChanged);
  }

  void _onTabControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DSGlassPanelSimple(
      borderColor: DSColors.borderDefault,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSTabBar(
            controller: _controller,
            onClose: (id) {
              _controller.closeById(id);
            },
          ),
          SizedBox(height: 400, child: DSTabView(controller: _controller)),
        ],
      ),
    );
  }
}

/// Demo for DSTabBar with 10 tabs to show scroll overflow behavior.
class _TabBarOverflowDemo extends StatefulWidget {
  @override
  State<_TabBarOverflowDemo> createState() => _TabBarOverflowDemoState();
}

class _TabBarOverflowDemoState extends State<_TabBarOverflowDemo> {
  late DSTabController _controller;

  @override
  void initState() {
    super.initState();
    final tabs = List.generate(10, (i) {
      final names = [
        'Alpha',
        'Beta',
        'Gamma',
        'Delta',
        'Epsilon',
        'Zeta',
        'Eta',
        'Theta',
        'Iota',
        'Kappa',
      ];
      return DSTab(
        id: 'tab-$i',
        label: names[i],
        closable: i > 0, // first tab not closable
        badgeCount: i == 3 ? 7 : null,
        content: (_) => _DemoPane(
          label: names[i],
          color: DSColors.accentCyan,
          icon: DSIcons.agent,
        ),
      );
    });
    _controller = DSTabController(tabs: tabs);
    _controller.addListener(_onTabControllerChanged);
  }

  void _onTabControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DSGlassPanelSimple(
      borderColor: DSColors.borderDefault,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSTabBar(
            controller: _controller,
            onClose: (id) {
              _controller.closeById(id);
            },
          ),
          SizedBox(height: 400, child: DSTabView(controller: _controller)),
        ],
      ),
    );
  }
}

/// Reusable demo pane used in tab content builders.
class _DemoPane extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _DemoPane({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.obsidianDeep,
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Row(
        children: [
          DSIcon(icon, color: color, size: 32),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DSText.headingSmall(label, color: color),
                const SizedBox(height: DSSpacing.xs),
                DSText.bodySmall(
                  'Content area for $label tab',
                  color: DSColors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive demo for DSSplitPane (horizontal or vertical).
class _SplitPaneDemo extends StatelessWidget {
  final Axis axis;

  const _SplitPaneDemo({required this.axis});

  @override
  Widget build(BuildContext context) {
    return DSGlassPanelSimple(
      borderColor: DSColors.borderDefault,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSRadii.card),
        child: DSSplitPane(
          axis: axis,
          initialRatio: 0.6,
          leadingMinExtent: 120,
          trailingMinExtent: 100,
          leading: Container(
            color: DSColors.obsidianElevated,
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelLarge(
                  axis == Axis.horizontal ? 'Master List' : 'Code Editor',
                  color: DSColors.accentCyan,
                ),
                const SizedBox(height: DSSpacing.sm),
                Expanded(
                  child: ListView(
                    children: const [
                      _DemoListTile(
                        icon: DSIcons.agent,
                        label: 'agent-alpha',
                        color: DSColors.assetAgent,
                      ),
                      _DemoListTile(
                        icon: DSIcons.agent,
                        label: 'agent-beta',
                        color: DSColors.assetAgent,
                      ),
                      _DemoListTile(
                        icon: DSIcons.skill,
                        label: 'prompt-engineering',
                        color: DSColors.assetSkill,
                      ),
                      _DemoListTile(
                        icon: DSIcons.workflow,
                        label: 'ci-pipeline',
                        color: DSColors.assetWorkflow,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          trailing: Container(
            color: DSColors.obsidianBase,
            padding: const EdgeInsets.all(DSSpacing.md),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DSText.labelLarge(
                  axis == Axis.horizontal ? 'Detail Inspector' : 'Preview',
                  color: DSColors.accentViolet,
                ),
                const SizedBox(height: DSSpacing.sm),
                const DSText.bodySmall(
                  'Drag the divider to resize. '
                  'Double-click to collapse/expand.',
                  color: DSColors.textTertiary,
                ),
                const SizedBox(height: DSSpacing.md),
                const DSText.labelMedium(
                  'agent-alpha',
                  color: DSColors.textPrimary,
                ),
                const DSText.bodySmall(
                  'Type: Agent · Status: Active',
                  color: DSColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple list tile for the split pane demo.
class _DemoListTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DemoListTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_DemoListTile> createState() => _DemoListTileState();
}

class _DemoListTileState extends State<_DemoListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm,
          vertical: DSSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _isHovered ? DSColors.obsidianHover : DSColors.transparent,
          borderRadius: BorderRadius.circular(DSRadii.sm),
        ),
        child: Row(
          children: [
            DSIcon(widget.icon, color: widget.color, size: 16),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: DSText.labelMedium(
                widget.label,
                color: DSColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  final String name;
  final String description;

  const _TemplatePreview({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: DSColors.obsidianHover,
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: DSColors.borderSubtle),
      ),
      child: Row(
        children: [
          const DSIcon(Icons.view_quilt_outlined, color: DSColors.accentViolet),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelLarge(name, color: DSColors.accentViolet),
                DSText.bodySmall(description, color: DSColors.textTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gallery preview card for the command palette.
///
/// Shows a static sample of command items to demonstrate the visual
/// treatment.  The actual interactive palette is available via
/// [showDSCommandPalette] or the [DSCommandPaletteShortcut] widget.
class _CommandPalettePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: DSColors.obsidianHover,
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: DSColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini search bar mock
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: DSColors.obsidianElevated,
              borderRadius: BorderRadius.circular(DSRadii.sm),
              border: Border.all(
                color: DSColors.accentCyan.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const DSIcon(
                  Icons.search,
                  color: DSColors.accentCyan,
                  size: 16,
                ),
                const SizedBox(width: DSSpacing.sm),
                const DSText.bodyMedium(
                  'Type a command...',
                  color: DSColors.textTertiary,
                ),
                const Spacer(),
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
                  child: const DSText.labelSmall(
                    'ESC',
                    color: DSColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.sm),

          // Category chips mock
          const Row(
            children: [
              _PreviewChip(label: 'All', isActive: true),
              SizedBox(width: DSSpacing.xs),
              _PreviewChip(label: 'Navigate', isActive: false),
              SizedBox(width: DSSpacing.xs),
              _PreviewChip(label: 'Run', isActive: false),
              SizedBox(width: DSSpacing.xs),
              _PreviewChip(label: 'Recent', isActive: false),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),

          // Sample command items
          const _PreviewCommandItem(
            icon: DSIcons.map,
            label: 'Map Workspace',
            description: 'Navigate to the asset map',
            isSelected: true,
          ),
          const _PreviewCommandItem(
            icon: DSIcons.operate,
            label: 'Operate — Task Board',
            description: 'Navigate to the task board',
            isSelected: false,
          ),
          const _PreviewCommandItem(
            icon: DSIcons.governance,
            label: 'Governance View',
            description: 'Navigate to governance diagnostics',
            isSelected: false,
          ),
          const SizedBox(height: DSSpacing.sm),

          // Keyboard hints
          const Row(
            children: [
              DSText.labelSmall('↑↓', color: DSColors.textDisabled),
              SizedBox(width: DSSpacing.xs),
              DSText.labelSmall('navigate', color: DSColors.textDisabled),
              SizedBox(width: DSSpacing.md),
              DSText.labelSmall('↵', color: DSColors.textDisabled),
              SizedBox(width: DSSpacing.xs),
              DSText.labelSmall('select', color: DSColors.textDisabled),
              SizedBox(width: DSSpacing.md),
              DSText.labelSmall('esc', color: DSColors.textDisabled),
              SizedBox(width: DSSpacing.xs),
              DSText.labelSmall('close', color: DSColors.textDisabled),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _PreviewChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? DSColors.accentCyan.withValues(alpha: 0.15)
        : DSColors.transparent;
    final border = isActive
        ? DSColors.accentCyan.withValues(alpha: 0.4)
        : DSColors.borderSubtle;
    final fg = isActive ? DSColors.accentCyan : DSColors.textTertiary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DSRadii.chip),
        border: Border.all(color: border),
      ),
      child: DSText.labelSmall(label, color: fg),
    );
  }
}

class _PreviewCommandItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool isSelected;

  const _PreviewCommandItem({
    required this.icon,
    required this.label,
    this.description,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? DSColors.accentCyan.withValues(alpha: 0.08)
        : DSColors.transparent;
    final borderColor = isSelected
        ? DSColors.accentCyan.withValues(alpha: 0.2)
        : DSColors.transparent;
    final iconColor = isSelected ? DSColors.accentCyan : DSColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          DSIcon(icon, color: iconColor, size: 16),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelMedium(
                  label,
                  color: isSelected
                      ? DSColors.textPrimary
                      : DSColors.textSecondary,
                ),
                if (description != null)
                  DSText.labelSmall(description!, color: DSColors.textTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixture demo for [DSMapHudWorkspace] — placeholder stage (no MapLibre).
class _MapHudWorkspaceDemo extends StatelessWidget {
  const _MapHudWorkspaceDemo();

  @override
  Widget build(BuildContext context) {
    return DSMapHudWorkspace(
      stage: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DSColors.obsidianBase,
              Color(0xFF0C1220),
              DSColors.obsidianElevated,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSIcon(
                Icons.map_outlined,
                color: DSColors.accentCyan.withValues(alpha: 0.5),
                size: 48,
              ),
              const SizedBox(height: DSSpacing.sm),
              const DSText.labelMedium(
                'Mock map stage (fixture — not MapLibre)',
                color: DSColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
      leftHud: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSText.labelLarge('Layers', color: DSColors.textPrimary),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall('Left rail fixture', color: DSColors.textSecondary),
        ],
      ),
      rightHud: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSText.labelLarge('Intel', color: DSColors.textPrimary),
          SizedBox(height: DSSpacing.xs),
          DSText.labelSmall(
            'Right strip fixture',
            color: DSColors.textSecondary,
          ),
        ],
      ),
      topChrome: const Align(
        alignment: Alignment.centerLeft,
        child: DSText.labelMedium(
          'Ops cluster fixture',
          color: DSColors.textSecondary,
        ),
      ),
      bottomChrome: const Align(
        alignment: Alignment.centerLeft,
        child: DSText.labelSmall(
          'Status ticker · coords · feed health (fixture)',
          color: DSColors.textTertiary,
        ),
      ),
    );
  }
}

/// Fixture demo for [DSToolStripSlideout] — exclusive tools, no live backends.
class _ToolStripSlideoutDemo extends StatelessWidget {
  const _ToolStripSlideoutDemo();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Align(
        alignment: Alignment.centerRight,
        child: DSToolStripSlideout(
          tools: [
            DSToolStripItem(
              id: 'recon',
              icon: Icons.radar_outlined,
              label: 'Recon',
              builder: (context) => const _ToolStripFixtureBody(
                title: 'Recon',
                body:
                    'Fixture recon results — exclusive slideout body A. '
                    'No live OSINT backends.',
              ),
            ),
            DSToolStripItem(
              id: 'alerts',
              icon: Icons.notifications_outlined,
              label: 'Alerts',
              builder: (context) => const _ToolStripFixtureBody(
                title: 'Alerts',
                body:
                    'Fixture alert feed — exclusive slideout body B. '
                    'Opening this closes Recon.',
              ),
            ),
            DSToolStripItem(
              id: 'graph',
              icon: Icons.hub_outlined,
              label: 'Graph',
              builder: (context) => const _ToolStripFixtureBody(
                title: 'Entity graph',
                body:
                    'Fixture relation panel placeholder (compose DSGraphCanvas later).',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolStripFixtureBody extends StatelessWidget {
  final String title;
  final String body;

  const _ToolStripFixtureBody({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText.bodySmall(body, color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.md),
        DSText.labelSmall('Fixture · $title', color: DSColors.textTertiary),
      ],
    );
  }
}

/// Fixture demo for [DSLayerControlPanel] — grouped toggles, no MapLibre.
class _LayerControlPanelDemo extends StatefulWidget {
  const _LayerControlPanelDemo();

  @override
  State<_LayerControlPanelDemo> createState() => _LayerControlPanelDemoState();
}

class _LayerControlPanelDemoState extends State<_LayerControlPanelDemo> {
  String? _lastConsent;

  static const _groups = <DSLayerGroup>[
    DSLayerGroup(
      id: 'base',
      label: 'Base map',
      icon: Icons.map_outlined,
      layers: [
        DSLayerItem(
          id: 'basemap',
          label: 'Basemap tiles',
          enabled: true,
          count: 1,
          freshness: DSLayerFreshness.live,
          freshnessLabel: 'live',
          icon: Icons.layers_outlined,
        ),
        DSLayerItem(
          id: 'labels',
          label: 'Place labels',
          enabled: true,
          count: 420,
          freshness: DSLayerFreshness.recent,
          freshnessLabel: '2m ago',
          icon: Icons.label_outline,
        ),
      ],
    ),
    DSLayerGroup(
      id: 'feeds',
      label: 'Intel feeds',
      icon: Icons.radar_outlined,
      layers: [
        DSLayerItem(
          id: 'agents',
          label: 'Agents',
          enabled: true,
          count: 24,
          freshness: DSLayerFreshness.live,
          freshnessLabel: '12s ago',
          icon: Icons.smart_toy_outlined,
        ),
        DSLayerItem(
          id: 'alerts',
          label: 'Alerts',
          enabled: false,
          count: 7,
          freshness: DSLayerFreshness.aging,
          freshnessLabel: '18m ago',
          icon: Icons.notifications_outlined,
        ),
        DSLayerItem(
          id: 'pii-overlay',
          label: 'PII overlay',
          enabled: false,
          count: 3,
          freshness: DSLayerFreshness.stale,
          freshnessLabel: '2h ago',
          requiresConsent: true,
          icon: Icons.privacy_tip_outlined,
          subtitle: 'Requires consent gate',
        ),
        DSLayerItem(
          id: 'archived-feed',
          label: 'Archived archive',
          enabled: false,
          count: 0,
          disabled: true,
          freshness: DSLayerFreshness.unknown,
          icon: Icons.archive_outlined,
          subtitle: 'Disabled fixture',
        ),
      ],
    ),
    DSLayerGroup(
      id: 'empty-group',
      label: 'Empty group',
      initiallyExpanded: false,
      layers: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DSLayerControlPanel(
                groups: _groups,
                onConsentRequired: (id) {
                  setState(() => _lastConsent = id);
                },
              ),
            ),
            if (_lastConsent != null) ...[
              const SizedBox(height: DSSpacing.xs),
              DSText.labelSmall(
                'Consent requested: $_lastConsent (fixture stub)',
                color: DSColors.accentViolet,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fixture demo for [DSFilterWorkbench] — sectioned criteria + advanced modal.
class _FilterWorkbenchDemo extends StatefulWidget {
  const _FilterWorkbenchDemo();

  @override
  State<_FilterWorkbenchDemo> createState() => _FilterWorkbenchDemoState();
}

class _FilterWorkbenchDemoState extends State<_FilterWorkbenchDemo> {
  Map<String, Object?> _values = const {};
  String _status = 'Draft empty · fixture schema only';

  static const List<DSFilterSection> _sections = [
    DSFilterSection(
      id: 'assets',
      title: 'Asset type',
      description: 'Quick catalog facets',
      criteria: [
        DSFilterCriterion(
          id: 'asset_type',
          label: 'Types',
          kind: DSFilterCriterionKind.multiSelect,
          options: [
            DSFilterOption(value: 'agent', label: 'Agent', count: 5),
            DSFilterOption(value: 'skill', label: 'Skill', count: 12),
            DSFilterOption(value: 'workflow', label: 'Workflow', count: 3),
          ],
        ),
        DSFilterCriterion(
          id: 'lifecycle',
          label: 'Lifecycle',
          kind: DSFilterCriterionKind.singleSelect,
          options: [
            DSFilterOption(value: 'active', label: 'Active'),
            DSFilterOption(value: 'stale', label: 'Stale'),
            DSFilterOption(value: 'orphan', label: 'Orphan'),
          ],
        ),
      ],
    ),
    DSFilterSection(
      id: 'scope',
      title: 'Scope',
      criteria: [
        DSFilterCriterion(
          id: 'query',
          label: 'Name contains',
          kind: DSFilterCriterionKind.text,
          placeholder: 'e.g. recon-agent',
        ),
        DSFilterCriterion(
          id: 'pinned_only',
          label: 'Pinned only',
          kind: DSFilterCriterionKind.boolean,
        ),
        DSFilterCriterion(
          id: 'freshness',
          label: 'Freshness window',
          kind: DSFilterCriterionKind.singleSelect,
          advanced: true,
          options: [
            DSFilterOption(value: '1h', label: '1 hour'),
            DSFilterOption(value: '24h', label: '24 hours'),
            DSFilterOption(value: '7d', label: '7 days'),
          ],
        ),
        DSFilterCriterion(
          id: 'sources',
          label: 'Evidence sources',
          kind: DSFilterCriterionKind.multiSelect,
          advanced: true,
          options: [
            DSFilterOption(value: 'asw', label: 'ASW'),
            DSFilterOption(value: 'git', label: 'Git'),
            DSFilterOption(value: 'ci', label: 'CI'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DSFilterWorkbench(
                title: 'Catalog filters',
                subtitle: 'Fixture schema · no live catalog',
                sections: _sections,
                values: _values,
                onChanged: (next) {
                  setState(() {
                    _values = Map<String, Object?>.from(next);
                    _status =
                        'Draft ${_values.isEmpty ? 'empty' : _values.keys.join(', ')}';
                  });
                },
                onApply: (applied) {
                  setState(() {
                    _status =
                        'Applied ${applied.isEmpty ? '(none)' : applied.keys.join(', ')}';
                  });
                },
                onReset: () {
                  setState(() {
                    _values = {};
                    _status = 'Cleared';
                  });
                },
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            DSText.labelSmall(_status, color: DSColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Fixture demo for [DSEntityIntelPanel] — ≥2 dossier types, no megafile port.
class _EntityIntelPanelDemo extends StatefulWidget {
  const _EntityIntelPanelDemo();

  @override
  State<_EntityIntelPanelDemo> createState() => _EntityIntelPanelDemoState();
}

class _EntityIntelPanelDemoState extends State<_EntityIntelPanelDemo> {
  DSEntitySelection? _selection = DSEntityIntelFixtures.agent;
  bool _pinned = false;
  String _status = 'Agent dossier · fixture registry';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: [
                _SelectChip(
                  label: 'Agent',
                  selected: _selection?.type == 'agent',
                  onTap: () => setState(() {
                    _selection = DSEntityIntelFixtures.agent;
                    _status = 'Agent dossier · fixture registry';
                  }),
                ),
                _SelectChip(
                  label: 'Region',
                  selected: _selection?.type == 'region',
                  onTap: () => setState(() {
                    _selection = DSEntityIntelFixtures.region;
                    _status = 'Region dossier · fixture registry';
                  }),
                ),
                _SelectChip(
                  label: 'None',
                  selected: _selection == null,
                  onTap: () => setState(() {
                    _selection = null;
                    _status = 'Empty · no selection';
                  }),
                ),
                _SelectChip(
                  label: 'Unknown',
                  selected: _selection?.type == 'satellite',
                  onTap: () => setState(() {
                    _selection = const DSEntitySelection(
                      id: 'sat-fixture',
                      type: 'satellite',
                      title: 'SAT-9',
                      subtitle: 'Unregistered type',
                    );
                    _status = 'Unknown type fallback';
                  }),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Expanded(
              child: DSEntityIntelPanel(
                selection: _selection,
                dossiers: DSEntityIntelFixtures.sampleDossiers(),
                pinned: _pinned,
                onPinChanged: (v) => setState(() {
                  _pinned = v;
                  _status = v ? 'Pinned' : 'Unpinned';
                }),
                onClose: () => setState(() {
                  _selection = null;
                  _status = 'Closed → empty';
                }),
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            DSText.labelSmall(_status, color: DSColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? DSColors.accentCyan.withValues(alpha: 0.2)
          : DSColors.obsidianElevated,
      borderRadius: BorderRadius.circular(DSRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
            minWidth: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.sm,
            ),
            child: Center(
              child: DSText.labelSmall(
                label,
                color: selected ? DSColors.accentCyan : DSColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fixture demo for [DSEntityLocateSearch] — multi-corpus locate, no geocoder.
class _EntityLocateSearchDemo extends StatefulWidget {
  const _EntityLocateSearchDemo();

  @override
  State<_EntityLocateSearchDemo> createState() =>
      _EntityLocateSearchDemoState();
}

class _EntityLocateSearchDemoState extends State<_EntityLocateSearchDemo> {
  String _status = 'Idle · type to locate across agents + places';

  static const List<DSLocateCorpus> _corpora = [
    DSLocateCorpus(
      id: 'agents',
      label: 'Agents',
      icon: Icons.smart_toy_outlined,
      color: DSColors.accentCyan,
      entries: [
        DSLocateEntry(
          id: 'agent-recon-01',
          label: 'recon-agent',
          sublabel: 'OSINT · healthy',
          entityType: 'agent',
          latitude: 37.7749,
          longitude: -122.4194,
          zoom: 12,
          searchText: 'recon scout osint',
        ),
        DSLocateEntry(
          id: 'agent-ops-02',
          label: 'ops-orchestrator',
          sublabel: 'Operate · running',
          entityType: 'agent',
          latitude: 40.7128,
          longitude: -74.0060,
          zoom: 11,
          searchText: 'orchestrator pipeline',
        ),
        DSLocateEntry(
          id: 'agent-gov-03',
          label: 'governance-auditor',
          sublabel: 'Governance · stale',
          entityType: 'agent',
          searchText: 'canonicality orphan audit',
        ),
      ],
    ),
    DSLocateCorpus(
      id: 'places',
      label: 'Places',
      icon: Icons.place_outlined,
      color: DSColors.accentGold,
      entries: [
        DSLocateEntry(
          id: 'place-sf-hq',
          label: 'San Francisco Hub',
          sublabel: 'West coast node',
          entityType: 'place',
          latitude: 37.7749,
          longitude: -122.4194,
          zoom: 14,
          searchText: 'california bay area',
        ),
        DSLocateEntry(
          id: 'place-nyc-edge',
          label: 'NYC Edge Site',
          sublabel: 'East coast node',
          entityType: 'place',
          latitude: 40.7128,
          longitude: -74.0060,
          zoom: 13,
          searchText: 'new york manhattan',
        ),
        DSLocateEntry(
          id: 'place-lab-remote',
          label: 'Remote Lab',
          sublabel: 'No live coords in fixture',
          entityType: 'place',
          searchText: 'sandbox lab offline',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DSEntityLocateSearch(
                corpora: _corpora,
                placeholder: 'Locate entity or place…',
                onQueryChanged: (q) {
                  setState(() {
                    _status = q.trim().isEmpty
                        ? 'Idle · type to locate across agents + places'
                        : 'Query: $q';
                  });
                },
                onLocate: (result) {
                  setState(() {
                    final coords = result.hasCoordinates
                        ? ' @ ${result.latitude}, ${result.longitude}'
                        : ' (no coords)';
                    _status =
                        'Locate ${result.label} · ${result.corpusLabel} · '
                        '${result.entityType}$coords';
                  });
                },
                onClear: () {
                  setState(() {
                    _status = 'Cleared';
                  });
                },
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            DSText.labelSmall(_status, color: DSColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Interactive [DSStatusGrid] gallery demo with toggleable state filters.
///
/// Uses [DSStatusGrid.embedInScrollView] so the outer gallery list remains
/// the primary scroller. Production CyberCore health surfaces should leave
/// `embedInScrollView` at its default (`false`) for independent lazy scroll.
class _HealthStatusGridDemo extends StatefulWidget {
  const _HealthStatusGridDemo();

  @override
  State<_HealthStatusGridDemo> createState() => _HealthStatusGridDemoState();
}

class _HealthStatusGridDemoState extends State<_HealthStatusGridDemo> {
  final Set<DSOperationalState> _filter = {};

  static final List<DSHealthCardData> _items = [
    DSHealthCardData(
      serviceName: 'MCP Server Alpha',
      operationalState: DSOperationalState.healthy,
      latency: const Duration(milliseconds: 42),
      uptimePercent: 0.9995,
      trendData: List.generate(12, (i) => 40.0 + i),
      lastCheck: DateTime.now(),
    ),
    const DSHealthCardData(
      serviceName: 'MCP Server Beta',
      operationalState: DSOperationalState.healthy,
      latency: Duration(milliseconds: 38),
      uptimePercent: 0.998,
    ),
    const DSHealthCardData(
      serviceName: 'Agent Parser',
      operationalState: DSOperationalState.degraded,
      latency: Duration(milliseconds: 230),
      uptimePercent: 0.97,
    ),
    const DSHealthCardData(
      serviceName: 'Build Pipeline',
      operationalState: DSOperationalState.error,
      latency: Duration(seconds: 5),
      uptimePercent: 0.82,
    ),
    const DSHealthCardData(
      serviceName: 'Auth Service',
      operationalState: DSOperationalState.disabled,
    ),
    const DSHealthCardData(
      serviceName: 'Memory Store',
      operationalState: DSOperationalState.healthy,
      latency: Duration(milliseconds: 12),
      uptimePercent: 0.9999,
    ),
    const DSHealthCardData(
      serviceName: 'Registry API',
      operationalState: DSOperationalState.running,
      latency: Duration(milliseconds: 55),
      uptimePercent: 0.995,
    ),
    const DSHealthCardData(
      serviceName: 'Proxy Gateway',
      operationalState: DSOperationalState.degraded,
      latency: Duration(milliseconds: 180),
      uptimePercent: 0.96,
    ),
    const DSHealthCardData(
      serviceName: 'Quota Tracker',
      operationalState: DSOperationalState.healthy,
      latency: Duration(milliseconds: 22),
      uptimePercent: 0.999,
    ),
    const DSHealthCardData(
      serviceName: 'Audit Logger',
      operationalState: DSOperationalState.healthy,
      latency: Duration(milliseconds: 31),
      uptimePercent: 0.9985,
    ),
    const DSHealthCardData(
      serviceName: 'Webhook Relay',
      operationalState: DSOperationalState.error,
      latency: Duration(seconds: 2),
      uptimePercent: 0.88,
    ),
    const DSHealthCardData(
      serviceName: 'Skill Indexer',
      operationalState: DSOperationalState.running,
      latency: Duration(milliseconds: 67),
      uptimePercent: 0.992,
    ),
  ];

  void _toggle(DSOperationalState state) {
    setState(() {
      if (_filter.contains(state)) {
        _filter.remove(state);
      } else {
        _filter.add(state);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DSStatusGrid(
      items: _items,
      maxCrossAxisExtent: 280,
      childAspectRatio: 1.5,
      showFilterBar: true,
      activeFilter: _filter.isEmpty ? null : _filter,
      onFilterToggle: _toggle,
      // Gallery embeds inside an outer scroll view.
      embedInScrollView: true,
    );
  }
}

/// Fixture demo for [DSTimeMachineScrubber] — mock density series, no live clock.
///
/// Pairing note (Task 1507): this is the temporal **control** surface. Use
/// [DSTimeline] / `PrismTimeline` for chronological event lists.
class _TimeMachineScrubberDemo extends StatefulWidget {
  const _TimeMachineScrubberDemo();

  @override
  State<_TimeMachineScrubberDemo> createState() =>
      _TimeMachineScrubberDemoState();
}

class _TimeMachineScrubberDemoState extends State<_TimeMachineScrubberDemo> {
  late final DateTime _domainStart;
  late final List<DSTimeDensityBucket> _buckets;
  String _status = 'Fixture 24h density · scrub or play';

  @override
  void initState() {
    super.initState();
    // Fixed epoch-relative fixture so the gallery is deterministic.
    _domainStart = DateTime.utc(2026, 7, 10, 0, 0);
    _buckets = List<DSTimeDensityBucket>.generate(24, (i) {
      final start = _domainStart.add(Duration(hours: i));
      final end = start.add(const Duration(hours: 1));
      // Synthetic wave with a midday peak and an evening risk spike.
      final base = (8 + (12 * (1 - ((i - 12).abs() / 12)))).round();
      final count = i == 18 ? base + 20 : base + (i % 3) * 2;
      final severity = i == 18
          ? DSTimeDensitySeverity.high
          : i >= 16 && i <= 20
          ? DSTimeDensitySeverity.medium
          : i >= 10 && i <= 14
          ? DSTimeDensitySeverity.low
          : DSTimeDensitySeverity.none;
      return DSTimeDensityBucket(
        id: 'h$i',
        start: start,
        end: end,
        count: count,
        severity: severity,
        label: 'Hour $i · $count events',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DSTimeMachineScrubber(
                title: 'Activity density (fixture)',
                buckets: _buckets,
                initialPlayhead: _domainStart.add(const Duration(hours: 12)),
                playbackStep: const Duration(hours: 1),
                playbackTickInterval: const Duration(milliseconds: 500),
                onPlayheadChanged: (t) {
                  setState(() {
                    _status =
                        'Playhead ${t.toUtc().toIso8601String().substring(0, 16)}Z';
                  });
                },
                onRangeChanged: (range) {
                  setState(() {
                    _status =
                        'As-of range → ${range.end.toUtc().toIso8601String().substring(0, 16)}Z';
                  });
                },
                onPlayingChanged: (playing) {
                  setState(() {
                    _status = playing ? 'Playing…' : 'Paused';
                  });
                },
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            DSText.labelSmall(_status, color: DSColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Fixture demo for [DSOsintWorkbench] — multi-tool recon, history, map handoff.
///
/// Documents fixture-only policy: [DSOsintFixtures.resolve] is in-memory only.
/// No live OSINT APIs, no API keys, no MapLibre engine.
class _OsintWorkbenchDemo extends StatefulWidget {
  const _OsintWorkbenchDemo();

  @override
  State<_OsintWorkbenchDemo> createState() => _OsintWorkbenchDemoState();
}

class _OsintWorkbenchDemoState extends State<_OsintWorkbenchDemo> {
  String _status =
      'Idle · switch tools, submit a query (try IP for geo handoff)';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DSOsintWorkbench(
                tools: DSOsintFixtures.defaultTools(),
                onToolChanged: (id) {
                  setState(() => _status = 'Active tool: $id');
                },
                onQuerySubmitted: (toolId, query, results) {
                  setState(() {
                    _status =
                        'Submitted $toolId · "$query" → ${results.length} result(s)';
                  });
                },
                onMapHandoff: (handoff) {
                  setState(() {
                    _status =
                        'Map handoff ${handoff.title} @ '
                        '${handoff.latitude}, ${handoff.longitude}';
                  });
                },
                onHistorySelected: (entry) {
                  setState(() {
                    _status =
                        'History re-run ${entry.toolLabel}: ${entry.query}';
                  });
                },
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            DSText.labelSmall(_status, color: DSColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Fixture demo for [DSWorkflowCanvasStage] (Task 1610 / C-11).
///
/// Workflow DAG only — not geo map stage; no MapLibre / force-graph JS.
class _WorkflowCanvasStageDemo extends StatefulWidget {
  const _WorkflowCanvasStageDemo();

  @override
  State<_WorkflowCanvasStageDemo> createState() =>
      _WorkflowCanvasStageDemoState();
}

class _WorkflowCanvasStageDemoState extends State<_WorkflowCanvasStageDemo> {
  String? _selectedNodeId = 'n-route';
  String? _selectedEdgeId;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: DSWorkflowCanvasStage(
        title: 'Workflow',
        subtitle: 'Fixture DAG — ingest → route → respond',
        semanticLabel: 'Fixture workflow canvas stage',
        nodes: dsWorkflowCanvasStageFixtureNodes(),
        edges: dsWorkflowCanvasStageFixtureEdges(),
        selectedNodeId: _selectedNodeId,
        selectedEdgeId: _selectedEdgeId,
        onNodeSelected: (node) {
          setState(() {
            _selectedNodeId = node.id;
            _selectedEdgeId = null;
          });
        },
        onEdgeSelected: (edge) {
          setState(() {
            _selectedEdgeId = edge.id;
            _selectedNodeId = null;
          });
        },
        onSelectionCleared: () {
          setState(() {
            _selectedNodeId = null;
            _selectedEdgeId = null;
          });
        },
      ),
    );
  }
}

/// Combined ops cluster + connector panel pack (Task 1515 / O-16 + O-20).
///
/// Hosts [DSOpsControlCluster] launchers driving a generic [DSConnectorPanel]
/// body — no domain one-off panels, no live backends.
class _OpsConnectorPackDemo extends StatefulWidget {
  const _OpsConnectorPackDemo();

  @override
  State<_OpsConnectorPackDemo> createState() => _OpsConnectorPackDemoState();
}

class _OpsConnectorPackDemoState extends State<_OpsConnectorPackDemo> {
  String? _selectedId;
  String _status = 'Select a launcher';
  int _refreshCount = 0;
  bool _minimized = false;

  String _bodyFor(String? id) {
    switch (id) {
      case 'console':
        return 'Fixture console slot — open terminal workspace (later wave).';
      case 'providers':
        return 'Provider health overview slot — compose health matrix here.';
      case 'alerts':
        return 'Operational alerts slot — fixture notice feed only.';
      case 'settings':
        return 'Workspace settings slot — read-only fixture summary.';
      case 'deploy':
        return 'Deploy is disabled in fixture mode.';
      default:
        return DSConnectorPanelFixtures.defaultBodyText;
    }
  }

  String _titleFor(String? id) {
    if (id == null) return DSConnectorPanelFixtures.defaultTitle;
    final match = DSOpsControlClusterFixtures.defaultLaunchers.where(
      (l) => l.id == id,
    );
    if (match.isEmpty) return DSConnectorPanelFixtures.defaultTitle;
    return match.first.label;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: DSOpsControlCluster(
                launchers: DSOpsControlClusterFixtures.defaultLaunchers,
                selectedId: _selectedId,
                onLauncherActivated: (launcher) {
                  setState(() {
                    _selectedId = launcher.id;
                    _status = 'Activated ${launcher.label}';
                    _minimized = false;
                  });
                },
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Expanded(
              child: Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 360,
                  child: DSConnectorPanel(
                    title: _titleFor(_selectedId),
                    subtitle: _status,
                    badgeLabel: DSConnectorPanelFixtures.defaultBadgeLabel,
                    leading: const DSIcon(
                      Icons.hub_outlined,
                      size: 16,
                      color: DSColors.accentCyan,
                    ),
                    minimized: _minimized,
                    onMinimizedChanged: (value) {
                      setState(() {
                        _minimized = value;
                        _status = value ? 'Panel minimized' : 'Panel expanded';
                      });
                    },
                    onRefresh: () {
                      setState(() {
                        _refreshCount++;
                        _status = 'Refresh #$_refreshCount (fixture)';
                      });
                    },
                    child: DSText.bodySmall(
                      _bodyFor(_selectedId),
                      color: DSColors.textSecondary,
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
}

/// Fixture demo for [DSAiAnalystPanel] — multi-turn seed + interactive composer.
///
/// Documents fixture-only policy: replies come from
/// [dsAiAnalystDefaultFixtureReply] (keyword script). No network / API keys.
class _AiAnalystPanelDemo extends StatefulWidget {
  const _AiAnalystPanelDemo();

  @override
  State<_AiAnalystPanelDemo> createState() => _AiAnalystPanelDemoState();
}

class _AiAnalystPanelDemoState extends State<_AiAnalystPanelDemo> {
  late final DSAiAnalystController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DSAiAnalystController(
      initialTurns: dsAiAnalystFixtureTurns(),
      streamSimulationDelay: const Duration(milliseconds: 400),
      simulateStreaming: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: DSAiAnalystPanel(
        controller: _controller,
        title: 'AI Analyst',
        subtitle: 'CyberCore fixture session',
        policyBanner: DSAiAnalystPanel.fixturePolicyBanner,
      ),
    );
  }
}

/// Fixture demo for [DSFloatingAnalyticsHud] — drag/minimize over plain stage.
///
/// Hosts the HUD on a colored [Stack] stage (soft-dep 1501 Map HUD not required).
/// Fixture metrics only — no live telemetry / MapLibre.
class _FloatingAnalyticsHudDemo extends StatelessWidget {
  const _FloatingAnalyticsHudDemo();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Plain stage fixture (not MapLibre / MapHudWorkspace).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DSColors.obsidianBase,
                    DSColors.obsidianElevated,
                    DSColors.obsidianDeep,
                  ],
                ),
                border: Border.all(color: DSColors.borderSubtle),
              ),
              child: const Center(
                child: DSText.bodySmall(
                  'Stage fixture — drag the analytics HUD; minimize collapses sections',
                  color: DSColors.textTertiary,
                ),
              ),
            ),
          ),
          DSFloatingAnalyticsHud(
            sections: DSFloatingAnalyticsFixtures.defaultSections(),
            title: 'Analytics',
            initialOffset: const Offset(24, 24),
            panelWidth: 340,
            maxBodyHeight: 300,
          ),
        ],
      ),
    );
  }
}

/// Fixture demo for [DSMapCanvasStage] — placeholder stage (no MapLibre).
///
/// Layer toggles drive the registry; tap markers for selection bus + popup.
class _MapCanvasStageDemo extends StatefulWidget {
  const _MapCanvasStageDemo();

  @override
  State<_MapCanvasStageDemo> createState() => _MapCanvasStageDemoState();
}

class _MapCanvasStageDemoState extends State<_MapCanvasStageDemo> {
  late final DSMapCanvasStageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DSMapCanvasStageController(
      initialLayers: DSMapCanvasStageFixtures.defaultLayers(),
      initialFeatures: DSMapCanvasStageFixtures.defaultFeatures(),
    );
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 168,
            child: Padding(
              padding: const EdgeInsets.all(DSSpacing.sm),
              child: DSGlassPanel.subtle(
                padding: const EdgeInsets.all(DSSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DSText.labelMedium(
                      'Layer registry',
                      color: DSColors.textPrimary,
                    ),
                    const SizedBox(height: DSSpacing.xxs),
                    const DSText.labelSmall(
                      'Fixture — not MapLibre',
                      color: DSColors.textTertiary,
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final layer in _controller.layers)
                            SwitchListTile.adaptive(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: DSText.labelSmall(
                                layer.label,
                                color: DSColors.textSecondary,
                              ),
                              value: layer.visible,
                              activeThumbColor:
                                  layer.color ?? DSColors.accentCyan,
                              onChanged: (v) =>
                                  _controller.setLayerVisibility(layer.id, v),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: DSColors.borderSubtle,
          ),
          Expanded(child: DSMapCanvasStage(controller: _controller)),
        ],
      ),
    );
  }
}

/// Fixture demo for [DSStatusTicker] — mock feed items, no live network.
///
/// Shows rotate (default) and marquee modes side-by-side for gallery proof.
class _StatusTickerDemo extends StatelessWidget {
  const _StatusTickerDemo();

  @override
  Widget build(BuildContext context) {
    final items = DSStatusTickerFixtures.mockFeed();
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DSText.labelSmall(
              'Rotate (auto · pause on hover)',
              color: DSColors.textTertiary,
            ),
            const SizedBox(height: DSSpacing.xs),
            DSStatusTicker(
              items: items,
              mode: DSStatusTickerMode.rotate,
              rotateInterval: const Duration(seconds: 2),
              height: 36,
            ),
            const SizedBox(height: DSSpacing.sm),
            const DSText.labelSmall(
              'Marquee (seamless track)',
              color: DSColors.textTertiary,
            ),
            const SizedBox(height: DSSpacing.xs),
            DSStatusTicker(
              items: items,
              mode: DSStatusTickerMode.marquee,
              marqueePeriod: const Duration(seconds: 18),
              height: 36,
            ),
          ],
        ),
      ),
    );
  }
}

/// Combined stand-alone stage chrome pack (Task 1509).
///
/// Hosts [DSWatchlistDock], [DSCoordinateStatusBar], and [DSMapLegend] over a
/// plain stage placeholder — no MapLibre, no MapHudWorkspace hard dependency.
class _StageChromePackDemo extends StatefulWidget {
  const _StageChromePackDemo();

  @override
  State<_StageChromePackDemo> createState() => _StageChromePackDemoState();
}

class _StageChromePackDemoState extends State<_StageChromePackDemo> {
  String? _selectedId;
  String? _lastAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.obsidianDeep,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 260,
                    child: DSWatchlistDock(
                      items: DSWatchlistFixtures.defaultItems,
                      selectedId: _selectedId,
                      onSelect: (item) {
                        setState(() {
                          _selectedId = item.id;
                          _lastAction = 'select ${item.label}';
                        });
                      },
                      onUnpin: (item) {
                        setState(() {
                          if (_selectedId == item.id) _selectedId = null;
                          _lastAction = 'unpin ${item.label}';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Stack(
                      children: [
                        // Stage placeholder (soft-dep host for HUD demos)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: DSColors.obsidianBase,
                              borderRadius: BorderRadius.circular(DSRadii.card),
                              border: Border.all(color: DSColors.borderSubtle),
                            ),
                            child: Center(
                              child: DSText.labelSmall(
                                _lastAction == null
                                    ? 'Stage placeholder (fixture)'
                                    : 'Last: $_lastAction',
                                color: DSColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: DSSpacing.sm,
                          top: DSSpacing.sm,
                          width: 240,
                          child: DSMapLegend(
                            categories: DSMapLegendFixtures.defaultCategories,
                            onVisibilityChanged: (id, visible) {
                              setState(() {
                                _lastAction =
                                    '${visible ? 'show' : 'hide'} $id';
                              });
                            },
                          ),
                        ),
                        const Positioned(
                          left: DSSpacing.sm,
                          right: DSSpacing.sm,
                          bottom: DSSpacing.sm,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: DSCoordinateStatusBar(
                              latitude:
                                  DSCoordinateStatusFixtures.defaultLatitude,
                              longitude:
                                  DSCoordinateStatusFixtures.defaultLongitude,
                              placeLabel:
                                  DSCoordinateStatusFixtures.defaultPlaceLabel,
                              styleLabel:
                                  DSCoordinateStatusFixtures.defaultStyleLabel,
                              secondaryMetric: 'z 11.2',
                              feeds: DSCoordinateStatusFixtures.defaultFeeds,
                              dense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewPresetsDemo extends StatefulWidget {
  const _ViewPresetsDemo();

  @override
  State<_ViewPresetsDemo> createState() => _ViewPresetsDemoState();
}

class _ViewPresetsDemoState extends State<_ViewPresetsDemo> {
  String? _activeId = 'preset-1';
  String _feedback = 'Selected: Global view';

  final List<DSViewPreset> _presets = const [
    DSViewPreset(
      id: 'preset-1',
      name: 'Global view',
      description: 'Optimal full-fleet zoom level (z 1.5, active layers: 3)',
      payload: {'zoom': 1.5, 'center': '0.0, 0.0'},
    ),
    DSViewPreset(
      id: 'preset-2',
      name: 'Agent Alpha sector',
      description:
          'Focus on primary execution cluster (z 14.5, coord: 34.052, -118.243)',
      payload: {'zoom': 14.5, 'center': '34.052, -118.243'},
    ),
    DSViewPreset(
      id: 'preset-3',
      name: 'Workspace Omega',
      description: 'Obsidian vault core (z 11.2, coord: 37.774, -122.419)',
      payload: {'zoom': 11.2, 'center': '37.774, -122.419'},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DSViewPresets(
          presets: _presets,
          activePresetId: _activeId,
          onSelected: (preset) {
            setState(() {
              _activeId = preset.id;
              _feedback = 'Selected: ${preset.name}';
            });
          },
        ),
        const SizedBox(height: DSSpacing.sm),
        DSText.labelSmall(_feedback, color: DSColors.textSecondary),
      ],
    );
  }
}

class _WorkspaceShareCardDemo extends StatelessWidget {
  const _WorkspaceShareCardDemo();

  @override
  Widget build(BuildContext context) {
    const summary = DSWorkspaceShareSummary(
      workspaceId: 'ws-obsidian-omega-12',
      workspaceName: 'Obsidian Omega 12',
      activePresetName: 'Agent Alpha sector',
      activeLayers: ['Agent Status', 'Task Grid', 'Active Spans'],
      cameraCenter: 'Lat: 34.052, Lng: -118.243',
      cameraZoom: 14.5,
      agentCount: 12,
      taskCount: 42,
      shareUrl:
          'https://warp-prism.ganthritor.local/share/ws-obsidian-omega-12?preset=preset-2',
    );

    return DSWorkspaceShareCard(
      summary: summary,
      onShare: (url) {
        // Safe callback validation feedback in fixture/gallery context
      },
    );
  }
}

class _TerminalWorkspaceDemo extends StatefulWidget {
  const _TerminalWorkspaceDemo();

  @override
  State<_TerminalWorkspaceDemo> createState() => _TerminalWorkspaceDemoState();
}

class _TerminalWorkspaceDemoState extends State<_TerminalWorkspaceDemo> {
  late final DSTerminalWorkspaceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DSTerminalWorkspaceController(
      panes: [
        const DSTerminalPane(
          id: 'term-main',
          title: 'Main Terminal',
          icon: Icons.terminal_outlined,
          history: [
            '[SYSTEM] Initializing Main Terminal...',
            '[SYSTEM] Connection established with OmniRoute bridge.',
            '[SYSTEM] Type "help" to view custom commands.',
          ],
        ),
        const DSTerminalPane(
          id: 'term-alpha',
          title: 'Agent Alpha Logs',
          icon: Icons.psychology_outlined,
          history: [
            '[ALPHA] Core engine online.',
            '[ALPHA] Listening to workspace events...',
          ],
        ),
      ],
      layoutMode: DSTerminalLayoutMode.splitHorizontal,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCommand(String paneId, String command) {
    _controller.addHistoryLine(paneId, '> $command');
    final cmd = command.toLowerCase().trim();
    if (cmd == 'help') {
      _controller.addHistoryLine(
        paneId,
        '[SYSTEM] Available commands: help, clear, status, ping',
      );
    } else if (cmd == 'clear' || cmd == 'cls') {
      _controller.clearHistory(paneId);
      _controller.addHistoryLine(paneId, '[SYSTEM] Console buffer cleared.');
    } else if (cmd == 'status') {
      _controller.addHistoryLine(
        paneId,
        '[SYSTEM] Status: OK. Connection healthy.',
      );
    } else if (cmd == 'ping') {
      _controller.addHistoryLine(paneId, 'pong');
    } else {
      _controller.addHistoryLine(
        paneId,
        'Command unrecognized: "$command". Type "help".',
      );
    }
  }

  int _paneCounter = 1;

  void _handleAddPane() {
    _paneCounter++;
    _controller.addPane(
      DSTerminalPane(
        id: 'term-extra-$_paneCounter',
        title: 'Tactical Term $_paneCounter',
        icon: Icons.code_outlined,
        history: ['[SYSTEM] Tactical unit $_paneCounter connected.'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DSTerminalWorkspace(
      controller: _controller,
      onCommandSubmitted: _handleCommand,
      onAddPane: _handleAddPane,
    );
  }
}

class _AgentShellPanelDemo extends StatefulWidget {
  const _AgentShellPanelDemo();

  @override
  State<_AgentShellPanelDemo> createState() => _AgentShellPanelDemoState();
}

class _AgentShellPanelDemoState extends State<_AgentShellPanelDemo> {
  final DSAgentShellPanelController _controller = DSAgentShellPanelController(
    initialLines: [
      DSAgentShellLine(
        id: 'line-0',
        text: 'Initializing builders agent subprocess...',
        type: DSAgentShellLineType.system,
        timestamp: DateTime.now().subtract(const Duration(seconds: 4)),
      ),
      DSAgentShellLine(
        id: 'line-1',
        text: 'builders onboard starting on lane: builders',
        type: DSAgentShellLineType.stdout,
        timestamp: DateTime.now().subtract(const Duration(seconds: 3)),
      ),
      DSAgentShellLine(
        id: 'line-2',
        text: '> git status --short',
        type: DSAgentShellLineType.input,
        timestamp: DateTime.now().subtract(const Duration(seconds: 2)),
      ),
      DSAgentShellLine(
        id: 'line-3',
        text: ' M packages/warp_prism_ui/lib/src/prism_aliases.dart',
        type: DSAgentShellLineType.stdout,
        timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
      ),
    ],
  );
  int _lineCounter = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _appendDummyLine() {
    _lineCounter++;
    final type = switch (_lineCounter % 4) {
      0 => DSAgentShellLineType.stdout,
      1 => DSAgentShellLineType.stderr,
      2 => DSAgentShellLineType.input,
      _ => DSAgentShellLineType.system,
    };
    final text = switch (type) {
      DSAgentShellLineType.stdout => 'Job batch $_lineCounter complete.',
      DSAgentShellLineType.stderr =>
        'Error: connection reset by peer (attempt $_lineCounter/3)',
      DSAgentShellLineType.input => '> check boundaries --verbose',
      DSAgentShellLineType.system => 'Subagent session state: execution idle',
    };
    _controller.appendLine(
      DSAgentShellLine(
        id: 'dummy-$_lineCounter',
        text: text,
        type: type,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: DSAgentShellPanel(
            controller: _controller,
            title: 'Agent Shell Panel',
            subtitle: 'session-id: tx-889a-02',
            onClear: () {
              _controller.clear();
            },
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Semantics(
              label: 'Append mock line to agent shell',
              button: true,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 14),
                label: const DSText.labelSmall('Append Line'),
                onPressed: _appendDummyLine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DSColors.obsidianBase,
                  foregroundColor: DSColors.accentCyan,
                  side: const BorderSide(color: DSColors.borderSubtle),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// EPIC-15 optional Wave I polish demos (Tasks 1522 / 1523)
// =============================================================================

class _KeyboardCheatsheetDemo extends StatefulWidget {
  const _KeyboardCheatsheetDemo();

  @override
  State<_KeyboardCheatsheetDemo> createState() =>
      _KeyboardCheatsheetDemoState();
}

class _KeyboardCheatsheetDemoState extends State<_KeyboardCheatsheetDemo> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.obsidianBase,
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: DSColors.borderDefault),
      ),
      child: Stack(
        children: [
          Center(
            child: Semantics(
              label: _open
                  ? 'Keyboard cheatsheet is open'
                  : 'Open keyboard cheatsheet',
              button: true,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _open = true),
                icon: const Icon(Icons.keyboard_alt_outlined, size: 16),
                label: const DSText.labelSmall('Show cheatsheet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DSColors.obsidianElevated,
                  foregroundColor: DSColors.accentCyan,
                  side: const BorderSide(color: DSColors.borderSubtle),
                ),
              ),
            ),
          ),
          if (_open)
            Positioned.fill(
              child: DSKeyboardCheatsheet(
                groups: DSKeyboardCheatsheetFixtures.defaultGroups(),
                onClose: () => setState(() => _open = false),
              ),
            ),
        ],
      ),
    );
  }
}

class _MediaDetailOverlayDemo extends StatefulWidget {
  const _MediaDetailOverlayDemo();

  @override
  State<_MediaDetailOverlayDemo> createState() =>
      _MediaDetailOverlayDemoState();
}

class _MediaDetailOverlayDemoState extends State<_MediaDetailOverlayDemo> {
  bool _open = false;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.obsidianBase,
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: DSColors.borderDefault),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: 'Open media detail overlay',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() {
                      _open = true;
                      _index = 0;
                    }),
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: const DSText.labelSmall('Open media overlay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DSColors.obsidianElevated,
                      foregroundColor: DSColors.accentCyan,
                      side: const BorderSide(color: DSColors.borderSubtle),
                    ),
                  ),
                ),
                if (!_open) ...[
                  const SizedBox(height: DSSpacing.sm),
                  DSText.labelSmall(
                    'Last index: $_index · fixture stills only',
                    color: DSColors.textTertiary,
                  ),
                ],
              ],
            ),
          ),
          if (_open)
            Positioned.fill(
              child: DSMediaDetailOverlay(
                items: DSMediaDetailFixtures.defaultItems(),
                initialIndex: _index,
                onIndexChanged: (i) => setState(() => _index = i),
                onClose: () => setState(() => _open = false),
              ),
            ),
        ],
      ),
    );
  }
}

class _BreadcrumbsDemo extends StatefulWidget {
  const _BreadcrumbsDemo();

  @override
  State<_BreadcrumbsDemo> createState() => _BreadcrumbsDemoState();
}

class _BreadcrumbsDemoState extends State<_BreadcrumbsDemo> {
  String _lastTapped = 'None';

  @override
  Widget build(BuildContext context) {
    const shortPath = [
      DSBreadcrumbItem(label: 'Home', icon: Icons.home_outlined),
      DSBreadcrumbItem(label: 'Workspace', icon: Icons.work_outline),
      DSBreadcrumbItem(label: 'Dashboard'),
    ];

    const longPath = [
      DSBreadcrumbItem(label: 'Root', icon: Icons.folder_outlined),
      DSBreadcrumbItem(label: 'Projects'),
      DSBreadcrumbItem(label: 'WarpPrism'),
      DSBreadcrumbItem(label: 'Packages'),
      DSBreadcrumbItem(label: 'warp_prism_ui'),
      DSBreadcrumbItem(label: 'DSBreadcrumbs'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText.labelSmall('Short Path (with icons):', color: DSColors.textTertiary),
        const SizedBox(height: DSSpacing.xs),
        DSBreadcrumbs(
          items: shortPath,
          onItemTap: (item) => setState(() => _lastTapped = item.label),
        ),
        const SizedBox(height: DSSpacing.md),

        DSText.labelSmall(
          'Long Truncated Path (maxItems: 4):',
          color: DSColors.textTertiary,
        ),
        const SizedBox(height: DSSpacing.xs),
        DSBreadcrumbs(
          items: longPath,
          maxItems: 4,
          onItemTap: (item) => setState(() => _lastTapped = item.label),
        ),
        const SizedBox(height: DSSpacing.sm),

        DSText.labelSmall(
          'Last tapped item: $_lastTapped',
          color: DSColors.accentCyan,
        ),
      ],
    );
  }
}

class _SwitchDemo extends StatefulWidget {
  const _SwitchDemo();

  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  bool _switch1 = false;
  bool _switch2 = true;
  bool _switch3 = false;
  bool _switch4 = true;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DSSpacing.lg,
      runSpacing: DSSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DSSwitch(
          value: _switch1,
          onChanged: (v) => setState(() => _switch1 = v),
          semanticLabel: 'Off switch demo',
        ),
        DSSwitch(
          value: _switch2,
          onChanged: (v) => setState(() => _switch2 = v),
          semanticLabel: 'On switch demo',
        ),
        DSSwitch(
          value: _switch3,
          onChanged: (v) => setState(() => _switch3 = v),
          label: 'Off with label',
        ),
        DSSwitch(
          value: _switch4,
          onChanged: (v) => setState(() => _switch4 = v),
          label: 'On with label',
        ),
        const DSSwitch(
          value: false,
          enabled: false,
          label: 'Disabled Off',
        ),
        const DSSwitch(
          value: true,
          enabled: false,
          label: 'Disabled On',
        ),
      ],
    );
  }
}

class _TextFieldDemo extends StatefulWidget {
  const _TextFieldDemo();

  @override
  State<_TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<_TextFieldDemo> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DSTextField(
                label: 'Standard Input',
                hint: 'Enter workspace name...',
                helperText: 'Must be unique within region',
              ),
              const SizedBox(height: DSSpacing.md),
              const DSTextField(
                label: 'With Prefix Icon',
                hint: 'Search agents or skills...',
                prefixIcon: DSIcons.search,
              ),
              const SizedBox(height: DSSpacing.md),
              DSTextField(
                label: 'Password Input',
                hint: 'Enter secret key...',
                prefixIcon: Icons.vpn_key_outlined,
                suffixIcon: _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                obscureText: _obscurePassword,
                onSuffixTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                suffixSemanticsLabel: 'Toggle password visibility',
              ),
              const SizedBox(height: DSSpacing.md),
              const DSTextField(
                label: 'Error State',
                hint: 'user@domain.com',
                errorText: 'Invalid email address',
                prefixIcon: DSIcons.error,
              ),
              const SizedBox(height: DSSpacing.md),
              const DSTextField(
                label: 'Disabled Field',
                hint: 'Read only setting...',
                enabled: false,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: DSSpacing.md),
              const DSTextField(
                label: 'Multiline Text Area',
                hint: 'Enter task description or notes...',
                maxLines: 3,
                minLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ButtonDemo extends StatelessWidget {
  const _ButtonDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variants x Enabled
        const DSText.labelSmall('Variants (Enabled)', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.xs),
        Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DSButton.primary(
              label: 'Primary',
              onPressed: () {},
            ),
            DSButton.secondary(
              label: 'Secondary',
              onPressed: () {},
            ),
            DSButton.outline(
              label: 'Outline',
              onPressed: () {},
            ),
            DSButton.ghost(
              label: 'Ghost',
              onPressed: () {},
            ),
            DSButton.danger(
              label: 'Danger',
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),

        // With Icons
        const DSText.labelSmall('With Icons', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.xs),
        Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DSButton.primary(
              label: 'Launch',
              icon: DSIcons.operate,
              onPressed: () {},
            ),
            DSButton.secondary(
              label: 'Filter',
              icon: DSIcons.filter,
              trailingIcon: DSIcons.expand,
              onPressed: () {},
            ),
            DSButton.danger(
              label: 'Delete',
              icon: DSIcons.delete,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),

        // Sizes
        const DSText.labelSmall('Sizes (Small, Medium, Large)', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.xs),
        Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DSButton.primary(
              label: 'Small',
              size: DSButtonSize.sm,
              icon: DSIcons.agent,
              onPressed: () {},
            ),
            DSButton.primary(
              label: 'Medium',
              size: DSButtonSize.md,
              icon: DSIcons.agent,
              onPressed: () {},
            ),
            DSButton.primary(
              label: 'Large',
              size: DSButtonSize.lg,
              icon: DSIcons.agent,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),

        // Disabled State
        const DSText.labelSmall('Disabled State', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.xs),
        const Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DSButton.primary(
              label: 'Primary',
              enabled: false,
            ),
            DSButton.secondary(
              label: 'Secondary',
              enabled: false,
            ),
            DSButton.outline(
              label: 'Outline',
              enabled: false,
            ),
            DSButton.ghost(
              label: 'Ghost',
              enabled: false,
            ),
            DSButton.danger(
              label: 'Danger',
              enabled: false,
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),

        // Loading State
        const DSText.labelSmall('Loading State', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.xs),
        const Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DSButton.primary(
              label: 'Primary',
              isLoading: true,
            ),
            DSButton.secondary(
              label: 'Secondary',
              isLoading: true,
            ),
            DSButton.outline(
              label: 'Outline',
              isLoading: true,
            ),
            DSButton.ghost(
              label: 'Ghost',
              isLoading: true,
            ),
            DSButton.danger(
              label: 'Danger',
              isLoading: true,
            ),
          ],
        ),
      ],
    );
  }
}
