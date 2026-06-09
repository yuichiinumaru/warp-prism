# SQLite Abolition Policy

> **Status**: Active  
> **Effective**: 2026-05-24  
> **Origin**: User directive after OmniRoute runtime performance investigation  
> **Cross-ref**: `AGENTS.md` § maximum priority directives

---

## Policy

**Runtime SQLite usage is prohibited across all Ganthritor-family projects.**

| State Type | Required Backend | Rationale |
|-----------|-----------------|-----------|
| Durable state | PostgreSQL | ACID, concurrent access, no file locking |
| Cache/ephemeral | Redis | In-memory, pub/sub, no disk I/O contention |
| Local-only dev tools | SQLite (excepted) | Desktop-only, never in server mode |
| External app DB reads | SQLite (excepted) | Reading Cursor/Zed/etc DBs, not our state |

## Scope

Projects covered:
- **OmniRoute** — Primary migration target (tasks 0636-0642)
- **Cybernetics Core** — PostgreSQL via Drizzle ORM
- **ganthritor-rs** — Memory crates (migration planned)
- **Khala Code** — SurrealDB migration planned (task 7496)
- **OpenCode** — Fork; upstream SQLite residue remains scanned and must be exception-listed
- **oh-my-openagent** — Third-party plugin; present paths remain scanned and must be exception-listed

## Exception Process

1. Add entry to `.agents/rules/sqlite-abolition-exceptions.json`
2. Each exception requires: `path`, `owner`, `reason`, `removal_task`, `expiry`, `reviewer`
3. Exceptions without `expiry` are permanent (migration tools, audit scripts, enforcement gates)
4. Exceptions with `removal_task` must be retired when the referenced task completes
5. When the scanner reports an unreachable exception path, verify that the path is absent before
   removing the stale JSON record. If an actual deprecated file still exists, move it to `.archive/`
   under the repository archive protocol rather than deleting it.

## Audit

Run the audit to verify compliance:

```bash
bash .agents/rules/scripts/audit-sqlite-abolition.sh          # Quick check
bash .agents/rules/scripts/audit-sqlite-abolition.sh --verbose # Detailed output
```

The shell command is a compatibility launcher. The single authoritative scanner is
`OmniRoute/scripts/sqlite-abolition-scanner.ts`; it normalizes child-workspace invocations to the
canonical Ganthritor root when the policy sentinel is reachable, scans OmniRoute (`src/`,
`open-sse/`, and `scripts/`) plus known family workspaces, and reports unreachable exception paths
as diagnostics. Confirmed stale diagnostics must be retired from the exception ledger so the
reported inventory remains current. Exit code 0 = compliant. Exit code 1 = forbidden runtime
SQLite or invalid exception schema detected.

## Classification

| Category | Description | Action |
|----------|-------------|--------|
| `forbidden_runtime` | Active runtime SQLite not in exception list | Must migrate or add exception |
| `allowed` | In exception list with owner/justification | Review at expiry |
| `migration_only` | Import/export/migration compatibility code | Keep until migration complete |
| `test_fixture` | Test-only references | Acceptable |
| `docs_only` | Documentation, changelogs, comments | Acceptable |
