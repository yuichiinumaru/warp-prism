/// Design System Gallery — the first runnable Warp Prism surface.
///
/// This page demonstrates every atomic design layer (tokens, atoms,
/// molecules, organisms, templates) in a scrollable layout.  It is
/// registered at `/design-system` in the router and serves as the
/// proof surface for the entire DS before any product screen ships.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../atoms/atoms.dart';
import '../tokens/tokens.dart';
import 'design_system_gallery_registry.dart';

/// Gallery page showcasing the full Warp Prism design system.
///
/// Read-only — no data dependencies, no providers, no mock workspace.
/// Pure visual proof of the atomic design layers.
///
/// Includes a registry-driven section index (TOC) so stakeholders can jump
/// to Tokens / Atoms / Organisms without endless scrolling. Section [id]s
/// come from [dsGallerySections] and must stay stable for Task 1613.
class DesignSystemGalleryPage extends StatefulWidget {
  const DesignSystemGalleryPage({super.key});

  @override
  State<DesignSystemGalleryPage> createState() =>
      _DesignSystemGalleryPageState();
}

class _DesignSystemGalleryPageState extends State<DesignSystemGalleryPage> {
  final ScrollController _scrollController = ScrollController();

  /// One [GlobalKey] per registry section for [Scrollable.ensureVisible] jumps.
  late final List<GlobalKey> _sectionKeys = List<GlobalKey>.generate(
    dsGallerySections.length,
    (index) => GlobalKey(
      debugLabel: 'gallery-section-${dsGallerySections[index].id}',
    ),
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Jump to a registry section.
  ///
  /// Lazy [ListView] may not have mounted far sections yet — page down until
  /// the section key has a context, then [Scrollable.ensureVisible].
  Future<void> _jumpToSection(int index) async {
    if (index < 0 || index >= _sectionKeys.length) return;
    final key = _sectionKeys[index];

    for (var attempt = 0; attempt < 48; attempt++) {
      if (!mounted) return;
      final targetContext = key.currentContext;
      if (targetContext != null && targetContext.mounted) {
        await Scrollable.ensureVisible(
          targetContext,
          duration: DSMotion.pageDuration,
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
        return;
      }

      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent) return;

      final next = (position.pixels + 640).clamp(
        0.0,
        position.maxScrollExtent,
      );
      _scrollController.jumpTo(next);
      await SchedulerBinding.instance.endOfFrame;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Material so catalog host (MaterialApp home without Scaffold) can mount
    // TextField-based demos (e.g. search bar) without "No Material widget".
    return Material(
      color: DSColors.obsidianDeep,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(DSSpacing.xl),
        children: [
          // Page header
          _buildHeader(),
          const SizedBox(height: DSSpacing.lg),

          // Registry-driven section index (TOC)
          _buildSectionIndex(),
          const SizedBox(height: DSSpacing.xxl),

          // All sections from registry
          for (var i = 0; i < dsGallerySections.length; i++) ...[
            KeyedSubtree(
              key: _sectionKeys[i],
              child: dsGallerySections[i].builder(),
            ),
            const SizedBox(height: DSSpacing.xxl),
          ],

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
      borderColor: DSColors.accentCyan.withValues(alpha: 0.3),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.headingLarge('Design System Gallery'),
                SizedBox(height: DSSpacing.xs),
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
              color: DSColors.statusSuccess.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DSRadii.chip),
              border: Border.all(
                color: DSColors.statusSuccess.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSIcon.small(
                  Icons.check_circle_outline,
                  color: DSColors.statusSuccess,
                ),
                SizedBox(width: DSSpacing.xs),
                DSText.labelMedium('DS Layer', color: DSColors.statusSuccess),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Jump chips driven by [dsGallerySections] — titles for UX, ids for keys.
  Widget _buildSectionIndex() {
    return DSGlassPanelSimple(
      padding: const EdgeInsets.all(DSSpacing.lg),
      borderColor: DSColors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DSText.labelLarge(
            'Section index',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.xs),
          const DSText.bodySmall(
            'Jump to a registry section. IDs stay stable for catalog registration.',
            color: DSColors.textTertiary,
          ),
          const SizedBox(height: DSSpacing.md),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: [
              for (var i = 0; i < dsGallerySections.length; i++)
                DSChip(
                  key: ValueKey('gallery-toc-${dsGallerySections[i].id}'),
                  label: dsGallerySections[i].title,
                  color: DSColors.accentCyan,
                  size: DSChipSize.small,
                  onTap: () => _jumpToSection(i),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: DSText.bodySmall(
        'ASW Observatory · Warp Prism · Design System v0.1.0',
        color: DSColors.textTertiary,
      ),
    );
  }
}
