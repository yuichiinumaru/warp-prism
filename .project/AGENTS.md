# `.project/` — Project-Local State and Records

This file is the project-local overlay for organizing records under this
repository's `.project/` root. The repository's root `AGENTS.md` and applicable
active rules remain higher authority. This template does not assume which
product, mission, milestones, tools, or `.project/` surfaces exist in a target
repository.

## Ownership and discovery

- `.project/` holds this project's durable state; it is not shared state and
  must not point at or depend on another repository's `.project/` tree.
- Keep project-specific context and overlays here. Reusable agent capabilities
  remain owned by the available harness under `.opencode/`.
- Add a surface to this repository's documented project-state inventory only
  after verifying that it exists and identifying its owner.
- The presence of this template does not require creating every possible
  `.project/` subdirectory.

## Tasks and other records

When this project uses task lanes, `.project/tasks/AGENTS.md` governs the local
task subtree and `.project/tasks/000-template.md` is the installed local task
template. The repository root `AGENTS.md` remains the higher project authority.
Treat reports, memories, sessions, and completed task ledgers as historical
records; do not regenerate or rewrite them as part of routine policy changes.

## Generated records

Before changing a generated projection, identify and verify its current owner
and generator in this repository. Do not infer commands or assume that a
generator, task-ID allocator, milestone file, or other tooling exists merely
because another project has one.
