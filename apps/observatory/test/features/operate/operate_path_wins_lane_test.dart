/// Path-to-100 residual (Task 0610/0611): path-segment-wins lane alignment.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/parsers/workspace_markdown_parser.dart';
import 'package:warp_prism_observatory/data/parsers/workspace_task_projection_parser.dart';
import 'package:warp_prism_observatory/features/operate/operate_projection_builder.dart';

void main() {
  group('path-wins lane inference', () {
    test('parser: 03-review + status completed → review', () {
      const parser = WorkspaceTaskProjectionParser();
      final projection = parser.parseTask('''
---
id: T999
title: Stale status fixture
status: completed
---

## Exit Conditions
- [ ] still open

## Completion Evidence
- **Files**: none yet
''', filePath: 'docs/tasks/03-review/T999-stale-status.md');
      expect(projection.lane, TaskLane.review);
      expect(projection.exitConditions, isNotEmpty);
      expect(projection.completionEvidenceRows, isNotEmpty);
    });

    test('markdown parser + operate bridge share path-wins', () {
      const md = WorkspaceMarkdownParser();
      final asset = md.parse('''
---
id: T998
title: Review with stale completed status
status: completed
type: task
---

## Exit Conditions
- [x] done item

## Completion Evidence
- **Proof**: live gates
''', filePath: 'docs/tasks/03-review/T998-stale.md');

      expect(asset.kind, AssetKind.task);
      final meta = asset.frontmatter['_taskMetadata'] as TaskMetadata;
      expect(meta.lane, TaskLane.review);

      final projection = taskProjectionFromAsset(asset);
      expect(projection.lane, TaskLane.review);
      expect(projection.exitConditions, isNotEmpty);
      expect(projection.completionEvidenceRows, isNotEmpty);
      expect(projection.sections, isNotEmpty);
    });

    test('inferLaneFromPath ignores status when segment present', () {
      expect(
        WorkspaceTaskProjectionParser.inferLaneFromPath(
          'docs/tasks/02-doing/foo.md',
          'completed',
        ),
        TaskLane.doing,
      );
      expect(
        WorkspaceTaskProjectionParser.inferLaneFromPath(
          'orphan/foo.md',
          'review',
        ),
        TaskLane.review,
      );
    });
  });
}
