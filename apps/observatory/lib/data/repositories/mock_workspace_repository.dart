/// Read-only mock workspace repository.
///
/// Loads the mock workspace corpus from `assets/mock_workspace/`,
/// parses it through [WorkspaceMarkdownParser], and returns a typed
/// [WorkspaceLoadState] with the resulting [WorkspaceSnapshot].
///
/// This repository is strictly read-only. It locates assets, reads
/// them, parses them, and aggregates them. It does not write, repair,
/// or move corpus files.
///
/// The mock workspace tree follows the standard layout:
/// ```
/// assets/mock_workspace/
///   .agents/
///     agents/*.md
///     skills/*/SKILL.md, sub-skills/*/SKILL.md, workflows/*.md
///     workflows/*.md
///   docs/
///     tasks/{lane}/*.md
///     changelog/*.md
/// ```
library;

import 'dart:io';

import 'workspace_repository.dart';
import 'workspace_load_state.dart';
import '../models/workspace_snapshot.dart';
import '../models/workspace_graph.dart';
import '../parsers/workspace_markdown_parser.dart';

/// Loads the mock workspace corpus from `assets/mock_workspace/`.
///
/// Uses `dart:io` [File] operations to read markdown files and
/// [WorkspaceMarkdownParser] to parse frontmatter into typed assets.
class MockWorkspaceRepository implements WorkspaceRepository {
  /// The path to the mock workspace root relative to the project.
  static const _defaultRoot = 'assets/mock_workspace';

  /// The markdown parser for parsing discovered files.
  static const _parser = WorkspaceMarkdownParser();

  @override
  final String rootPath;

  /// Creates a repository pointing at the given [rootPath].
  ///
  /// Defaults to `assets/mock_workspace` (relative to project root).
  const MockWorkspaceRepository({this.rootPath = _defaultRoot});

  @override
  Future<WorkspaceLoadState> load() async {
    // Verify the root directory exists
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) {
      return WorkspaceLoadState.error(
        message: 'Mock workspace directory not found: $rootPath',
        rootPath: rootPath,
      );
    }

    try {
      final agents = <WorkspaceAsset>[];
      final skills = <WorkspaceAsset>[];
      final workflows = <WorkspaceAsset>[];
      final tasks = <WorkspaceAsset>[];
      final changelogEntries = <WorkspaceAsset>[];
      var filesScanned = 0;
      var parseErrors = 0;

      // Scan .agents/agents/*.md
      await _scanDirectory(
        '$rootPath/.agents/agents',
        agents,
        onFile: () => filesScanned++,
        onError: () => parseErrors++,
      );

      // Scan .agents/skills/*/SKILL.md and sub-skills
      final skillsDir = Directory('$rootPath/.agents/skills');
      if (await skillsDir.exists()) {
        await for (final skillDir in skillsDir.list()) {
          if (skillDir is Directory) {
            // Top-level SKILL.md
            final skillFile = File('${skillDir.path}/SKILL.md');
            if (await skillFile.exists()) {
              filesScanned++;
              final asset = await _tryParse(skillFile);
              if (asset != null) {
                skills.add(asset);
              } else {
                parseErrors++;
              }
            }

            // Sub-skills
            await _scanDirectory(
              '${skillDir.path}/sub-skills',
              skills,
              filter: (f) => f.path.endsWith('SKILL.md'),
              onFile: () => filesScanned++,
              onError: () => parseErrors++,
            );

            // Skill-local workflows
            await _scanDirectory(
              '${skillDir.path}/workflows',
              workflows,
              onFile: () => filesScanned++,
              onError: () => parseErrors++,
            );
          }
        }
      }

      // Scan .agents/workflows/*.md
      await _scanDirectory(
        '$rootPath/.agents/workflows',
        workflows,
        onFile: () => filesScanned++,
        onError: () => parseErrors++,
      );

      // Scan docs/tasks/{lane}/*.md
      const lanes = [
        '00-planning',
        '01-open',
        '02-doing',
        '03-review',
        '04-completed',
      ];
      for (final lane in lanes) {
        await _scanDirectory(
          '$rootPath/docs/tasks/$lane',
          tasks,
          onFile: () => filesScanned++,
          onError: () => parseErrors++,
        );
      }

      // Scan docs/changelog/*.md
      await _scanDirectory(
        '$rootPath/docs/changelog',
        changelogEntries,
        onFile: () => filesScanned++,
        onError: () => parseErrors++,
      );

      final totalAssets =
          agents.length +
          skills.length +
          workflows.length +
          tasks.length +
          changelogEntries.length;

      final snapshot = WorkspaceSnapshot(
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

      if (totalAssets == 0 && filesScanned == 0) {
        return WorkspaceLoadState.empty(rootPath: rootPath);
      }

      return WorkspaceLoadState.success(snapshot: snapshot, rootPath: rootPath);
    } catch (e) {
      return WorkspaceLoadState.error(
        message: 'Failed to load mock workspace: $e',
        rootPath: rootPath,
      );
    }
  }

  /// Scan a directory for .md files and add parsed assets to [target].
  static Future<void> _scanDirectory(
    String dirPath,
    List<WorkspaceAsset> target, {
    bool Function(File)? filter,
    VoidCallback? onFile,
    VoidCallback? onError,
  }) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.md')) {
        if (filter != null && !filter(entity)) continue;
        onFile?.call();
        final asset = await _tryParse(entity);
        if (asset != null) {
          target.add(asset);
        } else {
          onError?.call();
        }
      }
    }
  }

  /// Try to read and parse a file. Returns null on failure.
  static Future<WorkspaceAsset?> _tryParse(File file) async {
    try {
      final content = await file.readAsString();
      return _parser.tryParse(content, filePath: file.path);
    } catch (_) {
      return null;
    }
  }
}

/// Callback with no arguments and no return value.
typedef VoidCallback = void Function();
