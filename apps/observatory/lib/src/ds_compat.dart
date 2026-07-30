/// DS* compatibility imports for Observatory.
///
/// The public barrel `warp_prism_ui.dart` now only exports Prism* names.
/// Observatory still uses DS* names internally. This file re-exports
/// the internal DS* modules so Observatory files can import them.
///
/// This is a temporary compatibility layer. Observatory should be
/// migrated to Prism* names in a future task (see Task 1408).
library;

// ignore: implementation_imports
export 'package:warp_prism_ui/src/tokens/tokens.dart';
// ignore: implementation_imports
export 'package:warp_prism_ui/src/tokens/ds_operational_state.dart';
// ignore: implementation_imports
export 'package:warp_prism_ui/src/atoms/atoms.dart';
// ignore: implementation_imports
export 'package:warp_prism_ui/src/molecules/molecules.dart';
// ignore: implementation_imports
export 'package:warp_prism_ui/src/organisms/organisms.dart';
// ignore: implementation_imports
export 'package:warp_prism_ui/src/templates/templates.dart';
// ignore: implementation_imports
export 'package:warp_prism_ui/src/gallery/design_system_gallery_page.dart';
// ignore: implementation_imports
export 'package:warp_prism_ui/src/gallery/design_system_gallery_registry.dart';
// ignore: implementation_imports
export 'package:warp_prism_ui/src/gallery/design_system_gallery_sections.dart';
