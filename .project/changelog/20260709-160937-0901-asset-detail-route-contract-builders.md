---
date: 20260709-160937
timestamp: 20260709-160937
project: warp-prism
agent: builders
task: "0901"
description: "Asset detail route contract verified with scoped Flutter tests"
is_rebuild_safe: true
---

# Task 0901: Asset Detail Route Contract

## Summary

Verified and closed the deferred Flutter SDK gates for Task 0901. Canonical
`/assets/:assetId` route, selection controller, unknown-asset fallback, legacy
redirect, and close/back navigation are proven with scoped observatory tests.
Expanded route-contract widget coverage against the current `ConsumerWidget`
`AssetDetailPage` + graph-backed descriptor provider.

## Changes

- Confirmed monorepo paths under `apps/observatory/` (not root `lib/`).
- Strengthened `test/app/asset_detail_route_test.dart` with GoRouter contract
  widget tests: open, legacy redirect, unknown/missing asset fallback, close/back,
  and `detailRoute` helper alignment.
- No production route shape changes required — existing contract already correct:
  - `lib/app/router.dart`: `/assets/:assetId` + `/asset/:id` redirect
  - `lib/app/asset_selection_controller.dart`: resolve/clear/refresh selection
  - `lib/app/pages/asset_detail_page.dart`: Prism* public API + shell fallback

## Verification

| Command | Result |
| --- | --- |
| `flutter test test/app/asset_detail_route_test.dart test/app/deep_link_fallback_test.dart` | 33/33 PASS |
| `dart format --output=none --set-exit-if-changed` (scoped) | PASS |
| `flutter analyze` (scoped route/selection/page/tests) | No issues found |

**Author**: builders (self-review; reviewers unavailable)
