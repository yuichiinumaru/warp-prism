# FRI-01 — Generated binding leaked into Widget

A Flutter screen imports `frb_generated.dart` directly and calls generated Rust functions from `build()`/button callbacks. The app works today. Review the boundary and propose the smallest durable correction.
