# Warp Prism — Session Ledger & Persistent Fleet

> **Authority**: Operator convention adopted 2026-09-07 (see `AGENTS.md` §16).
> **Owner**: Root mission control plane (Karax / authorized orchestrator).
> **Purpose**: Single source of truth for subagent session identity + fleet
> reuse policy + per-task report destinations. Consult BEFORE dispatching any
> subagent; update AFTER every dispatch that returns a session ID.

**Canonical convention (operator law, 2026-09-07, incl. same-day item-6 update):**

1. **Every dispatched agent's session ID MUST be recorded here immediately
   after the dispatch returns**, in the Active Fleet table.
2. **Never launch fresh workers when a fleet session for a suitable
   role+domain exists**: reuse the recorded session ID via the `task` tool's
   `task_id` resume parameter. Consult this file before every dispatch.
3. **Engineer/expert may share one session** (the task tool acts as a
   session-bound wrapper; cross-role continuation in the same session is
   valid). **Reviewer keeps a dedicated session** (never send build-side
   work into it).
4. **Builder reports are additive per task**: all implementation/fix entries
   for one task go into ONE file
   `docs/reports/builders/<task-nbr>-<short-slug>-builder-report.md` — newest
   entry at top, prior entries preserved.
5. **Reviewer reports are additive per task**: all review iterations for one
   task go into ONE file
   `docs/reports/reviewers/<task-nbr>-<short-slug>-review-loop.md` — newest
   entry at top; still-open findings stay at the top, resolved findings move
   to the end section.
6. **Provider failure fallback**: when a resume fails on provider/transport
   error, retry the same session `task_id` with the next model from the
   ladder below (in order). **Never use any model outside the ladder.**
7. **Onboarding**: every FRESH fleet agent first receives the
   `.agents/workflows/wp-warp-prism-onboarding.md` workflow (light, bounded).
   Grandfathered deep-context sessions may skip it when the dispatch waives
   it. *(Renamed 2026-09-07 from `wp-warpblade-onboard.md` — operator
   correction of the original request's project name.)*
8. **Cross-task reuse**: the same fleet sessions are reused across MULTIPLE
   tasks when the domain is roughly the same — the accumulated context is
   the point of the fleet, not a cost.
9. **Capacity cap**: the ledger tracks at most **30 agents** (≈10 per
   role). When over capacity, retire least-recently-used lineage rows first;
   retired sessions remain cited in their task ledgers and reports (durable
   provenance lives there, not in this file).
10. **Researchers and architects are fleet roles too**: onboard a fleet
    session for that role via `wp-warp-prism-onboarding.md` when a domain
    needs it, record it here, then reuse it the same way.
11. **Stale-session notification**: when resuming a session after
    repository changes, the dispatching parent MUST briefly inform the agent
    which areas changed since the agent's last turn, and the agent must
    verify those areas before relying on prior context.

---

## Active Fleet

| Role | Agent profile (subagent_type) | Session ID | First onboarded | Status | Notes |
|---|---|---|---|---|---|
| Reviewer (Flutter) | `gt-reviewers-reviewer-flutter` | `ses_f8745bd18ffephR7OiLVh6S8xJ` | 2026-09-06 (1835 review; grandfathered — no re-onboard) | active | Deep context on 1833/1835 wave, meta-test, boundary harness, goldens freeze. **Dedicated reviewer session — do not send build work here.** |
| Engineer (Flutter) | `gt-builders-engineer-flutter` | `ses_f82fb269fffe4z330QdDqUSyK1` | 2026-09-07 (`wp-warpblade-onboard`; readiness declared; both review reports reconciled 100% against source) | active | Owns 1833-F6 + DSButton focus-ring + 1835 F1/F2/F3 remediations. Expert pass may continue in this same session when needed. |
| Expert (Flutter) | `gt-builders-expert-flutter` | *(pending)* | — | pending | Optional polish pass between fix loops; may share the engineer session. |

### Grandfathered / historical sessions (context reference only — do not reuse for new roles)

> If a lineage session becomes active again, promote it into the Active Fleet
> table above with the same session ID and remove it from this list.

| Session ID | Role | Domain context (reuse when domain matches) |
|---|---|---|
| `ses_f9a461d7cffeOG5bVLNO6MPJqV` | Builder | 1833 theme-role remediation |
| `ses_f9cebe293ffewfceUI8tDwxZ9H` | Builder | 2026-09-06 wave (1833/1835 breadth) |
| `ses_fa64e1616ffeQwSADlZpuNmAkB` | Builder | 1834 capture-proof / host-exercise |
| `ses_fb0237ca8ffeEU75shi0yRgCcn` | Builder | 1836 layout-band |
| `ses_11caac625ffe7vav9EPEG769P9` | Builder | 1836 layout-band (aux) |
| `ses_fcdddc95affeg7uzxV6evqck15` | Builder | 1832 responsive-layout |
| `ses_fcddde37effe553gOyqYnRbMt7` | Builder | 1831 host-composition |
| `ses_fcde09181ffeGKqYbxb1MEOLp4` | Builder | 1830 boundary-checks activation |
| `ses_f923db084ffeGnwneMKIpClg5O` | Builder | 1805 capture wave |
| `ses_f9a4fad55ffetq7jWCrvqYs2TD` | Builder | 1809 Taldarim/Talon skins (theme domain) |
| `ses_f8785b624ffeWG0RMDr8ZjeSrm` | Reviewer | 1833 Review 1 lineage |
| `ses_fce34ef94ffeNzNsPSN2UEs8j1` | Reviewer | 1831 review |
| `ses_fce350aa1ffe6E8Ubd0zaOaM2e` | Reviewer | 1832 review |
| `ses_fce353de0ffeElvu0lJXoO4urT` | Reviewer | 1834 review |
| `ses_fcebe5559ffefIEHT7Mf2XvhcL` | Reviewer | 1836 review |
| `ses_fce106a5dffea64mIZ6YyKASV9` | Reviewer | 1817 IDS promotion review |
| `ses_fcebe91baffeCH0lyFdXGVinH7` | Reviewer | Epic-16 acceptance audits |
| `ses_f9a879d75ffeETthoQrx9qAm6v` | Reviewer | 1807 token-override review |
| `ses_fce10876affeTtHKJp2uFQZ2fw` | Architect | 1825 L1 exit gate |
| `ses_fce16ad0affeTbNEy3i2hP63ie` | Architect | 1825/1824 L1 evidence |
| `ses_faf79f1e5ffeVDULRPLVp9eWdi` | Architect | v2 foundation handoff (2026-09-01) |

**Retired lineage rows (2026-09-07, per the 30-agent cap)** — provenance
preserved in their task ledgers/reports; only the ledger tracking row was
dropped: EPIC-15-era `ses_11c828da…`, `ses_11c828dc…`, `ses_11c8e3422…`,
`ses_11caac5f2…`, `ses_fcec24285…`; builders `ses_f923db0a6ffe…` (1805/06),
`ses_f923db0d4ffe…` (1807), `ses_f9a60ce9effe…` (1811),
`ses_f9a73b3fdffe…` (1816), `ses_f9a7bdf1affe…` (1817), and 1836 aux
`ses_11caac659…/692…/6d4…`.

> Sessions in the historical table are lineage references, not the active
> fleet. When in doubt, prefer a fleet session or a deliberate, documented
> resume of a lineage session with the right domain context.

---

## Per-Task Report Destinations (additive loop convention)

| Task | Builder report (additive) | Reviewer loop report (additive) |
|---|---|---|
| 1833 | `docs/reports/builders/1833-theme-role-accent-propagation-builder-report.md` | `docs/reports/reviewers/1833-theme-role-accent-propagation-review-loop.md` |
| 1835 | `docs/reports/builders/1835-material-ancestry-meta-test-builder-report.md` | `docs/reports/reviewers/1835-material-ancestry-meta-test-review-loop.md` |

> Loop format (both files): newest entry at the TOP of the entry list; every
> prior entry preserved verbatim below; reviewer file distinguishes
> "Still-open findings" (top) from "Resolved findings" (bottom section).
> Existing one-shot reports under `docs/reports/review/` and
> `docs/reports/builders/` remain valid historical evidence; the additive
> loop files are the live iteration surface for ongoing waves.

---

## Provider-Failure Model Fallback Ladders

> Law (operator, 2026-09-07): on provider failure when resuming a fleet
> session, retry the same session `task_id` with a model from the ladder
> **in this order**. **No other models may be used** for these roles.
> Consult `opencode models --refresh` before switching.

### Architects & Reviewers

1. `opencode/muse-spark-1.3-contributor-free --variant xhigh`
2. `omniroute/architect`
3. `omniroute/claude-opus-4.6`
4. `omniroute/glm-5.3`
5. `omniroute/orchestrator`
6. `omniroute/reviewer`
7. `openai/gpt-5.6-luna --variant xhigh`

### Engineers & Experts

1. `omniroute/builder-engineer`
2. `omniroute/builder-expert`
3. `omniroute/gemini-flash`
4. `omniroute/minimax-m3`
5. `opencode/muse-spark-1.3-contributor-free --variant xhigh`
6. `omniroute/glm-5.3`

---

## Dispatch Log

*(Append-only. One line per fleet dispatch: date, role, task_id/sessionID, objective, outcome.)*

| Date | Role | Session | Objective | Outcome |
|---|---|---|---|---|
| 2026-09-06 | Reviewer (Flutter) | `ses_f8745bd18ffephR7OiLVh6S8xJ` | Task 1835 independent review (aborted → resumed) | FAIL 82/100, F1 PrismSelect blocker; report at `docs/reports/review/1835-material-ancestry-meta-test-independent-review-2026-09-06.md` |
| 2026-09-07 | Root (Karax) | — | Convention adoption (items 1–5): session ledger + fleet policy + onboard workflow + AGENTS.md §16 + lanes 1833/1835 → 02-doing + tasklist rebuild | done |
| 2026-09-07 | Engineer (Flutter) | `ses_f82fb269fffe4z330QdDqUSyK1` | Fleet engineer onboarded via `wp-warpblade-onboard` | ready; both review reports reconciled 100%; additive report destinations confirmed |
| 2026-09-07 | Root (Karax) | — | Convention update (item 6): cross-task reuse + 30-agent cap + researcher/architect fleet roles + stale-session notification; lineage table trimmed to cap | done |
| 2026-09-07 | Engineer (Flutter) | `ses_f82fb269fffe4z330QdDqUSyK1` | Remediation Round 3 (1833: F6 chrome migration + chrome teal test + DSButton oracle fix + task:178; 1835: PrismSelect spec + F2 oracle + F3 teardowns + F4 + 117→118) | COMPLETE — all gates green (boundary 15/15, cybercore +23 incl. new chrome test, meta 123, scoped 171, builds exit 0); builder reports written; ready for re-review |
| 2026-09-07 | Reviewer (Flutter) | `ses_f8745bd18ffephR7OiLVh6S8xJ` | Re-review 1833 Round 3 + 1835 Round 1 + Rule-70 governance rider on §16 convention | 1833: 93/100 APPROVED_PATH100 (F6 RESOLVED, 0 regressions); 1835: 95/100 APPROVED_PATH100 (F1–F4/F6 RESOLVED, 0 regressions); rider PASS (behavioral, no contradictions). Loop files written under docs/reports/reviewers/ |
| 2026-09-07 | Root (Karax) | — | Closeout: ledger patches applied, Review State → Promoted, changelog published ×2 (add+closeout, 320 entries valid), tasks promoted 03-review → 04-completed (188 total), tasklist rebuilt | done |
| 2026-09-07 | Root (Karax) | — | Task 1836 closeout (PASS 90/100 pre-existing review of 2026-09-06): ledger patch applied, Review State → Review Approved, promoted via documented claim-law bypass (complete independent review had examined full task content), changelog closeout published (321 entries valid), tasklist rebuilt (189 completed) | done |
| 2026-09-07 | Root (Karax) | — | Task 1837 materialized (golden-suite tagging — F5 follow-up routed by 1835 reviews to wave owner) + moved 01-open → 02-doing + tasklist rebuilt | dispatched to fleet engineer next |
| 2026-09-07 | Engineer (Flutter) | `ses_f82fb269fffe4z330QdDqUSyK1` | Task 1837 round 1: 13 library tags + both-direction verification; guardrail caught 4 embedded checkbox goldens outside scope | COMPLETE w/ scope finding (correctly reported, not expanded) |
| 2026-09-07 | Engineer (Flutter) | `ses_f82fb269fffe4z330QdDqUSyK1` | Task 1837 round 2 (parent scope repair): group-tags on 3 embedded golden groups (checkbox/button/text_field) + full sweep | COMPLETE — primary gate green: exclusion exit 0 +1692; freeze intact |
| 2026-09-07 | Reviewer (Flutter) | `ses_f8745bd18ffephR7OiLVh6S8xJ` | Task 1837 independent review (both rounds, 7 falsification items) | 95/100 APPROVED_PATH100, 0 regressions; N1 count-correction (60/1/59; surface 74); count arithmetic reconciled exactly |
| 2026-09-07 | Root (Karax) | — | Task 1837 closeout: N1 corrections applied, Review State → Promoted, changelog closeout published (322 entries valid), promoted to 04-completed (190 total), tasklist rebuilt | done |
| 2026-09-08 | Root (Karax) | — | Operator naming correction: onboarding workflow renamed `wp-warpblade-onboard.md` → `wp-warp-prism-onboarding.md` (canonical, Rule-74 frontmatter); old path now retired tombstone; stale Warpblade content archived at `.archive/.agents/workflows/`; AGENTS.md §16.4 + ledger refs repaired; harness-evolution entry added; discovered `.agents/` is parent-root symlink (workflows are parent-canonical) | done |
| 2026-09-08 | Engineer (Flutter) | `ses_f82fb269fffe4z330QdDqUSyK1` | Task 1838 real-host revalidation dispatch | FAILED — provider: "all upstream accounts are inactive"; retry pending (fallback ladder available) |
| 2026-09-08 | Engineer (Flutter) | `ses_f82fb269fffe4z330QdDqUSyK1` | Task 1838 retry (provider recovered) | COMPLETE — 12-run matrix, all exit 0, errors:[] in every trace incl. CyberCore compact-500x900 teal (F6 surface); 10 traces persisted; revalidation suites added; zero product code touched |
| 2026-09-08 | Reviewer (Flutter) | `ses_f8745bd18ffephR7OiLVh6S8xJ` | Task 1838 independent review (instrument + evidence, 8 falsification items) | 93/100 APPROVED_PATH100, 0 regressions; instrument audited line-by-line (no false-PASS path); traces authentic + action-deterministic (byte-drift N2/Info closed per 1834-F1); compact F6 surface genuinely exercised |
| 2026-09-08 | Root (Karax) | — | Task 1838 closeout: N1 prose fold applied, Review State → Promoted, changelog closeout (323 entries valid), promoted to 04-completed (191 total), tasklist rebuilt | done |
