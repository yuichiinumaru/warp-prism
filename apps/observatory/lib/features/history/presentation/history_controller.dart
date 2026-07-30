/// State management for the History workspace timeline.
///
/// Holds filter state (project, type, task, skill/workflow, impact_tags)
/// and selected entry, driving the History page without embedding
/// mock data in the widget tree.
///
/// Consumes [HistoryEntry] from the Task 0711 History read model.
library;

import 'package:flutter/foundation.dart';
import 'package:warp_prism_observatory/data/repositories/history_repository.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_view_mode.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// A project-story group: one project's changelog entries with narrative.
@immutable
class ProjectStoryGroup {
  final String project;
  final List<HistoryEntry> entries;

  const ProjectStoryGroup({required this.project, required this.entries});

  /// Narrative: count of entries, types involved, date range.
  String get summary {
    final types = entries.map((e) => e.type.name).toSet();
    final dated = entries.where((e) => e.date != null).toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));
    final range = dated.isEmpty
        ? 'no date'
        : dated.first.date == dated.last.date
        ? _formatDate(dated.first.date!)
        : '${_formatShort(dated.first.date!)} – ${_formatShort(dated.last.date!)}';
    return '${entries.length} change${entries.length == 1 ? '' : 's'} '
        '(${types.join(', ')}) · $range';
  }

  /// Tasks involved in this project group.
  List<String> get taskIds =>
      entries.map((e) => e.task).where((t) => t.isNotEmpty).toList();

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _formatShort(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}

/// An impact-path node: links a changelog entry to its downstream task
/// and optionally to skills/workflows it touched.
@immutable
class ImpactPathNode {
  final HistoryEntry entry;
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
enum HistoryFilterCategory { project, type, task, skillWorkflow, impactTag }

/// Immutable state snapshot for the History workspace.
@immutable
class HistoryState {
  /// All parsed history entries from the Task 0711 read model.
  final List<HistoryEntry> allEntries;

  /// Currently selected filter values, keyed by category.
  final Map<HistoryFilterCategory, Set<String>> activeFilters;

  /// ID of the currently selected timeline entry (null = none).
  final String? selectedEntryId;

  /// Current view mode.
  final HistoryViewMode viewMode;

  /// Whether the read model is still loading.
  final bool isLoading;

  /// Error message if loading/parsing failed.
  final String? error;

  const HistoryState({
    this.allEntries = const [],
    this.activeFilters = const {},
    this.selectedEntryId,
    this.viewMode = HistoryViewMode.timeline,
    this.isLoading = false,
    this.error,
  });

  /// Build state from a [HistoryTimeline] read model (Task 0711).
  factory HistoryState.fromTimeline(
    HistoryTimeline timeline, {
    HistoryViewMode viewMode = HistoryViewMode.timeline,
    String? selectedEntryId,
    Map<HistoryFilterCategory, Set<String>> activeFilters = const {},
  }) {
    return HistoryState(
      allEntries: timeline.entries,
      viewMode: viewMode,
      selectedEntryId: selectedEntryId,
      activeFilters: activeFilters,
    );
  }

  /// Entries after applying all active filters.
  List<HistoryEntry> get filteredEntries {
    var entries = List<HistoryEntry>.from(allEntries);

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
          entries = entries.where((e) => entry.value.contains(e.task)).toList();
        case HistoryFilterCategory.skillWorkflow:
          entries = entries
              .where(
                (e) =>
                    e.resolvedSkills.any((s) => entry.value.contains(s)) ||
                    e.resolvedWorkflows.any((w) => entry.value.contains(w)),
              )
              .toList();
        case HistoryFilterCategory.impactTag:
          entries = entries
              .where((e) => e.impactTags.any((t) => entry.value.contains(t)))
              .toList();
      }
    }

    // Sort chronologically (newest first; null dates last).
    entries.sort((a, b) {
      if (a.date == null && b.date == null) return a.id.compareTo(b.id);
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      final byDate = b.date!.compareTo(a.date!);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
    return entries;
  }

  /// Distinct values available for a given filter category.
  Set<String> availableFilters(HistoryFilterCategory category) {
    switch (category) {
      case HistoryFilterCategory.project:
        return allEntries
            .map((e) => e.project)
            .where((p) => p.isNotEmpty)
            .toSet();
      case HistoryFilterCategory.type:
        return allEntries.map((e) => e.type.name).toSet();
      case HistoryFilterCategory.task:
        return allEntries.map((e) => e.task).where((t) => t.isNotEmpty).toSet();
      case HistoryFilterCategory.skillWorkflow:
        return {
          ...allEntries.expand((e) => e.resolvedSkills),
          ...allEntries.expand((e) => e.resolvedWorkflows),
        };
      case HistoryFilterCategory.impactTag:
        return allEntries.expand((e) => e.impactTags).toSet();
    }
  }

  /// Convert to [PrismTimelineEntry]s for the timeline organism.
  List<PrismTimelineEntry> toTimelineEntries() {
    return filteredEntries.map((e) {
      final dateStr = e.date == null
          ? 'unknown'
          : '${e.date!.year}-${e.date!.month.toString().padLeft(2, '0')}-${e.date!.day.toString().padLeft(2, '0')}';
      final taskLabel = e.task.isEmpty ? 'unlinked' : e.task;
      final title = e.title.isNotEmpty
          ? e.title
          : '$taskLabel — ${e.type.name}';
      return PrismTimelineEntry(
        id: e.id,
        date: dateStr,
        title: title,
        type: e.type.name,
        project: e.project.isEmpty ? null : e.project,
        taskId: e.task.isEmpty ? null : e.task,
        impacts: e.impactTags.isEmpty ? null : e.impactTags,
      );
    }).toList();
  }

  /// Group filtered entries by project for Project Story mode.
  List<ProjectStoryGroup> toProjectStoryGroups() {
    final map = <String, List<HistoryEntry>>{};
    for (final entry in filteredEntries) {
      final key = entry.project.isEmpty ? '(no project)' : entry.project;
      map.putIfAbsent(key, () => []).add(entry);
    }
    return map.entries
        .map((e) => ProjectStoryGroup(project: e.key, entries: e.value))
        .toList()
      ..sort((a, b) => b.entries.length.compareTo(a.entries.length));
  }

  /// Build impact-path nodes from filtered entries for Impact Story mode.
  ///
  /// Complete path = task hop + (skill hop OR workflow hop). Missing hops
  /// stay explicit — never fabricated.
  List<ImpactPathNode> toImpactPathNodes() {
    return filteredEntries.map((entry) {
      final hasTask = entry.task.isNotEmpty;
      final skills = entry.resolvedSkills;
      final workflows = entry.resolvedWorkflows;
      final hasSkillsOrWorkflows = skills.isNotEmpty || workflows.isNotEmpty;
      return ImpactPathNode(
        entry: entry,
        resolvedTaskId: hasTask ? entry.task : null,
        resolvedSkills: skills,
        resolvedWorkflows: workflows,
        hasCompletePath: hasTask && hasSkillsOrWorkflows,
      );
    }).toList();
  }

  /// Lookup selected entry from the full corpus (not just filtered).
  HistoryEntry? get selectedEntry {
    final id = selectedEntryId;
    if (id == null) return null;
    for (final e in allEntries) {
      if (e.id == id) return e;
    }
    return null;
  }

  HistoryState copyWith({
    List<HistoryEntry>? allEntries,
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
