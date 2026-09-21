# Task 1805 — Visual Re-Judgment Runbook (owner human gate)

> **Prepared by**: Karax (root mission control plane), 2026-09-10
> **Purpose**: execute the Task 1805 human visual re-judgment — the gate that
> unblocks 1703, 1806, 1807 and closes the L1 revalidation cycle.
> **State at preparation**: technical evidence layer GREEN (Task 1838:
> 12-run host-exercise matrix, all `errors: []`, independently reviewed
> 93/100 incl. compact-500×900 CyberCore teal). What remains is the owner's
> visual verdict per criterion.

---

## 1. Pre-flight (one-time, ~5 min first host)

Build caches were cleaned on 2026-09-09 (quick win per operator request).
First launch recompiles.

```bash
# Disk must have ≥ 10G free for 3 debug builds (current: ~198G free — OK)
df -h /home

# Cold build happens automatically on first run; just run:
cd apps/catalog && flutter run -d linux
```

If the editor shows analysis errors after the cache clean, restart the
analysis server (Dart: Restart Analysis Server) or reopen the project.

## 2. The three hosts, in this order

| # | Host | Command | What it proves |
|---|---|---|---|
| 1 | **Catalog** | `cd apps/catalog && flutter run -d linux` | Theme switcher propagation + gallery; criteria 1, 2, 6, 7, 8 |
| 2 | **Observatory** | `cd apps/observatory && flutter run -d linux` | Operational UI consumer; criteria 4, 9, 11 |
| 3 | **CyberCore** | `cd apps/cybercore && flutter run -d linux` | Product integration consumer w/ teal skin; criteria 3, 5, 10, 11 + resize window to compact (<600px) to exercise the bottom-nav path |

## 3. The 11-criterion checklist (binary, verbatim from Task 1805)

Judge each on the live app in front of you:

```text
[ ] 1  background is black obsidian, not blue
[ ] 2  surfaces neutral near-black with restrained elevation
[ ] 3  blue confined to action/focus/highlight roles
[ ] 4  semantic green/amber/red remain meaningful
[ ] 5  no excessive teal/green/rainbow chrome
[ ] 6  no persistent high-intensity blue ambient glow
[ ] 7  UI typography readable and non-mono in interface roles
[ ] 8  JetBrains Mono only in technical roles
[ ] 9  contrast/focus states accessible
[ ] 10 density matches approved reference intent
[ ] 11 Catalog and app hosts render the same theme contract
```

**What changed since the 2026-09-03 FAIL verdicts** (criteria 3/5/11 were the
FAILs; 10 was REOPEN):

- **Criterion 3 (accent confined to interaction/focus)**: the 1833 wave removed
  all registry mutation and migrated 10 host-side chrome reads to
  `PrismTheme.accentOf` — CyberCore chrome now resolves teal **from the theme**,
  with the widget-level teal test + 1838 compact trace as proof. Judge whether
  the accent discipline now reads correctly on screen.
- **Criterion 5 (no rainbow chrome)**: unified teal recipe in CyberCore; no
  static Khalai Blue chrome reads remain (`grep accentBlue` in apps = 0 hits).
- **Criterion 10 (density)**: 1836 fixed the falsified scrubber/table layout
  bands (h∈[70,95), h∈[110,118], textScale 2.0); 1838 proved zero overflow in
  exercised routes.
- **Criterion 11 (same contract across hosts)**: 1838 ran all 3 hosts through
  the same exercise runner with zero contract violations.

## 4. Recording the verdict (per criterion)

Reply to the session with one line per criterion:

```text
1: PASS | 2: PASS | 3: PASS | 4: PASS | 5: PASS | 6: PASS | 7: PASS |
8: PASS | 9: PASS | 10: PASS | 11: PASS
```

Any FAIL: name the criterion + what looks wrong (one sentence is enough);
screenshots help. Rejected output is preserved under
`docs/reports/captures/rejected/` — never silently overwritten.

## 5. After your PASS (then I execute, you don't)

Once criteria are PASS and you authorize the golden refresh:

1. **I** run the single deliberate golden refresh (63 drifted baselines +
   embedded groups) and verify the full suite green post-refresh.
2. **I** record the sign-off + refresh evidence in Task 1805 (Review Ledger +
   `docs/reports/1805-visual-acceptance-gate-report.md`).
3. **I** unblock and close out **1703** (goldens), **1806** (2 pending exits),
   **1807** (bake-back session — if you also declare token convergence here,
   the export-snippet workflow in the Catalog's Theme Editor produces the
   bake-back values).
4. **I** re-run the L1 Integration Readiness evaluation against the refreshed
   evidence and dispatch the independent L1 gate review.

## 6. If you FAIL any criterion

The loop stays alive: I dispatch the fix to the fleet engineer (same session),
reviewer re-reviews, and you re-judge only the failed criterion. Failing one
branch does not block the others.
