# Review Wave 1 — Task 1121: Code Block And Markdown Renderer

**Date**: 2026-06-13  
**Reviewer**: independent Flutter reviewer  
**Task**: `docs/tasks/03-review/1121-warp-prism-code-block-and-markdown-renderer.md`  
**Previous report**: `docs/reports/build-gate-review/1121-review.md`  
**Report lineage**: Re-review after `gt-build-review` scored 100/100. The previous artifact exists and is from a different reviewer/workflow; this report is a delta review and supersedes the prior approval for Task 1121.

## Score: 30/100 — Critical

## Verdict: REJECTED

Task 1121 delivers visible `DSCodeBlock` and `DSMarkdownRenderer` functionality, and the user-requested path-scoped commands pass. However, the implementation violates the Flutter lifecycle/accessibility axioms and the task's own "no hardcoded values" token contract. The previous 100/100 review missed a `TapGestureRecognizer` lifecycle leak, undersized copy control, analyzer integrity gaps in task tests, and proof gaps around copy/syntax-highlight behavior.

A lifecycle leak in Markdown links caps this review in the Critical band under the six-axiom rubric. Do not promote this task until the recognizer ownership is fixed and the task-specific tests are analyzer-clean.

## Delta Summary vs Previous Review

| Previous claim | Current verification | Delta classification |
|---|---:|---|
| Analyzer Integrity PASS | Path-scoped source analyze passes, but full package analyze reports 599 issues, including task-test `prefer_const_constructors` info in `test/organisms/code_block_test.dart`. | `REGRESSION/EVIDENCE_GAP` |
| Lifecycle Safety PASS | `TapGestureRecognizer()` is created in `DSMarkdownRenderer` with 0 matching `dispose()` calls. | `NEW` |
| UI Accessibility PASS | Interactive affordances: 2; semantic wrappers: 1; initial copy target is 24x24 dp, below 48x48 dp. | `NEW` |
| DS token usage PASS | Raw layout/timing constants remain in both task widgets. | `NEW` |
| Proof Reality PASS | 43 tests pass, but copy-to-clipboard is not actually tapped/asserted and syntax highlighting tests do not assert highlighted token styles. | `NEW` |

## Axiom Compliance

| Axiom | Status | Evidence |
|---|---|---|
| 1. Analyzer Integrity | **FAIL** | `flutter analyze lib/src/organisms/code_block/ lib/src/organisms/markdown_renderer/` passes, but package-level `flutter analyze` reports 599 issues. Task-owned test file `test/organisms/code_block_test.dart` contributes `prefer_const_constructors` info at lines 45, 46, 57, 58, 67, 68, 69, 81, 82, 83, 93, 94, 95, 105, 106, 115, 116, 140, 141, 154, 155, 156, 171, 172, 183, 184, 185, 195, 196, 212, 213, 214, 235, 236, 237, 256, 257, 258, 280, 281. |
| 2. Lifecycle Safety | **FAIL** | Controller/subscription/timer counts in task source: `TextEditingController` 0, `ScrollController` 0, `AnimationController` 0, `StreamSubscription` 0, `Timer` 0. Gesture recognizers: `TapGestureRecognizer()` 1 at `ds_markdown_renderer.dart:271`; matching `dispose()` calls in task source: 0. `Future.delayed` count: 1 at `ds_code_block.dart:213`, guarded by mounted checks at lines 211 and 214. |
| 3. Dependency Direction | **PASS** | Task files import Flutter + local DS tokens/atoms/organisms only. No domain/data/presentation layering breach in `packages/warp_prism_ui`. Public aliases exist at `lib/src/prism_aliases.dart:327-331`. |
| 4. UI Accessibility | **FAIL** | Interactive affordances in task source: 2 (`InkWell` at `ds_code_block.dart:183`, `TapGestureRecognizer` at `ds_markdown_renderer.dart:271`). `Semantics` widgets in task source: 1 (`ds_code_block.dart:180`). Copy target initial hit area is 16 dp icon + 4 dp padding on each side = 24x24 dp, below the 48x48 dp minimum. Markdown link recognizer has no semantics/link role. |
| 5. Proof Reality | **PARTIAL** | Required task tests pass: 43/43. But `code_block_test.dart:193-205` only verifies the copy button exists/has an `InkWell`; it does not tap the button or verify copied state/clipboard data. Syntax-highlight tests at `code_block_test.dart:210-273` assert `RichText` and plain text presence, not highlighted token styles/colors. |
| 6. Release Security | **PASS** | No secrets, endpoints, signing, platform permissions, `print()`, or `debugPrint()` found in task organism source. Clipboard copy is user-initiated display functionality, not a release secret path. |

## Verification Commands Run

All commands were run from `packages/warp_prism_ui/`.

| Command | Result | Notes |
|---|---:|---|
| `flutter analyze lib/src/organisms/code_block/ lib/src/organisms/markdown_renderer/` | **PASS** | `No issues found!` for 2 task source items. Flutter also refreshed dependencies and reported 14 outdated-but-constrained packages. |
| `flutter test test/organisms/code_block_test.dart test/organisms/markdown_renderer_test.dart` | **PASS** | `All tests passed!`; observed 43/43 task tests pass. |
| `dart format --set-exit-if-changed lib/src/organisms/code_block/ lib/src/organisms/markdown_renderer/` | **PASS** | `Formatted 2 files (0 changed)`. |
| `flutter analyze` | **FAIL** | 599 issues. Includes package-existing issues plus task-test analyzer info in `test/organisms/code_block_test.dart`. Also includes 7 errors in `test/performance/virtual_scroll_benchmark.dart`, which appear outside Task 1121 scope. |
| `flutter test` | **PASS with harness caveat** | `All tests passed!`; 872 tests pass. Output includes a pure-Dart boundary harness message: `5/6 PASS, 1 FAIL` for public barrel hiding DS names, but this message did not fail the Flutter test process. |

## Evidence Paths Read

- Governance: `AGENTS.md`, `.agents/rules/definition-of-done.md`, `.agents/rules/project-boundaries.md`, `.agents/rules/task-governance.md`
- Task: `docs/tasks/03-review/1121-warp-prism-code-block-and-markdown-renderer.md`
- Previous review: `docs/reports/build-gate-review/1121-review.md`
- Context: `docs/reports/ads-gap-analysis-20260608.md`, `docs/tasks/03-review/1105-warp-prism-token-theme-catalog-policy.md`
- Implementation: `packages/warp_prism_ui/lib/src/organisms/code_block/ds_code_block.dart`, `packages/warp_prism_ui/lib/src/organisms/markdown_renderer/ds_markdown_renderer.dart`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`
- Tests: `packages/warp_prism_ui/test/organisms/code_block_test.dart`, `packages/warp_prism_ui/test/organisms/markdown_renderer_test.dart`
- Tokens/atoms checked for sizing/token evidence: `ds_spacing.dart`, `ds_typography.dart`, `ds_colors.dart`, `ds_icon.dart`

## Classified Findings

### CRITICAL — Lifecycle leak: `TapGestureRecognizer` is created without disposal

- **File**: `packages/warp_prism_ui/lib/src/organisms/markdown_renderer/ds_markdown_renderer.dart:271-276`
- **Evidence**: `TapGestureRecognizer()` constructors in task source: 1. `dispose()` methods in task source: 0.
- **Blast radius**: Any Markdown content with links creates recognizers during build. Rebuilds of documentation/detail panes can allocate additional recognizers without owner disposal. This is exactly the kind of leak lifecycle review exists to catch.
- **Why this fails**: `TextSpan.recognizer` ownership belongs to the code that creates the recognizer; Flutter does not dispose recognizers embedded in spans automatically.
- **Specific fix**: For the current display-only contract, remove the recognizer entirely:
  - Delete `import 'package:flutter/gestures.dart';`.
  - Delete `recognizer: TapGestureRecognizer()..onTap = () { ... }` at lines 271-276.
  - Keep the link styled with underline/cyan text as non-interactive display text.
  - If interactive links are required later, convert `_RichMarkdownText` to a `StatefulWidget`, store every recognizer in a list, and dispose every recognizer in `dispose()`.

### MODERATE — Copy button target is below 48x48 dp

- **File**: `packages/warp_prism_ui/lib/src/organisms/code_block/ds_code_block.dart:180-205`
- **Evidence**: Interactive widgets in task source: 2. Semantic wrappers in task source: 1. The copy control uses `DSIcon.small`, which is 16 dp (`ds_icon.dart:41-42`), plus `EdgeInsets.all(DSSpacing.xs)`, where `DSSpacing.xs` is 4 (`ds_spacing.dart:9-10`). Initial target: 16 + 4 + 4 = 24 dp on each axis.
- **Why this fails**: UI Accessibility axiom requires 48x48 dp touch targets for interactive widgets. Desktop-first does not exempt accessibility/focus sizing.
- **Specific fix**: Wrap the `InkWell` child in `const SizedBox.square(dimension: DSSpacing.huge)` or use a DS icon-button atom that enforces `DSSpacing.huge` (48). Keep `Semantics(label: ..., button: true)` outside it.

### MODERATE — Markdown links are styled as interactive but have no semantic link/button role

- **File**: `packages/warp_prism_ui/lib/src/organisms/markdown_renderer/ds_markdown_renderer.dart:260-277`
- **Evidence**: Link path creates 1 `TapGestureRecognizer`; there are 0 `Semantics` widgets in `ds_markdown_renderer.dart`.
- **Why this fails**: A screen reader user cannot identify the span as a link or know the URL. The empty `onTap` also makes it semantically deceptive: it looks clickable but does nothing.
- **Specific fix**: Preferred for this task: remove the recognizer and document links as display-only styled spans. If link activation is later required, add `onLinkTap(String url)` to `DSMarkdownRenderer`, render link text through a `WidgetSpan` with `Semantics(link: true, label: 'Link: $linkText, $url')`, and manage recognizer disposal in a stateful owner.

### MODERATE — Task widgets violate the "DS tokens only / no hardcoded values" requirement

- **Files**:
  - `packages/warp_prism_ui/lib/src/organisms/code_block/ds_code_block.dart:89,129,149,159,213`
  - `packages/warp_prism_ui/lib/src/organisms/markdown_renderer/ds_markdown_renderer.dart:106,108,109,148,181`
- **Evidence**: Raw UI/timing literals in task organism source: 10 matched locations. Examples: border width `1`, code line-height overrides `1.6`, gutter math `8.0 + 4`, copied reset delay `2` seconds, bullet marker `6x6`, ordered-list gutter `24`, blockquote border width `3`.
- **Why this fails**: Task explicitly required both widgets to use DS tokens with no hardcoded values.
- **Specific fix**: Route these through existing or new DS token constants. Immediate low-risk substitutions include `DSSpacing.xxl` for `24`, `DSSpacing.huge` for minimum target size, `DSTypography.codeMedium.height`/`codeSmall.height` instead of hardcoded `1.6`, and a DS border/timing token for 1/3 px borders and copied-feedback duration.

### MODERATE — Analyzer proof is narrower than the package contract

- **Files**: `packages/warp_prism_ui/test/organisms/code_block_test.dart:45-281`; package-level failures also exist outside Task 1121.
- **Evidence**: Required source-only analyze passes. Full `flutter analyze` fails with 599 issues. Task-owned `code_block_test.dart` contributes many `prefer_const_constructors` info-level findings, violating the zero-warning/zero-info analyzer axiom.
- **Why this fails**: The task's completion evidence claims full-package analyze status, and the code-quality axiom does not permit info-level issues in new/modified task files.
- **Specific fix**: Make Task 1121 tests analyzer-clean by adding `const` to `MaterialApp`, `Scaffold`, and `DSCodeBlock` invocations wherever possible. Then rerun full `flutter analyze` and classify remaining non-task failures as pre-existing in the task ledger.

### LOW — Tests do not prove copy behavior or actual syntax token styling

- **Files**:
  - `packages/warp_prism_ui/test/organisms/code_block_test.dart:193-205`
  - `packages/warp_prism_ui/test/organisms/code_block_test.dart:210-273`
- **Evidence**: Copy test asserts icon and `InkWell` existence but never taps the control. Syntax tests assert `RichText` exists and text is present but not that JSON keys, strings, numbers, Dart keywords, YAML keys, or Markdown headings receive distinct DS colors.
- **Why this matters**: Proof Reality requires tests to prove behavior, not presence.
- **Specific fix**: Add tests that tap the copy control and verify the check icon/`Copied` label after `pump()`. Add TextSpan traversal helpers that assert token spans have expected DS colors for each supported language.

## Scope Claims Verification

| Requirement | Status | Evidence |
|---|---|---|
| DSCodeBlock supports Dart highlighting | **PARTIAL** | Pattern set exists at `ds_code_block.dart:330-360`; tests only verify rendered text, not highlighted styles. |
| DSCodeBlock supports JSON highlighting | **PARTIAL** | Pattern set exists at `ds_code_block.dart:362-372`; tests only verify rendered text, not highlighted styles. |
| DSCodeBlock supports YAML highlighting | **PARTIAL** | Pattern set exists at `ds_code_block.dart:374-389`; tests only verify rendered text, not highlighted styles. |
| DSCodeBlock supports Markdown highlighting | **PARTIAL** | Pattern set exists at `ds_code_block.dart:391-407`; no direct code-block test asserts Markdown style spans. |
| DSCodeBlock copy-to-clipboard action | **PARTIAL** | Implementation calls `Clipboard.setData` at `ds_code_block.dart:210`; tests do not tap/assert clipboard or copied state. |
| DSCodeBlock line numbers configurable | **PASS** | `showLineNumbers` branch at `ds_code_block.dart:121-124`; tests at `code_block_test.dart:138-164`. |
| DSMarkdownRenderer required block/inline types | **PARTIAL** | Headings, paragraphs, code blocks, lists, blockquotes, bold/italic/code/link parsing exist; link implementation has lifecycle/a11y defects. |
| Both widgets use DS tokens, no hardcoded values | **FAIL** | 10 raw UI/timing literal locations listed above. |

## Task Ledger Patch Suggestion

Do not move the task file yet. Suggested compact ledger row after fixes land and reviewer re-runs gates:

```markdown
| 2026-06-13 | independent Flutter reviewer | 30/100 | REJECTED | `docs/reports/review-wave-1/1121-review.md` |
```

If task ledger notes are allowed, add:

```markdown
**Review Notes**: Rejected for lifecycle leak in Markdown link `TapGestureRecognizer`, accessibility target/semantics gaps, hardcoded non-token values, and proof gaps in copy/highlighting tests. Required path-scoped commands pass, but package analyzer is not clean and Task 1121 tests include analyzer info-level findings.
```

## Path to 100

1. **Fix lifecycle first**: remove the `TapGestureRecognizer` from display-only Markdown links, or make `_RichMarkdownText` stateful and dispose every recognizer. Re-run `flutter analyze lib/src/organisms/code_block/ lib/src/organisms/markdown_renderer/`.
2. **Repair accessibility**: make the copy control at least 48x48 dp and resolve Markdown link semantics by either making links non-interactive display spans or adding proper link semantics plus disposal.
3. **Eliminate task-owned analyzer info**: add missing `const` constructors in `test/organisms/code_block_test.dart` and verify task test files no longer contribute analyzer issues under full `flutter analyze`.
4. **Replace raw widget literals with DS tokens**: remove the 10 hardcoded UI/timing literal locations or define explicit DS border/timing/marker tokens.
5. **Strengthen proof**: add a real copy-action test and language-specific TextSpan color tests for Dart, JSON, YAML, and Markdown.
6. **Re-run gates**: required three commands plus full `flutter analyze` and full `flutter test`. Document any remaining non-task package failures as pre-existing with file paths and counts.

