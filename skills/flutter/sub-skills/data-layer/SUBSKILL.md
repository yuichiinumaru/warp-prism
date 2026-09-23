---
name: data-layer
parent: flutter
description: Design and audit Flutter repositories/services/datasources, API clients, persistence boundaries, migrations, DTO mapping, caching, offline behavior, and data-boundary tests according to project architecture.
---

# Flutter Data Layer

Use this route for Flutter-side API/data access, DTO mapping, persistence,
caching/offline behavior, migrations, and data-boundary tests.

## Project Policy Boundary

This subskill does **not** choose a product-wide database merely because the
project belongs to the Ganthritor family.

Read the active project/family rules for canonical source-of-truth and persistence
policy. Flutter local persistence may be a cache, offline store, user setting,
fixture, import/export surface, or canonical local state depending on the
product's declared architecture.

The reusable Flutter rule is:

> persistence role, ownership, durability, synchronization, and migration
> semantics must be explicit.

## Data Axioms

- **Separate semantic state from transport/storage representation.** Map external
  DTO/record shapes at a boundary rather than leaking them through the UI.
- **Encapsulate technology-specific access.** HTTP/database/plugin/file APIs
  should sit behind a project-appropriate service/repository/datasource boundary
  when direct use would spread infrastructure concerns.
- **One source of truth per semantic state.** Caches/projections must state their
  staleness/refresh/conflict policy.
- **Failure semantics are explicit.** Do not use `null` as an undocumented
  universal failure channel.
- **Migrations require evidence** when persisted data/schema compatibility can be
  affected.
- **Client bundles are not trusted secret stores.** Privileged secrets/operations
  stay outside distributable clients.

## Checklist

- [ ] API parsing handles missing/extra/null fields per contract.
- [ ] Domain/UI surfaces are not accidentally coupled to persistence records.
- [ ] Source-of-truth/cache/offline ownership is explicit.
- [ ] Retry/idempotency/conflict behavior is appropriate to mutation semantics.
- [ ] Persistence choices comply with active project/family authority.
- [ ] Migration/compatibility proof exists where shipped data can be affected.
- [ ] Sensitive local data has an explicit threat/storage policy.

## Common Smells

- Widget directly owns durable storage/network protocol details.
- Same semantic object is independently mutable in multiple stores/layers.
- Persistence annotation/schema becomes the public domain model by accident.
- Non-idempotent mutation is retried blindly.
- Local cache is treated as authoritative without a declared ownership rule.
- Reference-repo architecture (for example one mandatory repository/datasource
  pattern) is imposed on a codebase that uses another valid boundary.

## Implementation Guidance

Follow the current project architecture. A repository/datasource split is a
useful pattern when it clarifies policy versus mechanism, but it is not a
universal naming or layering mandate.

When the project uses Hive/Drift/SQLite/files/secure storage or another local
mechanism, verify:
- data ownership;
- migration compatibility;
- serialization/schema stability;
- encryption/threat requirements where applicable;
- test coverage for recovery/corruption/empty/failure paths appropriate to the
  risk.

When the Flutter app talks to a remote backend, keep server-only authority and
credentials off the client and make cache/refresh/conflict semantics explicit.
