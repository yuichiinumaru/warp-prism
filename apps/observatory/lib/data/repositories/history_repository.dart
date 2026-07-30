/// History read model for the ASW Observatory.
///
/// Provides a typed, chronologically ordered timeline of changelog entries
/// with filter facets (project, type, task, skill, workflow, impact_tags)
/// and story-ready groupings. Downstream consumers (History surface) should
/// consume this read model instead of re-parsing or re-sorting entries.
///
/// This service is pure and stateless — it takes parsed changelog assets
/// (and optional task/skill/workflow assets for multi-hop impact edges)
/// and returns a [HistoryTimeline].
library;

import 'package:flutter/foundation.dart';
import '../models/workspace_graph.dart';
import '../models/changelog_contracts.dart';
import '../models/task_contracts.dart';

/// Typed hop kind for history impact paths.
enum HistoryImpactHopKind {
  /// changelog entry -> task (what motivated this change).
  changelogToTask,

  /// changelog entry -> skill (direct frontmatter skill reference).
  changelogToSkill,

  /// changelog entry -> workflow (direct frontmatter workflow reference).
  changelogToWorkflow,

  /// task -> skill (resolved from task frontmatter / TaskMetadata).
  taskToSkill,

  /// task -> workflow (resolved from task frontmatter / TaskMetadata).
  taskToWorkflow,

  /// changelog entry -> project (project facet linkage).
  changelogToProject,
}

/// A single typed impact edge in the History read model.
///
/// Materializes multi-hop paths such as
/// `changelog -> task -> skill/workflow` and `changelog -> project`
/// without forcing the UI to re-walk graph edges.
@immutable
class HistoryImpactEdge {
  /// Source asset id (usually a changelog or task id).
  final String sourceId;

  /// Target asset id (task:, skill:, workflow:, or project:).
  final String targetId;

  /// Typed hop kind.
  final HistoryImpactHopKind kind;

  const HistoryImpactEdge({
    required this.sourceId,
    required this.targetId,
    required this.kind,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryImpactEdge &&
          runtimeType == other.runtimeType &&
          sourceId == other.sourceId &&
          targetId == other.targetId &&
          kind == other.kind;

  @override
  int get hashCode => Object.hash(sourceId, targetId, kind);

  @override
  String toString() =>
      'HistoryImpactEdge($sourceId -[${kind.name}]-> $targetId)';
}

/// A single entry in the history timeline, carrying all typed metadata
/// needed for rendering, filtering, and drill-down.
@immutable
class HistoryEntry {
  /// The changelog asset id (e.g., "changelog:2026-06-05-T012").
  final String id;

  /// Human-readable title derived from frontmatter or body heading.
  final String title;

  /// Date of the changelog entry. Null when the source date is missing
  /// or unparseable; such entries sort last and carry [isMalformed].
  final DateTime? date;

  /// Project this change belongs to.
  final String project;

  /// Task id that motivated this change.
  final String task;

  /// Type of change (feature, fix, chore, etc.).
  final ChangelogType type;

  /// Impact tags from frontmatter.
  final List<String> impactTags;

  /// Skills referenced by this entry (direct frontmatter).
  final List<String> skills;

  /// Workflows referenced by this entry (direct frontmatter).
  final List<String> workflows;

  /// Filesystem path of the source asset.
  final String path;

  /// Whether this entry is incomplete/malformed and needs graceful UI treatment.
  final bool isMalformed;

  /// Human-readable warnings describing malformed/missing fields.
  final List<String> warnings;

  /// Typed multi-hop impact edges for this entry.
  final List<HistoryImpactEdge> impactEdges;

  /// Linked task asset id (resolved to graph id format).
  String? get linkedTaskId => task.isNotEmpty ? 'task:$task' : null;

  /// Whether this entry has a linked task in the graph.
  bool get hasTaskLink => task.isNotEmpty;

  /// Skills reachable via direct frontmatter or task hop.
  List<String> get resolvedSkills {
    final fromEdges = impactEdges
        .where(
          (e) =>
              e.kind == HistoryImpactHopKind.changelogToSkill ||
              e.kind == HistoryImpactHopKind.taskToSkill,
        )
        .map((e) => e.targetId.replaceFirst(RegExp(r'^skill:'), ''))
        .toList();
    if (fromEdges.isEmpty) return skills;
    return {...skills, ...fromEdges}.toList();
  }

  /// Workflows reachable via direct frontmatter or task hop.
  List<String> get resolvedWorkflows {
    final fromEdges = impactEdges
        .where(
          (e) =>
              e.kind == HistoryImpactHopKind.changelogToWorkflow ||
              e.kind == HistoryImpactHopKind.taskToWorkflow,
        )
        .map((e) => e.targetId.replaceFirst(RegExp(r'^workflow:'), ''))
        .toList();
    if (fromEdges.isEmpty) return workflows;
    return {...workflows, ...fromEdges}.toList();
  }

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
    this.workflows = const [],
    this.isMalformed = false,
    this.warnings = const [],
    this.impactEdges = const [],
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
      'HistoryEntry($id, $project, ${type.name}, '
      '${date?.toIso8601String().substring(0, 10) ?? 'no-date'}'
      '${isMalformed ? ', malformed' : ''})';
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

  /// Unique workflow references (from entry frontmatter and task hops).
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
      'workflows: ${workflows.length}, impactTags: ${impactTags.length})';
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
  /// All entries sorted chronologically (newest first; malformed last).
  final List<HistoryEntry> entries;

  /// Available filter facets.
  final HistoryFacets facets;

  /// Entries grouped by project for story mode.
  final List<HistoryStoryGroup> byProject;

  /// Entries grouped by type for story mode.
  final List<HistoryStoryGroup> byType;

  /// Entries grouped by task for story mode.
  final List<HistoryStoryGroup> byTask;

  /// Flat list of all typed impact edges across entries.
  final List<HistoryImpactEdge> impactEdges;

  const HistoryTimeline({
    required this.entries,
    required this.facets,
    required this.byProject,
    required this.byType,
    required this.byTask,
    this.impactEdges = const [],
  });

  /// An empty timeline with no entries.
  const HistoryTimeline.empty()
    : entries = const [],
      facets = const HistoryFacets.empty(),
      byProject = const [],
      byType = const [],
      byTask = const [],
      impactEdges = const [];

  /// Total number of entries.
  int get count => entries.length;

  /// Whether the timeline is empty.
  bool get isEmpty => entries.isEmpty;

  /// Whether the timeline has entries.
  bool get isNotEmpty => entries.isNotEmpty;

  /// Entries that are incomplete/malformed.
  List<HistoryEntry> get malformedEntries =>
      entries.where((e) => e.isMalformed).toList();

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

  /// Filter entries by skill (direct or resolved hop).
  List<HistoryEntry> filterBySkill(String skill) =>
      entries.where((e) => e.resolvedSkills.contains(skill)).toList();

  /// Filter entries by workflow (direct or resolved hop).
  List<HistoryEntry> filterByWorkflow(String workflow) =>
      entries.where((e) => e.resolvedWorkflows.contains(workflow)).toList();

  @override
  String toString() =>
      'HistoryTimeline(${entries.length} entries, ${byProject.length} projects, '
      '${impactEdges.length} impact edges)';
}

/// Computes the history read model from changelog [WorkspaceAsset] entries.
///
/// Usage:
/// ```dart
/// const repo = HistoryRepository();
/// final timeline = repo.buildTimeline(
///   changelogAssets,
///   tasks: taskAssets,
/// );
/// ```
class HistoryRepository {
  const HistoryRepository();

  /// Build a [HistoryTimeline] from a list of changelog [WorkspaceAsset]s.
  ///
  /// Optional [tasks] enable multi-hop resolution
  /// `changelog -> task -> skill/workflow`. Optional [skills]/[workflows]
  /// are reserved for future existence checks and do not change hop emission.
  ///
  /// Steps:
  /// 1. Extract [ChangelogMetadata] / raw frontmatter from each asset.
  /// 2. Preserve incomplete entries as malformed data with warnings.
  /// 3. Build [HistoryEntry] objects with typed impact edges.
  /// 4. Sort chronologically (newest first; null dates last).
  /// 5. Compute filter facets and story-mode groupings.
  HistoryTimeline buildTimeline(
    List<WorkspaceAsset> changelogAssets, {
    List<WorkspaceAsset> tasks = const [],
    List<WorkspaceAsset> skills = const [],
    List<WorkspaceAsset> workflows = const [],
  }) {
    // Silence unused reserved parameters without changing the public API.
    assert(skills.isEmpty || skills.isNotEmpty);
    assert(workflows.isEmpty || workflows.isNotEmpty);

    final taskIndex = _indexTasks(tasks);
    final rawEntries = <_RawEntry>[];

    for (final asset in changelogAssets) {
      rawEntries.add(_RawEntry.fromAsset(asset));
    }

    // Sort: newest first, null/malformed dates at the end, stable by id.
    rawEntries.sort((a, b) {
      if (a.date == null && b.date == null) {
        return a.asset.id.compareTo(b.asset.id);
      }
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      final byDate = b.date!.compareTo(a.date!);
      if (byDate != 0) return byDate;
      return a.asset.id.compareTo(b.asset.id);
    });

    final entries = rawEntries
        .map((raw) => _toHistoryEntry(raw, taskIndex))
        .toList();

    final allImpactEdges = entries.expand((e) => e.impactEdges).toList();
    final facets = _computeFacets(entries);

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
      impactEdges: allImpactEdges,
    );
  }

  HistoryEntry _toHistoryEntry(
    _RawEntry raw,
    Map<String, _TaskHopTargets> taskIndex,
  ) {
    final warnings = List<String>.from(raw.warnings);
    final isMalformed = warnings.isNotEmpty;

    final impactEdges = <HistoryImpactEdge>[];
    final project = raw.project ?? 'unknown';
    final task = raw.task ?? '';
    final skills = raw.skills;
    final workflows = raw.workflows;

    if (project.isNotEmpty && project != 'unknown') {
      impactEdges.add(
        HistoryImpactEdge(
          sourceId: raw.asset.id,
          targetId: 'project:$project',
          kind: HistoryImpactHopKind.changelogToProject,
        ),
      );
    } else {
      warnings.add('missing_project');
    }

    if (task.isNotEmpty) {
      impactEdges.add(
        HistoryImpactEdge(
          sourceId: raw.asset.id,
          targetId: 'task:$task',
          kind: HistoryImpactHopKind.changelogToTask,
        ),
      );

      final hop = taskIndex[task] ?? taskIndex[_normalizeTaskKey(task)];
      if (hop != null) {
        for (final skill in hop.skills) {
          impactEdges.add(
            HistoryImpactEdge(
              sourceId: 'task:$task',
              targetId: 'skill:$skill',
              kind: HistoryImpactHopKind.taskToSkill,
            ),
          );
        }
        for (final workflow in hop.workflows) {
          impactEdges.add(
            HistoryImpactEdge(
              sourceId: 'task:$task',
              targetId: 'workflow:$workflow',
              kind: HistoryImpactHopKind.taskToWorkflow,
            ),
          );
        }
      }
    }

    for (final skill in skills) {
      impactEdges.add(
        HistoryImpactEdge(
          sourceId: raw.asset.id,
          targetId: 'skill:$skill',
          kind: HistoryImpactHopKind.changelogToSkill,
        ),
      );
    }
    for (final workflow in workflows) {
      impactEdges.add(
        HistoryImpactEdge(
          sourceId: raw.asset.id,
          targetId: 'workflow:$workflow',
          kind: HistoryImpactHopKind.changelogToWorkflow,
        ),
      );
    }

    return HistoryEntry(
      id: raw.asset.id,
      title: _extractTitle(raw.asset),
      date: raw.date,
      project: project,
      task: task,
      type: raw.type ?? ChangelogType.chore,
      impactTags: raw.impactTags,
      skills: skills,
      workflows: workflows,
      path: raw.asset.path,
      isMalformed: isMalformed || warnings.isNotEmpty,
      warnings: warnings.toSet().toList(),
      impactEdges: impactEdges,
    );
  }

  /// Compute filter facets from the entry list.
  HistoryFacets _computeFacets(List<HistoryEntry> entries) {
    final projects = <String>{};
    final types = <ChangelogType>{};
    final tasks = <String>{};
    final skills = <String>{};
    final workflows = <String>{};
    final impactTags = <String>{};

    for (final entry in entries) {
      projects.add(entry.project);
      types.add(entry.type);
      if (entry.task.isNotEmpty) tasks.add(entry.task);
      skills.addAll(entry.resolvedSkills);
      workflows.addAll(entry.resolvedWorkflows);
      impactTags.addAll(entry.impactTags);
    }

    return HistoryFacets(
      projects: projects,
      types: types,
      tasks: tasks,
      skills: skills,
      workflows: workflows,
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
    final fm = asset.frontmatter;
    final name = fm['name']?.toString();
    if (name != null && name.isNotEmpty) return name;

    final id = fm['id']?.toString();
    if (id != null && id.isNotEmpty) return id;

    return asset.name;
  }

  static Map<String, _TaskHopTargets> _indexTasks(List<WorkspaceAsset> tasks) {
    final index = <String, _TaskHopTargets>{};
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      final rawId =
          meta?.id ??
          task.frontmatter['id']?.toString() ??
          task.id.replaceFirst(RegExp(r'^task:'), '');
      final skills =
          meta?.skills ?? _parseStringList(task.frontmatter['skills']);
      final workflows =
          meta?.workflows ?? _parseStringList(task.frontmatter['workflows']);
      final targets = _TaskHopTargets(skills: skills, workflows: workflows);
      index[rawId] = targets;
      index[_normalizeTaskKey(rawId)] = targets;
      // Also index bare numeric / T-prefixed variants.
      final alt = rawId.startsWith('T') ? rawId.substring(1) : 'T$rawId';
      index.putIfAbsent(alt, () => targets);
      index.putIfAbsent(_normalizeTaskKey(alt), () => targets);
    }
    return index;
  }

  static String _normalizeTaskKey(String taskId) {
    return taskId.trim().toUpperCase();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}

/// Skills/workflows reachable from a task asset.
class _TaskHopTargets {
  final List<String> skills;
  final List<String> workflows;

  const _TaskHopTargets({required this.skills, required this.workflows});
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
  final List<String> workflows;
  final List<String> warnings;

  _RawEntry({
    required this.asset,
    required this.date,
    required this.project,
    required this.task,
    required this.type,
    required this.impactTags,
    required this.skills,
    required this.workflows,
    required this.warnings,
  });

  /// Build from a parsed changelog asset, never dropping the entry.
  factory _RawEntry.fromAsset(WorkspaceAsset asset) {
    final warnings = <String>[];
    final fm = asset.frontmatter;
    final meta = fm['_changelogMetadata'] as ChangelogMetadata?;

    DateTime? date;
    String? project;
    String? task;
    ChangelogType? type;
    List<String> impactTags;
    List<String> skills;
    List<String> workflows;

    final rawDate = fm['date'];
    final parsedRawDate = _parseDate(rawDate);

    if (meta != null) {
      // Prefer a real parse of the raw frontmatter date over the parser's
      // DateTime.now() fallback for invalid strings.
      if (rawDate != null && parsedRawDate == null) {
        date = null;
        warnings.add('invalid_date');
      } else {
        date = parsedRawDate ?? meta.date;
      }
      project = meta.project;
      task = meta.task;
      type = meta.type;
      impactTags = meta.impact;
      skills = meta.skills;
      workflows = _parseStringList(fm['workflows']);
    } else {
      date = parsedRawDate;
      if (rawDate != null && date == null) {
        warnings.add('invalid_date');
      } else if (rawDate == null) {
        warnings.add('missing_date');
      }
      project = fm['project']?.toString();
      task = fm['task']?.toString();
      type = ChangelogTypeParsing.fromString(fm['type']?.toString());
      impactTags = _parseStringList(fm['impact']);
      skills = _parseStringList(fm['skills']);
      workflows = _parseStringList(fm['workflows']);
      warnings.add('missing_changelog_metadata');
    }

    if (project == null || project.isEmpty) {
      warnings.add('missing_project');
    }

    return _RawEntry(
      asset: asset,
      date: date,
      project: project,
      task: task,
      type: type,
      impactTags: impactTags,
      skills: skills,
      workflows: workflows,
      warnings: warnings,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return DateTime.tryParse(trimmed);
    }
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
