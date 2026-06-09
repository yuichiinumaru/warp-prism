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
library;

export 'src/tokens/tokens.dart';
export 'src/atoms/atoms.dart';
export 'src/molecules/molecules.dart';
export 'src/organisms/organisms.dart';
export 'src/templates/templates.dart';
export 'src/gallery/design_system_gallery_page.dart';
export 'src/gallery/design_system_gallery_sections.dart';

// Prism* public API aliases for promoted operational components.
// Consumer apps should prefer these over DS* names.
export 'src/prism_aliases.dart';
