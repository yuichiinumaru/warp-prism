/// Design System Gallery — the first runnable Warp Prism surface.
///
/// This page demonstrates every atomic design layer (tokens, atoms,
/// molecules, organisms, templates) in a scrollable layout.  It is
/// registered at `/design-system` in the router and serves as the
/// proof surface for the entire DS before any product screen ships.
library;

import 'package:flutter/material.dart';
import '../../warp_prism_ui.dart';
import 'design_system_gallery_sections.dart';

/// Gallery page showcasing the full Warp Prism design system.
///
/// Read-only — no data dependencies, no providers, no mock workspace.
/// Pure visual proof of the atomic design layers.
class DesignSystemGalleryPage extends StatelessWidget {
  const DesignSystemGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.obsidianDeep,
      child: ListView(
        padding: const EdgeInsets.all(DSSpacing.xl),
        children: [
          // Page header
          _buildHeader(),
          const SizedBox(height: DSSpacing.xxl),

          // Atomic layers
          DSGallerySections.buildTokensSection(),
          const SizedBox(height: DSSpacing.xxl),
          DSGallerySections.buildAtomsSection(),
          const SizedBox(height: DSSpacing.xxl),
          DSGallerySections.buildMoleculesSection(),
          const SizedBox(height: DSSpacing.xxl),
          DSGallerySections.buildOperationalStatesSection(),
          const SizedBox(height: DSSpacing.xxl),
          DSGallerySections.buildOrganismsSection(),
          const SizedBox(height: DSSpacing.xxl),
          DSGallerySections.buildVirtualScrollSection(),
          const SizedBox(height: DSSpacing.xxl),
          DSGallerySections.buildHealthDashboardSection(),
          const SizedBox(height: DSSpacing.xxl),
          DSGallerySections.buildToastsSection(),
          const SizedBox(height: DSSpacing.xxl),
          DSGallerySections.buildAccessibilitySection(),
          const SizedBox(height: DSSpacing.xxl),
          DSGallerySections.buildTemplatesSection(),

          // Footer
          const SizedBox(height: DSSpacing.huge),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return DSGlassPanelSimple(
      padding: const EdgeInsets.all(DSSpacing.xxl),
      borderColor: DSColors.accentCyan.withOpacity(0.3),
      child: Row(
        children: [
          // Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [DSColors.accentCyan, DSColors.accentViolet],
              ),
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            child: const Center(
              child: DSIcon(Icons.hub, color: DSColors.white, size: 24),
            ),
          ),
          const SizedBox(width: DSSpacing.lg),

          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.headingLarge('Design System Gallery'),
                const SizedBox(height: DSSpacing.xs),
                DSText.bodyMedium(
                  'Warp Prism atomic design proof — tokens, atoms, molecules, '
                  'organisms, and templates demonstrated in one surface.',
                  color: DSColors.textSecondary,
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: DSColors.statusSuccess.withOpacity(0.15),
              borderRadius: BorderRadius.circular(DSRadii.chip),
              border: Border.all(
                color: DSColors.statusSuccess.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSIcon.small(
                  Icons.check_circle_outline,
                  color: DSColors.statusSuccess,
                ),
                const SizedBox(width: DSSpacing.xs),
                DSText.labelMedium('DS Layer', color: DSColors.statusSuccess),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: DSText.bodySmall(
        'ASW Observatory · Warp Prism · Design System v0.1.0',
        color: DSColors.textTertiary,
      ),
    );
  }
}
