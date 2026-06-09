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
/// final projection = parser.parseTask(markdownContent, filePath: 'docs/tasks/02-doing/T009-implement-task-lane-board-ui.md');
/// final operateProjection = parser.parseAll(taskContents);
/// ```
library;

import 'package:flutter/foundation.dart';
import 'frontmatter_parser.dart';
import '../../features/operate/task_projection.dart';
import '../models/task_contracts.dart';

/// Parses task markdown files into [TaskProjection] objects.
class WorkspaceTaskProjectionParser {
  static const _fmParser = FrontmatterParser();

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
    final lane = _inferLane(filePath, fm['status']?.toString());

    return TaskProjection(
      id: fm['id']?.toString() ?? _idFromPath(filePath),
      title: fm['title']?.toString() ?? _titleFromPath(filePath),
      lane: lane,
      priority: _normalizePriority(fm['priority']?.toString()),
      owner: fm['owner']?.toString() ?? 'unassigned',
      proofState: ProofStateParsing.fromString(fm['proof_state']?.toString()),
      reviewScore: _parseDouble(fm['review_score']),
      linkedSkills: _parseStringList(fm['skills']),
      linkedWorkflows: _parseStringList(fm['workflows']),
      dependsOn: _parseStringList(fm['depends_on']),
      created: _parseDate(fm['created']),
      updated: _parseDate(fm['updated']),
      verificationCommands: _extractVerificationCommands(body),
      completionEvidenceSummary: _extractSection(body, 'Completion Evidence'),
      exitConditions: _extractExitConditions(body),
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
        final priorityCompare = _priorityWeight(a.priority)
            .compareTo(_priorityWeight(b.priority));
        if (priorityCompare != 0) return priorityCompare;
        return a.created.compareTo(b.created);
      });
    }

    final lanes = TaskLane.values
        .map((lane) => TaskLaneProjection(
              lane: lane,
              tasks: laneMap[lane]!,
            ))
        .toList();

    return OperateProjection(
      lanes: lanes,
      totalTasks: allTasks.length,
    );
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
  // Lane inference
  // ---------------------------------------------------------------------------

  static TaskLane _inferLane(String path, String? status) {
    // Prefer explicit status from frontmatter
    if (status != null) return TaskLaneParsing.fromStatus(status);
    // Fall back to directory path
    if (path.contains('00-planning')) return TaskLane.planning;
    if (path.contains('01-open')) return TaskLane.open;
    if (path.contains('02-doing')) return TaskLane.doing;
    if (path.contains('03-review')) return TaskLane.review;
    if (path.contains('04-completed')) return TaskLane.completed;
    return TaskLane.open;
  }

  // ---------------------------------------------------------------------------
  // Body section extraction
  // ---------------------------------------------------------------------------

  /// Extract verification commands from fenced code blocks in the body.
  static List<String> _extractVerificationCommands(String body) {
    final commands = <String>[];
    final codeBlockRegex = RegExp(r'```(?:bash|sh)?\s*\n(.*?)```', dotAll: true);
    for (final match in codeBlockRegex.allMatches(body)) {
      final block = match.group(1)?.trim();
      if (block != null && block.isNotEmpty) {
        // Split multi-line blocks into individual commands
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
  static List<ExitCondition> _extractExitConditions(String body) {
    final conditions = <ExitCondition>[];
    final section = _extractSection(body, 'Exit Conditions');
    if (section == null) return conditions;

    for (final line in section.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- [x]') || trimmed.startsWith('- [X]')) {
        conditions.add(ExitCondition(
          text: trimmed.substring(5).trim(),
          isComplete: true,
        ));
      } else if (trimmed.startsWith('- [ ]')) {
        conditions.add(ExitCondition(
          text: trimmed.substring(5).trim(),
          isComplete: false,
        ));
      }
    }
    return conditions;
  }

  /// Extract a named section from markdown body.
  static String? _extractSection(String body, String sectionName) {
    final regex = RegExp(
      '^##\\s+$sectionName\\s*\$',
      multiLine: true,
    );
    final match = regex.firstMatch(body);
    if (match == null) return null;

    final afterMatch = body.substring(match.end);
    final nextHeading = RegExp(r'^##\s', multiLine: true).firstMatch(afterMatch);
    final section = nextHeading != null
        ? afterMatch.substring(0, nextHeading.start)
        : afterMatch;
    return section.trim();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _idFromPath(String path) {
    final filename = path.split('/').last.replaceAll('.md', '');
    final match = RegExp(r'(T\d+)').firstMatch(filename);
    return match?.group(1) ?? filename;
  }

  static String _titleFromPath(String path) {
    return path.split('/').last.replaceAll('.md', '').replaceAll(RegExp(r'^T\d+-'), '');
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
