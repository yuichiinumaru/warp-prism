/// View mode enum for the History workspace.
///
/// Controls which presentation layer is active: chronological timeline,
/// project-story grouping, or impact-path causality chain.
enum HistoryViewMode {
  /// Classic chronological timeline (default).
  timeline,

  /// Project Story: groups entries by project and explains why changes matter.
  projectStory,

  /// Impact Story: shows causality chain changelog -> task -> skill/workflow.
  impactStory,
}
