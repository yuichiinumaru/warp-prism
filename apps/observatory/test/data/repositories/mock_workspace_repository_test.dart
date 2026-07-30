/// Tests for the MockWorkspaceRepository.
///
/// Tests successful loading from the mock workspace corpus, empty
/// directory behavior, total parse-failure error, and partial-success
/// with parseErrorPaths. Temp fixtures use repo-local `tmp/` only.
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/repositories/mock_workspace_repository.dart';
import 'package:warp_prism_observatory/data/repositories/workspace_load_state.dart';

/// Repo-local temp root (never Directory.systemTemp).
Directory _repoTempRoot() {
  final candidates = [
    Directory('tmp/test_fixtures'),
    Directory('apps/observatory/tmp/test_fixtures'),
  ];
  for (final d in candidates) {
    d.createSync(recursive: true);
    if (d.existsSync()) return d;
  }
  fail('Unable to create repo-local tmp/test_fixtures');
}

Future<Directory> _createTempDir(String prefix) async {
  final root = _repoTempRoot();
  final dir = Directory(
    '${root.path}/$prefix${DateTime.now().microsecondsSinceEpoch}',
  );
  await dir.create(recursive: true);
  return dir;
}

void main() {
  group('MockWorkspaceRepository', () {
    test('loads assets from the real mock workspace corpus', () async {
      final mockDir = Directory('assets/mock_workspace');
      final altDir = Directory('apps/observatory/assets/mock_workspace');
      final rootPath = mockDir.existsSync()
          ? mockDir.path
          : altDir.existsSync()
              ? altDir.path
              : null;
      expect(
        rootPath,
        isNotNull,
        reason:
            'Mock corpus assets/mock_workspace must exist for repository tests '
            '(cwd=${Directory.current.path})',
      );

      final repo = MockWorkspaceRepository(rootPath: rootPath!);
      final state = await repo.load();

      expect(
        state.isSuccess,
        isTrue,
        reason: 'Load should succeed: ${state.errorMessage ?? "no error"}',
      );
      expect(state.status, equals(WorkspaceLoadStatus.success));

      final snapshot = state.snapshot!;
      expect(
        snapshot.totalAssets,
        greaterThan(0),
        reason: 'Mock corpus should contain assets',
      );
      expect(snapshot.agents, isNotEmpty);
      expect(snapshot.skills, isNotEmpty);
      expect(snapshot.tasks, isNotEmpty);
      expect(snapshot.changelogEntries, isNotEmpty);
      expect(snapshot.metadata.rootPath, equals(rootPath));
      expect(snapshot.metadata.filesScanned, greaterThan(0));
      // Skill-local workflows carry frontmatter — clean load expected.
      expect(
        snapshot.metadata.parseErrors,
        equals(0),
        reason:
            'Real corpus under repository scan rules should parse cleanly. '
            'parseErrorPaths=${snapshot.metadata.parseErrorPaths}',
      );
      expect(snapshot.metadata.parseErrorPaths, isEmpty);

      final tasksByLane = snapshot.tasksByLane;
      expect(tasksByLane, isNotEmpty);
      final totalFromLanes = tasksByLane.values.fold<int>(
        0,
        (sum, c) => sum + c,
      );
      expect(totalFromLanes, equals(snapshot.tasks.length));
    });

    test('returns error state for non-existent root path', () async {
      const repo = MockWorkspaceRepository(
        rootPath: '/nonexistent/path/to/mock/workspace',
      );
      final state = await repo.load();

      expect(state.isError, isTrue);
      expect(state.errorMessage, contains('not found'));
      expect(state.rootPath, equals('/nonexistent/path/to/mock/workspace'));
    });

    test('returns empty state for empty directory', () async {
      final tempDir = await _createTempDir('mock_repo_empty_');
      try {
        await Directory(
          '${tempDir.path}/.agents/agents',
        ).create(recursive: true);
        await Directory(
          '${tempDir.path}/.agents/skills',
        ).create(recursive: true);
        await Directory(
          '${tempDir.path}/.agents/workflows',
        ).create(recursive: true);
        await Directory(
          '${tempDir.path}/docs/tasks/00-planning',
        ).create(recursive: true);
        await Directory(
          '${tempDir.path}/docs/tasks/01-open',
        ).create(recursive: true);
        await Directory(
          '${tempDir.path}/docs/tasks/02-doing',
        ).create(recursive: true);
        await Directory(
          '${tempDir.path}/docs/tasks/03-review',
        ).create(recursive: true);
        await Directory(
          '${tempDir.path}/docs/tasks/04-completed',
        ).create(recursive: true);
        await Directory(
          '${tempDir.path}/docs/changelog',
        ).create(recursive: true);

        final repo = MockWorkspaceRepository(rootPath: tempDir.path);
        final state = await repo.load();

        expect(state.status, equals(WorkspaceLoadStatus.empty));
        expect(state.rootPath, equals(tempDir.path));
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
      'partial success: valid assets + parseErrors with error paths',
      () async {
        final tempDir = await _createTempDir('mock_repo_partial_');
        try {
          final agentDir = Directory('${tempDir.path}/.agents/agents');
          await agentDir.create(recursive: true);
          await File(
            '${agentDir.path}/bad-agent.md',
          ).writeAsString('No frontmatter here, just plain text.');

          await File('${agentDir.path}/good-agent.md').writeAsString('''
---
name: good-agent
description: A properly formatted agent
---
# good-agent
''');

          final repo = MockWorkspaceRepository(rootPath: tempDir.path);
          final state = await repo.load();

          // Partial success contract: assets present + parseErrors recorded.
          expect(state.isSuccess, isTrue);
          expect(state.status, equals(WorkspaceLoadStatus.success));
          final snapshot = state.snapshot!;
          expect(snapshot.agents.length, equals(1));
          expect(snapshot.agents.first.name, equals('good-agent'));
          expect(snapshot.metadata.parseErrors, equals(1));
          expect(snapshot.metadata.filesScanned, equals(2));
          expect(snapshot.metadata.parseErrorPaths.length, equals(1));
          expect(
            snapshot.metadata.parseErrorPaths.first,
            contains('bad-agent.md'),
          );
        } finally {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );

    test('total parse failure returns error (not empty/success)', () async {
      final tempDir = await _createTempDir('mock_repo_all_bad_');
      try {
        final agentDir = Directory('${tempDir.path}/.agents/agents');
        await agentDir.create(recursive: true);
        await File(
          '${agentDir.path}/only-bad.md',
        ).writeAsString('No frontmatter at all.');

        final repo = MockWorkspaceRepository(rootPath: tempDir.path);
        final state = await repo.load();

        expect(state.isError, isTrue);
        expect(state.status, equals(WorkspaceLoadStatus.error));
        expect(state.errorMessage, contains('failed to parse'));
        expect(state.errorMessage, contains('only-bad.md'));
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('uses workspace_graph.dart backbone types', () async {
      final tempDir = await _createTempDir('mock_repo_types_');
      try {
        final agentDir = Directory('${tempDir.path}/.agents/agents');
        await agentDir.create(recursive: true);
        await File('${agentDir.path}/test-agent.md').writeAsString('''
---
name: test-agent
description: Tests backbone type usage
tags:
  - test
---
# test-agent
''');

        final repo = MockWorkspaceRepository(rootPath: tempDir.path);
        final state = await repo.load();

        expect(state.status, equals(WorkspaceLoadStatus.success));
        final asset = state.snapshot!.agents.first;

        expect(asset.kind, isNotNull);
        expect(asset.kind.name, equals('agent'));
        expect(asset.canonicality, isNotNull);
        expect(asset.frontmatter, isA<Map<String, dynamic>>());
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('state equality works correctly', () {
      const state1 = WorkspaceLoadState.empty(rootPath: '/test');
      const state2 = WorkspaceLoadState.empty(rootPath: '/test');
      const state3 = WorkspaceLoadState.error(
        message: 'fail',
        rootPath: '/test',
      );

      expect(state1, equals(state2));
      expect(state1 == state3, isFalse);
    });
  });
}
