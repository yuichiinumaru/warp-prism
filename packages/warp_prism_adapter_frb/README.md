# Warp Prism FRB Native Adapter (`warp_prism_adapter_frb`)

> **Tier**: Dart Native Adapter · **Lifecycle**: `EXPERIMENTAL`

## Overview

`warp_prism_adapter_frb` provides the Flutter Rust Bridge (FRB) projection of the native Rust substrate (`warp_bridge_core` & `warp_bridge_frb`), implementing the backend-agnostic runtime contracts defined in `package:warp_prism_runtime`.

## Boundary Laws (Layer Contracts v2)

1. **Sole FRB Consumer**: This is the **ONLY** Dart package in the Warp Prism monorepo permitted to import `package:flutter_rust_bridge`.
2. **Contract Implementation**: Exposes adapter classes (`FrbEventStream`, `FrbHealthSource`, `FrbGraphSource`, `FrbAsyncCommand`) that implement `warp_prism_runtime` interfaces.
3. **No Presentation Imports**: Visual components in `warp_prism_ui` **MUST NOT** import `warp_prism_adapter_frb` or direct FRB bindings. Application layers (`apps/`) compose UI and adapters.
