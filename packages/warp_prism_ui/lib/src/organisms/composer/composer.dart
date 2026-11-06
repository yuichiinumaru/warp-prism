/// Composer organism barrel (Task 1866, F-18 — EXPERIMENTAL, local only).
///
/// This barrel is intentionally **not** re-exported from
/// `organisms.dart`, `warp_prism_ui.dart`, or `prism_aliases.dart` until
/// the promotion task wires the public surface (layer-contracts §9).
/// Tests and the gallery import these files directly by path.
library;

export 'ds_composer.dart';
export 'ds_composer_model.dart';
