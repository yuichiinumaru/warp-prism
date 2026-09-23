# FRI-06 — Rust domain depends on FRB

`project_core` contains domain state and persistence but directly imports `flutter_rust_bridge` annotations/types throughout its public API because that made codegen easy. What is wrong, if anything?
