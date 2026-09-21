---
lane: architects
type: continuity
ts: 2026-08-31
---

# Source-Reality Pass — Warp Prism v2 planning falsified against repo (2026-08-31)

## What happened

User directive (24 points): pivot from transcript-coverage to repo-falsification. Executed full adversarial pass. NO planning rewrite, no v9 stories, no new stories — verdicts + in-place amendments only.

## Key ground-truth discoveries (change everything downstream)

1. **EPIC-18 já foi IMPLEMENTADO por builders** (outras sessões): `PrismTokenRegistry` live (DSColors = getters), `DSTheme.dark()` full M3 factory + Taldarim/Talon skins, `PrismThemeEditor` organism, Rajdhani bundled, `integration_test/` existem. 1800 completed; 1801–1809 em `03-review` (36 tasks parked). PLAN-1807 const-containment = SUPERSEDED-BY-REALITY (blast radius pago na prática).
2. **Zero Rust/FRB/Cargo** no repo — EPIC-22 greenfield completo; versão FRB rebaixada a "candidate" até spike.
3. **IDS/Runtime não existem**; seleção é ad-hoc (>100 usos, 10+ padrões); só `DSWorkflowSelection` é payload dedicado → kernel IDS admitirá SÓ Selection/Inspection/Command-intent (evidence-driven); Query/Navigation/Viewport → ledger.
4. **Presentation policy vazava nos contracts** (auto-scroll/polling/retry) → purgado; `GraphNode`/`DSWorkflowNode` misturam layout+semântica (mapper no binding edge, nunca no contract).
5. **S19-03 era contaminação de harness Ganthritor** (Skill Sections/lobe) → REWRITTEN como integration-gateway policy WP; handoff pro parent.
6. **Rust topology 5+ crates → 2** (`warp_bridge_core` modules + `warp_bridge_frb`); concept ≠ crate.
7. **Lab = single hypothesis (FRB only)** — daemon/RPC/Cersei/Ganthritor/OmniRoute excluídos do primeiro lab.
8. **Declutter vira state-based** (não epic-number-based): CURRENT = non-terminal tasks + active planning + canon; HISTORICAL = terminal + superseded.
9. **Lifecycle anti-circularidade**: PROPOSED→EXPERIMENTAL (sem stable barrel)→PROVEN→STABLE.
10. **HealthSource = 0 consumidores hoje**; EventStream/GraphSource ≈ 2 same-domain cada; todos começam EXPERIMENTAL.

## Deliverables

- Report canônico: `docs/reports/warp-prism-v2-source-reality-review-2026-08-31.md` (verdicts A–G: review, amendments, DAG, authority, task compression 33→15, boundary matrix 3-now+7-phased, deferred ledger)
- EPICs 19–25 + OR emendados IN-PLACE (verdict headers); STORIES = genome-not-queue banner; PLAN-1807 superseded; PLAN-drain evidence note.
- Continuity prior entries (2026-08-22/29) refletem estados antigos — este registro é o mais atual; os arquivos EPIC em si agora são a fonte.

## Next steps (blocked on user)

1. **19-gate sign-off** do pacote source-reality (15 tasks: 19-A..D, 20-A..C, 21-A..D, 22-A..D).
2. **AGENTS.md authorization** (protected file) para 19-A.
3. **Task 1805 human screenshot gate** → destrava W1 drain e 19-D.
4. Aprovação → promote 19-A/B/C imediatamente (não dependem de EPIC-18 visual).

## Subagent trail (completo)

- ses_fa64e1616ffeQwSADlZpuNmAkB — investigator codebase (facts, file:line) — first message truncated, resent full, delivered
- Anteriores: ses_fb0237ca8ffe… (synthesis, dead), ses_faf79f1e5ffe… (stories v8, dead)
