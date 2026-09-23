# Adoption Notes — `flutter-rust-integration`

This package is intentionally **candidate**, not active law.

## Recommended install

Copy:

```text
flutter-rust-integration/
```

to:

```text
.agents/skills/flutter-rust-integration/
```

Then route through the repository's normal harness mutation / candidate → eval → independent review → activation process.

## Required adjacent routing changes after admission

Do not duplicate doctrine. Add pointers only.

### `flutter/SKILL.md`

Add a negative/cross trigger approximately:

```text
Flutter↔Rust/native boundary design, FRB transport, cross-boundary lifecycle,
or native data-plane concerns
→ flutter-rust-integration
```

Pure Flutter implementation remains under `flutter`.

### `rust/SKILL.md`

Replace overly broad "Flutter/Dart → flutter" behavior with:

```text
pure Flutter/Dart → flutter
pure Rust → rust
Flutter↔Rust boundary → flutter-rust-integration
```

### `api-design`

No ownership change. `flutter-rust-integration` routes public semantic Dart/Rust contracts there.

### `dependency`

No ownership change. Keep FRB version tuple, pub/Cargo/lockfile/toolchain/codegen mutation policy there.

### `code-quality`

Do not create a competing integration review doctrine. Reviewers may load this skill as domain praxis and grant narrow boundary clearances; code-quality retains verdict/acceptance ownership.

## Suggested Rust upgrade (separate task)

Create:

```text
rust/sub-skills/design-ffi-boundaries/SUBSKILL.md
```

Owner:
- ABI / `repr(C)`
- foreign ownership/allocation/free symmetry
- callbacks/foreign threads
- panic containment
- handles/stale handles
- buffer/string representation
- dynamic library/resource lifetime
- FFI-facing error transport

Keep `rust/unsafe-soundness` focused on:
- aliasing/raw pointers
- transmute
- uninitialized memory
- Pin invariants
- custom Send/Sync
- unsafe block proof
- Miri/Kani

Relationship:

```text
flutter-rust-integration
→ designs the Flutter↔Rust seam

rust/design-ffi-boundaries
→ proves/designs the foreign Rust ABI/resource boundary

rust/unsafe-soundness
→ audits unsafe invariants inside that implementation
```

## Activation checks

Before changing `maturity: candidate`:

1. Run FRI-01..08 treatment/control.
2. Verify the candidate improves the expected distinctions without over-routing.
3. Run script unit tests.
4. Run harness/lobe-gateway validator.
5. Check root index == physical subskills.
6. Check no nested `SKILL.md` exists below the root.
7. Check relative links.
8. Independent harness review.
9. Apply routing pointers to Flutter/Rust only after the skill is admitted.
