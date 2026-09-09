# wp-warpblade-onboard — Warpblade Project Onboarding (bounded)

For FRESH sessions only. Grandfathered crew sessions with deep mission context
(see `.project/sessions/sessions.md`) skip this. Supplements — never replaces —
`gt-global-onboard.md`; on conflict the global workflow wins unless this file is
explicitly narrower for Warpblade.

Budget: ~10 reads max. Reconnaissance, not archaeology. Do NOT deep-dive the
whole tree to "be thorough" — unbounded recon explodes context and is a defect.

1. Read `MISSION.md` (product destination + §20 Slice-1 DoD) and `AGENTS.md`
   §§1 (prime directives), 9 (Flutter/Rust/FRB law), 12 (conformance gate),
   14 (evidence layers), 18 (crew continuity).
2. Read `docs/ops/CURRENT.md` + `docs/ops/WORK.md` — live mission state.
   Conversation history is not truth; these files are.
3. Read your assigned task file FULLY + every path in its Where table
   (headers/summaries first; full bodies only for files you will edit).
4. Recon the layout with cheap calls only (`ls crates/ apps/
   docs/architecture/`; one symbol-summary per crate you will touch).
   No full source reads beyond your write_scope.
5. Load skills ONLY via the skill tool and ONLY those named in your dispatch
   packet (`skill_routes`); record truthful `skill_attestation`.
6. Declare readiness in ≤6 lines: task, planned touch-list, key risks,
   blockers, ready/not-ready.

Hard prohibitions: no `git`/jj (harness-denied), no deletes (archive flow),
no `AGENTS.md`/`MISSION.md` edits (root-only), stay inside assigned
write_scope, read before write, package PASS ≠ host PASS, builder claim ≠
reviewer acceptance, never weaken spec to fit implementation.
