# Warp Prism — Operational State Vocabulary

> **Task**: 1102 — Warp Prism Control Surface Inventory  
> **Date**: 2026-07-09 (reconciled rewrite; §0.5 governance amend same day)  
> **Status**: Active vocabulary + live implementation alignment (source-backed DoD)  
> **Review readiness**: **Ready for reviewer** under 2026-07-09 DoD — screenshots **optional / deferred** (see `component-inventory.md` §0.5 APPLIED)  
> **Evidence**: Live CC frontend enums (source-backed, **primary**) + live Prism `DSOperationalState` / `DSStateType`; screenshot-backed **absent / optional**

---

## 1. Two Orthogonal Axes

| Axis | Type | Live implementation | Purpose |
| --- | --- | --- | --- |
| **UI data surface states** | `DSStateType` | `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | Whether the **view** can show data |
| **Entity operational states** | `DSOperationalState` | `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart` | Health/lifecycle/verification of an **entity** |

### 1.1 Live `DSStateType` (7 values — not 3)

```text
empty, loading, error, disabled, stale, degraded, excluded
```

Maps directly to CC `AdminDataState` for the first three (`loading|empty|error`) and extends it.

### 1.2 Live `DSOperationalState` (15 values)

| ID | Category | Required by Task 1102 |
| --- | --- | --- |
| `pending` | lifecycle | yes |
| `running` | lifecycle | yes |
| `approved` | lifecycle | yes |
| `rejected` | lifecycle | yes |
| `promoted` | lifecycle | yes |
| `archived` | lifecycle | yes |
| `healthy` | health | yes |
| `degraded` | health | yes |
| `error` | health | yes |
| `disabled` | health | yes |
| `unverified` | verification | yes |
| `exposed` | verification | yes |
| `redacted` | verification | yes |
| `stale` | governance | yes |
| `excluded` | governance | extra (kept; used by `DSStateType` overlap + filters) |

All 14 task-required IDs are present; `excluded` is retained as the 15th live enum value.

---

## 2. Design Principles

1. **Operational ≠ loading.** A page can be `DSStateType.loading` while entities would be `healthy` once loaded.
2. **Composable fields.** An entity may carry lifecycle + health + verification simultaneously (e.g. active provider + failing test + untested history).
3. **Evidence grades** (mandatory for every mapping claim):
   - `explicit` — same or synonymous string/enum in CC source
   - `derived` — deterministic function of CC fields (documented)
   - `speculative` — product intent only; not for gate completion
4. **No screenshot invention.** Visual-only states without source enums stay `needs-research`.
5. **Canonical UI metadata** lives on `DSOperationalStateUI` (color, icon, label, severity, allowsActions, isTerminal).

---

## 3. Universal Operational States

### 3.1 Lifecycle

| State | ID | Color token (Prism) | Behavioral contract | CC evidence (grade) | UI semantics |
| --- | --- | --- | --- | --- | --- |
| Pending | `pending` | statusPending | Exists; work not started | Remote exposure `configured` not yet `enabled` (`derived`); legacy import awaiting confirm (`derived`); create mutation idle form (`derived`) | Muted label; no progress bar |
| Running | `running` | statusRunning | Active work / in-flight | MCP inspector `connecting` (`explicit`); create/test mutations `isPending` (`derived`) | Gold/amber activity; disable conflicting actions |
| Approved | `approved` | statusApproved | Passed gate | Legacy mapping `importable` preflight success (`derived`); combo entry `ready` (`derived`) | Success chrome; allow promote/enable |
| Rejected | `rejected` | statusRejected | Failed gate | Legacy `blocked`/`unsupported` (`explicit` status strings); catalog `unsupported` (`explicit`) | Error chrome; show reason |
| Promoted | `promoted` | statusPromoted | Advanced trust/enablement | Remote exposure `enabled` (`explicit`); provider preset `configured` (`explicit`); provider `isActive` + test success (`derived`) | Accent highlight; “live” badge |
| Archived | `archived` | statusArchived | Terminal retention | No dedicated CC “archived” enum found on primary admin pages | **needs-research** for CC entity archive; keep vocabulary for ASW/plugin lifecycle from backend docs (`speculative` for UI until source appears) |

### 3.2 Health

| State | ID | Color token | Behavioral contract | CC evidence (grade) | UI semantics |
| --- | --- | --- | --- | --- | --- |
| Healthy | `healthy` | statusHealthy | Normal operation | `ProviderHealthStatus=ready` (`explicit`); badge Active+success (`explicit`); combo readiness `ready` (`explicit`) | Green success |
| Degraded | `degraded` | statusDegraded | Partial/impaired | Combo `provider-warning` / entry `warning` (`explicit`); catalog `needs_env` (`derived`) | Warning amber; allow remediation |
| Error | `error` | statusOpError | Failure needs intervention | Provider test `error` (`explicit`); health `failing` (`explicit`); exposure `error` (`explicit`); connection `error*` (`explicit`); AdminDataState error (`explicit` UI) | Destructive; alert role |
| Disabled | `disabled` | statusDisabled | Intentionally off | Provider `isActive=false` / Inactive badge (`explicit`); exposure `disabled` (`explicit`); health `inactive` (`explicit`); settings feature toggles off (`explicit`) | Muted; re-enable affordance |

### 3.3 Verification

| State | ID | Color token | Behavioral contract | CC evidence (grade) | UI semantics |
| --- | --- | --- | --- | --- | --- |
| Unverified | `unverified` | statusUnverified | No proof yet | Provider badge Untested / testStatus `unknown` (`explicit`); health `unknown` (`explicit`); catalog `needs_review` (`derived`) | Neutral pending mark |
| Exposed | `exposed` | statusExposed | Published/visible with risk | Remote exposure `enabled` or public origin present (`derived` from exposure status); API URLs on llm-endpoints page (`derived`) | Warning/error if unreviewed; emphasize boundary copy |
| Redacted | `redacted` | statusRedacted | Intentionally hidden | Live logs redaction helpers; legacy preflight `redactionStatus.secretsRedacted` + field counts (`explicit`); llm-endpoints audit metadata redacted before render (`explicit` comments/helpers) | Placeholder glyphs; never show raw secret |

### 3.4 Governance

| State | ID | Color token | Behavioral contract | CC evidence (grade) | UI semantics |
| --- | --- | --- | --- | --- | --- |
| Stale | `stale` | statusStale | Out of date | Models page metric “Discovered rows older than policy” (`explicit` product metric); stale data surface type (`DSStateType.stale`) | Warning refresh CTA |
| Excluded | `excluded` | statusExcluded | Filtered out of scope | Client-mode hides admin nav items (`derived`); table filters excluding rows (`derived`); `DSStateType.excluded` | “Outside scope” empty, not error |

---

## 4. CC Domain Enum → Prism Mapping Table

Citations are under `/home/sephiroth/working/ganthritor/cybernetics-core/apps/frontend/` unless noted. Prism enums: `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart`, `.../molecules/ds_state_surface.dart`.

| CC source (path) | CC value | Prism `DSOperationalState` | Grade |
| --- | --- | --- | --- |
| `components/providers/provider-status-badge.tsx` | Inactive (`!isActive`) | `disabled` | explicit |
| same | Active (`testStatus === "success"`) | `healthy` | explicit |
| same | Error (`testStatus === "error"`) | `error` | explicit |
| same | Untested (default active + unknown) | `unverified` | explicit |
| `lib/llm-diagnostics.ts` `ProviderHealthStatus` | ready | `healthy` | explicit |
| same | failing | `error` | explicit |
| same | inactive | `disabled` | explicit |
| same | unknown | `unverified` | explicit |
| `lib/llm-remote-exposure.ts` `RemoteExposureState` | disabled | `disabled` | explicit |
| same | configured | `pending` | derived |
| same | enabled | `exposed` (+ optional `promoted` for go-live framing) | derived — primary risk UI = `exposed` |
| same | error | `error` | explicit |
| `types/search.ts` catalog `status` | ready | `healthy` | derived |
| same | needs_env | `degraded` | derived |
| same | needs_review | `unverified` | derived |
| same | unsupported | `rejected` | derived |
| `lib/combo-readiness.ts` `ComboReadinessStatus` | ready | `healthy` | explicit |
| same | provider-warning | `degraded` | explicit |
| same | inactive-provider | `disabled` | derived |
| same | missing-provider | `error` | derived |
| same | empty | *(UI `DSStateType.empty`)* | explicit UI, not ops |
| `lib/constants.ts` `ConnectionStatus` (+ `hooks/useConnection.ts`) | disconnected | `disabled` | derived |
| same | connecting | `running` | derived (name is operational lifecycle) |
| same | connected | `healthy` (prefer over `running` when stable) | derived |
| same | error / error-connecting-to-proxy | `error` | explicit |
| `app/.../providers/page.tsx` legacy mapping | importable | `approved` or `pending` | derived |
| same | blocked / unsupported | `rejected` | derived |
| same | duplicate | `stale` or `rejected` | speculative — **needs-research** |
| Live logs / legacy preflight redaction helpers | redacted fields | `redacted` | explicit |
| — | — | `archived` | **no primary admin UI enum** — keep vocabulary; CC UI mapping needs-research |

---

## 5. UI Data States (`DSStateType`) vs CC AdminDataState

| CC `AdminDataState` | Prism `DSStateType` | Notes |
| --- | --- | --- |
| loading | `loading` | direct |
| empty | `empty` | direct |
| error | `error` | direct; CC sets `role=alert` |
| *(absent)* | `disabled` | use for feature-off pages |
| *(absent)* | `stale` | use for expired catalog/metrics |
| *(absent)* | `degraded` | partial page success |
| *(absent)* | `excluded` | filtered-out scope |

---

## 6. Behavioral Contracts (Summary)

Full detail remains in `docs/design/operational-state-behavioral-contracts.md` and transitions in `operational-state-transitions.md`. Non-negotiables for ADS consumers:

| State | allowsActions | isTerminal | showsWarning | severity |
| --- | --- | --- | --- | --- |
| pending | true | false | false | info |
| running | true | false | false | info |
| approved | true | false | false | success |
| rejected | true | false | true | error |
| promoted | true | false | false | success |
| archived | false | true | false | info |
| healthy | false* | false | false | success |
| degraded | true | false | true | warning |
| error | true | false | true | error |
| disabled | true | false | false | info |
| unverified | true | false | false | info |
| exposed | true | false | true | error |
| redacted | true | false | false | warning |
| stale | true | false | true | warning |
| excluded | false | true | false | info |

\* `healthy` defaults `allowsActions=false` for pure status chips; parent surfaces may still expose unrelated actions (edit connection, open detail).

---

## 7. Accessibility Semantics

| Requirement | Implementation hook |
| --- | --- |
| Not color-alone | Always pair `DSOperationalStateUI.label` / `semanticLabel` with color |
| Live updates | Wrap dynamic AdminDataState replacements in `aria-live=polite` (CC gap; Prism should not regress) |
| Redaction | Announce “redacted” in `semanticLabel` when displaying placeholders |
| Terminal states | Hide primary “continue” CTAs when `isTerminal` |

Known CC gaps (from `ui-patterns.md`, still source-backed, not screenshot-proven): missing `aria-current` on sidebar, missing live regions on filters, table scroll regions unlabeled.

---

## 8. What Was Wrong In The 2026-06-08 Draft

| Issue | Correction |
| --- | --- |
| Claimed `DSStateType` has 3 values | Live enum has **7** |
| Proposed future `OperationalState` | Already implemented as `DSOperationalState` (15) |
| Cited `lib/design_system/...` | Melos path is `packages/warp_prism_ui/lib/src/...` |
| Mapped states primarily from mock task lanes | Primary evidence is now **CC frontend enums** |
| Overstated mock corpus as universal proof | Mock/ASW mappings are secondary; graded `derived`/`speculative` only when used |

---

## 9. Screenshot Gap And Governance Amend (2026-07-09 APPLIED)

No screenshot packet is available (`/tmp/opencode/cc-ui-screenshots-round2` absent; no in-repo reports). Therefore:

- Color contrast failures are **not** asserted.
- “Looks broken in dark mode” style claims are **out of scope** until screenshots are imported (do not invent).
- Vocabulary remains valid from **source enums + Prism tokens** (primary DoD evidence).
- Per `component-inventory.md` §0.5 and Task 1102 governance amend (2026-07-09 **APPLIED**), screenshots are **optional / deferred** — not a hard exit gate. Source-backed vocabulary **satisfies** inventory DoD for `ready_for_reviewer: yes`. Visual claims stay out of scope until real screenshot reports exist (follow-up if ever available).
