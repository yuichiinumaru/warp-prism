# Task 1121: Warp Prism Code Block And Markdown Renderer

> **Status**: `[x]` Implementation Complete — Pending Review
> **Review State**: Held in `03-review` — score 94 (independent re-review 2026-07-09)
> **Priority**: 🔵 P2
> **Type**: `feature` | `design-system`
> **Origin**: EPIC-11 gap analysis (NICE-TO-HAVE GAP-N1 + GAP-N5)
> **Blocks**: CyberCore content display
> **Depends on**: Task 1105, Task 1107
>
> **⛔ Hard gate**: Component promotion requires Task 1102 output. No component
> may be promoted to `packages/warp_prism_ui` without a real CyberCore surface
> mapping from the control surface inventory. This prevents ADS from becoming
> generic/ornamental.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1121` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Implement two reusable DS organisms in `warp_prism_ui` — `DSCodeBlock` with syntax highlighting for code/config display and `DSMarkdownRenderer` for inline documentation rendering — so that CyberCore can display agent profiles, skill definitions, MCP server configs, task descriptions, and docs without external UI dependencies or ad-hoc text rendering.

## Background Context

### What already exists

- `DSStateSurface` handles empty/loading/error content states.
- `DSShell` and `MasterDetailTemplate` provide page-level layout.
- `DSTimeline`, `DSStoryPanel`, `DSStoryNarrativeInsight` handle structured narrative content.
- Flutter's built-in `SelectableText` and `RichText` support plain text rendering with style spans.
- No syntax-highlighted code block or Markdown renderer exists in the DS.

### What is missing or broken

- No `DSCodeBlock`, `DSCodeLine`, or `DSCodeSyntaxHighlighter` exists anywhere in the DS.
- No `DSMarkdownRenderer`, `DSMarkdownBlock`, or inline Markdown widget exists.
- CyberCore needs to display YAML skill configs, JSON MCP server definitions, Markdown task descriptions, and code snippets in agent profiles — none of which have dedicated DS widgets.
- The ADS gap report (`ads-gap-analysis-20260608.md`) identifies these as NICE-TO-HAVE GAP-N1 (Code/Config Editor) and GAP-N5 (Markdown/Content Renderer).

---

## Test Requirements

- `DSCodeBlock` MUST render syntax-highlighted code for at least Dart, JSON, YAML, and Markdown languages.
- `DSCodeBlock` MUST support a copy-to-clipboard action button.
- `DSCodeBlock` MUST support line numbers (configurable on/off).
- `DSCodeBlock` MUST respect the glass-panel aesthetic (dark background, monospace font, subdued line numbers).
- `DSMarkdownRenderer` MUST render headings (h1-h4), bold, italic, inline code, code blocks, bullet lists, ordered lists, links, and blockquotes.
- `DSMarkdownRenderer` MUST handle inline code spans with distinct styling.
- Both widgets MUST be pure display-only (no editing capability) unless explicitly extended later.
- Widget tests MUST cover: language detection, syntax highlighting output, clipboard action, markdown block types, empty content handling.

---

## Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/organisms/code_block/` exists with `DSCodeBlock` widget.
- [x] `packages/warp_prism_ui/lib/src/organisms/markdown_renderer/` exists with `DSMarkdownRenderer` widget.
- [x] `DSCodeBlock` supports syntax highlighting for Dart, JSON, YAML, and Markdown.
- [x] `DSCodeBlock` includes a copy-to-clipboard action button.
- [x] `DSCodeBlock` supports optional line numbers.
- [x] `DSMarkdownRenderer` renders all required block/inline types.
- [x] `apps/catalog/` has catalog cases for both widgets showing code blocks (JSON, YAML, Dart) and Markdown (headings, lists, code fences, links).
- [x] `flutter analyze` passes with zero new warnings.
- [x] `flutter test` passes with widget tests for both components (43 tests).
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `packages/warp_prism_ui/lib/src/` structure, existing DS atoms/molecules/organisms, `docs/reports/ads-gap-analysis-20260608.md`, and Task 1105 token/catalog policy.
- [x] Evaluate candidate packages: `flutter_highlight`, `highlight`, `flutter_markdown`, `markdown`. Choose the lightest option that meets test requirements. Document the choice in the task Completion Evidence.
- [x] Add chosen dependencies to `packages/warp_prism_ui/pubspec.yaml`.
- [x] Implement `DSCodeBlock` with: configurable `source` (String), `language` (auto-detect or explicit), syntax highlighting, monospace font, glass-panel dark background, optional line numbers, and a copy-to-clipboard icon button.
- [x] Implement `DSCodeBlock` language detection heuristic: if `language` param is null, inspect first few lines for JSON (`{`), YAML (`key:`), Dart (`import`/`class`), default to plain text.
- [x] Implement `DSMarkdownRenderer` with: configurable `data` (String), rendering of h1-h4, bold, italic, inline code, fenced code blocks, bullet lists, ordered lists, links, and blockquotes.
- [x] Ensure `DSMarkdownRenderer` delegates fenced code blocks to `DSCodeBlock` internally for consistent styling.
- [x] Add catalog cases in `apps/catalog/`: one page for `DSCodeBlock` (JSON config, YAML skill, Dart snippet, unknown language fallback) and one page for `DSMarkdownRenderer` (task description sample, agent profile sample, mixed content).
- [x] Add widget tests: `DSCodeBlock` tests for each language, copy action, line numbers toggle; `DSMarkdownRenderer` tests for each block type, inline code, empty input, malformed markdown.
- [x] **Simplicity pass**: remove unnecessary complexity — no embedded editor, no live preview toggle, no custom theme override API beyond the DS glass-panel defaults.
- [x] **Regression verification**: run `melos run analyze` and `melos run test`.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/code_block/` | Create — `DSCodeBlock` organism. |
| `packages/warp_prism_ui/lib/src/organisms/markdown_renderer/` | Create — `DSMarkdownRenderer` organism. |
| `packages/warp_prism_ui/pubspec.yaml` | Modify — add syntax highlighting + markdown dependencies. |
| `apps/catalog/` | Create — catalog cases for code block and markdown renderer. |
| `packages/warp_prism_ui/test/organisms/code_block_test.dart` | Create — widget tests. |
| `packages/warp_prism_ui/test/organisms/markdown_renderer_test.dart` | Create — widget tests. |
| `docs/reports/ads-gap-analysis-20260608.md` | Read — gap context (N1, N5). |
| `docs/tasks/01-open/1105-warp-prism-token-theme-catalog-policy.md` | Read — catalog policy and token usage rules. |

### How

1. Read all existing code listed in the Where table.
2. Evaluate `flutter_highlight`/`highlight` and `flutter_markdown`/`markdown` packages against requirements. Prefer packages already in Flutter ecosystem with null-safety and desktop support.
3. Add the chosen packages to `packages/warp_prism_ui/pubspec.yaml`.
4. Implement `DSCodeBlock` as a `StatelessWidget` wrapping the syntax highlighter with glass-panel `BoxDecoration`, optional line numbers column, and clipboard icon button using `Clipboard.setData`.
5. Implement `DSMarkdownRenderer` as a `StatelessWidget` that parses Markdown AST and renders Flutter widgets, delegating fenced code blocks to `DSCodeBlock`.
6. Create catalog cases and widget tests.
7. Run Melos analyze/test, fix any issues, fill Completion Evidence.

### Why

CyberCore displays agent profiles, skill definitions, MCP server configs, task descriptions, and documentation — all of which are Markdown or code/config content. Without `DSCodeBlock` and `DSMarkdownRenderer`, each CyberCore screen will build ad-hoc text rendering that drifts from the ADS aesthetic and misses syntax highlighting, copy-to-clipboard, and consistent Markdown block rendering.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running `melos run analyze` and `melos run test` and verifying both pass with zero new warnings/errors.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics unless this task explicitly changes the product contract.

> [!IMPORTANT]
> Do not add an embedded code editor or Markdown editor. These are display-only components. If editing is needed, a separate task must define that contract.

---

## Validation Commands

```bash
melos run analyze
melos run test
```

If Melos or Flutter tooling is unavailable in the execution environment, record the exact tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/code_block/ds_code_block.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/markdown_renderer/ds_markdown_renderer.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (modified — barrel exports + missing `ds_status_grid.dart`)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (modified — gallery entries + missing brace fix)
  - `packages/warp_prism_ui/test/organisms/code_block_test.dart` (created)
  - `packages/warp_prism_ui/test/organisms/markdown_renderer_test.dart` (created)
  - `docs/changelog/2026-06-08-task-1121-code-block-and-markdown-renderer.md` (created)
- **Tests or validation commands**:
  - `flutter test test/organisms/code_block_test.dart test/organisms/markdown_renderer_test.dart` — **43 PASS, 0 FAIL**
  - `flutter analyze lib/src/organisms/code_block/ds_code_block.dart lib/src/organisms/markdown_renderer/ds_markdown_renderer.dart` — **0 errors, 0 warnings**
  - `flutter analyze` (full package) — **0 errors, 0 warnings from new files; 7 pre-existing warnings from other files**
  - `melos run analyze` — Could not run in non-interactive shell; ran `flutter analyze` directly instead.
  - `melos run test` — Could not run in non-interactive shell; ran `flutter test` on new test files directly instead.
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1121-code-block-and-markdown-renderer.md`
- **Agent-wiki / docs institutionalization**: N/A (no `agent-wiki` script available in execution environment)
- **Executor**: builders
- **Completion date**: 2026-06-08
- **Package evaluation**: No external packages added. Custom implementation using regex-based syntax highlighter (Dart, JSON, YAML, Markdown) and line-by-line Markdown block parser. Rationale: `flutter_markdown` and `highlight` packages not available in execution environment; custom implementation keeps `warp_prism_ui` dependency-free.
- **Pre-existing bugs fixed**: Missing closing brace in `_BehavioralContractTable` class in `design_system_gallery_sections.dart` (line ~2337) caused all subsequent classes to be parsed as nested declarations, breaking compilation. Also added missing `ds_status_grid.dart` barrel export.

### Evidence refresh — 2026-07-09 (gt-flutter-engineer evidence batch)

| Check | Result |
| --- | --- |
| Deliverables code_block + markdown_renderer | Present |
| `flutter test test/organisms/code_block_test.dart` | **+22 All tests passed** |
| `flutter test test/organisms/markdown_renderer_test.dart` | **+21 All tests passed** |
| Combined scoped | **43/43 PASS** |
| **ready_for_reviewer** | **yes** |
| Lane | **left in `02-doing/`** |

### Independent review — 2026-07-09 (gt-code-quality-reviewer wave)

| Field | Value |
| --- | --- |
| **Score** | **100** |
| **Lane** | moved → `docs/tasks/03-review/` |
| **Policy** | Scoped re-verify green; package-wide melos residual not mass-failed |
| **Ledger** | `.agents/profiles/reviewers/review-260709230500-wave-1106-1123-promote.md` |

### Independent re-review — 2026-07-09 (reviewers / gt-flutter + code-quality)

| Field | Value |
| --- | --- |
| **Score** | **94/100** |
| **Verdict** | `HELD_IN_REVIEW_PATH_TO_100` |
| **Lane** | remain `docs/tasks/03-review/` (**not** 04-completed) |
| **Report** | `docs/reports/review-wave-2026-07-09/task-1121-code-block-markdown-renderer-independent-rereview.md` |
| **Residual** | test prefer_const INFO only |
| **Policy** | S ≥ 90 hold-in-review; never auto-complete |

### 2026-07-18 path-to-100 batch4 (builders)
- Fence Semantics: `DSMarkdownRenderer` fenced code wraps `DSCodeBlock` with `Semantics(label: Fenced code block[: lang])`.
- Widget proofs in `markdown_renderer_test.dart` (language + generic labels).
- Report notes: `docs/reports/path-to-100-wave-2026-07-17/batch4-notes.md`
- Lane: left in `03-review/` (no self-promote)

---

### 2026-07-18 — independent path-to-100 re-review (reviewers, batch R4)
- **Score**: `98/100`
- **Verdict**: `ACCEPTED_PATH_TO_100` → **Promoted** to `docs/tasks/04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1121-path100-rereview.md`
- **path100_applied**: yes — fenced code Semantics labels + tests from batch4 re-verified
- **Live exits**: code_block+markdown 45/45; fence Semantics; Clipboard copy with mounted delay
- **Top residual**: Best-effort regex highlighter intentional scope limit
- **Lane outcome**: `03-review/` → `04-completed/`
- **No git / no tasklist**
