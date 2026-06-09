/// Tests for the MockWorkspaceRepository.
///
/// Tests successful loading from the mock workspace corpus, empty
/// directory behavior, and error propagation for missing directories.
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/repositories/mock_workspace_repository.dart';
import 'package:warp_prism_observatory/data/repositories/workspace_load_state.dart';

void main() {
  group('MockWorkspaceRepository', () {
    test('loads assets from the real mock workspace corpus', () async {
      // Verify the mock workspace exists (skip if not present)
      final mockDir = Directory('assets/mock_workspace');
      if (!await mockDir.exists()) {
        // If we can't find assets relative to cwd, try from project root
        final altDir = Directory('warp-prism/assets/mock_workspace');
        if (!await altDir.exists()) {
          return; // Skip: assets not available in test environment
        }
      }

      const repo = MockWorkspaceRepository();
      final state = await repo.load();

      // Should succeed (or be empty if assets dir exists but is empty)
      expect(
        state.isSuccess,
        isTrue,
        reason: 'Load should succeed: ${state.errorMessage ?? "no error"}',
      );

      if (state.status == WorkspaceLoadStatus.success) {
        final snapshot = state.snapshot!;
        // The mock corpus should have at least some assets
        expect(snapshot.totalAssets, greaterThan(0),
            reason: 'Mock corpus should contain assets');

        // Agents should be present
        expect(snapshot.agents, isNotEmpty,
            reason: 'Mock corpus contains agent files');

        // Skills should be present
        expect(snapshot.skills, isNotEmpty,
            reason: 'Mock corpus contains skill files');

        // Tasks should be present
        expect(snapshot.tasks, isNotEmpty,
            reason: 'Mock corpus contains task files');

        // Changelog entries should be present
        expect(snapshot.changelogEntries, isNotEmpty,
            reason: 'Mock corpus contains changelog files');

        // Metadata should reflect the scan
        expect(snapshot.metadata.rootPath, equals('assets/mock_workspace'));
        expect(snapshot.metadata.filesScanned, greaterThan(0));

        // Task lane breakdown should be populated
        final tasksByLane = snapshot.tasksByLane;
        expect(tasksByLane, isNotEmpty);
        final totalFromLanes =
            tasksByLane.values.fold<int>(0, (sum, c) => sum + c);
        expect(totalFromLanes, equals(snapshot.tasks.length));
      }
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
      // Create a temp directory with the expected structure but no files
      final tempDir =
          await Directory.systemTemp.createTemp('mock_repo_empty_test_');
      try {
        // Create the directory structure but leave it empty
        await Directory('${tempDir.path}/.agents/agents').create(recursive: true);
        await Directory('${tempDir.path}/.agents/skills').create(recursive: true);
        await Directory('${tempDir.path}/.agents/workflows')
            .create(recursive: true);
        await Directory('${tempDir.path}/docs/tasks/00-planning')
            .create(recursive: true);
        await Directory('${tempDir.path}/docs/tasks/01-open')
            .create(recursive: true);
        await Directory('${tempDir.path}/docs/tasks/02-doing')
            .create(recursive: true);
        await Directory('${tempDir.path}/docs/tasks/03-review')
            .create(recursive: true);
        await Directory('${tempDir.path}/docs/tasks/04-completed')
            .create(recursive: true);
        await Directory('${tempDir.path}/docs/changelog')
            .create(recursive: true);

        final repo = MockWorkspaceRepository(rootPath: tempDir.path);
        final state = await repo.load();

        // Empty directory should return empty state
        expect(state.status, equals(WorkspaceLoadStatus.empty));
        expect(state.rootPath, equals(tempDir.path));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('handles malformed files gracefully', () async {
      final tempDir =
          await Directory.systemTemp.createTemp('mock_repo_malformed_test_');
      try {
        // Create agent dir with a malformed file
        final agentDir = Directory('${tempDir.path}/.agents/agents');
        await agentDir.create(recursive: true);
        await File('${agentDir.path}/bad-agent.md').writeAsString(
          'No frontmatter here, just plain text.',
        );

        // Create a valid agent
        await File('${agentDir.path}/good-agent.md').writeAsString('''
---
name: good-agent
description: A properly formatted agent
---
# good-agent
''');

        final repo = MockWorkspaceRepository(rootPath: tempDir.path);
        final state = await repo.load();

        // Should succeed with partial data
        expect(state.isSuccess, isTrue);
        if (state.status == WorkspaceLoadStatus.success) {
          final snapshot = state.snapshot!;
          expect(snapshot.agents.length, equals(1));
          expect(snapshot.agents.first.name, equals('good-agent'));
          expect(snapshot.metadata.parseErrors, equals(1));
          expect(snapshot.metadata.filesScanned, equals(2));
        }
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('uses workspace_graph.dart backbone types', () async {
      final tempDir =
          await Directory.systemTemp.createTemp('mock_repo_types_test_');
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

        // Verify backbone model types are used
        expect(asset.kind, isNotNull);
        expect(asset.kind.name, equals('agent'));
        expect(asset.canonicality, isNotNull);
        expect(asset.frontmatter, isA<Map<String, dynamic>>());
      } finally {
        await tempDir.delete(recursive: true);
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
