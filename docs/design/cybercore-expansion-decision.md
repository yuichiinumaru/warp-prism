# CyberCore Expansion Decision

> **Task**: 1111 — CyberCore Pilot Mirror and Expansion Gate
> **Date**: 2026-06-08
> **Status**: Final
> **Decision**: PAUSE expansion and live API, mandate remediation of ADS naming contract.

## 1. Primary Decision

**Decision:** The project must **PAUSE** route expansion and **PAUSE** live API authorization. A targeted remediation wave must occur to address the ADS namespace violation, after which the project will **CONTINUE fixture-backed**. 

## 2. Rationale

The pilot evaluation (`cybercore-pilot-evaluation.md`) demonstrated that the `warp_prism_ui` Design System seamlessly fits the CyberCore domain. The route parity requirements were successfully met, and the mock-backed approach clearly proves the viability of an ASW Observatory.

However, the pilot failed the fundamental boundary contract defined in Task 1105. `apps/cybercore` directly utilizes the legacy `DS*` internal aliases instead of the mandated `Prism*` public component API. Before further features or routes are built, this drift must be corrected. If we expand now, the technical debt will scale alongside new features.

## 3. Non-Goals for Next Wave

To ensure laser focus, the following remain strictly out of scope for the immediate next wave:
1. **Live API Integration**: No live networking or HTTP clients will be built.
2. **New Routes**: No new CyberCore domain screens will be added until the 5 existing routes are strictly compliant.
3. **Data Mutation**: Read-only rules remain enforced. No state write operations.
4. **Auth Systems**: Flutter authentication flows remain deferred.

## 4. Gates for Live API Authorization

Live API authorization is **NOT GRANTED** at this time. To authorize live backend connectivity in the future, the following gates must be met:
1. **Dart SDK Availability**: CyberCore Backend Features 1300-1304 (OpenAPI generated client SDK) must be complete and published.
2. **Data Abstraction**: The Flutter app must extract `FixtureLoader` direct calls into abstract Repositories so UI code relies solely on interfaces, making the switch to HTTP clients a dependency-injection swap.
3. **Auth Availability**: Feature 1302 (Auth Endpoints Stable) must be validated.

## 5. Expansion Boundaries (Next Steps)

The immediate next boundaries for expansion—once the pause is lifted—are strictly structural:
1. **Remediation Task**: A new task must migrate `apps/cybercore` to use only `Prism*` prefixed components and tokens.
2. **Repository Abstraction Layer**: Introduce a clean architecture boundary separating data fetching from UI screens.
3. **Missing Component Build**: Fill remaining visual gaps by promoting necessary atoms/molecules (e.g., proper Datatables and Command Palettes) via strict promotion gates.
