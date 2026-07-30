/// Warp Prism UI — Reusable Flutter Atomic Design System
///
/// An atomic design system for Ganthritor operational UIs.
/// Implements the ultradark obsidian glass visual aesthetic with
/// subtle hacker/protoss accents.
///
/// Structure:
/// - Tokens: Colors, typography, spacing, radii, shadows, motion
/// - Atoms: Basic building blocks (text, icon, badge, chip, etc.)
/// - Molecules: Compositions of atoms (search bar, cards, etc.)
/// - Organisms: Complex UI sections (sidebar, topbar, panels, etc.)
/// - Templates: Page-level layouts (master-detail, canvas, timeline)
/// - Gallery: Design system gallery/demo pages
///
/// Public API: All consumer apps should use Prism* names.
/// DS* names are internal implementation details.
library;

// Prism* public API aliases — the sole public surface for consumer apps.
// All DS* implementation names are hidden from the public barrel.
export 'src/prism_aliases.dart';

// Operational state extension — available via PrismOperationalState typedef.
// The extension DSOperationalStateUI on DSOperationalState is automatically
// accessible through PrismOperationalState (typedef to DSOperationalState).
// No explicit export of the DS-named extension is needed.

// Gallery is intentionally public for design system documentation.
// DSGallery* implementation names are hidden; consumers use PrismGallery*
// aliases from prism_aliases.dart (and DesignSystemGalleryPage, which has
// no DS prefix).
export 'src/gallery/design_system_gallery_page.dart';
export 'src/gallery/design_system_gallery_registry.dart'
    hide DSGallerySectionSpec;
export 'src/gallery/design_system_gallery_sections.dart' hide DSGallerySections;
