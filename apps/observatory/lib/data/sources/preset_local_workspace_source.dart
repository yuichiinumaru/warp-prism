/// Filesystem-based workspace source that scans a real directory.
///
/// Reads from a configurable root path using `dart:io` [Directory] and
/// [File] operations. Discovers agents, skills, workflows, tasks (by
/// lane), and changelog entries from the standard `.agents/` and `docs/`
/// directory layout.
///
/// The scanner parses YAML frontmatter via [WorkspaceMarkdownParser] and
/// returns a typed [WorkspaceSnapshot] with scan metadata.
///
/// Usage:
/// ```dart
/// const source = PresetLocalWorkspaceSource();
/// final snapshot = await source.load('/home/user/workspace');
/// ```
library;

import 'dart:io';

import 'workspace_source.dart';
import '../models/workspace_snapshot.dart';
import '../models/workspace_graph.dart';
import '../parsers/workspace_markdown_parser.dart';

/// Scans a real filesystem workspace directory and returns a typed snapshot.
///
/// This is the "quick win" implementation that reads directly from the
/// filesystem without requiring mock corpus setup or EPIC-03 data layer.
class PresetLocalWorkspaceSource implements WorkspaceSource {
  /// The markdown parser used to parse discovered files.
  static const _parser = WorkspaceMarkdownParser();

  const PresetLocalWorkspaceSource();

  @override
  Future<WorkspaceSnapshot> load(String rootPath) async {
    final agents = <WorkspaceAsset>[];
    final skills = <WorkspaceAsset>[];
    final workflows = <WorkspaceAsset>[];
    final tasks = <WorkspaceAsset>[];
    final changelogEntries = <WorkspaceAsset>[];
    var filesScanned = 0;
    var parseErrors = 0;

    // Scan .agents/agents/*.md
    final agentDir = Directory('$rootPath/.agents/agents');
    if (await agentDir.exists()) {
      await for (final entity in agentDir.list()) {
        if (entity is File && entity.path.endsWith('.md')) {
          filesScanned++;
          final asset = await _tryParseFile(entity, 'agents');
          if (asset != null) {
            agents.add(asset);
          } else {
            parseErrors++;
          }
        }
      }
    }

    // Scan .agents/skills/*/SKILL.md (top-level skills)
    final skillsDir = Directory('$rootPath/.agents/skills');
    if (await skillsDir.exists()) {
      await for (final skillDir in skillsDir.list()) {
        if (skillDir is Directory) {
          // Top-level SKILL.md
          final skillFile = File('${skillDir.path}/SKILL.md');
          if (await skillFile.exists()) {
            filesScanned++;
            final asset = await _tryParseFile(skillFile, 'skills');
            if (asset != null) {
              skills.add(asset);
            } else {
              parseErrors++;
            }
          }

          // Sub-skills: sub-skills/*/SKILL.md
          final subSkillsDir = Directory('${skillDir.path}/sub-skills');
          if (await subSkillsDir.exists()) {
            await for (final subDir in subSkillsDir.list()) {
              if (subDir is Directory) {
                final subSkillFile = File('${subDir.path}/SKILL.md');
                if (await subSkillFile.exists()) {
                  filesScanned++;
                  final asset = await _tryParseFile(subSkillFile, 'sub-skills');
                  if (asset != null) {
                    skills.add(asset);
                  } else {
                    parseErrors++;
                  }
                }
              }
            }
          }

          // Skill-local workflows: skills/*/workflows/*.md
          final wfDir = Directory('${skillDir.path}/workflows');
          if (await wfDir.exists()) {
            await for (final wfFile in wfDir.list()) {
              if (wfFile is File && wfFile.path.endsWith('.md')) {
                filesScanned++;
                final asset = await _tryParseFile(wfFile, 'workflows');
                if (asset != null) {
                  workflows.add(asset);
                } else {
                  parseErrors++;
                }
              }
            }
          }
        }
      }
    }

    // Scan .agents/workflows/*.md (top-level workflows)
    final workflowsDir = Directory('$rootPath/.agents/workflows');
    if (await workflowsDir.exists()) {
      await for (final entity in workflowsDir.list()) {
        if (entity is File && entity.path.endsWith('.md')) {
          filesScanned++;
          final asset = await _tryParseFile(entity, 'workflows');
          if (asset != null) {
            workflows.add(asset);
          } else {
            parseErrors++;
          }
        }
      }
    }

    // Scan docs/tasks/{lane}/*.md for each task lane
    const lanes = [
      '00-planning',
      '01-open',
      '02-doing',
      '03-review',
      '04-completed',
    ];
    for (final lane in lanes) {
      final laneDir = Directory('$rootPath/docs/tasks/$lane');
      if (await laneDir.exists()) {
        await for (final entity in laneDir.list()) {
          if (entity is File && entity.path.endsWith('.md')) {
            filesScanned++;
            final asset = await _tryParseFile(entity, 'tasks/$lane');
            if (asset != null) {
              tasks.add(asset);
            } else {
              parseErrors++;
            }
          }
        }
      }
    }

    // Scan docs/changelog/*.md
    final changelogDir = Directory('$rootPath/docs/changelog');
    if (await changelogDir.exists()) {
      await for (final entity in changelogDir.list()) {
        if (entity is File && entity.path.endsWith('.md')) {
          filesScanned++;
          final asset = await _tryParseFile(entity, 'changelog');
          if (asset != null) {
            changelogEntries.add(asset);
          } else {
            parseErrors++;
          }
        }
      }
    }

    return WorkspaceSnapshot(
      agents: agents,
      skills: skills,
      workflows: workflows,
      tasks: tasks,
      changelogEntries: changelogEntries,
      metadata: WorkspaceScanMetadata(
        rootPath: rootPath,
        scannedAt: DateTime.now(),
        filesScanned: filesScanned,
        parseErrors: parseErrors,
      ),
    );
  }

  /// Try to read and parse a file. Returns null on any failure.
  static Future<WorkspaceAsset?> _tryParseFile(
    File file,
    String expectedDir,
  ) async {
    try {
      final content = await file.readAsString();
      return _parser.tryParse(content, filePath: file.path);
    } catch (_) {
      return null;
    }
  }
}
