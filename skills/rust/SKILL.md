---
name: rust
description: |
  Rust engineering, review, ownership, unsafe soundness, async cancellation,
  error handling, testing, and verification governance. READ THIS FIRST for
  Rust code reviews, refactoring, security audits, new Rust modules, or
  ganthritor-rs work. Combines review protocol, soundness auditing, and
  engineering best practices covering ownership safety, unsafe boundaries,
  async/tokio cancellation, FFI, type-state proofs, and formal verification.
sub-skills-index:
  - review: "Rust review protocol and soundness checks: ownership, unsafe, cancellation, FFI, miri, scoring."
  - unsafe-soundness: "Unsafe block auditing, SAFETY comments, FFI boundaries, raw pointers, Miri/Kani proof."
  - async-concurrency: "Tokio async cancellation safety, select! hazards, mutex-across-await, task lifecycle, Send/Sync."
  - error-handling: "Error type design, thiserror/anyhow, context propagation, unwrap discipline, panic safety."
  - testing-verification: "Cargo test, property-based testing, Miri, Kani, benchmarks, coverage, fixture discipline."
  - cargo-queue: "Serialized cargo via flock + agent-decides dedup, single target/ only (refuse CARGO_TARGET_DIR/--target-dir/orphans), size-gated clean + post-run gate (30GiB), CARGO_QUEUE_ENVELOPE. REQUIRED for multi-agent cargo."
triggers:
  - rust code review
  - rust review
  - rust audit
  - rust quality
  - rust best practices
  - rust ownership
  - rust unsafe
  - rust async
  - rust cancellation
  - rust ffi
  - rust testing
  - rust error handling
  - rust performance
  - rust soundness
  - cargo check
  - cargo test
  - cargo clippy
  - cargo miri
  - cargo queue
  - cargo lock contention
  - cargo dedup
  - CARGO_QUEUE_ENVELOPE
  - ganthritor-rs
  - Cargo.toml
metadata:
  maturity: draft
  implementation_kind: full
  owner: architects/language-harness
  negative_triggers:
    - condition: "User asks for cross-language review scoring, review-lineage routing, verification gates, or sabotage gates."
      reason: "Language harness gathers language-specific evidence; code-quality owns cross-language scoring and review workflows."
      delegate_to:
        skill: code-quality
        surface: .agents/skills/code-quality/SKILL.md
    - condition: "User asks for Go code review, goroutine safety, or Go engineering."
      reason: "Go work belongs to go."
      delegate_to:
        skill: go
        surface: .agents/skills/go/SKILL.md
    - condition: "User asks for Flutter, Dart, Riverpod, or Flutter UI work."
      reason: "Flutter/Dart belongs to flutter."
      delegate_to:
        skill: flutter
        surface: .agents/skills/flutter/SKILL.md
    - condition: "User asks for Python review, typing, or Python engineering."
      reason: "Python work belongs to python."
      delegate_to:
        skill: python
        surface: .agents/skills/python/SKILL.md
    - condition: "User asks for TypeScript/JavaScript review or frontend engineering."
      reason: "TS/JS work belongs to tsjs."
      delegate_to:
        skill: tsjs
        surface: .agents/skills/tsjs/SKILL.md
    - condition: "User asks for security architecture, threat modeling, authz, secrets, or supply-chain gates beyond Rust-local checks."
      reason: "Broad security governance belongs to security."
      delegate_to:
        skill: security
        surface: .agents/skills/security/SKILL.md
    - condition: "User asks for debugging runtime failures, crashes, traces, or profiling investigations."
      reason: "Runtime investigation belongs to remediation."
      delegate_to:
        skill: remediation
        surface: .agents/skills/remediation/SKILL.md
    - condition: "User asks for dependency update waves or version governance."
      reason: "Dependency governance belongs to dependency."
      delegate_to:
        skill: dependency
        surface: .agents/skills/dependency/SKILL.md
  inputs:
    required: [task, source_paths, crate_root]
    optional: [test_commands, Cargo.toml, previous_reports, target_modules]
  outputs:
    primary: [language_review_evidence, soundness_findings, axiom_compliance]
    secondary: [recommended_commands, path_to_100, tool_report]
  side_effects: [read-only, tool-execution]
  evidence_required: [source_reads, command_output, task_evidence]
  completion_signal: "Language-specific evidence and unresolved blockers are recorded with file/path references."
---

# Rust Harness

**Rust engineering, review, and soundness governance.** Language-domain harness
for ownership safety, unsafe auditing, async cancellation, error handling,
type-state proofs, FFI boundaries, testing discipline, and formal verification.

## Core Axioms (Non-Negotiable)

| # | Axiom | Violation = | Check |
|---|-------|-------------|-------|
| 1 | **Ownership** | Aliasing + Mutation = UB | Every `&mut` is exclusive; no shared mutability without `Cell`/`Mutex` |
| 2 | **Type-State** | Invalid states representable | Use enums/newtypes to make impossible states uncompilable |
| 3 | **Zero-Cost** | Runtime penalty from abstraction | No unnecessary `Box`, `dyn Trait`, or allocation where static dispatch suffices |
| 4 | **Safety Boundary** | Missing `// SAFETY:` | Every `unsafe` block MUST have a `// SAFETY:` comment justifying invariants |
| 5 | **Cancellation Safety** | Resource leak on `Future` drop | Any `.await` point must be safe to drop — use RAII/`Drop` guards |

## Sub-Skills

| # | Sub-Skill | Scope |
|---|-----------|-------|
| 1 | `review` | Full Rust review protocol: security heat map, async audit, idiomatics, proof architecture, scoring |
| 2 | `unsafe-soundness` | Unsafe block audit, SAFETY comments, FFI boundaries, raw pointers, Miri/Kani, Send/Sync |
| 3 | `async-concurrency` | Tokio async patterns, cancellation safety, select! hazards, mutex-across-await, spawned task lifecycle |
| 4 | `error-handling` | Error type design, thiserror/anyhow, context chain, unwrap discipline, panic boundaries |
| 5 | `testing-verification` | Cargo test, property testing, Miri, Kani, benchmarks, coverage, fixture discipline |
| 6 | `cargo-queue` | Multi-agent cargo serialization, single `target/` policy, size-gated clean, `CARGO_QUEUE_ENVELOPE`, dedup, force, ledger |

## Quick Decision Tree

```
What are you doing with Rust code?
├── Full code review / audit         → use review
├── Auditing unsafe blocks / FFI     → use unsafe-soundness
├── Async / tokio / cancellation     → use async-concurrency
├── Error types / unwrap / panics    → use error-handling
├── Tests / benchmarks / Miri / Kani → use testing-verification
├── cargo check/test/clippy/build
│   in multi-agent OR any shared workspace
│                                    → use cargo-queue (REQUIRED; never bare cargo)
├── Cross-language scoring / gates   → delegate to code-quality
├── Security threat modeling         → delegate to security
└── Runtime debugging / profiling    → delegate to remediation
```

## Loading Matrix

| Intent | Primary Subskill | Also Load |
|--------|-----------------|-----------|
| Full Rust PR review | `review` | `error-handling`, `testing-verification` |
| Unsafe / FFI audit | `unsafe-soundness` | `review` (security heat map), `testing-verification` (Miri) |
| Async / tokio work | `async-concurrency` | `error-handling`, `testing-verification` |
| Error handling review | `error-handling` | `review` (idiomatics phase) |
| Test strategy / coverage | `testing-verification` | `review` (proof architecture) |
| Ownership / borrow issues | `review` | `unsafe-soundness` (if unsafe involved) |
| Performance / allocation | `review` (Phase 3) | `testing-verification` (benchmarks) |
| Multi-agent / orchestrated cargo | `cargo-queue` | `testing-verification` (what gate to request) |

## Suggested Baseline Commands

Use project-specific commands from `Cargo.toml` when present. In multi-agent
or builder/reviewer waves, **always** go through `cargo-queue` (see sub-skill).

```bash
# Multi-agent / shared machine (REQUIRED path)
AGENT_NAME=<id> TASK_ID=<nnnn> \
  bash .agents/skills/rust/sub-skills/cargo-queue/scripts/cargo-queue.sh check --lib
# Parse CARGO_QUEUE_ENVELOPE: dedup_hit / dedup_running (exit 75) / force with --force

# Solo local (optional; still prefer queue if other agents may run)
cargo check --lib
cargo clippy --all-targets -- -D warnings
cargo test --lib
cargo audit
cargo deny check
MIRIFLAGS="-Zmiri-strict-provenance" cargo +nightly miri test
```

> [!IMPORTANT]
> **Do not** invent `target-<task>/` or set custom `CARGO_TARGET_DIR`. Only
> project-root `target/` is allowed; the queue **refuses** custom dirs and orphan
> `target-*` trees. Prefer `cargo-queue.sh clean` (size-gated, default only when
> `target/` > 30 GiB). Blind clean after every green gate destroys warm cache;
> the queue already runs a post-run size gate after non-clean cargo.

> [!IMPORTANT]
> Prefer **scoped** gates for task evidence (`check --lib`, focused `--test`).
> Tree-wide `check --all-targets` / clippy failures are often EXTERNAL — classify
> them; do not re-enqueue the same global red 10× (dedup will surface the prior log).

## Non-Negotiable Operating Rules

1. **Read current project code first.** Do not introduce patterns by name alone. Use the project's actual stack and task evidence.
2. **Run verification from the crate root.** Prefer the project-defined command. When no command is defined, use `cargo check` from the workspace root.
3. **No phantom Rust validation.** If Rust toolchain is missing, report the blocker. Do not mark Rust tasks complete without compiler/test evidence.
4. **Respect Ganthritor persistence policy.** SQLite is not an acceptable runtime persistence backend. Prefer PostgreSQL for durable state and Redis for cache/queue/coordination.
5. **Disk cleanup is size-gated.** Use `cargo-queue.sh clean` (or project policy);
   do not force `cargo clean` after every green gate. Queue post-run gate cleans
   when `target/` > 30 GiB.
6. **Single `target/` only.** Never `CARGO_TARGET_DIR=target-*`, `--target-dir`, or
   parallel target trees — the queue fails closed if those appear.
7. **Every `unsafe` needs proof.** No `unsafe` block without `// SAFETY:` comment and formal justification.
8. **Multi-agent cargo goes through `cargo-queue`.** Parse the envelope; on
   `dedup_hit` / `dedup_running`, inspect prior logs before `--force`. Never claim
   task PASS from a failure prior log alone. Never bare `cargo` for project work
   when other agents may share the machine.

## Compatibility Note

This harness coexists with the existing
`.agents/skills/code-quality/sub-skills/rust/SUBSKILL.md` compatibility
adapter. After `Task AD-ganthritor-code-quality-language-routing-refactor`, new
Rust-specific work routes here first; the old code-quality path is legacy
compatibility only. This harness provides the expanded, standalone version with
domain-specific subskills.

## Integration with code-quality

rust provides Rust-specific doctrine. code-quality provides
cross-language governance gates.

| code-quality provides | rust uses it for |
|------------------------------|------------------------|
| scoring-rubric (0-100) | Final score for all Rust reviews |
| verification-gate | Mandatory for P0/P1 task completion |
| sabotage-gate | Mandatory for P0/P1 regression proof |
| review-lineage | Tracking review history |
| contract-compliance | Verifying spec adherence |

Routing: `code-quality` decision tree routes Rust → `rust`
for evidence gathering, then applies its own gates for scoring and proof.

## Related Skills

| Skill | Relationship | When to Load |
|:------|:-------------|:-------------|
| [`code-quality`](../code-quality/SKILL.md) | Language-agnostic quality gates | Verification gates, sabotage gates, scoring rubric, review workflows |
| [`coding-execution`](../coding-execution/SKILL.md) | Implementation lifecycle and proof discipline | Task implementation patterns, verification checklists, self-proof, and review feedback handling |
| [`remediation`](../remediation/SKILL.md) | Debug and fix | When fixing issues found by Rust code review |
| [`security`](../security/SKILL.md) | Security architecture | Threat modeling, supply-chain, secrets beyond Rust-local scope |

## References

- `references/provenance.md` — Source absorption map and compatibility notes
- `.agents/skills/code-quality/references/rust-rules.md` — 179 Rust coding rules (14 categories)
- `.agents/skills/code-quality/references/scoring-rubric.md` — Unified 0-100 scoring rubric

## Governance

- Sub-skills follow Lobe Gateway pattern: max 1 level nesting
- Root SKILL.md maintained as lightweight gateway
- Maturity: `draft` — new bootstrap, not yet reviewed or proven in production
- Raw reference material stays in `references/`; do not inline large corpora into subskills

## Maintenance

When adding a new sub-skill to this harness:
1. Add entry to `sub-skills-index` in this SKILL.md frontmatter
2. Create `sub-skills/<name>/SUBSKILL.md` with substantive content
3. Update Quick Decision Tree and Loading Matrix
4. Run index validation: `python3 .agents/skills/harness-architecture/sub-skills/indexing-skills/scripts/index_rebuild.py .agents --validate`

---

*Bootstrap from code-quality/sub-skills/rust/SUBSKILL.md*
*Pattern: Lobe Gateway (harness-architecture/nest-skills)*
*Created: 2026-06-11*
