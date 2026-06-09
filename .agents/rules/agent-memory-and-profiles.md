---
id: agent-memory-and-profiles
title: Agent Memory and Profiles
scope: dev-agent-governance
applies_to: [all-agents, subagents, orchestrators]
triggers: [agent-wiki, profile-creation, continuity-writing]
priority: P0
status: active
---

# Agent Memory And Profiles

## Purpose

This rule defines where development agents write durable operational memory.
It exists to prevent profile sprawl, worker-specific continuity silos, and
accidental nested paths under `.agents/profiles/`.

It also defines the **purpose boundary** of canonical profiles: they are
role-scoped memory surfaces, not changelog substitutes, not task ledgers, and
not the final home of repository-wide truth.

## Canonical Active Profiles

Ganthritor uses role-level profile namespaces, not provider/tool-level or
worker-level namespaces:

| Canonical profile | Use for |
| --- | --- |
| `.agents/profiles/architects/` | architecture, planning, task creation, harness governance |
| `.agents/profiles/builders/` | implementation, remediation, builder waves, path-to-review fixes |
| `.agents/profiles/reviewers/` | independent reviews, audits, score gates, path-to-100 findings |
| `.agents/profiles/researchers/` | external intelligence, research harvests, synthesis waves |

Do not create active profile folders named after providers, runtime harnesses,
workers, specialist subagents, or orchestrator definitions unless the user
explicitly requests a separate durable identity.

## What Canonical Profiles Are For

Use canonical profiles for:

- continuity and handoff state
- role-local learnings and failure patterns
- tactical decisions that help the same role later
- review/fix/audit memory that future sessions may need to search
- synthesis/compression notes that explain noisy historical corpora

Do not use canonical profiles as the primary home for:

- task completion evidence that belongs in `docs/tasks/`
- user-visible historical change publication that belongs in changelog
- architecture/policy/operator docs that should live under `docs/`
- reusable agent behavior that should live in skills, workflows, or rules

If the knowledge should be trusted by another role as repository truth,
institutionalize it outside the profile and keep only a compact pointer or
role-local summary in the profile when useful.

## Parent Profile Binding

In orchestrated waves, the parent session owns durable memory.

- The parent selects one canonical `agentID`: `architects`, `builders`,
  `reviewers`, or `researchers`.
- Every dispatched subagent must run onboarding with that same `agentID` when
  onboarding is needed.
- Every subagent must write durable `agent-wiki` notes to the parent profile.
- Runtime role names such as `worker-7435`, `gt-harness-architect`,
  `gt-rust-code-reviewer`, `builder-orchestrator`, or `reviewer-orchestrator`
  are not profile names.

Examples:

```bash
python .agents/skills/agent-wiki/scripts/agentlog.py \
  --profile builders \
  --type continuity \
  --title "task-7453-benchmark-remediation" \
  "Builder-wave handoff content."
```

```bash
python .agents/skills/agent-wiki/scripts/agentlog.py \
  --profile reviewers \
  --type review \
  --title "task-7453-final-review" \
  "Review verdict, evidence, commands, and path to 100."
```

## Profile Argument Contract

`agentlog.py --profile` takes a bare canonical profile name, never a path.

Allowed active values by default:

- `architects`
- `builders`
- `reviewers`
- `researchers`

Forbidden examples:

- `.agents/profiles/builders`
- `codex-builder`
- `opencode-builder`
- `builder-orchestrator`
- `worker-7435`
- `gt-harness-architect`
- `codex-review-0410`

## Historical Entries

Historical entry frontmatter may contain old `agent:` values. Do not rewrite
old evidence solely to modernize names. Prefer preserving historical records
and rebuilding indexes in the canonical profile directory.

Historical corpora may also contain over-granular continuity/fix/review notes.
Prefer adding new synthesis entries that interpret older noise instead of
editing or deleting the underlying evidence.

## Exceptions

A non-canonical profile may be created only when the user explicitly asks for a
separate durable identity. If this is required, record the reason in the
canonical parent profile and use a clear migration/retirement plan.
