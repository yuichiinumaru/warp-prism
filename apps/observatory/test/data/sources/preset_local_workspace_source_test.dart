/// Tests for the PresetLocalWorkspaceSource filesystem scanner.
///
/// Uses a temporary fixture directory with sample .agents/ and docs/
/// structures to verify scanner success, empty directory, and missing
/// directory behaviors.
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/sources/preset_local_workspace_source.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('workspace_scanner_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PresetLocalWorkspaceSource', () {
    test(
      'returns empty snapshot for directory with no .agents or docs',
      () async {
        const source = PresetLocalWorkspaceSource();
        final snapshot = await source.load(tempDir.path);

        expect(snapshot.agents, isEmpty);
        expect(snapshot.skills, isEmpty);
        expect(snapshot.workflows, isEmpty);
        expect(snapshot.tasks, isEmpty);
        expect(snapshot.changelogEntries, isEmpty);
        expect(snapshot.totalAssets, equals(0));
        expect(snapshot.metadata.rootPath, equals(tempDir.path));
        expect(snapshot.metadata.filesScanned, equals(0));
        expect(snapshot.metadata.parseErrors, equals(0));
      },
    );

    test('returns empty snapshot for non-existent directory', () async {
      const source = PresetLocalWorkspaceSource();
      final snapshot = await source.load('${tempDir.path}/nonexistent');

      expect(snapshot.totalAssets, equals(0));
      expect(snapshot.metadata.filesScanned, equals(0));
    });

    test('scans agents from .agents/agents/*.md', () async {
      // Create agent file
      final agentDir = Directory('${tempDir.path}/.agents/agents');
      await agentDir.create(recursive: true);
      await File('${agentDir.path}/test-agent.md').writeAsString('''
---
name: test-agent
description: A test agent for scanner validation
tags:
  - test
  - scanner
---

# test-agent

This agent exists to validate the workspace scanner.
''');

      const source = PresetLocalWorkspaceSource();
      final snapshot = await source.load(tempDir.path);

      expect(snapshot.agents.length, equals(1));
      expect(snapshot.agents.first.name, equals('test-agent'));
      expect(
        snapshot.agents.first.description,
        contains('test agent for scanner validation'),
      );
      expect(snapshot.metadata.filesScanned, equals(1));
      expect(snapshot.metadata.parseErrors, equals(0));
    });

    test('scans skills from .agents/skills/*/SKILL.md', () async {
      final skillDir = Directory('${tempDir.path}/.agents/skills/test-skill');
      await skillDir.create(recursive: true);
      await File('${skillDir.path}/SKILL.md').writeAsString('''
---
name: test-skill
description: A test skill for validation
tags:
  - validation
---

# test-skill

This skill validates the scanner.
''');

      const source = PresetLocalWorkspaceSource();
      final snapshot = await source.load(tempDir.path);

      expect(snapshot.skills.length, equals(1));
      expect(snapshot.skills.first.name, equals('test-skill'));
      expect(snapshot.metadata.filesScanned, equals(1));
    });

    test('scans tasks from docs/tasks/{lane}/*.md', () async {
      final taskDir = Directory('${tempDir.path}/docs/tasks/02-doing');
      await taskDir.create(recursive: true);
      await File('${taskDir.path}/T999-test-task.md').writeAsString('''
---
id: "999"
title: Test task for scanner
status: 02-doing
priority: P1
owner: test-agent
created: 2026-06-07
updated: 2026-06-07
---

# Test Task

## Verification Commands

`echo "pass"`
''');

      const source = PresetLocalWorkspaceSource();
      final snapshot = await source.load(tempDir.path);

      expect(snapshot.tasks.length, equals(1));
      expect(snapshot.tasks.first.name, equals('Test task for scanner'));
      expect(snapshot.metadata.filesScanned, equals(1));
    });

    test('scans changelog from docs/changelog/*.md', () async {
      final changelogDir = Directory('${tempDir.path}/docs/changelog');
      await changelogDir.create(recursive: true);
      await File('${changelogDir.path}/2026-06-07-test-entry.md').writeAsString(
        '''
---
id: 2026-06-07-test-entry
date: 2026-06-07
project: warp-prism
task: "999"
type: chore
---

# Test Changelog Entry

## Why

Testing the scanner.
''',
      );

      const source = PresetLocalWorkspaceSource();
      final snapshot = await source.load(tempDir.path);

      expect(snapshot.changelogEntries.length, equals(1));
      expect(snapshot.metadata.filesScanned, equals(1));
    });

    test('scans multiple asset types in one run', () async {
      // Agent
      final agentDir = Directory('${tempDir.path}/.agents/agents');
      await agentDir.create(recursive: true);
      await File('${agentDir.path}/agent1.md').writeAsString('''
---
name: agent1
description: First test agent
---
# agent1
''');

      // Skill
      final skillDir = Directory('${tempDir.path}/.agents/skills/skill1');
      await skillDir.create(recursive: true);
      await File('${skillDir.path}/SKILL.md').writeAsString('''
---
name: skill1
description: First test skill
---
# skill1
''');

      // Task
      final taskDir = Directory('${tempDir.path}/docs/tasks/01-open');
      await taskDir.create(recursive: true);
      await File('${taskDir.path}/T001-test.md').writeAsString('''
---
id: "001"
title: Test task
status: 01-open
priority: P2
created: 2026-06-07
updated: 2026-06-07
---
# Test Task
''');

      // Changelog
      final changelogDir = Directory('${tempDir.path}/docs/changelog');
      await changelogDir.create(recursive: true);
      await File('${changelogDir.path}/2026-06-07-test.md').writeAsString('''
---
id: 2026-06-07-test
date: 2026-06-07
project: warp-prism
task: "001"
type: feature
---
# Test Entry
''');

      const source = PresetLocalWorkspaceSource();
      final snapshot = await source.load(tempDir.path);

      expect(snapshot.agents.length, equals(1));
      expect(snapshot.skills.length, equals(1));
      expect(snapshot.tasks.length, equals(1));
      expect(snapshot.changelogEntries.length, equals(1));
      expect(snapshot.totalAssets, equals(4));
      expect(snapshot.metadata.filesScanned, equals(4));
      expect(snapshot.metadata.parseErrors, equals(0));
    });

    test('handles malformed markdown gracefully', () async {
      final agentDir = Directory('${tempDir.path}/.agents/agents');
      await agentDir.create(recursive: true);
      // File without frontmatter
      await File(
        '${agentDir.path}/bad-agent.md',
      ).writeAsString('This is not a valid agent file with no frontmatter.');

      const source = PresetLocalWorkspaceSource();
      final snapshot = await source.load(tempDir.path);

      expect(snapshot.agents, isEmpty);
      expect(snapshot.metadata.filesScanned, equals(1));
      expect(snapshot.metadata.parseErrors, equals(1));
    });

    test('scans all five task lanes', () async {
      const lanes = [
        '00-planning',
        '01-open',
        '02-doing',
        '03-review',
        '04-completed',
      ];

      for (final lane in lanes) {
        final laneDir = Directory('${tempDir.path}/docs/tasks/$lane');
        await laneDir.create(recursive: true);
        await File('${laneDir.path}/T000-$lane.md').writeAsString('''
---
id: "000"
title: Task in $lane
status: $lane
priority: P2
created: 2026-06-07
updated: 2026-06-07
---
# Task in $lane
''');
      }

      const source = PresetLocalWorkspaceSource();
      final snapshot = await source.load(tempDir.path);

      expect(snapshot.tasks.length, equals(5));
      expect(snapshot.metadata.filesScanned, equals(5));

      // Verify lane breakdown
      final tasksByLane = snapshot.tasksByLane;
      expect(tasksByLane.length, equals(5));
      for (final count in tasksByLane.values) {
        expect(count, equals(1));
      }
    });
  });
}
