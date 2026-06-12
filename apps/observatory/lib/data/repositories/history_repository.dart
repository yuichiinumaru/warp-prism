/// History read model for the ASW Observatory.
///
/// Provides a typed, chronologically ordered timeline of changelog entries
/// with filter facets (project, type, task, skill, workflow, impact_tags)
/// and story-ready groupings. Downstream consumers (History surface) should
/// consume this read model instead of re-parsing or re-sorting entries.
///
/// This service is pure and stateless — it takes parsed changelog assets
/// and returns a [HistoryTimeline].
library;

import 'package:flutter/foundation.dart';
import '../models/workspace_graph.dart';
import '../models/changelog_contracts.dart';

/// A single entry in the history timeline, carrying all typed metadata
/// needed for rendering, filtering, and drill-down.
@immutable
class HistoryEntry {
  /// The changelog asset id (e.g., "changelog:2026-06-05-T012").
  final String id;

  /// Human-readable title derived from frontmatter or body heading.
  final String title;

  /// Date of the changelog entry.
  final DateTime date;

  /// Project this change belongs to.
  final String project;

  /// Task id that motivated this change.
  final String task;

  /// Type of change (feature, fix, chore, etc.).
  final ChangelogType type;

  /// Impact tags from frontmatter.
  final List<String> impactTags;

  /// Skills referenced by this entry.
  final List<String> skills;

  /// Filesystem path of the source asset.
  final String path;

  /// Linked task asset id (resolved to graph id format).
  String? get linkedTaskId => task.isNotEmpty ? 'task:$task' : null;

  /// Whether this entry has a linked task in the graph.
  bool get hasTaskLink => task.isNotEmpty;

  const HistoryEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.project,
    required this.task,
    required this.type,
    required this.impactTags,
    required this.skills,
    required this.path,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date;

  @override
  int get hashCode => Object.hash(id, date);

  @override
  String toString() =>
      'HistoryEntry($id, $project, ${type.name}, ${date.toIso8601String().substring(0, 10)})';
}

/// Available filter facets for the History surface.
///
/// Each facet provides the set of unique values present across all
/// changelog entries, allowing the UI to build filter chips without
/// scanning the timeline again.
@immutable
class HistoryFacets {
  /// Unique project values.
  final Set<String> projects;

  /// Unique changelog types.
  final Set<ChangelogType> types;

  /// Unique task references.
  final Set<String> tasks;

  /// Unique skill references.
  final Set<String> skills;

  /// Unique workflow references (from linked task/entry metadata).
  final Set<String> workflows;

  /// Unique impact tags across all entries.
  final Set<String> impactTags;

  const HistoryFacets({
    required this.projects,
    required this.types,
    required this.tasks,
    required this.skills,
    required this.workflows,
    required this.impactTags,
  });

  /// Empty facets with no values.
  const HistoryFacets.empty()
    : projects = const {},
      types = const {},
      tasks = const {},
      skills = const {},
      workflows = const {},
      impactTags = const {};

  @override
  String toString() =>
      'HistoryFacets(projects: ${projects.length}, types: ${types.length}, '
      'tasks: ${tasks.length}, skills: ${skills.length}, '
      'impactTags: ${impactTags.length})';
}

/// A story group aggregates changelog entries by a shared dimension
/// (project, type, or task) for story-mode rendering.
@immutable
class HistoryStoryGroup {
  /// The grouping key (e.g., project name, type name, task id).
  final String key;

  /// Display label for the group.
  final String label;

  /// Entries belonging to this group, in chronological order.
  final List<HistoryEntry> entries;

  const HistoryStoryGroup({
    required this.key,
    required this.label,
    required this.entries,
  });

  int get count => entries.length;

  @override
  String toString() => 'HistoryStoryGroup($key: ${entries.length} entries)';
}

/// The complete history timeline read model.
///
/// Contains chronologically ordered entries, available filter facets,
/// and optional story-mode groupings.
@immutable
class HistoryTimeline {
  /// All entries sorted chronologically (newest first).
  final List<HistoryEntry> entries;

  /// Available filter facets.
  final HistoryFacets facets;

  /// Entries grouped by project for story mode.
  final List<HistoryStoryGroup> byProject;

  /// Entries grouped by type for story mode.
  final List<HistoryStoryGroup> byType;

  /// Entries grouped by task for story mode.
  final List<HistoryStoryGroup> byTask;

  const HistoryTimeline({
    required this.entries,
    required this.facets,
    required this.byProject,
    required this.byType,
    required this.byTask,
  });

  /// An empty timeline with no entries.
  const HistoryTimeline.empty()
    : entries = const [],
      facets = const HistoryFacets.empty(),
      byProject = const [],
      byType = const [],
      byTask = const [];

  /// Total number of entries.
  int get count => entries.length;

  /// Whether the timeline is empty.
  bool get isEmpty => entries.isEmpty;

  /// Whether the timeline has entries.
  bool get isNotEmpty => entries.isNotEmpty;

  /// Filter entries by project.
  List<HistoryEntry> filterByProject(String project) =>
      entries.where((e) => e.project == project).toList();

  /// Filter entries by type.
  List<HistoryEntry> filterByType(ChangelogType type) =>
      entries.where((e) => e.type == type).toList();

  /// Filter entries by task reference.
  List<HistoryEntry> filterByTask(String task) =>
      entries.where((e) => e.task == task).toList();

  /// Filter entries by impact tag.
  List<HistoryEntry> filterByImpactTag(String tag) =>
      entries.where((e) => e.impactTags.contains(tag)).toList();

  /// Filter entries by skill.
  List<HistoryEntry> filterBySkill(String skill) =>
      entries.where((e) => e.skills.contains(skill)).toList();

  @override
  String toString() =>
      'HistoryTimeline(${entries.length} entries, ${byProject.length} projects)';
}

/// Computes the history read model from changelog [WorkspaceAsset] entries.
///
/// Usage:
/// ```dart
/// const repo = HistoryRepository();
/// final timeline = repo.buildTimeline(changelogAssets);
/// ```
class HistoryRepository {
  const HistoryRepository();

  /// Build a [HistoryTimeline] from a list of changelog [WorkspaceAsset]s.
  ///
  /// Steps:
  /// 1. Extract [ChangelogMetadata] from each asset's frontmatter.
  /// 2. Build [HistoryEntry] objects with resolved metadata.
  /// 3. Sort chronologically (newest first; malformed dates sort last).
  /// 4. Compute filter facets.
  /// 5. Build story-mode groupings.
  HistoryTimeline buildTimeline(List<WorkspaceAsset> changelogAssets) {
    final rawEntries = <_RawEntry>[];

    for (final asset in changelogAssets) {
      final meta =
          asset.frontmatter['_changelogMetadata'] as ChangelogMetadata?;
      if (meta != null) {
        rawEntries.add(_RawEntry(asset: asset, meta: meta));
      } else {
        // Fallback: try to extract minimal info from frontmatter map
        final fm = asset.frontmatter;
        final date = _parseDate(fm['date']);
        if (date != null) {
          rawEntries.add(_RawEntry.fromMap(asset: asset, date: date));
        }
      }
    }

    // Sort: newest first, malformed dates at the end
    rawEntries.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    // Build HistoryEntry objects
    final entries = rawEntries.map((raw) {
      return HistoryEntry(
        id: raw.asset.id,
        title: _extractTitle(raw.asset),
        date: raw.date ?? DateTime(2000, 1, 1), // Fallback for malformed
        project: raw.project ?? 'unknown',
        task: raw.task ?? '',
        type: raw.type ?? ChangelogType.chore,
        impactTags: raw.impactTags,
        skills: raw.skills,
        path: raw.asset.path,
      );
    }).toList();

    // Compute facets
    final facets = _computeFacets(entries);

    // Build story groupings
    final byProject = _groupBy(entries, (e) => e.project, 'Project');
    final byType = _groupBy(entries, (e) => e.type.name, 'Type');
    final byTask = _groupBy(
      entries.where((e) => e.task.isNotEmpty).toList(),
      (e) => e.task,
      'Task',
    );

    return HistoryTimeline(
      entries: entries,
      facets: facets,
      byProject: byProject,
      byType: byType,
      byTask: byTask,
    );
  }

  /// Compute filter facets from the entry list.
  HistoryFacets _computeFacets(List<HistoryEntry> entries) {
    final projects = <String>{};
    final types = <ChangelogType>{};
    final tasks = <String>{};
    final skills = <String>{};
    final impactTags = <String>{};

    for (final entry in entries) {
      projects.add(entry.project);
      types.add(entry.type);
      if (entry.task.isNotEmpty) tasks.add(entry.task);
      skills.addAll(entry.skills);
      impactTags.addAll(entry.impactTags);
    }

    return HistoryFacets(
      projects: projects,
      types: types,
      tasks: tasks,
      skills: skills,
      workflows: const {}, // Resolved from graph edges, not entries alone
      impactTags: impactTags,
    );
  }

  /// Group entries by a key function, creating story groups.
  List<HistoryStoryGroup> _groupBy(
    Iterable<HistoryEntry> entries,
    String Function(HistoryEntry) keyFn,
    String dimension,
  ) {
    final map = <String, List<HistoryEntry>>{};
    for (final entry in entries) {
      final key = keyFn(entry);
      map.putIfAbsent(key, () => []).add(entry);
    }

    final groups = map.entries
        .map(
          (e) => HistoryStoryGroup(
            key: e.key,
            label: '$dimension: ${e.key}',
            entries: e.value,
          ),
        )
        .toList();

    // Sort groups by entry count descending
    groups.sort((a, b) => b.count.compareTo(a.count));
    return groups;
  }

  /// Extract a human-readable title from an asset.
  String _extractTitle(WorkspaceAsset asset) {
    // Try frontmatter name or id
    final fm = asset.frontmatter;
    final name = fm['name']?.toString();
    if (name != null && name.isNotEmpty) return name;

    // For changelog, try the body heading
    final id = fm['id']?.toString();
    if (id != null && id.isNotEmpty) return id;

    // Fall back to asset name
    return asset.name;
  }

  /// Parse a date from a dynamic value.
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// Internal helper for raw entry processing.
class _RawEntry {
  final WorkspaceAsset asset;
  final DateTime? date;
  final String? project;
  final String? task;
  final ChangelogType? type;
  final List<String> impactTags;
  final List<String> skills;

  _RawEntry({required this.asset, required ChangelogMetadata meta})
    : date = meta.date,
      project = meta.project,
      task = meta.task,
      type = meta.type,
      impactTags = meta.impact,
      skills = meta.skills;

  _RawEntry.fromMap({required this.asset, required this.date})
    : project = asset.frontmatter['project']?.toString(),
      task = asset.frontmatter['task']?.toString(),
      type = ChangelogTypeParsing.fromString(
        asset.frontmatter['type']?.toString(),
      ),
      impactTags = _parseStringList(asset.frontmatter['impact']),
      skills = _parseStringList(asset.frontmatter['skills']);

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
