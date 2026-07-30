/// Markdown frontmatter parser for Warp-Prism workspace assets.
///
/// Parses `.md` files with YAML frontmatter into the normalized backbone
/// contract defined by Task 0310 ([WorkspaceAsset], [WorkspaceEdge],
/// [TaskMetadata], [ChangelogMetadata]).
///
/// Each asset kind (agent, skill, workflow, task, changelog) has its own
/// frontmatter schema, but all share the common `---` delimiter and
/// produce a [WorkspaceAsset] as output.
///
/// Usage:
/// ```dart
/// const parser = WorkspaceMarkdownParser();
/// final asset = parser.parse(markdownContent, filePath: 'assets/mock_workspace/.agents/agents/architect.md');
/// ```
library;

import 'package:flutter/foundation.dart';
import 'frontmatter_parser.dart';
import 'workspace_task_projection_parser.dart';
import '../models/data_models.dart';

/// Typed error for parser failures.
@immutable
class ParseException implements Exception {
  final String message;
  final String? filePath;

  const ParseException(this.message, {this.filePath});

  @override
  String toString() =>
      'ParseException: $message${filePath != null ? ' (in $filePath)' : ''}';
}

/// Parses workspace markdown files into normalized backbone models.
///
/// One instance can be reused across multiple parse calls. The
/// [FrontmatterParser] is stateless and const.
class WorkspaceMarkdownParser {
  static const _fmParser = FrontmatterParser();

  const WorkspaceMarkdownParser();

  /// Parse a markdown file into a [WorkspaceAsset].
  ///
  /// The [filePath] is used to derive the asset id, kind, and task lane.
  /// The file must have valid YAML frontmatter; a [ParseException] is
  /// thrown on malformed or missing frontmatter.
  WorkspaceAsset parse(String content, {required String filePath}) {
    final result = _fmParser.parse(content);
    if (!result.isOk) {
      throw ParseException(result.error!, filePath: filePath);
    }

    final kind = _inferKind(filePath);
    final id = _buildId(filePath, result.frontmatter, kind);

    switch (kind) {
      case AssetKind.agent:
        return _parseAgent(id, filePath, result.frontmatter, result.body);
      case AssetKind.skill:
      case AssetKind.subskill:
        return _parseSkill(id, filePath, result.frontmatter, result.body, kind);
      case AssetKind.workflow:
        return _parseWorkflow(id, filePath, result.frontmatter, result.body);
      case AssetKind.task:
        return _parseTask(id, filePath, result.frontmatter, result.body);
      case AssetKind.changelog:
        return _parseChangelog(id, filePath, result.frontmatter, result.body);
      default:
        return _parseGeneric(
          id,
          filePath,
          result.frontmatter,
          result.body,
          kind,
        );
    }
  }

  /// Parse frontmatter only (no body parsing). Returns the raw map.
  /// Throws [ParseException] on malformed frontmatter.
  Map<String, dynamic> parseFrontmatter(
    String content, {
    required String filePath,
  }) {
    final result = _fmParser.parse(content);
    if (!result.isOk) {
      throw ParseException(result.error!, filePath: filePath);
    }
    return result.frontmatter;
  }

  /// Try to parse without throwing. Returns null on failure.
  WorkspaceAsset? tryParse(String content, {required String filePath}) {
    try {
      return parse(content, filePath: filePath);
    } on ParseException {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Kind inference
  // ---------------------------------------------------------------------------

  /// Infer [AssetKind] from the file path.
  static AssetKind _inferKind(String path) {
    final lower = path.toLowerCase();
    if (lower.contains('/agents/')) return AssetKind.agent;
    if (lower.contains('/workflows/')) return AssetKind.workflow;
    if (lower.contains('/tasks/')) return AssetKind.task;
    if (lower.contains('/changelog/')) return AssetKind.changelog;
    if (lower.contains('/skills/')) {
      // Sub-skills are nested deeper
      final segments = path.split('/');
      final skillsIndex = segments.indexWhere((s) => s == 'skills');
      if (skillsIndex >= 0 && skillsIndex + 2 < segments.length) {
        // e.g., skills/harness-architecture/sub-skills/create-agent/SKILL.md
        if (segments.contains('sub-skills') ||
            segments.contains('sub_skills')) {
          return AssetKind.subskill;
        }
      }
      return AssetKind.skill;
    }
    return AssetKind.reference;
  }

  /// Build a canonical asset id from path and frontmatter.
  static String _buildId(String path, Map<String, dynamic> fm, AssetKind kind) {
    // For tasks, use the numeric id from frontmatter
    if (kind == AssetKind.task) {
      final taskId = fm['id']?.toString();
      if (taskId != null) return 'task:$taskId';
    }
    // For changelog, use the id from frontmatter
    if (kind == AssetKind.changelog) {
      final clId = fm['id']?.toString();
      if (clId != null) return 'changelog:$clId';
    }
    // Derive from path
    final name = fm['name']?.toString() ?? _nameFromPath(path);
    return '${kind.name}:$name';
  }

  /// Extract a file-name-based identifier from path.
  static String _nameFromPath(String path) {
    final segments = path.split('/');
    // Find the most specific name
    for (final candidate in [
      segments.lastWhere((s) => s.endsWith('.md'), orElse: () => segments.last),
      segments.last,
    ]) {
      final name = candidate
          .replaceAll('.md', '')
          .replaceAll('SKILL', '')
          .trim();
      if (name.isNotEmpty) return name;
    }
    return segments.last;
  }

  // ---------------------------------------------------------------------------
  // Asset-specific parsers
  // ---------------------------------------------------------------------------

  WorkspaceAsset _parseAgent(
    String id,
    String path,
    Map<String, dynamic> fm,
    String body,
  ) {
    return WorkspaceAsset(
      id: id,
      kind: AssetKind.agent,
      name: fm['name']?.toString() ?? _nameFromPath(path),
      path: path,
      description:
          fm['description']?.toString() ?? _extractFirstParagraph(body),
      canonicality: _parseCanonicality(fm['canonicality']?.toString()),
      frontmatter: fm,
      tags: _parseStringList(fm['tags']),
      triggers: _parseStringList(fm['triggers']),
      edges: _buildAgentEdges(id, fm),
    );
  }

  WorkspaceAsset _parseSkill(
    String id,
    String path,
    Map<String, dynamic> fm,
    String body,
    AssetKind kind,
  ) {
    return WorkspaceAsset(
      id: id,
      kind: kind,
      name: fm['name']?.toString() ?? _nameFromPath(path),
      path: path,
      description:
          fm['description']?.toString() ?? _extractFirstParagraph(body),
      canonicality: _parseCanonicality(fm['canonicality']?.toString()),
      frontmatter: fm,
      tags: _parseStringList(fm['tags']),
      triggers: _parseStringList(fm['triggers']),
      edges: _buildSkillEdges(id, fm),
    );
  }

  WorkspaceAsset _parseWorkflow(
    String id,
    String path,
    Map<String, dynamic> fm,
    String body,
  ) {
    return WorkspaceAsset(
      id: id,
      kind: AssetKind.workflow,
      name: fm['name']?.toString() ?? _nameFromPath(path),
      path: path,
      description:
          fm['description']?.toString() ?? _extractFirstParagraph(body),
      canonicality: _parseCanonicality(fm['canonicality']?.toString()),
      frontmatter: fm,
      tags: _parseStringList(fm['tags']),
      triggers: [],
      edges: _buildWorkflowEdges(id, fm),
    );
  }

  WorkspaceAsset _parseTask(
    String id,
    String path,
    Map<String, dynamic> fm,
    String body,
  ) {
    // Build TaskMetadata from frontmatter
    final taskId = fm['id']?.toString() ?? _nameFromPath(path);
    final lane = _inferTaskLane(path, fm['status']?.toString());
    final created = _parseDate(fm['created']);
    final updated = _parseDate(fm['updated']);

    final taskMeta = TaskMetadata(
      id: taskId,
      title: fm['title']?.toString() ?? _nameFromPath(path),
      lane: lane,
      priority: fm['priority']?.toString() ?? 'P2',
      owner: fm['owner']?.toString() ?? 'unassigned',
      created: created,
      updated: updated,
      skills: _parseStringList(fm['skills']),
      workflows: _parseStringList(fm['workflows']),
      dependsOn: _parseStringList(fm['depends_on']),
      proofState: ProofStateParsing.fromString(fm['proof_state']?.toString()),
      reviewScore: _parseDouble(fm['review_score']),
      verificationCommands: _extractSection(body, 'Verification Commands'),
      completionEvidence: _extractSection(body, 'Completion Evidence'),
    );

    return WorkspaceAsset(
      id: id,
      kind: AssetKind.task,
      name: taskMeta.title,
      path: path,
      description:
          fm['description']?.toString() ?? _extractFirstParagraph(body),
      canonicality: Canonicality.parentCanonical,
      // `_taskBody` keeps full markdown body for Operate deep projection.
      frontmatter: {...fm, '_taskMetadata': taskMeta, '_taskBody': body},
      tags: _parseStringList(fm['tags']),
      triggers: [],
      edges: _buildTaskEdges(id, fm),
    );
  }

  WorkspaceAsset _parseChangelog(
    String id,
    String path,
    Map<String, dynamic> fm,
    String body,
  ) {
    final clType = ChangelogTypeParsing.fromString(fm['type']?.toString());

    // Prefer `impact`, fall back to `impact_tags` for History facet coverage.
    final impact = _parseStringList(fm['impact']);
    final impactTags = impact.isNotEmpty
        ? impact
        : _parseStringList(fm['impact_tags']);

    final clMeta = ChangelogMetadata(
      id: fm['id']?.toString() ?? _nameFromPath(path),
      date: _parseDate(fm['date']),
      project: fm['project']?.toString() ?? 'unknown',
      task: fm['task']?.toString() ?? '',
      type: clType,
      impact: impactTags,
      skills: _parseStringList(fm['skills']),
      workflows: _parseStringList(fm['workflows']),
      why: _extractSection(body, 'Why'),
      changed: _extractSection(body, 'Changed'),
      evidence: _extractSection(body, 'Evidence'),
    );

    return WorkspaceAsset(
      id: id,
      kind: AssetKind.changelog,
      name: fm['id']?.toString() ?? _nameFromPath(path),
      path: path,
      description:
          fm['description']?.toString() ?? _extractFirstParagraph(body),
      canonicality: Canonicality.appendOnly,
      frontmatter: {...fm, '_changelogMetadata': clMeta},
      tags: _parseStringList(fm['tags']),
      triggers: [],
      edges: _buildChangelogEdges(id, fm),
    );
  }

  WorkspaceAsset _parseGeneric(
    String id,
    String path,
    Map<String, dynamic> fm,
    String body,
    AssetKind kind,
  ) {
    return WorkspaceAsset(
      id: id,
      kind: kind,
      name: fm['name']?.toString() ?? _nameFromPath(path),
      path: path,
      description:
          fm['description']?.toString() ?? _extractFirstParagraph(body),
      canonicality: _parseCanonicality(fm['canonicality']?.toString()),
      frontmatter: fm,
      tags: _parseStringList(fm['tags']),
      triggers: [],
    );
  }

  // ---------------------------------------------------------------------------
  // Edge builders
  // ---------------------------------------------------------------------------

  List<WorkspaceEdge> _buildAgentEdges(
    String agentId,
    Map<String, dynamic> fm,
  ) {
    final edges = <WorkspaceEdge>[];
    for (final skill in _parseStringList(fm['skills'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: agentId,
          targetId: normalizeAssetId('skill', skill),
          kind: EdgeKind.uses,
        ),
      );
    }
    for (final wf in _parseStringList(fm['workflows'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: agentId,
          targetId: normalizeAssetId('workflow', wf),
          kind: EdgeKind.uses,
        ),
      );
    }
    return edges;
  }

  List<WorkspaceEdge> _buildSkillEdges(
    String skillId,
    Map<String, dynamic> fm,
  ) {
    final edges = <WorkspaceEdge>[];
    for (final sub in _parseStringList(fm['sub_skills'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: skillId,
          targetId: normalizeAssetId('subskill', sub),
          kind: EdgeKind.contains,
        ),
      );
    }
    for (final wf in _parseStringList(fm['workflows'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: skillId,
          targetId: normalizeAssetId('workflow', wf),
          kind: EdgeKind.references,
        ),
      );
    }
    for (final ref in _parseStringList(fm['references'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: skillId,
          targetId: normalizeAssetId('reference', ref),
          kind: EdgeKind.references,
        ),
      );
    }
    return edges;
  }

  List<WorkspaceEdge> _buildWorkflowEdges(
    String wfId,
    Map<String, dynamic> fm,
  ) {
    final edges = <WorkspaceEdge>[];
    for (final skill in _parseStringList(fm['uses_skills'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: wfId,
          targetId: normalizeAssetId('skill', skill),
          kind: EdgeKind.dependsOn,
        ),
      );
    }
    return edges;
  }

  List<WorkspaceEdge> _buildTaskEdges(String taskId, Map<String, dynamic> fm) {
    final edges = <WorkspaceEdge>[];
    for (final skill in _parseStringList(fm['skills'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: taskId,
          targetId: normalizeAssetId('skill', skill),
          kind: EdgeKind.references,
        ),
      );
    }
    for (final wf in _parseStringList(fm['workflows'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: taskId,
          targetId: normalizeAssetId('workflow', wf),
          kind: EdgeKind.references,
        ),
      );
    }
    for (final dep in _parseStringList(fm['depends_on'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: taskId,
          targetId: normalizeAssetId('task', dep),
          kind: EdgeKind.dependsOn,
        ),
      );
    }
    return edges;
  }

  List<WorkspaceEdge> _buildChangelogEdges(
    String clId,
    Map<String, dynamic> fm,
  ) {
    final edges = <WorkspaceEdge>[];
    final task = fm['task']?.toString();
    if (task != null && task.isNotEmpty) {
      edges.add(
        WorkspaceEdge(
          sourceId: clId,
          targetId: normalizeAssetId('task', task),
          kind: EdgeKind.changedBy,
        ),
      );
    }
    // Multi-hop History paths: changelog -> skill / workflow references.
    for (final skill in _parseStringList(fm['skills'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: clId,
          targetId: normalizeAssetId('skill', skill),
          kind: EdgeKind.references,
        ),
      );
    }
    for (final workflow in _parseStringList(fm['workflows'])) {
      edges.add(
        WorkspaceEdge(
          sourceId: clId,
          targetId: normalizeAssetId('workflow', workflow),
          kind: EdgeKind.references,
        ),
      );
    }
    return edges;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Canonicality _parseCanonicality(String? value) {
    switch (value?.toLowerCase()) {
      case 'parentcanonical':
        return Canonicality.parentCanonical;
      case 'childlocal':
        return Canonicality.childLocal;
      case 'generated':
        return Canonicality.generated;
      case 'appendonly':
        return Canonicality.appendOnly;
      case 'archive':
        return Canonicality.archive;
      case 'mock':
        return Canonicality.mock;
      default:
        return Canonicality.parentCanonical;
    }
  }

  /// Path-segment wins over frontmatter status (aligned with Task 0610 parser).
  static TaskLane _inferTaskLane(String path, String? status) {
    return WorkspaceTaskProjectionParser.inferLaneFromPath(path, status);
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Extract the first paragraph from markdown body.
  static String _extractFirstParagraph(String body) {
    final lines = body.split('\n');
    final buffer = StringBuffer();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        if (buffer.isNotEmpty) break;
        continue;
      }
      if (trimmed.startsWith('#')) continue;
      buffer.write('$trimmed ');
    }
    return buffer.toString().trim();
  }

  /// Extract a named section from markdown body.
  ///
  /// Returns the content under `## SectionName` until the next `##` heading.
  static String? _extractSection(String body, String sectionName) {
    final regex = RegExp('^##\\s+$sectionName\\s*\$', multiLine: true);
    final match = regex.firstMatch(body);
    if (match == null) return null;

    final afterMatch = body.substring(match.end);
    final nextHeading = RegExp(
      r'^##\s',
      multiLine: true,
    ).firstMatch(afterMatch);
    final section = nextHeading != null
        ? afterMatch.substring(0, nextHeading.start)
        : afterMatch;
    return section.trim();
  }
}
