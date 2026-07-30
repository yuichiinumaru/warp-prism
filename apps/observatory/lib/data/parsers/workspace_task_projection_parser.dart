/// Task projection parser for the Operate surface.
///
/// Reads task markdown files (Ganthritor format with YAML frontmatter)
/// from the canonical `docs/tasks/{lane}/` tree and produces structured
/// [TaskProjection] objects consumable by the Operate UI.
///
/// This parser builds on top of [FrontmatterParser] for YAML decoding
/// and adds task-specific body section extraction (exit conditions,
/// verification commands, completion evidence).
///
/// Usage:
/// ```dart
/// const parser = WorkspaceTaskProjectionParser();
/// final projection = parser.parseTask(
///   markdownContent,
///   filePath: 'docs/tasks/02-doing/T009-implement-task-lane-board-ui.md',
/// );
/// final operateProjection = parser.parseAll(taskContents);
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/task_projection.dart';
import 'frontmatter_parser.dart';

/// Parses task markdown files into [TaskProjection] objects.
class WorkspaceTaskProjectionParser {
  static const _fmParser = FrontmatterParser();

  /// Canonical lane directory segment → [TaskLane].
  static const _laneSegments = <String, TaskLane>{
    '00-planning': TaskLane.planning,
    '01-open': TaskLane.open,
    '02-doing': TaskLane.doing,
    '03-review': TaskLane.review,
    '04-completed': TaskLane.completed,
  };

  const WorkspaceTaskProjectionParser();

  /// Parse a single task markdown file into a [TaskProjection].
  ///
  /// The [filePath] is used to derive the task lane from the directory
  /// path (e.g., `docs/tasks/02-doing/` → [TaskLane.doing]).
  /// Throws [TaskParseException] on malformed frontmatter.
  TaskProjection parseTask(String content, {required String filePath}) {
    final result = _fmParser.parse(content);
    if (!result.isOk) {
      throw TaskParseException(result.error!, filePath: filePath);
    }

    final fm = result.frontmatter;
    final body = result.body;
    final declaredStatus = fm['status']?.toString();
    final lane = inferLaneFromPath(filePath, declaredStatus);
    final bodyFields = extractBodyFields(body);

    return TaskProjection(
      id: fm['id']?.toString() ?? _idFromPath(filePath),
      slug: _slugFromPath(filePath),
      title: fm['title']?.toString() ?? _titleFromPath(filePath),
      lane: lane,
      statusLabel: declaredStatus ?? lane.name,
      type: fm['type']?.toString() ?? 'task',
      priority: _normalizePriority(fm['priority']?.toString()),
      owner: fm['owner']?.toString() ?? 'unassigned',
      proofState: ProofStateParsing.fromString(fm['proof_state']?.toString()),
      reviewScore: _parseDouble(fm['review_score']),
      linkedSkills: _parseStringList(fm['skills']),
      linkedWorkflows: _parseStringList(fm['workflows']),
      dependsOn: _parseStringList(fm['depends_on']),
      blockers: _parseStringList(fm['blockers']),
      created: _parseDate(fm['created']),
      updated: _parseDate(fm['updated']),
      verificationCommands: bodyFields.verificationCommands,
      completionEvidenceSummary: bodyFields.completionEvidenceSummary,
      completionEvidenceRows: bodyFields.completionEvidenceRows,
      sections: bodyFields.sections,
      exitConditions: bodyFields.exitConditions,
      bodyMarkdown: body,
      filePath: filePath,
    );
  }

  /// Parse multiple task files and group them by lane.
  ///
  /// [taskContents] maps file paths to their markdown content.
  /// Returns a complete [OperateProjection] with tasks grouped into
  /// the five canonical lanes.
  OperateProjection parseAll(Map<String, String> taskContents) {
    final allTasks = <TaskProjection>[];
    for (final entry in taskContents.entries) {
      allTasks.add(parseTask(entry.value, filePath: entry.key));
    }

    // Group by lane
    final laneMap = <TaskLane, List<TaskProjection>>{};
    for (final lane in TaskLane.values) {
      laneMap[lane] = [];
    }
    for (final task in allTasks) {
      laneMap[task.lane]!.add(task);
    }

    // Sort within each lane: by priority (P0 first), then by creation date
    for (final entry in laneMap.entries) {
      entry.value.sort((a, b) {
        final priorityCompare = _priorityWeight(
          a.priority,
        ).compareTo(_priorityWeight(b.priority));
        if (priorityCompare != 0) return priorityCompare;
        return a.created.compareTo(b.created);
      });
    }

    final lanes = TaskLane.values
        .map((lane) => TaskLaneProjection(lane: lane, tasks: laneMap[lane]!))
        .toList();

    return OperateProjection(lanes: lanes, totalTasks: allTasks.length);
  }

  /// Try to parse without throwing. Returns null on failure.
  TaskProjection? tryParseTask(String content, {required String filePath}) {
    try {
      return parseTask(content, filePath: filePath);
    } on TaskParseException {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Lane inference — directory segment wins over frontmatter
  // ---------------------------------------------------------------------------

  /// Infer lane from path directory segments first; fall back to status.
  ///
  /// Matches only path segments equal to `00-planning` … `04-completed`, so a
  /// filename containing those substrings cannot hijack lane assignment.
  ///
  /// Public so Operate/markdown production paths share the same path-wins
  /// rule (Task 0610/0611 path-to-100 residual).
  static TaskLane inferLaneFromPath(String path, String? status) {
    final segments = path
        .replaceAll('\\', '/')
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();
    for (final segment in segments) {
      final lane = _laneSegments[segment];
      if (lane != null) return lane;
    }
    if (status != null && status.isNotEmpty) {
      return TaskLaneParsing.fromStatus(status);
    }
    return TaskLane.open;
  }

  /// Extract structured body fields used by Operate board + inspector.
  ///
  /// Shared by [parseTask] and [taskProjectionFromAsset] so the shallow
  /// asset bridge retains sections / evidence rows / exit conditions.
  static TaskBodyFields extractBodyFields(String body) {
    final sections = _extractAllSections(body);
    final evidenceSection = _findSectionBody(sections, 'Completion Evidence');
    return TaskBodyFields(
      sections: sections,
      completionEvidenceSummary: evidenceSection,
      completionEvidenceRows: _extractEvidenceRows(evidenceSection),
      exitConditions: _extractExitConditions(sections),
      verificationCommands: _extractVerificationCommands(sections),
    );
  }

  // ---------------------------------------------------------------------------
  // Body section extraction
  // ---------------------------------------------------------------------------

  /// Extract all `##` sections, tolerating emoji prefixes and parenthetical
  /// suffixes (e.g. `## Exit Conditions (GDD/TDD)`, `## 📋 Completion Evidence`).
  static List<MarkdownSection> _extractAllSections(String body) {
    final headingRe = RegExp(r'^##\s+(.+?)\s*$', multiLine: true);
    final matches = headingRe.allMatches(body).toList();
    if (matches.isEmpty) return const [];

    final sections = <MarkdownSection>[];
    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final rawName = match.group(1)!.trim();
      final start = match.end;
      final end = i + 1 < matches.length ? matches[i + 1].start : body.length;
      final sectionBody = body.substring(start, end).trim();
      sections.add(
        MarkdownSection(
          name: _normalizeHeadingName(rawName),
          body: sectionBody,
        ),
      );
    }
    return sections;
  }

  /// Strip leading emoji/symbols and trailing parenthetical suffixes.
  static String _normalizeHeadingName(String raw) {
    var name = raw.trim();
    // Drop leading non-letter/digit symbols (emoji, checklist icons, etc.).
    name = name.replaceFirst(RegExp(r'^[^A-Za-z0-9]+'), '').trim();
    // Drop trailing parenthetical notes: "(GDD/TDD)", "(preenchido pelo …)".
    name = name.replaceFirst(RegExp(r'\s*\([^)]*\)\s*$'), '').trim();
    return name;
  }

  static String? _findSectionBody(
    List<MarkdownSection> sections,
    String canonicalName,
  ) {
    final target = canonicalName.toLowerCase();
    for (final section in sections) {
      if (section.name.toLowerCase() == target) {
        return section.body.isEmpty ? null : section.body;
      }
    }
    return null;
  }

  /// Extract verification commands only from Verification/Validation Commands.
  static List<String> _extractVerificationCommands(
    List<MarkdownSection> sections,
  ) {
    final commands = <String>[];
    for (final section in sections) {
      final lower = section.name.toLowerCase();
      if (lower != 'verification commands' && lower != 'validation commands') {
        continue;
      }
      final codeBlockRegex = RegExp(
        r'```(?:bash|sh)?\s*\n(.*?)```',
        dotAll: true,
      );
      for (final match in codeBlockRegex.allMatches(section.body)) {
        final block = match.group(1)?.trim();
        if (block == null || block.isEmpty) continue;
        for (final line in block.split('\n')) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
            commands.add(trimmed);
          }
        }
      }
    }
    return commands;
  }

  /// Extract exit conditions as structured items.
  static List<ExitCondition> _extractExitConditions(
    List<MarkdownSection> sections,
  ) {
    final section = _findSectionBody(sections, 'Exit Conditions');
    if (section == null) return const [];

    final conditions = <ExitCondition>[];
    for (final line in section.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- [x]') || trimmed.startsWith('- [X]')) {
        conditions.add(
          ExitCondition(text: trimmed.substring(5).trim(), isComplete: true),
        );
      } else if (trimmed.startsWith('- [ ]')) {
        conditions.add(
          ExitCondition(text: trimmed.substring(5).trim(), isComplete: false),
        );
      }
    }
    return conditions;
  }

  /// Parse bullet / key-value evidence lines into structured rows.
  static List<EvidenceRow> _extractEvidenceRows(String? section) {
    if (section == null || section.trim().isEmpty) return const [];

    final rows = <EvidenceRow>[];
    for (final line in section.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Bullet: "- **Label**: value" or "- value"
      var text = trimmed;
      if (text.startsWith('- ') || text.startsWith('* ')) {
        text = text.substring(2).trim();
      }

      final kv = RegExp(r'^\*\*(.+?)\*\*\s*:\s*(.+)$').firstMatch(text);
      if (kv != null) {
        rows.add(
          EvidenceRow(label: kv.group(1)!.trim(), value: kv.group(2)!.trim()),
        );
        continue;
      }

      final plainKv = RegExp(r'^([^:]+):\s*(.+)$').firstMatch(text);
      if (plainKv != null &&
          !text.toLowerCase().startsWith('http') &&
          plainKv.group(1)!.length < 60) {
        rows.add(
          EvidenceRow(
            label: plainKv.group(1)!.trim(),
            value: plainKv.group(2)!.trim(),
          ),
        );
        continue;
      }

      rows.add(EvidenceRow(value: text));
    }
    return rows;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _idFromPath(String path) {
    final filename = path.split('/').last.replaceAll('.md', '');
    final match = RegExp(r'(T\d+)').firstMatch(filename);
    return match?.group(1) ?? filename;
  }

  static String _slugFromPath(String path) {
    return path.split('/').last.replaceAll(RegExp(r'\.md$'), '');
  }

  static String _titleFromPath(String path) {
    return path
        .split('/')
        .last
        .replaceAll('.md', '')
        .replaceAll(RegExp(r'^T\d+-'), '');
  }

  static String _normalizePriority(String? value) {
    if (value == null) return 'P2';
    final lower = value.toLowerCase();
    switch (lower) {
      case 'critical':
      case 'p0':
        return 'P0';
      case 'high':
      case 'p1':
        return 'P1';
      case 'medium':
      case 'p2':
        return 'P2';
      case 'low':
      case 'p3':
        return 'P3';
      default:
        return value;
    }
  }

  static int _priorityWeight(String priority) {
    switch (priority.toUpperCase()) {
      case 'P0':
        return 0;
      case 'P1':
        return 1;
      case 'P2':
        return 2;
      case 'P3':
        return 3;
      default:
        return 99;
    }
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final str = value.toString();
    if (str.toLowerCase() == 'n/a') return null;
    return double.tryParse(str);
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}

/// Structured body fields shared by the full parser and Operate bridge.
@immutable
class TaskBodyFields {
  final List<MarkdownSection> sections;
  final String? completionEvidenceSummary;
  final List<EvidenceRow> completionEvidenceRows;
  final List<ExitCondition> exitConditions;
  final List<String> verificationCommands;

  const TaskBodyFields({
    this.sections = const [],
    this.completionEvidenceSummary,
    this.completionEvidenceRows = const [],
    this.exitConditions = const [],
    this.verificationCommands = const [],
  });
}

/// Typed error for task projection parser failures.
@immutable
class TaskParseException implements Exception {
  final String message;
  final String? filePath;

  const TaskParseException(this.message, {this.filePath});

  @override
  String toString() =>
      'TaskParseException: $message${filePath != null ? ' (in $filePath)' : ''}';
}
