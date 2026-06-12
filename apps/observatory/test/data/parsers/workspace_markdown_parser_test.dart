// Tests for the Warp-Prism markdown frontmatter parser.
//
// Covers:
// - FrontmatterParser: generic frontmatter splitting and YAML decoding
// - WorkspaceMarkdownParser: asset-specific parsing into backbone models
// - Happy-path fixtures for agents, skills, workflows, tasks, changelog
// - Malformed frontmatter: missing delimiters, empty frontmatter, unclosed
//
// Run: flutter test test/data/parsers/workspace_markdown_parser_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/parsers/frontmatter_parser.dart';
import 'package:warp_prism_observatory/data/parsers/workspace_markdown_parser.dart';
import 'package:warp_prism_observatory/data/models/data_models.dart';

void main() {
  // ===========================================================================
  // FrontmatterParser — generic decoder
  // ===========================================================================
  group('FrontmatterParser', () {
    const parser = FrontmatterParser();

    test('parses simple key-value pairs', () {
      const input = '''---
name: test-agent
description: A test agent
version: 1.0.0
---
# Body''';

      final result = parser.parse(input);
      expect(result.isOk, true);
      expect(result.frontmatter['name'], 'test-agent');
      expect(result.frontmatter['description'], 'A test agent');
      expect(result.frontmatter['version'], '1.0.0');
      expect(result.body, '# Body');
    });

    test('parses block sequence lists', () {
      const input = '''---
name: with-lists
skills:
  - project-management
  - harness-architecture
tags:
  - orchestrator
  - planning
---
Body content''';

      final result = parser.parse(input);
      expect(result.isOk, true);
      expect(result.frontmatter['skills'], [
        'project-management',
        'harness-architecture',
      ]);
      expect(result.frontmatter['tags'], ['orchestrator', 'planning']);
    });

    test('parses boolean values', () {
      const input = '''---
active: true
disabled: false
---
''';

      final result = parser.parse(input);
      expect(result.isOk, true);
      expect(result.frontmatter['active'], true);
      expect(result.frontmatter['disabled'], false);
    });

    test('parses numeric values', () {
      const input = '''---
id: 7521
score: 85
rating: 3.5
---
''';

      final result = parser.parse(input);
      expect(result.isOk, true);
      expect(result.frontmatter['id'], 7521);
      expect(result.frontmatter['score'], 85);
      expect(result.frontmatter['rating'], 3.5);
    });

    test('parses null values', () {
      const input = '''---
name: test
review_score: null
empty_val:
---
''';

      final result = parser.parse(input);
      expect(result.isOk, true);
      expect(result.frontmatter['name'], 'test');
      expect(result.frontmatter['review_score'], null);
      expect(result.frontmatter['empty_val'], null);
    });

    test('parses inline lists', () {
      const input = '''---
name: inline
tags: [tag1, tag2, tag3]
---
''';

      final result = parser.parse(input);
      expect(result.isOk, true);
      expect(result.frontmatter['tags'], ['tag1', 'tag2', 'tag3']);
    });

    test('parses quoted values', () {
      const input = '''---
name: "quoted name"
desc: 'single quoted'
---
''';

      final result = parser.parse(input);
      expect(result.isOk, true);
      expect(result.frontmatter['name'], 'quoted name');
      expect(result.frontmatter['desc'], 'single quoted');
    });

    test('body is empty when no content after frontmatter', () {
      const input = '''---
name: no-body
---
''';

      final result = parser.parse(input);
      expect(result.isOk, true);
      expect(result.body, '');
    });

    test('handles comments in YAML', () {
      const input = '''---
# This is a comment
name: after-comment
---
''';

      final result = parser.parse(input);
      expect(result.isOk, true);
      expect(result.frontmatter['name'], 'after-comment');
    });

    // --- Error cases ---

    test('error: empty document', () {
      final result = parser.parse('');
      expect(result.isOk, false);
      expect(result.error, contains('Empty'));
    });

    test('error: no frontmatter delimiter', () {
      const input = 'Just plain markdown without frontmatter.';
      final result = parser.parse(input);
      expect(result.isOk, false);
      expect(result.error, contains('does not start with ---'));
    });

    test('error: missing closing delimiter', () {
      const input = '''---
name: unclosed
The closing --- is missing''';

      final result = parser.parse(input);
      expect(result.isOk, false);
      expect(result.error, contains('Missing closing'));
    });

    test('error: empty frontmatter section', () {
      const input = '''---

---
Body''';

      final result = parser.parse(input);
      expect(result.isOk, false);
      expect(result.error, contains('Empty frontmatter'));
    });
  });

  // ===========================================================================
  // WorkspaceMarkdownParser — agent parsing
  // ===========================================================================
  group('WorkspaceMarkdownParser - agent', () {
    const parser = WorkspaceMarkdownParser();

    test('parses agent with all frontmatter fields', () {
      const input = '''---
name: architect-orchestrator
description: Main-session architect orchestrator.
skills:
  - project-management
  - harness-architecture
workflows:
  - gt-ganthritor-onboard
canonicality: parentCanonical
tags:
  - orchestrator
  - governance
---

# architect-orchestrator

Main agent for the workspace.''';

      final asset = parser.parse(
        input,
        filePath:
            'assets/mock_workspace/.agents/agents/architect-orchestrator.md',
      );

      expect(asset.kind, AssetKind.agent);
      expect(asset.name, 'architect-orchestrator');
      expect(asset.description, 'Main-session architect orchestrator.');
      expect(asset.canonicality, Canonicality.parentCanonical);
      expect(asset.tags, ['orchestrator', 'governance']);
      expect(asset.edges.length, 3); // 2 skills + 1 workflow
      expect(asset.edges.where((e) => e.kind == EdgeKind.uses).length, 3);
    });

    test('agent with minimal frontmatter uses defaults', () {
      const input = '''---
name: minimal-agent
---

Body''';

      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/agents/minimal.md',
      );

      expect(asset.kind, AssetKind.agent);
      expect(asset.name, 'minimal-agent');
      expect(asset.description, 'Body');
      expect(asset.canonicality, Canonicality.parentCanonical);
      expect(asset.tags, isEmpty);
      expect(asset.edges, isEmpty);
    });

    test('agent description falls back to first paragraph', () {
      const input = '''---
name: fallback-agent
---

# Title

This is the first real paragraph of content.

More text follows.''';

      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/agents/fallback.md',
      );

      expect(asset.description, 'This is the first real paragraph of content.');
    });
  });

  // ===========================================================================
  // WorkspaceMarkdownParser — skill parsing
  // ===========================================================================
  group('WorkspaceMarkdownParser - skill', () {
    const parser = WorkspaceMarkdownParser();

    test('parses skill with sub-skills and triggers', () {
      const input = '''---
name: harness-architecture
description: Meta-cognition for asset creation.
triggers:
  - create agent
  - create skill
sub_skills:
  - create-agent
  - create-skill
canonicality: parentCanonical
tags:
  - harness
  - governance
---

# harness-architecture''';

      final asset = parser.parse(
        input,
        filePath:
            'assets/mock_workspace/.agents/skills/harness-architecture/SKILL.md',
      );

      expect(asset.kind, AssetKind.skill);
      expect(asset.name, 'harness-architecture');
      expect(asset.triggers, ['create agent', 'create skill']);
      expect(asset.tags, ['harness', 'governance']);
      // 2 sub-skills edges
      expect(asset.edges.where((e) => e.kind == EdgeKind.contains).length, 2);
    });
  });

  // ===========================================================================
  // WorkspaceMarkdownParser — workflow parsing
  // ===========================================================================
  group('WorkspaceMarkdownParser - workflow', () {
    const parser = WorkspaceMarkdownParser();

    test('parses workflow with uses_skills edges', () {
      const input = '''---
name: gt-code-review
description: Multi-tiered code review workflow.
uses_skills:
  - code-quality-harness
  - project-management
tags:
  - review
---

# gt-code-review''';

      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/workflows/gt-code-review.md',
      );

      expect(asset.kind, AssetKind.workflow);
      expect(asset.name, 'gt-code-review');
      expect(asset.edges.where((e) => e.kind == EdgeKind.dependsOn).length, 2);
    });
  });

  // ===========================================================================
  // WorkspaceMarkdownParser — task parsing
  // ===========================================================================
  group('WorkspaceMarkdownParser - task', () {
    const parser = WorkspaceMarkdownParser();

    test('parses task with full frontmatter and body sections', () {
      const input = '''---
id: 7521
title: Build ASW Observatory mock parser
status: 02-doing
priority: P1
owner: builder-orchestrator
created: 2026-06-01
updated: 2026-06-05
skills:
  - project-management
workflows:
  - builder-orchestration
depends_on:
  - 7518
proof_state: partial
review_score: 85
---

# Task 7521

## Goal

Build the parser.

## Exit Conditions

- [ ] Parser works

## Verification Commands

```bash
flutter test
```

## Completion Evidence

Parser tests created.''';

      final asset = parser.parse(
        input,
        filePath:
            'assets/mock_workspace/docs/tasks/02-doing/7521-build-parser.md',
      );

      expect(asset.kind, AssetKind.task);
      expect(asset.id, 'task:7521');
      expect(asset.name, 'Build ASW Observatory mock parser');

      // Verify TaskMetadata is embedded
      final taskMeta = asset.frontmatter['_taskMetadata'] as TaskMetadata;
      expect(taskMeta.id, '7521');
      expect(taskMeta.title, 'Build ASW Observatory mock parser');
      expect(taskMeta.lane, TaskLane.doing);
      expect(taskMeta.priority, 'P1');
      expect(taskMeta.owner, 'builder-orchestrator');
      expect(taskMeta.skills, ['project-management']);
      expect(taskMeta.workflows, ['builder-orchestration']);
      expect(taskMeta.dependsOn, ['7518']);
      expect(taskMeta.proofState, ProofState.partial);
      expect(taskMeta.reviewScore, 85.0);
      expect(taskMeta.verificationCommands, isNotNull);
      expect(taskMeta.verificationCommands, contains('flutter test'));
      expect(taskMeta.completionEvidence, isNotNull);

      // Verify edges
      expect(asset.edges.where((e) => e.kind == EdgeKind.dependsOn).length, 1);
      expect(
        asset.edges.where((e) => e.kind == EdgeKind.references).length,
        2,
      ); // 1 skill + 1 workflow
    });

    test('task lane inferred from path when status missing', () {
      const input = '''---
id: 100
title: Planning task
created: 2026-06-01
updated: 2026-06-01
---

Body''';

      final asset = parser.parse(
        input,
        filePath:
            'assets/mock_workspace/docs/tasks/00-planning/100-planning-task.md',
      );
      final taskMeta = asset.frontmatter['_taskMetadata'] as TaskMetadata;
      expect(taskMeta.lane, TaskLane.planning);
    });

    test('task with null review_score', () {
      const input = '''---
id: 200
title: No score
status: 01-open
created: 2026-06-01
updated: 2026-06-01
review_score: null
---

Body''';

      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/docs/tasks/01-open/200.md',
      );
      final taskMeta = asset.frontmatter['_taskMetadata'] as TaskMetadata;
      expect(taskMeta.reviewScore, null);
    });
  });

  // ===========================================================================
  // WorkspaceMarkdownParser — changelog parsing
  // ===========================================================================
  group('WorkspaceMarkdownParser - changelog', () {
    const parser = WorkspaceMarkdownParser();

    test('parses changelog with full frontmatter and body sections', () {
      const input = '''---
id: 2026-06-05-7521-asw-parser
date: 2026-06-05
project: warp-prism
task: 7521
type: feature
impact:
  - parser
  - graph-model
skills:
  - harness-architecture
---

# ASW parser mock data added

Implemented mock parsing layer.

## Why

Need real markdown parsing.

## Changed

Added FrontmatterParser and WorkspaceMarkdownParser.

## Evidence

All parser tests pass.''';

      final asset = parser.parse(
        input,
        filePath:
            'assets/mock_workspace/docs/changelog/2026-06-05-7521-asw-parser.md',
      );

      expect(asset.kind, AssetKind.changelog);
      expect(asset.id, 'changelog:2026-06-05-7521-asw-parser');
      expect(asset.canonicality, Canonicality.appendOnly);

      // Verify ChangelogMetadata is embedded
      final clMeta =
          asset.frontmatter['_changelogMetadata'] as ChangelogMetadata;
      expect(clMeta.id, '2026-06-05-7521-asw-parser');
      expect(clMeta.project, 'warp-prism');
      expect(clMeta.task, '7521');
      expect(clMeta.type, ChangelogType.feature);
      expect(clMeta.impact, ['parser', 'graph-model']);
      expect(clMeta.skills, ['harness-architecture']);
      expect(clMeta.why, isNotNull);
      expect(clMeta.why, contains('real markdown'));
      expect(clMeta.changed, isNotNull);
      expect(clMeta.evidence, isNotNull);

      // Verify edge to task
      expect(asset.edges.length, 1);
      expect(asset.edges.first.targetId, 'task:7521');
      expect(asset.edges.first.kind, EdgeKind.changedBy);
    });

    test('changelog with chore type', () {
      const input = '''---
id: 2026-06-06-chore
date: 2026-06-06
project: warp-prism
task: 0000
type: chore
---

# Housekeeping

## Why

Maintenance.

## Changed

Cleaned up.''';

      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/docs/changelog/2026-06-06-chore.md',
      );
      final clMeta =
          asset.frontmatter['_changelogMetadata'] as ChangelogMetadata;
      expect(clMeta.type, ChangelogType.chore);
    });
  });

  // ===========================================================================
  // WorkspaceMarkdownParser — error handling
  // ===========================================================================
  group('WorkspaceMarkdownParser - error handling', () {
    const parser = WorkspaceMarkdownParser();

    test('throws ParseException on missing frontmatter', () {
      const input = 'Just plain markdown.';
      expect(
        () => parser.parse(input, filePath: 'bad.md'),
        throwsA(isA<ParseException>()),
      );
    });

    test('throws ParseException on empty frontmatter', () {
      const input = '''---

---
Body''';
      expect(
        () => parser.parse(input, filePath: 'bad.md'),
        throwsA(isA<ParseException>()),
      );
    });

    test('throws ParseException on unclosed frontmatter', () {
      const input = '''---
name: unclosed''';
      expect(
        () => parser.parse(input, filePath: 'bad.md'),
        throwsA(isA<ParseException>()),
      );
    });

    test('tryParse returns null on failure', () {
      const input = 'Not valid.';
      final result = parser.tryParse(input, filePath: 'bad.md');
      expect(result, null);
    });

    test('ParseException includes file path', () {
      const input = 'No frontmatter here.';
      try {
        parser.parse(input, filePath: 'test/fixtures/bad.md');
        fail('Expected ParseException');
      } on ParseException catch (e) {
        expect(e.message, contains('does not start with ---'));
        expect(e.filePath, 'test/fixtures/bad.md');
        expect(e.toString(), contains('test/fixtures/bad.md'));
      }
    });

    test('parseFrontmatter returns raw map on success', () {
      const input = '''---
name: test
---
Body''';
      final fm = parser.parseFrontmatter(input, filePath: 'test.md');
      expect(fm['name'], 'test');
    });

    test('parseFrontmatter throws on failure', () {
      const input = 'No frontmatter.';
      expect(
        () => parser.parseFrontmatter(input, filePath: 'bad.md'),
        throwsA(isA<ParseException>()),
      );
    });
  });

  // ===========================================================================
  // Kind inference
  // ===========================================================================
  group('Kind inference from path', () {
    const parser = WorkspaceMarkdownParser();

    test('agent path infers AssetKind.agent', () {
      const input = '''---
name: test
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/agents/test.md',
      );
      expect(asset.kind, AssetKind.agent);
    });

    test('skill path infers AssetKind.skill', () {
      const input = '''---
name: test-skill
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/skills/test-skill/SKILL.md',
      );
      expect(asset.kind, AssetKind.skill);
    });

    test('workflow path infers AssetKind.workflow', () {
      const input = '''---
name: test-wf
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/workflows/test-wf.md',
      );
      expect(asset.kind, AssetKind.workflow);
    });

    test('task path infers AssetKind.task', () {
      const input = '''---
id: 999
title: Test
created: 2026-06-01
updated: 2026-06-01
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/docs/tasks/01-open/999.md',
      );
      expect(asset.kind, AssetKind.task);
    });

    test('changelog path infers AssetKind.changelog', () {
      const input = '''---
id: cl-001
date: 2026-06-01
project: test
task: 1
type: chore
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/docs/changelog/cl-001.md',
      );
      expect(asset.kind, AssetKind.changelog);
    });
  });

  // ===========================================================================
  // Canonicality parsing
  // ===========================================================================
  group('Canonicality parsing', () {
    const parser = WorkspaceMarkdownParser();

    test('parentCanonical is parsed correctly', () {
      const input = '''---
name: canonical
canonicality: parentCanonical
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/agents/test.md',
      );
      expect(asset.canonicality, Canonicality.parentCanonical);
    });

    test('childLocal is parsed correctly', () {
      const input = '''---
name: local
canonicality: childLocal
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/agents/test.md',
      );
      expect(asset.canonicality, Canonicality.childLocal);
    });

    test('mock is parsed correctly', () {
      const input = '''---
name: mock
canonicality: mock
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/agents/test.md',
      );
      expect(asset.canonicality, Canonicality.mock);
    });

    test('unknown canonicality defaults to parentCanonical', () {
      const input = '''---
name: unknown
canonicality: something-else
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/agents/test.md',
      );
      expect(asset.canonicality, Canonicality.parentCanonical);
    });
  });

  // ===========================================================================
  // Edge inference
  // ===========================================================================
  group('Edge inference', () {
    const parser = WorkspaceMarkdownParser();

    test('agent edges reference skills with uses kind', () {
      const input = '''---
name: agent-with-edges
skills:
  - skill-a
  - skill-b
workflows:
  - wf-a
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/agents/test.md',
      );
      expect(asset.edges.length, 3);
      expect(asset.edges.every((e) => e.kind == EdgeKind.uses), true);
      expect(asset.edges.map((e) => e.targetId), contains('skill:skill-a'));
      expect(asset.edges.map((e) => e.targetId), contains('workflow:wf-a'));
    });

    test('task edges: dependsOn + references', () {
      const input = '''---
id: 100
title: Test
created: 2026-06-01
updated: 2026-06-01
skills:
  - parser
workflows:
  - builder
depends_on:
  - 99
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/docs/tasks/01-open/100.md',
      );
      final deps = asset.edges
          .where((e) => e.kind == EdgeKind.dependsOn)
          .toList();
      final refs = asset.edges
          .where((e) => e.kind == EdgeKind.references)
          .toList();
      expect(deps.length, 1);
      expect(deps.first.targetId, 'task:99');
      expect(refs.length, 2); // 1 skill + 1 workflow
    });

    test('changelog edge points to task via changedBy', () {
      const input = '''---
id: cl-1
date: 2026-06-01
project: test
task: 42
type: feature
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/docs/changelog/cl-1.md',
      );
      expect(asset.edges.length, 1);
      expect(asset.edges.first.kind, EdgeKind.changedBy);
      expect(asset.edges.first.targetId, 'task:42');
    });

    test('skill edges: contains sub-skills', () {
      const input = '''---
name: parent-skill
sub_skills:
  - child-a
  - child-b
  - child-c
---
''';
      final asset = parser.parse(
        input,
        filePath: 'assets/mock_workspace/.agents/skills/parent/SKILL.md',
      );
      final containsEdges = asset.edges
          .where((e) => e.kind == EdgeKind.contains)
          .toList();
      expect(containsEdges.length, 3);
      expect(
        containsEdges.map((e) => e.targetId),
        contains('subskill:child-a'),
      );
    });
  });
}
