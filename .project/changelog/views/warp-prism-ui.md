# Changelog: warp-prism-ui

> **Note**: Auto-generated view for project `warp-prism-ui` from `.project/changelog/` entries.
> **Do NOT edit manually** - use the changelog skill/subcommands.
> **Last rebuilt**: 2026-10-15 21:33:42 UTC

---

# Task 1838: Real-Host Composition Revalidation Evidence — 1805 Criteria 3/5/9/11 Technical Layer (promoted)

## Summary

All three hosts green across the viewport matrix with errors:[] in every trace; the three historical invalidations (Observatory search-bar Material crash, CyberCore data-table overflow, chrome teal divergence) each addressed by specific runs; harness gained compact500x900 viewport + durable revalidation suites in apps/*/test/host_exercise/; zero product code modified.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review: docs/reports/reviewers/1838-real-host-revalidation-evidence-review-loop.md (93/100 APPROVED_PATH100, zero REGRESSION findings; suites re-run by reviewer with exact exits +9/+8/+8/+10)

---

# Task 1837: Golden Suite Tagging — --exclude-tags=golden Effective (promoted)

## Summary

flutter test test/ --no-pub --exclude-tags=golden now exits 0 (+1692 all passed) — the documented full-suite validation command is finally usable on this branch; goldens still run without exclusion (60 dir tests: 59 expected frozen-drift failures + 1 drift-invariant pass; 14 embedded); Task 1800/1805 golden freeze intact (0 baselines touched); boundary harness 15/15.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review: docs/reports/reviewers/1837-golden-suite-tagging-review-loop.md (95/100 APPROVED_PATH100, zero REGRESSION findings; primary gate re-run +1692 exit 0)

---

# Task 1836: Layout-Band Completion — Scrubber/Table Falsified Bands + Trap Hygiene (promoted)

## Summary

Scrubber/table layout-contract bands independently re-executed green (18/18, 7/7, 2/2, 707/707 organisms, both host widget suites, both debug builds, capture suites); expected data-table golden drift recorded under Task 1800 freeze without refresh; F3/F7/F8 carried as accepted non-blocking residuals.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review: docs/reports/review/1836-layout-band-completion-independent-review-2026-09-06.md (90/100 PASS, zero regressions)

---

# Task 1835: Package-Wide Material Ancestry Meta-Test — Remediation Round 1 (PrismSelect + oracle)

## Summary

Meta-test guards the full 118/118 public widget surface with a falsification-tight oracle; 123 tests green; classification counts corrected; task promoted to completed after 95/100 independent acceptance.

## Changes

- Documented task completion details.

## Verification

- [x] Independent re-review: docs/reports/reviewers/1835-material-ancestry-meta-test-review-loop.md (Entry 2, 95/100 APPROVED_PATH100, zero REGRESSION findings)

---

# Task 1833: Theme-Role and Accent Propagation — Remediation Round 3 (F6 chrome migration)

## Summary

CyberCore shell chrome now resolves teal from the installed theme; regression guard added; boundary harness 15/15; cybercore +23 tests green; task promoted to completed after 93/100 independent acceptance.

## Changes

- Documented task completion details.

## Verification

- [x] Independent re-review: docs/reports/reviewers/1833-theme-role-accent-propagation-review-loop.md (Entry 3, 93/100 APPROVED_PATH100, zero REGRESSION findings)

---

# Task 1835: Package-Wide Material Ancestry Meta-Test — Remediation Round 1 (PrismSelect + oracle)

## Summary

Meta-test now guards the full public widget surface (118/118) with a falsification-tight bare-phase oracle; test hygiene fixed (controller teardowns); classification counts corrected to 113 SELF_SUFFICIENT + 5 DECLARED_PREREQUISITE + 0 UNDOCUMENTED_PREREQUISITE.

## Changes

- Documented task completion details.

## Verification

- [x] cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings -> Exit 0 (0 errors, 212 pre-existing info baseline)
- [x] cd packages/warp_prism_ui && flutter test test/meta/material_ancestry_meta_test.dart --no-pub -> Exit 0 (+123: All tests passed)
- [x] cd packages/warp_prism_ui && flutter test test/meta/material_ancestry_meta_test.dart --no-pub --plain-name PrismSelect -> Exit 0 (+1)
- [x] cd packages/warp_prism_ui && flutter test <scoped 5-file suite> --no-pub -> Exit 0 (+171: All tests passed)

---

# Task 1833: Theme-Role and Accent Propagation — Remediation Round 3 (F6 chrome migration)

## Summary

CyberCore shell chrome (header gradient, compact bottom-nav selection, all 4 story-panel accents) now resolves teal from the installed theme via PrismTheme.accentOf/accentMutedOf instead of static Khalai Blue; regression guard added proving teal resolution with pristine registry; DSButton focus-ring oracle strengthened to theme-following; boundary Check 8 stays 15/15 with zero registry mutators in apps/cybercore/lib.

## Changes

- Documented task completion details.

## Verification

- [x] cd apps/cybercore && flutter analyze --no-fatal-infos --no-fatal-warnings -> Exit 0 (No issues found)
- [x] cd apps/cybercore && flutter test --no-pub -> Exit 0 (+23: All tests passed, incl. new chrome teal tests)
- [x] cd apps/cybercore && flutter build linux --debug -> Exit 0
- [x] dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root . -> Exit 0 (15/15 PASS)
- [x] cd packages/warp_prism_ui && flutter test test/atoms/button/ds_button_test.dart test/theme/theme_role_accent_propagation_test.dart --no-pub -> Exit 0 (+25)

---
