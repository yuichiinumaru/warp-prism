# flutter_rust_bridge — Current Practice Reference

**Volatile reference. Verify against the project's pinned FRB runtime/codegen versions and current primary documentation before mutation.**

This file intentionally avoids freezing CLI/config details that may change.

## Stable expectations

- Runtime/package/codegen versions must be mutually coherent under the project's dependency policy.
- Generated bindings are generated artifacts; do not hand-edit them.
- The semantic Rust core should remain transport-independent where practical.
- Generated Dart APIs should be contained behind an adapter rather than imported throughout the UI.
- Async/stream/error/resource projections require lifecycle-aware design, not only successful codegen.
- Clean regeneration/drift should be part of evidence when generated surfaces change.
- Codegen success is not runtime proof.
- Native library load is not semantic integration proof.
- FRB is a transport adapter, not the canonical product model.

## Before changing FRB configuration

Route to `dependency` and collect:

```text
Flutter version
Dart version
rustc/cargo version
FRB Dart/runtime package version
FRB Rust crate version
FRB codegen version
current generated artifact metadata
```

Then consult current official FRB documentation/changelog for that version line.

## Native Assets / Build Integration

Treat any FRB/native-assets/build-hook path as version-sensitive. Evaluate maturity and actual target-platform behavior rather than assuming the newest mechanism is universally appropriate.

## Escape Hatches

When FRB does not project a semantic type cleanly, consult `implement-frb`'s typed projection ladder before falling back to serialized strings.
