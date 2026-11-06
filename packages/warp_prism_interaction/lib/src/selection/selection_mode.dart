/// Selection mode constraint for interactive selections.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
enum SelectionMode {
  /// At most one item can be selected at a time.
  single,

  /// Multiple items can be selected simultaneously.
  multiple,

  /// Selection is disabled / disallowed.
  none,
}

/// Provenance or origin of a selection change.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
enum SelectionSource {
  /// Direct user pointer/touch interaction.
  user,

  /// Keyboard arrow/space navigation or shortcut.
  keyboard,

  /// Programmatic API call or view-model update.
  programmatic,

  /// External synchronization (e.g. multi-view coordination).
  sync,
}
