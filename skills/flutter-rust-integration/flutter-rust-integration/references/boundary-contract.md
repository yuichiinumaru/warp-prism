# Boundary Contract Template

Use only for nontrivial boundaries where externalizing the contract reduces ambiguity.

```yaml
boundary_contract:
  semantic_owner: rust

  topology:
    mode: embedded
    transport: flutter_rust_bridge
    replaceable: true

  dart:
    semantic_adapter: packages/example_adapter/lib
    generated_imports_allowed_from:
      - packages/example_adapter/lib/src/frb

  rust:
    semantic_core: crates/example_core
    bridge_adapter: crates/example_frb
    domain_transport_free: true

  control_plane:
    commands:
      - execute
      - cancel
    streams:
      - execution_events
    snapshots:
      - health
    handles:
      - asset_id

  data_plane:
    native:
      - decoded_frames
    strategy:
      decoded_frames: native_surface

  lifecycle:
    cancellation:
      owner: rust
      request_origin: dart
      terminal_state_required: true
    resources:
      decoded_frame_surface:
        owner: rust
        release: explicit

  failures:
    semantic_model:
      - invalid_command
      - unavailable
      - cancelled
      - internal

  evidence:
    require:
      - static_boundary
      - codegen_repro
      - native_call
      - native_stream
      - native_cancellation
      - real_host
```

The exact schema is not constitutional. Adapt it to project reality.

A Boundary Contract is evidence/decision support, not permission to mutate files or grant review acceptance.
