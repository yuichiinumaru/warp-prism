---
type: review
title: "task-1308-toast-async-lifecycle-review"
agent: reviewers
created: 2026-06-30T02:31:13
date: 2026-06-30
---

# task-1308-toast-async-lifecycle-review

Score 42/100 REJECTED. Live filesystem evidence invalidates Task 1308 proof: flutter test test/molecules/ds_toast_test.dart fails to compile from packages/warp_prism_ui because the test imports package:warp_prism_ui/warp_prism_ui.dart but uses hidden DS symbols. dart analyze test/molecules/ds_toast_test.dart reports exactly 102 undefined-symbol issues. dart analyze task source files passes. flutter analyze lib/ reports exactly 433 package issues. I added a compact Review Ledger entry to the task and moved it from docs/tasks/03-review to docs/tasks/02-doing. Path to 100: fix test imports or rewrite to Prism aliases, rerun toast test three times, analyze test plus source files, resolve format drift, refresh evidence.
