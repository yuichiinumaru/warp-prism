# Feature Catalog: Credential Broker & Secrets

> **Series**: 400
> **EPICs**: EPIC-400, EPIC-410, EPIC-420, EPIC-430, EPIC-440, EPIC-450
> **Tasks**: 0181-0215
> **Total Features**: 35

## Features

### Crypto Primitives (400-409)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 400 | Envelope Encryption | Implement envelope encryption: data encryption key (DEK) per secret, master key (KEK) encrypts DEKs, AES-256-GCM | P0 |
| 401 | Master Key Management | Implement master key loading: from environment variable, file path, or KMS URI; fail-closed if unavailable in production | P0 |
| 402 | DEK Generation | Generate random 256-bit DEKs for each secret; store encrypted DEK alongside ciphertext | P0 |
| 403 | Key Derivation | Implement HKDF for deriving purpose-specific keys from master key: encryption, signing, HMAC | P0 |
| 404 | Timing-Safe Comparison | Implement timing-safe byte comparison for all secret/token validations: `crypto/subtle.ConstantTimeCompare` | P0 |
| 405 | Secure Random Generation | Implement secure random byte/string generation: `crypto/rand` for all security-critical randomness | P0 |
| 406 | BLAKE3-HMAC | Implement BLAKE3-HMAC for API key hashing: faster than Argon2id for high-throughput key validation | P1 |
| 407 | Key Rotation Support | Implement key rotation primitives: re-encrypt DEKs with new KEK, support multiple active KEKs during rotation | P1 |
| 408 | Crypto Audit Logging | Log all cryptographic operations (encrypt, decrypt, sign, verify) to audit trail without logging secrets | P1 |
| 409 | Crypto Self-Test | Implement crypto self-test on startup: verify encryption/decryption round-trip, hash generation, random source quality | P0 |

### Secret Store (410-419)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 410 | Secret Repository | Implement `SecretRepository` — store encrypted credentials in PostgreSQL: ID, name, provider, encrypted payload, DEK, metadata | P0 |
| 411 | Secret Create | Create secret: validate input, generate DEK, encrypt payload with DEK, encrypt DEK with KEK, persist | P0 |
| 412 | Secret Read | Read secret: retrieve encrypted payload, decrypt DEK with KEK, decrypt payload with DEK; never cache decrypted value | P0 |
| 413 | Secret Update | Update secret: re-encrypt with new DEK, update metadata, emit rotation event | P0 |
| 414 | Secret Delete | Soft-delete secret: mark as deleted, revoke all grants, retain encrypted payload for audit; hard-delete after retention period | P0 |
| 415 | Secret Listing | List secrets: return metadata only (ID, name, provider, status, created, last rotated); NEVER return decrypted values | P0 |
| 416 | Secret Types | Support secret types: API key, OAuth token pair, username/password, certificate/key, custom structured secret | P0 |
| 417 | Secret Metadata | Track secret metadata: provider, last rotated, rotation schedule, expiry, usage count, last used | P0 |
| 418 | Secret Validation | Validate secret on create: type-specific validation (e.g., API key format, OAuth token structure, certificate validity) | P1 |
| 419 | Secret Import/Export | Support secret import/export: encrypted export bundle for migration; import with re-encryption under local KEK | P2 |

### Credential Grants (420-429)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 420 | Grant Repository | Implement `GrantRepository` — map credentials to capabilities: credential ID, capability ID/set, scope restrictions, conditions | P0 |
| 421 | Grant Creation | Create grant: validate credential exists, capability exists, scope is valid, no conflicting grants | P0 |
| 422 | Grant Validation | Validate grant on use: check credential status (active, not expired), capability status, scope match | P0 |
| 423 | Grant Scoping | Support grant scopes: restrict credential to specific capabilities, capability kinds, or capability sets | P0 |
| 424 | Grant Revocation | Revoke grant: immediate effect, release active leases using this grant, emit audit event | P0 |
| 425 | Grant Listing | List grants for a credential or capability: show scope, status, usage stats | P0 |
| 426 | Grant Conditions | Support conditional grants: time-based (business hours only), subject-based (specific users/roles), workload-based | P1 |
| 427 | Grant Priority | Assign priority to grants: when multiple credentials match a capability, prefer higher priority grant | P1 |
| 428 | Grant Usage Tracking | Track per-grant usage: lease count, last used, total duration, error count | P1 |
| 429 | Grant Cascade Delete | When credential or capability is deleted, cascade to related grants; emit events for affected exposures | P0 |

### Credential Broker (430-439)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 430 | Lease Request Model | Define `LeaseRequest`: capability ID, subject, required scopes, max duration, urgency (normal, critical) | P0 |
| 431 | Lease Model | Define `CredentialLease`: ID, grant ID, credential ID, subject, acquired at, expires at, status | P0 |
| 432 | Broker: Acquire | Implement `Acquire(ctx, LeaseRequest) → CredentialLease`: find matching grant, validate, decrypt credential, create lease in Redis, return | P0 |
| 433 | Broker: Release | Implement `Release(ctx, leaseID)`: mark lease as released in Redis, update usage stats | P0 |
| 434 | Lease TTL Enforcement | Set lease TTL in Redis; auto-expire leases that are not released; emit warning events for long-running leases | P0 |
| 435 | Lease Concurrency Limit | Enforce max concurrent leases per credential: prevent credential exhaustion, queue or reject on limit | P0 |
| 436 | Lease Renewal | Support lease renewal: extend TTL before expiry without re-acquiring; validate grant still valid | P1 |
| 437 | Credential Selection Strategy | When multiple credentials match: prefer highest priority grant, then least recently used, then least loaded | P0 |
| 438 | Broker Audit Trail | Log all lease operations (acquire, release, expire, renew) to audit trail with lease ID, credential prefix, subject | P0 |
| 439 | Broker Metrics | Track broker metrics: active leases, acquisition latency, rejection rate, lease duration distribution | P1 |

### Rotation & OAuth Refresh (440-449)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 440 | Rotation Schedule | Define rotation schedule per credential: interval, next rotation time, rotation strategy (manual, automatic, on-expiry) | P1 |
| 441 | Automatic API Key Rotation | Implement automatic API key rotation: generate new key at provider, update encrypted store, grace period for old key | P1 |
| 442 | OAuth Token Refresh | Implement OAuth token refresh in credential broker: detect expiring tokens, use refresh token, update store | P1 |
| 443 | OAuth Refresh Worker | Background worker for proactive OAuth token refresh: scan for tokens expiring within window, refresh in batch | P1 |
| 444 | Rotation Event Emission | Emit outbox events on rotation: `CredentialRotated` with credential ID, old/new version, trigger descriptor recompilation | P1 |
| 445 | Rotation Failure Handling | Handle rotation failures: retry with backoff, alert on repeated failure, keep old credential active until success | P1 |
| 446 | Rotation Audit Trail | Log all rotation operations: credential ID, rotation type, success/failure, old/new version timestamps | P1 |
| 447 | Multi-Credential Rotation | Rotate multiple credentials for same provider atomically: update all grants, recompile affected descriptors | P2 |
| 448 | Rotation Notification | Emit admin notification on rotation: success/failure alerts, approaching expiry warnings | P1 |
| 449 | Credential Expiry Warning | Background check for credentials approaching expiry: 7 days, 1 day, 1 hour warnings via audit events | P1 |

### Redaction & Secret Scanning (450-456)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 450 | Log Redaction | Implement log redaction: scan structured log fields for patterns matching secrets (API keys, tokens, passwords), replace with `[REDACTED]` | P0 |
| 451 | Response Redaction | Implement API response redaction: ensure no credential values appear in any API response body or headers | P0 |
| 452 | Error Message Redaction | Implement error message redaction: scrub credential fragments from error messages before logging or returning to client | P0 |
| 453 | Secret Pattern Scanner | Implement pattern scanner for common secret formats: `sk-`, `cc_live_`, `ghp_`, `Bearer `, base64-encoded blobs, PEM blocks | P0 |
| 454 | Redaction Test Suite | Comprehensive test suite: verify no secrets leak through logs, errors, API responses, stack traces, debug endpoints | P0 |
| 455 | Audit Trail Redaction | Verify audit trail records contain credential lease IDs but NEVER decrypted credential values | P0 |
| 456 | Redaction Performance | Benchmark redaction: ensure log-path redaction adds < 1μs per log entry; response redaction adds < 100μs per response | P1 |
