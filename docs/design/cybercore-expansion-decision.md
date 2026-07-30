# CyberCore Expansion Decision

> **Task**: 1111 — CyberCore Pilot Mirror and Expansion Gate  
> **Date**: 2026-07-09 (post-1110 realign re-decision; supersedes same-day PAUSE for absent pilots)  
> **Status**: Active decision  
> **Evaluation**: `docs/design/cybercore-pilot-evaluation.md` (same-day post-realign)  
> **Decision**: **EXPAND** deferred routes (conditional, fixture-backed) · **DENY** live API · pilot A/B/C **PASS**

## 1. Primary decision (binary)

| Decision axis | Verdict | One-line rationale |
| --- | --- | --- |
| **Pilot A/B/C gate** | **PASS** | Routes, pages, pilot-domain fixtures, and minimum tests present (3/3) |
| **Expand beyond pilot routes** | **EXPAND (conditional)** | One deferred live-CC route at a time, still fixture-backed; no Observatory invent |
| **Authorize live CyberCore API** | **DENIED** | No repository abstraction; UI hard-binds `FixtureLoader`; auth/SDK gates open |
| **Continue fixture-backed development** | **CONTINUE** | Authorized as the only data plane for next wave |
| **Companion admin app / replacement** | **REJECTED** (unchanged from 1108) | First wave remains read-only mirror |
| **ADS Prism\* remediation wave** | **NOT REQUIRED** | Namespace gate is PASS |

**Headline:** The pilot **proves** ADS consumption against real CyberCore IA. Route expansion may proceed **only** as fixture-backed deferred routes from the 1108 matrix. Live networking remains **closed**.

---

## 2. Rationale (evidence-backed)

1. **Task 1108 authority:** First-wave MVP = Pilot A `/providers`, Pilot B `/mcp-servers` + `/mcp-inspector`, Pilot C `/live-logs`.
2. **Task 1110 reality (post realign):** `apps/cybercore` implements exactly those pilot routes (plus nested provider/MCP detail). Observatory-proxy paths are not registered. Scoped tests **16/16 PASS**.
3. **ADS health:** **PASS** — zero `DS*` under `apps/cybercore/lib`; ~183 `Prism*`; path dep on `warp_prism_ui`.
4. **Fixtures:** Runtime JSON is pilot domain (providers / MCP / inspector / live logs). Design docs (`cybercore-fixture-schema.md`, parts of 1109 inventory) still describe ASW shapes → **doc residual**, not pilot FAIL.
5. **Therefore:** Pausing for “missing pilots” is no longer justified. Authorizing live HTTP is still unjustified.

---

## 3. Gates

### 3.1 Expand-routes gate — **MET** (conditional continue)

All minimum criteria from the prior pause document are now true:

1. Flutter routes include `/providers`, `/mcp-servers`, `/mcp-inspector`, `/live-logs` (+ nested A/B detail).
2. Fixtures exist under `apps/cybercore/assets/cybercore_fixtures/` for those domains.
3. Widget tests cover shell + Pilot A happy path + Pilot A non-happy + nav to Pilot C; unit tests cover A/B/C models.
4. This 1111 re-evaluation scores pilots A/B/C **PASS**.

**Conditional constraints on expansion:**

| Rule | Enforcement |
| --- | --- |
| Only routes classified **defer** in Task 1108 live matrix | e.g. `/llm-endpoints`, `/combos`, `/usage`, `/costs` — not invented paths |
| One new surface (or tightly coupled pair) per task | No big-bang admin rewrite |
| Fixture-backed only | No network clients until §3.2 closes |
| Prefer source-backed `page.tsx` evidence | Same discipline as 1102/1108 |
| Prefer ADS reuse over app-local widgets | Path dep `warp_prism_ui` only |

### 3.2 Live API authorization gates — **still closed**

Live API authorization remains **DENIED** until **all** are true:

| # | Gate | Status now |
| --- | --- | --- |
| 1 | Pilot routes A/B/C implemented fixture-backed and gate-green | **Closed / PASS** |
| 2 | Repository / data abstraction so UI does not hard-bind to `FixtureLoader` | **Open** |
| 3 | Task 1109 design docs refreshed for pilot DTOs + live read-model mapping tables | **Partial / open** (runtime ahead of docs) |
| 4 | Auth posture defined (session/admin); Flutter auth deferred series closed or waived | **Open** |
| 5 | Explicit integration task authorizes network clients (not 1110/1111) | **Not started** |
| 6 | Mutations remain off unless a separate mutation-safety task authorizes them | **Enforced** |

No partial “call only health” exception is granted by this gate.

---

## 4. Non-goals for the next wave

1. **No live networking** in Flutter CyberCore.
2. **No data mutation** (display of import/test outcomes as fixture data only).
3. **No auth implementation** unless a dedicated auth task opens.
4. **No `DS*` remediation task** for `apps/cybercore` (already Prism*).
5. **No claim** that Observatory `/tasks` board is CyberCore Operate parity (Task 1102 rejects candidate X).
6. **No reintroduction** of Observatory-proxy primary routes as pilots.
7. **No replacement** of Next.js CyberCore frontend.
8. **No screenshots invented** — screenshot packet remains optional/absent per 1102 DoD.
9. **No bulk expansion** of all deferred routes in one task.

---

## 5. Expansion boundaries (ordered next steps)

| Order | Action | Owner task class |
| --- | --- | --- |
| 1 | Optional: refresh 1109 fixture-schema + inventory to document pilot DTOs (close doc drift) | Task 1109 follow-on / docs |
| 2 | Optional: deepen B/C widget tests (list happy path + empty) | Task 1110 residual or test hardening |
| 3 | First deferred route (recommended candidates: `/llm-endpoints` or `/combos` per 1108 matrix) | New implementation task |
| 4 | Repository abstraction + client interface (still fixture default) | Integration prep task |
| 5 | Only after §3.2: live client wiring | Integration task |

---

## 6. Decision record

| Field | Value |
| --- | --- |
| **Decision** | **EXPAND (conditional, fixture-backed) · DENY live API · ADS namespace PASS · pilots PASS** |
| **Primary blocker (prior)** | Route parity: pilots A/B/C absent — **resolved by Task 1110 realign** |
| **Primary remaining blocker for live API** | No repository abstraction + auth/SDK + explicit integration task |
| **Non-blocker (corrected)** | `DS*` vs `Prism*`; Observatory shell quality |
| **Revisit trigger (live API)** | Integration task lands §3.2 gates 2–5 |
| **Author** | docs + light reviewer · Task 1111 · 2026-07-09 post-realign |

---

## 7. Supersession

| Prior decision | Disposition |
| --- | --- |
| 2026-06-08 pause for ADS naming | **Superseded** — Prism* PASS |
| 2026-07-09 early PAUSE for missing A/B/C | **Superseded** — pilots implemented; this document **EXPAND**s fixture-backed deferred routes |
| Live API DENIED | **Retained** with updated gate table |
