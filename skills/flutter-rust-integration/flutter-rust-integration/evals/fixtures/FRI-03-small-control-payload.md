# FRI-03 — Small control payload counterfactual

Rust emits a compact `PlaybackPosition { micros: i64, playing: bool }` around 10 times/second to Flutter. Someone argues all cross-boundary streams are bad and it must become shared memory. Evaluate.
