/// Tests for the Operate task projection parser.
///
/// Covers:
/// - Parsing task markdown with Ganthritor-style frontmatter
/// - Lane inference from directory path and frontmatter status
/// - Metadata extraction: priority, owner, proof state, review score
/// - Dependency, skill, and workflow linkage
/// - Verification commands from fenced code blocks
/// - Exit conditions as structured checkbox items
/// - Completion evidence extraction
/// - Lane-neutral task ID references
/// - Fixtures for all five canonical lanes
///
/// Run: flutter test test/data/parsers/workspace_task_projection_parser_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/parsers/workspace_task_projection_parser.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';

void main() {
  const parser = WorkspaceTaskProjectionParser();

  // =========================================================================
  // Fixtures — one per lane
  // =========================================================================

  const planningFixture = '''---
id: T001
title: "Plan workspace onboarding epic"
status: planning
priority: high
owner: architect-orchestrator
created: "2026-05-15"
updated: "2026-05-20"
skills:
  - project-management
  - development-methodologies
workflows:
  - architect-orchestration
  - plan-evidence-to-tasks
depends_on: []
proof_state: none
review_score: n/a
---

# Plan Workspace Onboarding Epic

## Goal
Define the RF8 decomposition for the workspace onboarding experience.

## Exit Conditions
- [ ] RF8 document produced with at least 8 decomposed tasks
- [ ] Dependency DAG reviewed by architect-orchestrator
- [ ] Each task has acceptance criteria and verification commands

## Verification Commands
```bash
cat docs/tasks/00-planning/T001-plan-workspace-onboarding-epic.md | grep "Exit Conditions" -A 3
```

## Completion Evidence
*Not yet completed — task is in planning lane.*
''';

  const openFixture = '''---
id: T006
title: "Parse YAML workspace manifest"
status: open
priority: high
owner: builder-orchestrator
created: "2026-05-20"
updated: "2026-05-28"
skills:
  - coding-execution-harness
workflows:
  - builder-orchestration
  - gt-create-tasks
depends_on:
  - T003
proof_state: none
review_score: n/a
---

# Parse YAML Workspace Manifest

## Goal
Implement a parser that reads manifest.yaml.

## Exit Conditions
- [ ] WorkspaceManifest.fromYaml(String) returns typed model
- [ ] Count validation detects mismatches
- [ ] Unit tests cover valid and invalid inputs

## Verification Commands
```bash
flutter test test/data/manifest_parser_test.dart
```

## Completion Evidence
*Not yet completed — task is in open lane.*
''';

  const doingFixture = '''---
id: T009
title: "Implement task lane board UI"
status: doing
priority: high
owner: builder-orchestrator
created: "2026-06-01"
updated: "2026-06-05"
skills:
  - coding-execution-harness
  - frontend-quality-harness
  - design-system-harness
workflows:
  - builder-orchestration
  - gt-code-review
depends_on:
  - T003
  - T006
proof_state: partial
review_score: 7.5
---

# Implement Task Lane Board UI

## Goal
Build the five-lane task board surface using DSLaneBoard.

## Exit Conditions
- [x] All 5 lanes render with correct task counts
- [ ] DSTaskCard displays title, priority, owner, and review_score
- [ ] Drag from one lane to another fires status change callback
- [ ] Filter controls reduce visible tasks without full reload

## Verification Commands
```bash
flutter test test/features/operate/lane_board_test.dart
```

## Completion Evidence
*Partial — DSLaneBoard organism exists; feature integration pending.*
''';

  const reviewFixture = '''---
id: T015
title: "Governance audit of task dependency chains"
status: review
priority: medium
owner: gt-security-reviewer
created: "2026-06-01"
updated: "2026-06-06"
skills:
  - code-quality-harness
  - project-management
workflows:
  - audit-tasks
  - gt-verify-task-completion
depends_on:
  - T009
  - T012
proof_state: complete
review_score: 9.0
---

# Governance Audit of Task Dependency Chains

## Goal
Verify that all task dependency chains are acyclic.

## Exit Conditions
- [x] Zero cycles detected in dependency graph
- [x] All depends_on references resolve to existing task IDs
- [x] Lane ordering constraint verified
- [ ] Audit report written to docs/reports/

## Verification Commands
```bash
find assets/mock_workspace/docs/tasks -name "*.md" -exec grep -l "depends_on" {} \\; | wc -l
```

## Completion Evidence
*Audit complete. All 22 task dependency references resolve. No cycles found.*
''';

  const completedFixture = '''---
id: T018
title: "Completed: mock agent corpus creation"
status: completed
priority: high
owner: gt-wave-orchestrator
created: "2026-05-10"
updated: "2026-05-18"
skills:
  - harness-architecture
  - agent-wiki
workflows:
  - gt-ganthritor-onboard
  - gt-harness-architecture
depends_on: []
proof_state: complete
review_score: 9.5
---

# Completed: Mock Agent Corpus Creation

## Goal
Create all 9 required agent .md files.

## Exit Conditions
- [x] 9 agent .md files exist in assets/mock_workspace/.agents/agents/
- [x] Each file has valid YAML frontmatter with all required fields
- [x] All referenced skills and workflows resolve to existing files

## Verification Commands
```bash
ls assets/mock_workspace/.agents/agents/*.md | wc -l
grep -l "^name:" assets/mock_workspace/.agents/agents/*.md | wc -l
```

## Completion Evidence
- **Files created**: 9 agent .md files
- **Validation**: ls | wc -l produces 9
- **Reviewer**: gt-wave-orchestrator
- **Completion date**: 2026-05-18
''';

  // =========================================================================
  // Single-task parsing — per-lane happy paths
  // =========================================================================

  group('WorkspaceTaskProjectionParser — single task', () {
    test('parses planning lane task (T001)', () {
      final task = parser.parseTask(
        planningFixture,
        filePath:
            'docs/tasks/00-planning/T001-plan-workspace-onboarding-epic.md',
      );

      expect(task.id, 'T001');
      expect(task.title, 'Plan workspace onboarding epic');
      expect(task.lane, TaskLane.planning);
      expect(task.priority, 'P1'); // "high" → P1
      expect(task.owner, 'architect-orchestrator');
      expect(task.proofState, ProofState.none);
      expect(task.reviewScore, isNull);
      expect(task.linkedSkills, [
        'project-management',
        'development-methodologies',
      ]);
      expect(task.linkedWorkflows, [
        'architect-orchestration',
        'plan-evidence-to-tasks',
      ]);
      expect(task.dependsOn, isEmpty);
      expect(task.dependencyCount, 0);
      expect(task.verificationCommands, hasLength(1));
      expect(task.verificationCommands.first, contains('grep'));
      expect(task.exitConditions, hasLength(3));
      expect(task.exitConditions.every((e) => !e.isComplete), isTrue);
      expect(task.hasCompletionEvidence, isFalse);
    });

    test('parses open lane task (T006)', () {
      final task = parser.parseTask(
        openFixture,
        filePath: 'docs/tasks/01-open/T006-parse-yaml-workspace-manifest.md',
      );

      expect(task.id, 'T006');
      expect(task.lane, TaskLane.open);
      expect(task.priority, 'P1');
      expect(task.dependsOn, ['T003']);
      expect(task.dependencyCount, 1);
      expect(task.proofState, ProofState.none);
      expect(task.exitConditions, hasLength(3));
    });

    test('parses doing lane task (T009)', () {
      final task = parser.parseTask(
        doingFixture,
        filePath: 'docs/tasks/02-doing/T009-implement-task-lane-board-ui.md',
      );

      expect(task.id, 'T009');
      expect(task.lane, TaskLane.doing);
      expect(task.proofState, ProofState.partial);
      expect(task.reviewScore, 7.5);
      expect(task.linkedSkills, hasLength(3));
      expect(task.dependsOn, ['T003', 'T006']);
      expect(task.dependencyCount, 2);
      // First exit condition is checked
      expect(task.exitConditions.first.isComplete, isTrue);
      expect(task.hasVerificationCommands, isTrue);
    });

    test('parses review lane task (T015)', () {
      final task = parser.parseTask(
        reviewFixture,
        filePath:
            'docs/tasks/03-review/T015-governance-audit-task-dependency-chains.md',
      );

      expect(task.id, 'T015');
      expect(task.lane, TaskLane.review);
      expect(task.priority, 'P2'); // "medium" → P2
      expect(task.owner, 'gt-security-reviewer');
      expect(task.proofState, ProofState.complete);
      expect(task.reviewScore, 9.0);
      expect(task.dependsOn, ['T009', 'T012']);
      expect(task.exitConditions.where((e) => e.isComplete).length, 3);
      expect(task.hasCompletionEvidence, isTrue);
    });

    test('parses completed lane task (T018)', () {
      final task = parser.parseTask(
        completedFixture,
        filePath:
            'docs/tasks/04-completed/T018-completed-mock-agent-corpus-creation.md',
      );

      expect(task.id, 'T018');
      expect(task.lane, TaskLane.completed);
      expect(task.priority, 'P1'); // "high" → P1
      expect(task.proofState, ProofState.complete);
      expect(task.reviewScore, 9.5);
      expect(task.exitConditions.every((e) => e.isComplete), isTrue);
      expect(task.hasCompletionEvidence, isTrue);
      expect(task.verificationCommands, hasLength(2));
    });
  });

  // =========================================================================
  // Lane inference
  // =========================================================================

  group('lane inference', () {
    test('infers lane from directory path when status is missing', () {
      const content = '''---
id: T999
title: "Test task"
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
---
# Test''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/03-review/T999-test.md',
      );
      expect(task.lane, TaskLane.review);
    });

    test('frontmatter status overrides directory path', () {
      const content = '''---
id: T999
title: "Test task"
status: completed
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
---
# Test''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/01-open/T999-test.md',
      );
      expect(task.lane, TaskLane.completed);
    });

    test('defaults to open lane for unknown paths', () {
      const content = '''---
id: T999
title: "Test task"
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
---
# Test''';

      final task = parser.parseTask(
        content,
        filePath: 'some/other/path/T999-test.md',
      );
      expect(task.lane, TaskLane.open);
    });
  });

  // =========================================================================
  // Metadata extraction edge cases
  // =========================================================================

  group('metadata extraction', () {
    test('normalizes priority values', () {
      const content = '''---
id: T001
title: "Test"
priority: critical
owner: test
created: "2026-01-01"
updated: "2026-01-01"
---
# Test''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/01-open/T001.md',
      );
      expect(task.priority, 'P0');
    });

    test('handles n/a review score as null', () {
      const content = '''---
id: T001
title: "Test"
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
review_score: n/a
---
# Test''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/01-open/T001.md',
      );
      expect(task.reviewScore, isNull);
    });

    test('extracts numeric review score', () {
      const content = '''---
id: T001
title: "Test"
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
review_score: 8.5
---
# Test''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/01-open/T001.md',
      );
      expect(task.reviewScore, 8.5);
    });

    test('handles missing optional fields gracefully', () {
      const content = '''---
id: T001
title: "Minimal task"
---
# Minimal''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/01-open/T001.md',
      );
      expect(task.id, 'T001');
      expect(task.title, 'Minimal task');
      expect(task.owner, 'unassigned');
      expect(task.priority, 'P2');
      expect(task.linkedSkills, isEmpty);
      expect(task.dependsOn, isEmpty);
    });
  });

  // =========================================================================
  // Body section extraction
  // =========================================================================

  group('body extraction', () {
    test('extracts verification commands from fenced code blocks', () {
      const content = '''---
id: T001
title: "Test"
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
---
# Test

## Verification Commands
```bash
flutter test
flutter analyze
```
''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/01-open/T001.md',
      );
      expect(task.verificationCommands, ['flutter test', 'flutter analyze']);
    });

    test('extracts exit conditions as structured items', () {
      const content = '''---
id: T001
title: "Test"
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
---
# Test

## Exit Conditions
- [x] First condition done
- [ ] Second condition pending
- [x] Third condition done
''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/01-open/T001.md',
      );
      expect(task.exitConditions, hasLength(3));
      expect(task.exitConditions[0].isComplete, isTrue);
      expect(task.exitConditions[0].text, 'First condition done');
      expect(task.exitConditions[1].isComplete, isFalse);
      expect(task.exitConditions[2].isComplete, isTrue);
    });

    test('hasCompletionEvidence is false for "not yet" text', () {
      const content = '''---
id: T001
title: "Test"
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
---
# Test

## Completion Evidence
*Not yet completed — task is in open lane.*
''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/01-open/T001.md',
      );
      expect(task.hasCompletionEvidence, isFalse);
    });

    test('hasCompletionEvidence is true for real evidence', () {
      const content = '''---
id: T001
title: "Test"
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
---
# Test

## Completion Evidence
All tests pass. Files created as expected.
''';

      final task = parser.parseTask(
        content,
        filePath: 'docs/tasks/04-completed/T001.md',
      );
      expect(task.hasCompletionEvidence, isTrue);
    });
  });

  // =========================================================================
  // parseAll — full Operate projection
  // =========================================================================

  group('parseAll — OperateProjection', () {
    test('groups tasks into five lanes', () {
      final projection = parser.parseAll({
        'docs/tasks/00-planning/T001-plan.md': planningFixture,
        'docs/tasks/01-open/T006-parse.md': openFixture,
        'docs/tasks/02-doing/T009-lane-board.md': doingFixture,
        'docs/tasks/03-review/T015-audit.md': reviewFixture,
        'docs/tasks/04-completed/T018-agent-corpus.md': completedFixture,
      });

      expect(projection.totalTasks, 5);
      expect(projection.lanes, hasLength(5));
      expect(projection.laneFor(TaskLane.planning).count, 1);
      expect(projection.laneFor(TaskLane.open).count, 1);
      expect(projection.laneFor(TaskLane.doing).count, 1);
      expect(projection.laneFor(TaskLane.review).count, 1);
      expect(projection.laneFor(TaskLane.completed).count, 1);
    });

    test('returns empty lane when no tasks match', () {
      final projection = parser.parseAll({
        'docs/tasks/02-doing/T009.md': doingFixture,
      });

      expect(projection.laneFor(TaskLane.planning).isEmpty, isTrue);
      expect(projection.laneFor(TaskLane.doing).count, 1);
    });

    test('sorts tasks by priority within a lane', () {
      const lowPriority = '''---
id: T050
title: "Low priority task"
priority: low
owner: test
created: "2026-01-01"
updated: "2026-01-01"
---
# Test''';

      const criticalPriority = '''---
id: T051
title: "Critical task"
priority: critical
owner: test
created: "2026-01-02"
updated: "2026-01-02"
---
# Test''';

      final projection = parser.parseAll({
        'docs/tasks/01-open/T050-low.md': lowPriority,
        'docs/tasks/01-open/T051-critical.md': criticalPriority,
      });

      final openTasks = projection.laneFor(TaskLane.open).tasks;
      expect(openTasks.first.id, 'T051'); // P0 before P3
      expect(openTasks.last.id, 'T050');
    });

    test('allTasks returns flat list across lanes', () {
      final projection = parser.parseAll({
        'docs/tasks/00-planning/T001.md': planningFixture,
        'docs/tasks/02-doing/T009.md': doingFixture,
        'docs/tasks/04-completed/T018.md': completedFixture,
      });

      expect(projection.allTasks, hasLength(3));
    });
  });

  // =========================================================================
  // tryParse — error handling
  // =========================================================================

  group('tryParse', () {
    test('returns null for malformed content', () {
      final result = parser.tryParseTask(
        'not valid markdown',
        filePath: 'docs/tasks/01-open/bad.md',
      );
      expect(result, isNull);
    });

    test('returns projection for valid content', () {
      final result = parser.tryParseTask(
        planningFixture,
        filePath: 'docs/tasks/00-planning/T001.md',
      );
      expect(result, isNotNull);
      expect(result!.id, 'T001');
    });
  });

  // =========================================================================
  // Error cases
  // =========================================================================

  group('error handling', () {
    test('throws TaskParseException for missing frontmatter', () {
      expect(
        () => parser.parseTask(
          'no frontmatter here',
          filePath: 'docs/tasks/01-open/bad.md',
        ),
        throwsA(isA<TaskParseException>()),
      );
    });

    test('TaskParseException includes file path', () {
      try {
        parser.parseTask('bad content', filePath: 'docs/tasks/01-open/bad.md');
        fail('Should have thrown');
      } on TaskParseException catch (e) {
        expect(e.filePath, 'docs/tasks/01-open/bad.md');
        expect(e.toString(), contains('bad.md'));
      }
    });
  });
}
