---
name: route-data-plane
parent: flutter-rust-integration
description: |
  Route heavy Flutter↔Rust payloads deliberately: media frames, PCM, tensors, GPU/native
  surfaces, large buffers, files, shared memory, rings, handles, and bounded copies.
triggers:
  - flutter rust zero copy
  - native texture rust flutter
  - pcm flutter rust
  - video frame flutter rust
  - tensor flutter rust
  - gpu surface flutter
  - shared memory flutter rust
metadata:
  owner: flutter-rust-integration
  maturity: candidate
  implementation_kind: full
  inputs:
    - payload size/rate/lifetime
    - producer and consumer locations
    - platform/runtime capabilities
  outputs:
    - data placement decision
    - transfer mechanism and ownership plan
    - measurement/evidence plan
  side_effects: [none]
  evidence_required:
    - measured or bounded payload characteristics
    - profiling/benchmark evidence for performance-sensitive claims
  completion_signal: "Heavy data has an explicit physical owner/location, transfer strategy, lifetime, and measurement plan; zero-copy is not assumed as a correctness requirement."
---

# Route Data Plane

**Data location is architecture.**

## First Classification

Ask:

```text
payload size × frequency × fanout × copy cost × lifetime
```

Small/occasional control-plane data can cross normally.

High-throughput/realtime/native data needs a data-plane decision.

## Common Strategies

### Native handle / opaque identity

Best when the consumer needs to refer to a resource, not own its bytes.

Examples: native decoder object, model session, media asset, GPU resource.

### Native/Flutter texture or surface

Preferred for decoded visual data when platform support allows rendering without
round-tripping full frames through Dart.

### Ring buffer / bounded queue

Useful for realtime producer/consumer flows such as audio/telemetry where bounded
capacity and drop/backpressure policy can be explicit.

### Shared memory / mapped region

Useful only when lifecycle, synchronization, security, portability, and cleanup are
clear. Do not adopt merely because "zero copy" sounds optimal.

### File-backed exchange

Often simplest for large durable/intermediate artifacts that do not require realtime
latency.

### Bounded copy

A valid fallback. A bounded, measured copy is better than unsafe or opaque zero-copy
machinery whose ownership cannot be proven.

## Zero-Copy Rule

> Zero-copy is an optimization target, not an authority to violate ownership,
> lifecycle clarity, portability, or correctness.

## Smells

- 4K frames serialized into Dart lists at frame rate.
- Realtime PCM repeatedly allocated/converted as high-level Dart collections.
- GPU resources copied to CPU only to cross the bridge and copied back.
- Huge tensors/materialized model data crossing only to display tiny metadata.
- No backpressure on high-frequency stream data.
- An "optimization" that cannot state who frees the buffer.

## Measurement

For performance claims measure the actual relevant property:

- bytes/sec crossing;
- copies per item;
- allocation rate;
- latency and tail latency;
- frame/audio deadline misses;
- CPU/GPU synchronization cost;
- memory pressure;
- GC impact on the Flutter side.

Do not accept architectural performance claims solely from static reasoning when a
representative measurement is feasible.
