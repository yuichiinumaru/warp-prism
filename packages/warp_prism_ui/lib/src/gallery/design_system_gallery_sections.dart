/// Design System Gallery — reusable section builders.
///
/// Each static method returns a widget tree that showcases one atomic layer
/// (tokens, atoms, molecules, organisms, templates) in a consistent card
/// layout.  The gallery page composes these sections into a scrollable list.
library;

import 'package:flutter/material.dart';
import '../../warp_prism_ui.dart';

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
        DSText.labelLarge('Color Palette', color: DSColors.textSecondary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText.labelLarge('Typography', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.sm),
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
      _ScaleDef('xxs', DSSpacing.xxs),
      _ScaleDef('xs', DSSpacing.xs),
      _ScaleDef('sm', DSSpacing.sm),
      _ScaleDef('md', DSSpacing.md),
      _ScaleDef('lg', DSSpacing.lg),
      _ScaleDef('xl', DSSpacing.xl),
      _ScaleDef('xxl', DSSpacing.xxl),
      _ScaleDef('xxxl', DSSpacing.xxxl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText.labelLarge('Spacing Scale', color: DSColors.textSecondary),
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
                    color: DSColors.accentCyan.withOpacity(0.3),
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
      _ScaleDef('none', DSRadii.none),
      _ScaleDef('xs', DSRadii.xs),
      _ScaleDef('sm', DSRadii.sm),
      _ScaleDef('md', DSRadii.md),
      _ScaleDef('lg', DSRadii.lg),
      _ScaleDef('xl', DSRadii.xl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText.labelLarge('Radii Scale', color: DSColors.textSecondary),
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
        DSText.labelLarge('Shadows', color: DSColors.textSecondary),
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
        DSText.labelLarge('Motion', color: DSColors.textSecondary),
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
          'DSText · DSIcon · DSBadge · DSChip · DSStatusDot · DSDivider · DSGlowBorder · DSGlassPanel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text variants
          DSText.labelLarge('Text Variants', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          DSText.headingMedium('Heading Medium'),
          DSText.bodyMedium('Body medium text'),
          DSText.labelSmall('Label small'),
          const SizedBox(height: DSSpacing.md),

          // Icons
          DSText.labelLarge('Icons', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
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
          const SizedBox(height: DSSpacing.md),

          // Badges
          DSText.labelLarge('Badges', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            children: [
              DSBadge.count(3, color: DSColors.accentCyan),
              DSBadge.count(42, color: DSColors.accentViolet),
              DSBadge.count(7, color: DSColors.statusWarning),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // Chips
          DSText.labelLarge('Chips', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            children: [
              DSChip(label: 'Agent', color: DSColors.assetAgent),
              DSChip(label: 'Skill', color: DSColors.assetSkill),
              DSChip(label: 'Workflow', color: DSColors.assetWorkflow),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // Status dots
          DSText.labelLarge('Status Dots', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.md,
            children: const [
              DSStatusDot.success(tooltip: 'Success'),
              DSStatusDot.warning(tooltip: 'Warning'),
              DSStatusDot.error(tooltip: 'Error'),
              DSStatusDot.info(tooltip: 'Info'),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // Dividers
          DSText.labelLarge('Dividers', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const DSDivider.subtle(),
          const SizedBox(height: DSSpacing.sm),
          const DSDivider.glow(),

          const SizedBox(height: DSSpacing.md),

          // Glass panels
          DSText.labelLarge('Glass Panels', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.md),
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
          'DSSearchBar · DSFilterChipGroup · DSAssetCard · DSTaskCard · DSTimelineMarker · DSStateSurface · DSShimmer · DSSkeletonCard · DSSkeletonTableRows · DSSkeletonTextLine',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          DSText.labelLarge('Search Bar', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            width: 360,
            child: DSSearchBar(placeholder: 'Search assets...'),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Filter chips
          DSText.labelLarge('Filter Chip Group', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          DSFilterChipGroup(
            options: const [
              DSFilterOption(value: 'agent', label: 'Agent', count: 5),
              DSFilterOption(value: 'skill', label: 'Skill', count: 12),
              DSFilterOption(value: 'workflow', label: 'Workflow', count: 3),
            ],
            selected: const {'agent'},
          ),
          const SizedBox(height: DSSpacing.lg),

          // Metric tile
          DSText.labelLarge('Metric Tile', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            width: 200,
            child: DSMetricTile(
              label: 'Total Assets',
              value: '47',
              icon: Icons.hub_outlined,
              color: DSColors.accentCyan,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Provenance pill
          DSText.labelLarge('Provenance Pill', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            children: const [
              DSProvenancePill(canonicality: 'parentcanonical'),
              DSProvenancePill(canonicality: 'childlocal'),
              DSProvenancePill(canonicality: 'generated'),
              DSProvenancePill(canonicality: 'mock'),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // State surfaces
          DSText.labelLarge('State Surfaces', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          DSStateSurface.empty(
            icon: Icons.inbox_outlined,
            title: 'No assets loaded',
            subtitle: 'The workspace will populate once assets are parsed',
            compact: true,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSStateSurface.loading(title: 'Loading workspace...', compact: true),
          const SizedBox(height: DSSpacing.sm),
          DSStateSurface.error(
            title: 'Failed to parse workspace',
            subtitle: 'Unexpected token at line 42',
            compact: true,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSStateSurface.disabled(title: 'Feature disabled', compact: true),
          const SizedBox(height: DSSpacing.sm),
          DSStateSurface.stale(title: 'Data outdated', compact: true),
          const SizedBox(height: DSSpacing.sm),
          DSStateSurface.degraded(
            title: 'Partial data available',
            compact: true,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSStateSurface.excluded(
            title: 'Filtered out by governance',
            compact: true,
          ),
          const SizedBox(height: DSSpacing.lg),

          // Shimmer
          DSText.labelLarge(
            'Shimmer (base animation)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSShimmer(width: 200, height: 16),
          const SizedBox(height: DSSpacing.sm),
          const DSShimmer(width: 48, height: 48, borderRadius: DSRadii.full),
          const SizedBox(height: DSSpacing.lg),

          // Skeleton Text Line
          DSText.labelLarge(
            'Skeleton Text Line',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSSkeletonTextLine(widthFactor: 1.0),
          const SizedBox(height: DSSpacing.xs),
          const DSSkeletonTextLine(widthFactor: 0.7),
          const SizedBox(height: DSSpacing.xs),
          const DSSkeletonTextLine(widthFactor: 0.4),
          const SizedBox(height: DSSpacing.lg),

          // Skeleton Card
          DSText.labelLarge('Skeleton Card', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(width: 360, child: DSSkeletonCard()),
          const SizedBox(height: DSSpacing.lg),

          // Skeleton Table Rows
          DSText.labelLarge(
            'Skeleton Table Rows (3 rows)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSSkeletonTableRows(
            rowCount: 3,
            columnWidths: [0.25, 0.45, 0.3],
          ),
          const SizedBox(height: DSSpacing.lg),
          DSText.labelLarge(
            'Skeleton Table Rows (5 rows)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSSkeletonTableRows(
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
          DSText.labelLarge('Lifecycle', color: DSColors.textSecondary),
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
          DSText.labelLarge('Health', color: DSColors.textSecondary),
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
          DSText.labelLarge('Verification', color: DSColors.textSecondary),
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
          DSText.labelLarge('Governance', color: DSColors.textSecondary),
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
          DSText.labelLarge(
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
          DSText.labelLarge(
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
          DSText.labelLarge(
            'Behavioral Contracts',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          _BehavioralContractTable(),
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
          'DSShell · DSSidebar · DSTopbar · DSLaneBoard · DSTimeline · DSDetailInspector · DSStoryPanel · DSGraphCanvas · DSCodeBlock · DSMarkdownRenderer · DSErrorBoundary · DSFallbackView · DSTabBar · DSSplitPane',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar preview
          DSText.labelLarge(
            'DSSidebar (collapsed preview)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 260,
            child: DSSidebar(
              items: const [
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
          DSText.labelLarge('DSTopbar', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const DSTopbar(
            title: 'Map Workspace',
            breadcrumbs: ['Home', 'Map', 'Agent Alpha'],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Lane board preview
          DSText.labelLarge(
            'DSLaneBoard (sample lanes)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 240,
            child: DSLaneBoard(
              lanes: [
                DSLane(
                  id: '01-open',
                  label: 'Open',
                  tasks: [
                    const DSLaneTask(
                      id: 1,
                      title: 'Align organism APIs',
                      priority: 'high',
                    ),
                    const DSLaneTask(
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
                    const DSLaneTask(
                      id: 3,
                      title: 'Build data layer',
                      priority: 'high',
                    ),
                  ],
                ),
                DSLane(id: '03-review', label: 'Review', tasks: const []),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Timeline preview
          DSText.labelLarge('DSTimeline', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 260,
            child: DSTimeline(
              entries: const [
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
          DSText.labelLarge('DSStoryPanel', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          DSStoryPanel(
            title: 'Workspace Health',
            subtitle: 'Current state of the design system',
            icon: Icons.insights_outlined,
            accentColor: DSColors.accentCyan,
            insights: const [
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
          DSText.labelLarge(
            'DSGraphCanvas (empty state)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 200,
            child: DSGraphCanvas(nodes: [], edges: []),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Graph canvas preview — force-directed layout with sample data
          DSText.labelLarge(
            'DSGraphCanvas (force-directed layout)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 300,
            child: DSGraphCanvas(
              nodes: [
                GraphNode(id: 'agent-1', label: 'Builder', type: 'agent'),
                GraphNode(id: 'skill-1', label: 'Analyze', type: 'skill'),
                GraphNode(id: 'skill-2', label: 'Refactor', type: 'skill'),
                GraphNode(id: 'wf-1', label: 'CI/CD', type: 'workflow'),
                GraphNode(id: 'task-1', label: 'Task 1117', type: 'task'),
                GraphNode(id: 'doc-1', label: 'ADS Spec', type: 'doc'),
              ],
              edges: [
                const GraphEdge(
                  sourceId: 'agent-1',
                  targetId: 'skill-1',
                  edgeType: 'uses',
                ),
                const GraphEdge(
                  sourceId: 'agent-1',
                  targetId: 'skill-2',
                  edgeType: 'uses',
                ),
                const GraphEdge(
                  sourceId: 'skill-1',
                  targetId: 'wf-1',
                  edgeType: 'triggers',
                ),
                const GraphEdge(
                  sourceId: 'skill-2',
                  targetId: 'task-1',
                  edgeType: 'references',
                ),
                const GraphEdge(
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
          DSText.labelLarge(
            'DSErrorBoundary (with retry)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSErrorBoundary(
            child: DSGlassPanelSimple(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: DSText.bodyMedium(
                'Protected content — an error in this area will not crash the app.',
                color: DSColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          // Show a pre-crashed boundary to demonstrate the fallback view
          _ErrorBoundaryDemo(),
          const SizedBox(height: DSSpacing.lg),

          // Command palette preview
          DSText.labelLarge(
            'DSCommandPalette (trigger with Cmd+K)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          _CommandPalettePreview(),
          const SizedBox(height: DSSpacing.lg),

          // Log viewer preview
          DSText.labelLarge('DSLogViewer', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 300,
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
          DSText.labelLarge(
            'DSTabBar (3 closeable tabs with badges)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          _TabBarDemo(),
          const SizedBox(height: DSSpacing.lg),

          // DSTabBar overflow preview
          DSText.labelLarge(
            'DSTabBar (10 tabs — scrollable overflow)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          _TabBarOverflowDemo(),
          const SizedBox(height: DSSpacing.lg),

          // DSSplitPane horizontal preview
          DSText.labelLarge(
            'DSSplitPane (horizontal, draggable)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(height: 240, child: _SplitPaneDemo(axis: Axis.horizontal)),
          const SizedBox(height: DSSpacing.lg),

          // DSSplitPane vertical preview
          DSText.labelLarge(
            'DSSplitPane (vertical, draggable)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(height: 240, child: _SplitPaneDemo(axis: Axis.vertical)),
          const SizedBox(height: DSSpacing.lg),

          // DSCodeBlock — JSON config
          DSText.labelLarge(
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
          DSText.labelLarge(
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
          DSText.labelLarge(
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
          DSText.labelLarge(
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
          DSText.labelLarge(
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
          DSText.labelLarge(
            'DSMarkdownRenderer (task description)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: const DSMarkdownRenderer(
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
          DSText.labelLarge(
            'DSMarkdownRenderer (agent profile)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: const DSMarkdownRenderer(
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
    return _SectionCard(
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
          const SizedBox(height: DSSpacing.lg),

          // Interactive board: 3 lanes, one empty
          DSText.labelLarge(
            'Interactive Board (long-press to drag)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(height: 280, child: _DragDropDemo()),
          const SizedBox(height: DSSpacing.lg),

          // Visual feedback documentation
          DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelLarge(
                  'Visual Feedback',
                  color: DSColors.accentCyan,
                ),
                const SizedBox(height: DSSpacing.xs),
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
          DSText.labelLarge(
            'Focus Ring Pattern',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSText.bodySmall(
            'All interactive DS components use a 2px accentCyan border at 50% opacity '
            'when focused via keyboard.  This is the project-wide focus indicator.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.md),

          // Focusable chips — keyboard demo
          DSText.labelLarge(
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
              DSChip(label: 'Disabled', enabled: false),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Focusable filter chip group
          DSText.labelLarge(
            'Focusable Filter Chips',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSFilterChipGroup(
            options: const [
              DSFilterOption(value: 'agent', label: 'Agent', count: 5),
              DSFilterOption(value: 'skill', label: 'Skill', count: 12),
              DSFilterOption(value: 'workflow', label: 'Workflow', count: 3),
            ],
            selected: const {'skill'},
          ),
          const SizedBox(height: DSSpacing.lg),

          // Sidebar focus states
          DSText.labelLarge(
            'Sidebar Navigation (focusable items)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 200,
            child: DSSidebar(
              items: const [
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
          DSText.labelLarge(
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
          DSText.labelLarge(
            'Semantic Status Colors (WCAG AA)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
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
          DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelLarge('Contrast Rules', color: DSColors.accentCyan),
                const SizedBox(height: DSSpacing.xs),
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
          DSText.labelLarge('Severity Variants', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          _buildSeverityRow(),
          const SizedBox(height: DSSpacing.lg),

          // Toast with action button
          DSText.labelLarge(
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
          DSText.labelLarge('Long Message', color: DSColors.textSecondary),
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
          DSText.labelLarge(
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
          DSText.labelLarge('Auto-Dismiss', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          DSText.bodySmall(
            'Toasts auto-dismiss after a configurable duration (default 4s). '
            'Hover pauses the timer. Use DSToastManager.of(context).show(entry) '
            'to display toasts with auto-dismiss and overlay stacking.',
            color: DSColors.textTertiary,
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
          DSText.labelLarge(
            'Sortable Table with Status Cells',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 320,
            child: DSDataTable(
              columns: const [
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
          DSText.labelLarge('Paginated Table', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 300,
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
          DSText.labelLarge('Empty State', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(
            height: 200,
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
          DSText.labelLarge('Loading State', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 200,
            child: DSDataTable(
              columns: const [
                DSDataColumn(id: 'name', label: 'Name'),
                DSDataColumn(id: 'value', label: 'Value'),
              ],
              loading: true,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Error state
          DSText.labelLarge('Error State', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 200,
            child: DSDataTable(
              columns: const [
                DSDataColumn(id: 'name', label: 'Name'),
                DSDataColumn(id: 'value', label: 'Value'),
              ],
              errorMessage: 'Connection timed out after 30s',
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // Operational state vocabulary
          DSText.labelLarge(
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
          DSText.labelLarge('Secret Cell', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          const DSSecretCell(
            maskedValue: '••••••••••••abc1',
            fullValue: 'sk-1234567890abcdef',
          ),
          const SizedBox(height: DSSpacing.lg),

          // Actions cell
          DSText.labelLarge('Actions Cell', color: DSColors.textSecondary),
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
          DSText.labelLarge('Selectable Table', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 240,
            child: DSDataTable(
              columns: const [
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
      subtitle: 'DSVirtualList · DSVirtualGrid · 10K+ items at 60fps',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DSVirtualList — 1K fixed-height items
          DSText.labelLarge(
            'DSVirtualList — 1,000 fixed-height items',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSText.bodySmall(
            'Fixed 48px extent with O(1) scroll offset computation. '
            'Scroll to verify smooth rendering.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 300,
            child: DSVirtualList(
              itemCount: 1000,
              config: DSVirtualScrollConfig.fixed,
              semanticLabel: '1,000 fixed-height items',
              itemBuilder: (context, index) {
                return Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: DSColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      DSIcon.small(DSIcons.task, color: DSColors.accentCyan),
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
          DSText.labelLarge(
            'DSVirtualList — 5,000 variable-height items',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSText.bodySmall(
            'No itemExtent — falls back to standard variable-height layout. '
            'Still virtualized (only visible + cached items are built).',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 300,
            child: DSVirtualList(
              itemCount: 5000,
              config: DSVirtualScrollConfig.variable,
              semanticLabel: '5,000 variable-height items',
              itemBuilder: (context, index) {
                // Alternate between 1-line and 2-line items.
                final hasSubtitle = index % 3 == 0;
                return ListTile(
                  dense: true,
                  leading: DSIcon.small(
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
          DSText.labelLarge(
            'DSVirtualList — 10,000 fixed-height items',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSText.bodySmall(
            'High-cache config (500px cache) for fast scrollbar drags. '
            '10K rows rendered at 60fps.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 300,
            child: DSVirtualList(
              itemCount: 10000,
              config: DSVirtualScrollConfig.highCache,
              semanticLabel: '10,000 fixed-height items',
              itemBuilder: (context, index) {
                return Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
                  decoration: BoxDecoration(
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
          DSText.labelLarge(
            'DSVirtualGrid — 1,000 items (4 columns)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 300,
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
                      DSIcon(
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
          DSText.labelLarge(
            'DSVirtualGrid — 5,000 items (3 columns)',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 300,
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
                      DSIcon(
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
          DSText.labelLarge(
            'DSDataTable + DSVirtualList integration',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSText.bodySmall(
            'DSDataTable accepts a virtualScrollConfig parameter. When provided '
            'and paginated=false, the table body renders using DSVirtualList '
            'with explicit itemExtent for O(1) scroll offset computation. '
            'This is the recommended configuration for tables with 1K+ rows.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.sm),
          SizedBox(
            height: 300,
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
          DSText.labelLarge(
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
          DSText.labelLarge(
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
          DSText.labelLarge(
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
          DSText.labelLarge(
            'DSUptimeBar — threshold coloring',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const SizedBox(height: 24, child: DSUptimeBar(uptimePercent: 0.995)),
          const SizedBox(height: DSSpacing.sm),
          DSText.labelSmall(
            '99.5% — green (>99%)',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.md),
          const SizedBox(height: 24, child: DSUptimeBar(uptimePercent: 0.97)),
          const SizedBox(height: DSSpacing.sm),
          DSText.labelSmall('97% — amber (>95%)', color: DSColors.textTertiary),
          const SizedBox(height: DSSpacing.md),
          const SizedBox(height: 24, child: DSUptimeBar(uptimePercent: 0.80)),
          const SizedBox(height: DSSpacing.sm),
          DSText.labelSmall('80% — red (<=95%)', color: DSColors.textTertiary),
          const SizedBox(height: DSSpacing.lg),

          // DSHealthCard examples
          DSText.labelLarge(
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
              SizedBox(
                width: 260,
                child: DSHealthCard(
                  serviceName: 'Auth Service',
                  operationalState: DSOperationalState.disabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // DSStatusGrid — commented out: DSHealthCardData/DSStatusGrid pending from health dashboard task
          // DSText.labelLarge('DSStatusGrid — 12 mock services', color: DSColors.textSecondary),
          // const SizedBox(height: DSSpacing.sm),
          // DSStatusGrid(items: _mockHealthItems, maxCrossAxisExtent: 280, childAspectRatio: 1.5),
        ],
      ),
    );
  }

  // static final List<DSHealthCardData> _mockHealthItems = [
  //   DSHealthCardData(serviceName: 'MCP Server Alpha', operationalState: DSOperationalState.healthy, latency: Duration(milliseconds: 42), uptimePercent: 0.9995, trendData: [], lastCheck: DateTime.now()),
  // ];

  // _mockHealthItems commented out: DSHealthCardData pending from health dashboard task
  // static final List<DSHealthCardData> _mockHealthItems = [...];

  static Widget buildTemplatesSection() {
    return _SectionCard(
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
          const SizedBox(height: DSSpacing.md),
          _TemplatePreview(
            name: 'MasterDetailTemplate',
            description:
                'Sidebar + topbar + master list + detail inspector. '
                'Responsive: side-by-side ≥1200px, overlay 800-1199px, '
                'full-screen <800px.',
          ),
          const SizedBox(height: DSSpacing.sm),
          _TemplatePreview(
            name: 'CanvasTemplate',
            description:
                'Sidebar + topbar + full-bleed graph canvas + floating controls + '
                'overlay inspector panel.',
          ),
          const SizedBox(height: DSSpacing.sm),
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
        color: state.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: state.color.withOpacity(0.3)),
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
            child: Row(
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
              decoration: BoxDecoration(
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
          content: (_) => _DemoPane(
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
          content: (_) => _DemoPane(
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
          content: (_) => _DemoPane(
            label: 'Tasks',
            color: DSColors.assetTask,
            icon: DSIcons.task,
          ),
        ),
      ],
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
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
          SizedBox(height: 120, child: DSTabView(controller: _controller)),
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
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
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
          SizedBox(height: 100, child: DSTabView(controller: _controller)),
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
                    children: [
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
                DSText.bodySmall(
                  'Drag the divider to resize. '
                  'Double-click to collapse/expand.',
                  color: DSColors.textTertiary,
                ),
                const SizedBox(height: DSSpacing.md),
                DSText.labelMedium('agent-alpha', color: DSColors.textPrimary),
                DSText.bodySmall(
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
            DSText.labelMedium(widget.label, color: DSColors.textSecondary),
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
          DSIcon(Icons.view_quilt_outlined, color: DSColors.accentViolet),
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
                DSIcon(Icons.search, color: DSColors.accentCyan, size: 16),
                const SizedBox(width: DSSpacing.sm),
                DSText.bodyMedium(
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
                  child: DSText.labelSmall('ESC', color: DSColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.sm),

          // Category chips mock
          Row(
            children: [
              _PreviewChip(label: 'All', isActive: true),
              const SizedBox(width: DSSpacing.xs),
              _PreviewChip(label: 'Navigate', isActive: false),
              const SizedBox(width: DSSpacing.xs),
              _PreviewChip(label: 'Run', isActive: false),
              const SizedBox(width: DSSpacing.xs),
              _PreviewChip(label: 'Recent', isActive: false),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),

          // Sample command items
          _PreviewCommandItem(
            icon: DSIcons.map,
            label: 'Map Workspace',
            description: 'Navigate to the asset map',
            isSelected: true,
          ),
          _PreviewCommandItem(
            icon: DSIcons.operate,
            label: 'Operate — Task Board',
            description: 'Navigate to the task board',
            isSelected: false,
          ),
          _PreviewCommandItem(
            icon: DSIcons.governance,
            label: 'Governance View',
            description: 'Navigate to governance diagnostics',
            isSelected: false,
          ),
          const SizedBox(height: DSSpacing.sm),

          // Keyboard hints
          Row(
            children: [
              DSText.labelSmall('↑↓', color: DSColors.textDisabled),
              const SizedBox(width: DSSpacing.xs),
              DSText.labelSmall('navigate', color: DSColors.textDisabled),
              const SizedBox(width: DSSpacing.md),
              DSText.labelSmall('↵', color: DSColors.textDisabled),
              const SizedBox(width: DSSpacing.xs),
              DSText.labelSmall('select', color: DSColors.textDisabled),
              const SizedBox(width: DSSpacing.md),
              DSText.labelSmall('esc', color: DSColors.textDisabled),
              const SizedBox(width: DSSpacing.xs),
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
