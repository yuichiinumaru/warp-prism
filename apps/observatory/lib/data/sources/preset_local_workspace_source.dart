/// Filesystem-based workspace source that scans a real directory.
///
/// Reads from a configurable root path using `dart:io` [Directory] and
/// [File] operations. Discovers agents, skills, workflows, tasks (by
/// lane), and changelog entries from the standard `.agents/` and `docs/`
/// directory layout.
///
/// ## Symlink policy
///
/// By default [followLinks] is `false`: the scanner does **not** follow
/// symbolic links into parent-canonical surfaces. When a scan root (e.g.
/// `.agents/skills`) or a listed entry is a symlink, it is skipped and its
/// path is recorded on [WorkspaceScanMetadata.skippedSymlinks].
///
/// Pass `followLinks: true` only when the caller explicitly opts in to
/// merging linked harness data.
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

  /// Whether to follow symbolic links while scanning.
  ///
  /// Defaults to `false` so parent-canonical harness mounts (e.g.
  /// `.agents/skills` → monorepo root) are not silently merged. When
  /// `false`, symlink paths are listed in
  /// [WorkspaceScanMetadata.skippedSymlinks].
  final bool followLinks;

  const PresetLocalWorkspaceSource({this.followLinks = false});

  @override
  Future<WorkspaceSnapshot> load(String rootPath) async {
    final agents = <WorkspaceAsset>[];
    final skills = <WorkspaceAsset>[];
    final workflows = <WorkspaceAsset>[];
    final tasks = <WorkspaceAsset>[];
    final changelogEntries = <WorkspaceAsset>[];
    final skippedSymlinks = <String>[];
    var filesScanned = 0;
    var parseErrors = 0;

    // Scan .agents/agents/*.md
    final agentDir = Directory('$rootPath/.agents/agents');
    await for (final entity in _listEntries(agentDir, skippedSymlinks)) {
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

    // Scan .agents/skills/*/SKILL.md (top-level skills)
    final skillsDir = Directory('$rootPath/.agents/skills');
    await for (final skillDir in _listEntries(skillsDir, skippedSymlinks)) {
      if (skillDir is! Directory) continue;

      // Top-level SKILL.md
      final skillFile = File('${skillDir.path}/SKILL.md');
      if (await _isUsableFile(skillFile, skippedSymlinks)) {
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
      await for (final subDir in _listEntries(subSkillsDir, skippedSymlinks)) {
        if (subDir is! Directory) continue;
        final subSkillFile = File('${subDir.path}/SKILL.md');
        if (await _isUsableFile(subSkillFile, skippedSymlinks)) {
          filesScanned++;
          final asset = await _tryParseFile(subSkillFile, 'sub-skills');
          if (asset != null) {
            skills.add(asset);
          } else {
            parseErrors++;
          }
        }
      }

      // Skill-local workflows: skills/*/workflows/*.md
      final wfDir = Directory('${skillDir.path}/workflows');
      await for (final wfFile in _listEntries(wfDir, skippedSymlinks)) {
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

    // Scan .agents/workflows/*.md (top-level workflows)
    final workflowsDir = Directory('$rootPath/.agents/workflows');
    await for (final entity in _listEntries(workflowsDir, skippedSymlinks)) {
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
      await for (final entity in _listEntries(laneDir, skippedSymlinks)) {
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

    // Scan docs/changelog/*.md
    final changelogDir = Directory('$rootPath/docs/changelog');
    await for (final entity in _listEntries(changelogDir, skippedSymlinks)) {
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
        skippedSymlinks: List.unmodifiable(skippedSymlinks),
      ),
    );
  }

  /// Lists entries under [dir], respecting [followLinks].
  ///
  /// If [dir] itself is a symlink and [followLinks] is false, records the
  /// path on [skipped] and yields nothing. When listing with
  /// `followLinks: false`, symlink entries appear as [Link] and are recorded
  /// then skipped.
  Stream<FileSystemEntity> _listEntries(
    Directory dir,
    List<String> skipped,
  ) async* {
    if (!await dir.exists()) return;

    if (!followLinks && await FileSystemEntity.isLink(dir.path)) {
      skipped.add(dir.path);
      return;
    }

    await for (final entity in dir.list(followLinks: followLinks)) {
      if (!followLinks &&
          (entity is Link || await FileSystemEntity.isLink(entity.path))) {
        skipped.add(entity.path);
        continue;
      }
      yield entity;
    }
  }

  /// Returns true when [file] exists and is usable under the current symlink
  /// policy. Symlinked files are skipped (and recorded) when [followLinks]
  /// is false.
  Future<bool> _isUsableFile(File file, List<String> skipped) async {
    if (!await file.exists()) return false;
    if (!followLinks && await FileSystemEntity.isLink(file.path)) {
      skipped.add(file.path);
      return false;
    }
    return true;
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
