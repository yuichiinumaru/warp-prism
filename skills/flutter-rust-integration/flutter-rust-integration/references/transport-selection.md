# Transport Selection

The semantic contract should survive transport replacement.

## Embedded process

Default candidate: `flutter_rust_bridge` when:
- Flutter and Rust ship in the same desktop/mobile application;
- typed calls/async/streams are a good fit;
- native library lifecycle is acceptable.

## Native resource surface

Use for heavy media/GPU payloads where control remains via semantic commands but data is rendered/consumed natively.

## Resident daemon / sidecar

Consider typed local IPC/RPC when:
- backend must survive UI restart;
- multiple clients may connect;
- crash isolation is valuable;
- independent update/deployment is required;
- native runtime cannot safely live in the UI process.

Do not move to a daemon merely because "microservices" sounds scalable.

## Remote

Use a network protocol when the semantic owner is truly remote/distributed.

## Decision dimensions

- process lifetime;
- crash isolation;
- throughput/data placement;
- deployment/packaging;
- security boundary;
- observability;
- restart/recovery;
- multi-client needs;
- compatibility/evolution;
- testability.

Transport choice does not transfer semantic ownership.
