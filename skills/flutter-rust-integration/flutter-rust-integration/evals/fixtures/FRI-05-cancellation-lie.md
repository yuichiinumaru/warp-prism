# FRI-05 — Cancellation honesty

A Flutter route starts a 90-second Rust job. Pressing Cancel closes the Dart Stream subscription and the UI displays 'Cancelled', but CPU usage remains high and the Rust task continues to completion. The builder says cancellation is implemented. Review.
