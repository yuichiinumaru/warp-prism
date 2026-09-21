# Visual Direction Diagnosis — Black Obsidian Reset for Warp Prism

> **Date**: 2026-08-22
> **Status**: Diagnostic report and planning proposal — no implementation performed
> **Audience**: Architect orchestrator, task architects, builders, reviewers, product/user owner
> **Primary plan**: `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md`
> **Proposed tasks**: `1800`–`1806`

## Executive Summary

A human visual review of the running ADS Catalog/storybook found that the component
behavior is promising, but the visual identity is unacceptable: the system reads as the
wrong palette and typography direction. The remediation should **not** delete the
component library. It should pause further visual expansion and correct the shared
visual contract, token layer, typography roles, app theme composition, and visual
acceptance process.

The corrected requirement is explicit:

> **The default background is black obsidian. Blue is allowed only as a controlled
> action/focus/link/data-highlight accent. Blue must not become the background, dominant
> surface family, or ambient viewport wash.**

This report reconciles three evidence families:

1. `references/cc-reference-images/` and `references/cc-visual-id/`;
2. Cybernetics Core / OmniRoute-2 reference material and current implementation;
3. live Warp Prism token/theme/app code.

The evidence indicates a governance and composition failure, not merely isolated bad
component styling.

---

## User Correction Recorded

The initial proposed remediation used the phrase “blue obsidian” too broadly. That is
incorrect and is superseded by this report and EPIC-18:

- **Correct**: black obsidian structural backgrounds and surfaces;
- **Allowed**: blue accent/highlight roles;
- **Forbidden**: blue structural background, blue wallpaper, blue ambient gradient,
  blue-dominant card/shell surfaces;
- **Health consideration**: avoid persistent high-intensity blue luminous decoration in
  the viewport. This is a human-comfort/product-design constraint, not a medical claim.

The phrase `blue obsidian` must not be used as a shorthand in future tasks unless it is
explicitly defined as **black obsidian + blue accents**.

---

## Evidence Findings

### 1. `cc-visual-id` defines black structural surfaces

`references/cc-visual-id/src/index.css` explicitly declares:

| Role | Evidence |
|---|---|
| Font display | Orbitron |
| Font UI | Rajdhani |
| Font technical | JetBrains Mono |
| Deep background | `#030506` |
| Panel | `#080c0e` |
| Panel hover | `#0c1215` |
| Panel border | `#121d22` |
| Core accent | `#00FFCC` |

Its `body` uses the obsidian background and Rajdhani. The reference `App.tsx` uses
obsidian/panel surfaces throughout; the core accent is used for active navigation,
focus, borders, progress, icons, and telemetry rather than replacing the page background.

### 2. OmniRoute-2 confirms the structural direction

The current `cybernetics-core/omniroute-2/src/app/globals.css` contains:

- `--color-bg: #030506`;
- `--color-bg-alt: #06080a`;
- `--color-surface: #080c0e`;
- `--color-card: #080c0e`;
- `--color-sidebar: #080c0e`;
- `--color-border: #121d22`;
- `--color-primary: #00FFCC`.

`src/app/rajdhani.css` bundles Rajdhani weights 300–700. The current VR migration is
also recorded in OmniRoute-2 changelog evidence as black/obsidian + core cyan + Rajdhani
+ JetBrains Mono.

The useful transferable rule is not “copy teal everywhere.” It is:

> **Keep the structural canvas black/obsidian; use one energy accent deliberately; keep
> technical typography separate from UI typography.**

### 3. Current Warp Prism tokens diverge materially

`packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` currently declares:

- `#050508`, `#0A0A0F`, `#0F1015`, `#14141C`, `#1A1A24` for obsidian surfaces;
- sky cyan `#00D4FF` as primary accent;
- violet and gold as prominent secondary accents;
- numerous green, amber, red, pink, orange, and blue semantic families.

These values are not inherently invalid, but the current visual system is too far from the
black-obsidian reference intent when rendered as a whole and needs a product-level reset.

### 4. Current typography wiring has a concrete defect

`DSTypography` declares:

- `fontFamilyMono = 'JetBrainsMono'`;
- `fontFamilySans = 'Inter'`.

`apps/observatory/lib/app/app.dart` then sets:

```dart
fontFamily: PrismTypography.fontFamilyMono,
```

This makes JetBrains Mono the global app font rather than limiting it to technical roles.
That is a direct implementation defect independent of subjective font preference.

The app packages currently bundle JetBrains Mono assets, but no equivalent Rajdhani assets
were found in the Warp Prism app asset directories. A font contract cannot be considered
implemented until the actual app host loads and renders the intended UI font.

### 5. Catalog is not a canonical theme host

`apps/catalog/lib/main.dart` uses:

```dart
theme: ThemeData.dark(),
```

Therefore the Catalog/storybook does not consume an explicit Warp Prism theme composition.
It can render components with defaults that differ from Observatory or CyberCore. This
undermines visual validation and explains why a human may see a result that does not map
cleanly to the intended product identity.

### 6. Teal skin exists and should remain scoped

Task 1616 created `DSCyberCoreTealSkin` / `PrismCyberCoreTealSkin` as an opt-in
`ThemeExtension`, preserving `DSColors.accentCyan = #00D4FF`.

That implementation pattern is useful: product skins should be explicit and scoped. The
new user decision does not require deleting the teal skin. It requires preventing any
teal/blue accent from becoming the default structural background or being forced through
all products.

---

## Root Cause Classification

| Failure | Category | Consequence |
|---|---|---|
| No human-approved visual contract with exact structural rules | Governance | Builders interpret references differently |
| Token palette was approved without a screenshot acceptance gate | Product/design process | CI can pass while the UI is visually wrong |
| Catalog uses bare `ThemeData.dark()` | Integration | Demo host does not represent product theme |
| Observatory applies mono font globally | Theme wiring | Interface typography reads incorrectly |
| UI font assets do not match declared reference role | Asset contract | Declared typography may not render in host |
| Structural colors and local raw colors coexist | Token discipline | Components drift individually |
| Goldens are treated as verification without human visual approval | QA process | Bad visual output can be crystallized as “correct” |

---

## Remediation Strategy

### Phase 0 — Freeze visual expansion

Before more component work:

- approve EPIC-18 / Task 1800;
- pause visual promotion that depends on the old palette;
- do not regenerate goldens;
- do not run broad color find/replace.

### Phase 1 — Correct shared foundations

Run Tasks 1801 and 1802 in parallel after 1800 approval:

- migrate structural tokens to black obsidian;
- define a bounded blue accent ladder;
- preserve semantic status colors;
- correct typography roles and font assets.

### Phase 2 — Correct app composition

Task 1803 creates or standardizes canonical theme composition for:

- Catalog;
- Observatory;
- CyberCore;
- deterministic demo/screenshot hosts.

### Phase 3 — Audit bypasses

Task 1804 classifies raw values. Structural violations are fixed; meaningful fixture/data
colors are retained with documented semantics.

### Phase 4 — Human visual gate

Task 1805 captures deterministic screenshots and requires product/user approval before
refreshing goldens.

### Phase 5 — Reconcile existing components

Task 1806 reviews EPIC-15, EPIC-16, EPIC-17, shells, gallery, and legacy components after
the foundations are stable. Behavior/accessibility work should be preserved unless the
visual correction exposes a real component defect.

---

## Proposed Task Set

| Task | Name | Main deliverable |
|---|---|---|
| 1800 | Black Obsidian Visual Contract and Approval Packet | Signed visual contract, palette, typography, target screenshot |
| 1801 | Black Obsidian Token Migration and Semantic Palette Mapping | Shared token implementation and contract tests |
| 1802 | Typography Roles and Font Asset Correctness | Role separation, font assets, host smoke proof |
| 1803 | Canonical ThemeData and App Host Wiring | One theme composition across Catalog/Observatory/CyberCore |
| 1804 | Hardcoded Visual-Value and Structural-Color Audit | Classified audit and remediation of bypasses |
| 1805 | Screenshot Visual Acceptance Gate and Golden Policy | Human-gated screenshot/Golden workflow |
| 1806 | Component and Gallery Visual Reconciliation | Family-by-family visual correction |

### Dependency graph

```text
                 ┌── 1801 Token migration ──┐
1800 Contract ───┤                           ├── 1803 Theme wiring ──┐
                 └── 1802 Typography ───────┘                       ├── 1805 Visual gate ── 1806 Reconciliation
                                      1801 ── 1804 Audit ────────────┘
```

1801 and 1802 can be parallel. 1804 may begin after the token contract is stable but
must finish before 1805 closes.

---

## Palette Guidance for Task Architects

Exact values are intentionally left for Task 1800 approval. The structural shape is not:

- deep background: black obsidian, ideally close to `#030506`;
- base/elevated surfaces: neutral near-black, not blue slate;
- border: low-luminance neutral blue-gray may be acceptable;
- primary accent: approved blue for focus/action/highlight only;
- teal: explicit CyberCore/OmniRoute skin or controlled highlight;
- green/amber/red: semantic statuses;
- violet/gold/pink/orange: data categories only where justified.

A candidate blue such as `#2F81FF` or `#3B82F6` is illustrative only. It must not be
implemented before product approval, and it must never be assigned to page background.

---

## Typography Guidance for Task Architects

The current app-level mono assignment must be removed. The intended split is:

- Rajdhani-like or approved UI face for normal interface content;
- JetBrains Mono for code, logs, IDs, terminal, metrics, timestamps, and telemetry;
- deterministic system fallbacks;
- no automatic Orbitron port.

Task 1802 must prove this in the actual Catalog/Observatory host, not only by inspecting
constant strings.

---

## Review and Promotion Gates

Reviewers must be explicitly adversarial on visual claims:

1. Read the target screenshot and Task 1800 contract before reading builder claims.
2. Inspect the live app host/theme composition.
3. Verify root background and representative surfaces directly.
4. Verify font role behavior with rendered text, not just token constants.
5. Run hardcoded-value audit and classify intentional exceptions.
6. Reject if blue is used as structural background or if global mono remains.
7. Reject if goldens were refreshed without human screenshot approval.
8. Score each task independently; do not accept a green analyzer result as visual proof.

A task may pass code gates and still fail the visual gate.

---

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Broad token change breaks existing components | Run visual reconciliation after token migration; preserve semantic aliases |
| Builders overcorrect into blue UI | Task 1800 non-negotiable black-background rule; screenshot gate |
| Teal becomes global again | Keep ThemeExtension opt-in and test non-mutation |
| Status colors lose meaning | Semantic mapping tests and audit |
| Font appears correct in tests but not app | Host-level smoke screenshots and asset checks |
| Golden churn hides regressions | Human approval before refresh; preserve before/after artifacts |
| Scope expands into component rewrite | Separate foundation tasks from 1806 reconciliation |
| Existing policy contradictions confuse builders | Architect must reconcile 1105/1616/EPIC-17 explicitly |

---

## Architect Orchestrator Validation Questions

1. Should EPIC-18 formally supersede the default visual sections of Task 1105, or amend
   them with a new revision record?
2. What exact black-obsidian values are acceptable, and which are prohibited as too blue?
3. What exact blue accent ladder is acceptable for actions/focus/highlights?
4. Should Rajdhani be mandatory or a preferred reference with fallback requirements?
5. Is the existing `PrismCyberCoreTealSkin` API retained as-is?
6. Which host is canonical for screenshots: Catalog, Observatory `/design-system`, or a
   dedicated deterministic harness?
7. What artifact counts as human visual approval?
8. Which current visual tasks should be returned to planning or blocked until 1805?
9. Should EPIC-17's teal active/checked-state clause be amended before implementation?
10. Should visual reviewers receive a mandatory screenshot-review checklist in their
    prompt/workflow?

---

## Final Recommendation

Do not delete the project or component library. Stop treating the current visual output as
an acceptable interpretation of the references. Approve the black-obsidian reset plan,
make the visual contract authoritative, fix the shared token/theme/font foundations, and
only then reconcile the component families.

The most important operational change is process-level:

> **No architect or builder may infer product identity from a vague “cyber” adjective.
> The approved screenshot and non-negotiable background/accent rules must be read before
> implementation, and reviewers must be empowered to fail visual work even when tests
> pass.**
