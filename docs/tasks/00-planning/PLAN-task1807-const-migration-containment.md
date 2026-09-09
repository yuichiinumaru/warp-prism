# PLAN — Task 1807 Const-Migration Containment (PrismTokenRegistry blast radius)

> **⚠️ SUPERSEDED-BY-REALITY (2026-08-31 source-reality review)**: builders already absorbed the const→getter migration during EPIC-18 execution — `prism_token_registry.dart` is live, `DSColors` getters delegate to the registry, `PrismThemeEditor` organism + registry tests exist, catalog consumes `PrismTheme.dark()`. The blast radius was paid in practice, not on paper. This plan retains historical value only (its measurement command still serves as a pattern for future migrations). Do not schedule any task from this file. The registry-mutation tooling-guard check (its §4.3) survives as boundary-harness check #8 in the source-reality report §F.

---

## 1. The risk, precisely

Task 1807 converts the **editable role set** of `DSColors` (blue ladder, focus, deep/base/elevated/hover surfaces, border) from `static const Color` to **registry-backed getters** (`static Color get x => PrismTokenRegistry.instance.x`).

Every use of those tokens in a **const context** becomes a compile error:

```dart
// breaks:
const Color c = DSColors.accentBlue;
const BoxDecoration(color: DSColors.surfaceBase);       // const constructor arg
const [DSColors.borderSubtle, DSColors.borderStrong];     // const list
const Text('x', style: TextStyle(color: DSColors.accentBlue)); // const style w/ const color arg — only if whole expr const
```

`static const` values are compile-time constants; `static get` is runtime. Dart will reject each const context referencing them. The original task called this "bounded, mechanical" — **true per-mechanics, false per-scale until measured**.

## 2. Blast-radius measurement — REQUIRED BEFORE APPROVAL

Task 1807 promotion must be gated on a **measured count**, not an estimate. Deterministic pre-counts (to be executed by builder as first subtask, results recorded in task file):

```bash
# (a) total references to each editable token (all contexts)
for t in accentBlue surfaceBase border; do
  echo "$t: $(rg -c "DSColors.$t\b" packages apps | awk -F: '{s+=$2} END {print s}')"
done

# (b) references inside const contexts (the breaking subset) — conservative regex
rg -n "const [^\n]*DSColors\.(accentBlue|surfaceBase|border)" packages apps

# (c) const-constructor call sites whose arguments include editable tokens
rg -n "const [A-Z]\w+\(" -A0 packages/warp_prism_ui/lib | rg "DSColors\."
```

**Decision rule:** if const-context count (b) exceeds **~40 sites**, Task 1807 must be split into 1807a (registry + non-const migrations) and 1807b (const-context mechanical remediation wave) before any builder picks it up. Below that, single task remains valid.

## 3. Containment strategies (pick by measurement, record ADR in 1807)

| Strategy | Mechanism | Cost | Reversibility |
|---|---|---|---|
| **A — drop `const` at call sites** (default) | remove `const` keyword from affected expressions | runtime: negligible (Color objects are cheap; Flutter canonicalizes) / churn: mechanical | trivial |
| **B — keep `const` via default-const bridge** | `static const Color accentBlue = Color(0xFF...)` stays; registry applies via ThemeExtension overlay instead of token mutation | zero call-site churn; editor recolors only extension-aware consumers (components reading DSColors statics directly will NOT recolor live — limits editor fidelity) | high (architecture) |
| **C — hybrid** (recommended) | structural surfaces keep `static const` (Strategy B path); ONLY the blue ladder + focus become getters; const-context remediation confined to accent usages (smaller subset) | medium | moderate |

**Recommendation:** measure first (§2); default to **C**. The editor's purpose is accent convergence — surfaces rarely need live override during the convergence session (bake-back covers them).

## 4. Golden/test determinism containment (unchanged from 1807, restated as hard rules)

1. `PrismTokenRegistry.reset()` in `setUp/tearDown` of every suite touching migrated tokens — export a shared test helper so this is one line per suite.
2. Any golden suite that accidentally renders under a mutated registry fails by producing drift → CI red is the intended alarm; **never** regenerate goldens to silence it.
3. Production code paths MUST NOT read registry mutators — add an analyzer grep check to boundary harness: `rg "PrismTokenRegistry.instance\.(set|apply|mutate)" packages/warp_prism_ui/lib apps/*/lib --glob '!**/catalog/**'` returns zero.
4. Registry mutation API gated: `assert(!kReleaseMode)` or explicit tooling flag, so release builds physically cannot mutate tokens.

## 5. Sequencing amendment to the EPIC-18 graph

```
1801 (token migration, cyan data-accent stays const)
   └─→ 1807a registry (getters for accent ladder + focus only)  [const-count gate applies here]
         └─→ 1807b const-context remediation wave (if measured >40)
               └─→ 1807c editor organism + catalog hosting (no const impact)
                     └─→ bake-back → 1805 screenshot gate
```

If 1807a/b split happens, renumber within the 18xx range (e.g. 1809/1810) rather than overloading 1807 — task identity registry governs.

## 6. Exit conditions for this plan

- [ ] const-context counts measured and recorded in Task 1807 file (evidence, not estimate)
- [ ] Strategy A/B/C chosen with one-line ADR note in 1807
- [ ] Registry test-reset helper + analyzer check specified as mandatory subtasks
- [ ] 1807 split decision (a/b/c) recorded if threshold tripped
- [ ] Task 1807 file amended to reference this plan
