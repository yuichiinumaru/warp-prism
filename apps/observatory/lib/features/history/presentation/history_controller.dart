/// State management for the History workspace timeline.
///
/// Holds filter state (project, type, task, skill/workflow, impact_tags)
/// and selected entry, driving the [HistoryPage] without embedding
/// mock data in the widget tree.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/changelog_contracts.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'history_view_mode.dart';

/// A project-story group: one project's changelog entries with narrative.
@immutable
class ProjectStoryGroup {
  final String project;
  final List<ChangelogMetadata> entries;

  const ProjectStoryGroup({required this.project, required this.entries});

  /// Narrative: count of entries, types involved, date range.
  String get summary {
    final types = entries.map((e) => e.type.name).toSet();
    final sorted = entries.toList()..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.first.date;
    final last = sorted.last.date;
    final range = first == last
        ? '${first.year}-${first.month.toString().padLeft(2, '0')}-${first.day.toString().padLeft(2, '0')}'
        : '${first.month.toString().padLeft(2, '0')}/${first.day.toString().padLeft(2, '0')}'
            ' – ${last.month.toString().padLeft(2, '0')}/${last.day.toString().padLeft(2, '0')}';
    return '${entries.length} change${entries.length == 1 ? '' : 's'} '
        '(${types.join(', ')}) · $range';
  }

  /// Tasks involved in this project group.
  List<String> get taskIds =>
      entries.map((e) => e.task).where((t) => t.isNotEmpty).toList();
}

/// An impact-path node: links a changelog entry to its downstream task
/// and optionally to skills/workflows it touched.
@immutable
class ImpactPathNode {
  final ChangelogMetadata entry;
  final String? resolvedTaskId;
  final List<String> resolvedSkills;
  final List<String> resolvedWorkflows;
  final bool hasCompletePath;

  const ImpactPathNode({
    required this.entry,
    this.resolvedTaskId,
    this.resolvedSkills = const [],
    this.resolvedWorkflows = const [],
    this.hasCompletePath = false,
  });
}

/// Facet categories for History filters.
enum HistoryFilterCategory {
  project,
  type,
  task,
  skillWorkflow,
  impactTag,
}

/// Immutable state snapshot for the History workspace.
@immutable
class HistoryState {
  /// All parsed changelog entries from the read model.
  final List<ChangelogMetadata> allEntries;

  /// Currently selected filter values, keyed by category.
  final Map<HistoryFilterCategory, Set<String>> activeFilters;

  /// ID of the currently selected timeline entry (null = none).
  final String? selectedEntryId;

  /// Current view mode.
  final HistoryViewMode viewMode;

  /// Whether the read model is still loading.
  final bool isLoading;

  /// Error message if parsing failed.
  final String? error;

  const HistoryState({
    this.allEntries = const [],
    this.activeFilters = const {},
    this.selectedEntryId,
    this.viewMode = HistoryViewMode.timeline,
    this.isLoading = false,
    this.error,
  });

  /// Entries after applying all active filters.
  List<ChangelogMetadata> get filteredEntries {
    var entries = List<ChangelogMetadata>.from(allEntries);

    for (final entry in activeFilters.entries) {
      if (entry.value.isEmpty) continue;
      switch (entry.key) {
        case HistoryFilterCategory.project:
          entries = entries
              .where((e) => entry.value.contains(e.project))
              .toList();
        case HistoryFilterCategory.type:
          entries = entries
              .where((e) => entry.value.contains(e.type.name))
              .toList();
        case HistoryFilterCategory.task:
          entries = entries
              .where((e) => entry.value.contains(e.task))
              .toList();
        case HistoryFilterCategory.skillWorkflow:
          entries = entries
              .where((e) =>
                  e.skills.any((s) => entry.value.contains(s)))
              .toList();
        case HistoryFilterCategory.impactTag:
          entries = entries
              .where((e) =>
                  e.impact.any((t) => entry.value.contains(t)))
              .toList();
      }
    }

    // Sort chronologically (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// Distinct values available for a given filter category.
  Set<String> availableFilters(HistoryFilterCategory category) {
    switch (category) {
      case HistoryFilterCategory.project:
        return allEntries.map((e) => e.project).toSet();
      case HistoryFilterCategory.type:
        return allEntries.map((e) => e.type.name).toSet();
      case HistoryFilterCategory.task:
        return allEntries.map((e) => e.task).toSet();
      case HistoryFilterCategory.skillWorkflow:
        return allEntries.expand((e) => e.skills).toSet();
      case HistoryFilterCategory.impactTag:
        return allEntries.expand((e) => e.impact).toSet();
    }
  }

  /// Convert to [DSTimelineEntry]s for the timeline organism.
  List<DSTimelineEntry> toTimelineEntries() {
    return filteredEntries.map((e) {
      final dateStr =
          '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      return DSTimelineEntry(
        id: e.id,
        date: dateStr,
        title: '${e.task} — ${e.type.name}',
        type: e.type.name,
        project: e.project,
        taskId: e.task,
        impacts: e.impact.isEmpty ? null : e.impact,
      );
    }).toList();
  }

  /// Group filtered entries by project for Project Story mode.
  List<ProjectStoryGroup> toProjectStoryGroups() {
    final map = <String, List<ChangelogMetadata>>{};
    for (final entry in filteredEntries) {
      map.putIfAbsent(entry.project, () => []).add(entry);
    }
    return map.entries
        .map((e) => ProjectStoryGroup(project: e.key, entries: e.value))
        .toList()
      ..sort((a, b) => b.entries.length.compareTo(a.entries.length));
  }

  /// Build impact-path nodes from filtered entries for Impact Story mode.
  ///
  /// Each entry gets a node. If the entry has task + skills, the path is
  /// complete; otherwise we expose the gaps explicitly.
  List<ImpactPathNode> toImpactPathNodes() {
    return filteredEntries.map((entry) {
      final hasTask = entry.task.isNotEmpty;
      final hasSkills = entry.skills.isNotEmpty;
      return ImpactPathNode(
        entry: entry,
        resolvedTaskId: hasTask ? entry.task : null,
        resolvedSkills: entry.skills,
        resolvedWorkflows: const [],
        hasCompletePath: hasTask && hasSkills,
      );
    }).toList();
  }

  HistoryState copyWith({
    List<ChangelogMetadata>? allEntries,
    Map<HistoryFilterCategory, Set<String>>? activeFilters,
    String? selectedEntryId,
    bool clearSelection = false,
    HistoryViewMode? viewMode,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HistoryState(
      allEntries: allEntries ?? this.allEntries,
      activeFilters: activeFilters ?? this.activeFilters,
      selectedEntryId: clearSelection
          ? null
          : (selectedEntryId ?? this.selectedEntryId),
      viewMode: viewMode ?? this.viewMode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
