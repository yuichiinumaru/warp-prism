# Docs Folder Lifecycle and Indexing Rule

> **Status**: Binding pointer rule.  
> **Canonical guide**: `docs/guides/docs-folder-lifecycle-and-indexing.md`  
> **Source Task**: `AD-ganthritor-docs-folder-lifecycle-indexing-rule`

Agents working on `docs/` MUST follow `docs/guides/docs-folder-lifecycle-and-indexing.md` before proposing or executing documentation reorganization.

Minimum binding requirements:

1. Classify docs by authority/lifecycle before using file counts as evidence.
2. Treat folder-size thresholds as review triggers, not automatic move/delete instructions.
3. Preserve generated ledgers, append-only ledgers, task lanes, raw corpora, and child-project provenance unless a scoped task explicitly authorizes a path-level change.
4. Do not manually edit generated changelog/tasklist surfaces.
5. Do not add new entries to legacy project-local changelogs such as `docs/omniroute/changelog/`; use the parent changelog engine under `docs/changelog/`.
6. Any broad reorganization requires a separate task with exact paths, collision checks, validation commands, changelog evidence, and rollback/restore instructions.

This rule intentionally delegates detailed examples, owner matrices, metadata conventions, and lifecycle classes to the canonical guide to avoid policy drift.
