# Feature Catalog: Identity & Authentication

> **Series**: 200
> **EPICs**: EPIC-200, EPIC-210, EPIC-220, EPIC-230, EPIC-240, EPIC-250, EPIC-260, EPIC-270, EPIC-280
> **Tasks**: 0096-0145
> **Total Features**: 50

## Features

### User Management (200-209)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 200 | User Domain Model | Define `User` entity: ID, email, display name, role (admin/operator/viewer), status (active/suspended/deleted), timestamps | P0 |
| 201 | User Repository | Implement `UserRepository` — Create, GetByID, GetByEmail, Update, List, SoftDelete with PostgreSQL | P0 |
| 202 | Password Hashing | Implement password hashing with Argon2id: configurable memory, iterations, parallelism; timing-safe comparison | P0 |
| 203 | User Creation Use Case | Implement `CreateUser` use case: validate input, check email uniqueness, hash password, persist, emit audit event | P0 |
| 204 | User Update Use Case | Implement `UpdateUser` use case: validate input, check authorization, update fields, emit audit event | P0 |
| 205 | User Suspension | Implement user suspension: suspend/reactivate user, revoke all active sessions on suspension | P1 |
| 206 | User Roles | Implement role-based access: admin (full), operator (manage capabilities/exposures), viewer (read-only) | P0 |
| 207 | User Listing & Filtering | Implement paginated user listing with filters: role, status, email search, created date range | P1 |
| 208 | User Soft Delete | Implement soft delete: mark user as deleted, revoke sessions/API keys, retain for audit trail | P1 |
| 209 | Initial Admin Bootstrap | Create initial admin user from environment variables on first startup if no users exist | P0 |

### Session Management (210-219)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 210 | Session Domain Model | Define `Session` entity: ID, user ID, token hash, IP address, user agent, created, expires, last active | P0 |
| 211 | Session Repository | Implement `SessionRepository` — Create, GetByToken, GetByUserID, Revoke, RevokeAll, CleanupExpired | P0 |
| 212 | Session Creation | Create session on successful authentication: generate cryptographically random token, hash for storage, set TTL | P0 |
| 213 | Session Validation | Validate session on each request: check token hash, verify not expired, update last active timestamp | P0 |
| 214 | Session Revocation | Revoke individual session or all sessions for a user; immediate effect via token invalidation | P0 |
| 215 | Session Cleanup Worker | Background worker to delete expired sessions from database on configurable interval | P1 |
| 216 | Session Redis Cache | Cache active sessions in Redis for fast validation; invalidate on revocation | P1 |
| 217 | Concurrent Session Limit | Configurable max concurrent sessions per user; evict oldest session when limit exceeded | P2 |
| 218 | Session Fingerprinting | Track session metadata (IP, user agent) for anomaly detection; warn on significant changes | P2 |
| 219 | Session Activity Log | Log session activity (creation, validation, revocation) to audit trail | P1 |

### API Key Management (220-229)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 220 | API Key Domain Model | Define `APIKeyRecord`: ID, prefix (first 8 chars), hash (Argon2id/BLAKE3-HMAC), name, user ID, scopes, rate limit, expires, status | P0 |
| 221 | API Key Repository | Implement `APIKeyRepository` — Create, GetByPrefix, GetByUserID, Revoke, List, CleanupExpired | P0 |
| 222 | API Key Generation | Generate API key: `cc_live_` or `cc_test_` prefix + 40 random bytes base62 encoded; show full key ONCE on creation | P0 |
| 223 | API Key Hash Storage | Hash API key with Argon2id for storage; store prefix for lookup; NEVER store or log full key after creation | P0 |
| 224 | API Key Validation | Validate API key: extract prefix, lookup record, hash-compare with timing-safe comparison, check expiry/status/scopes | P0 |
| 225 | API Key Scopes | Define key scopes: `chat:*`, `models:read`, `admin:*`, `mcp:*`, custom scopes; validate scope on each request | P0 |
| 226 | API Key Rate Limits | Per-key rate limit configuration: requests/minute, tokens/day, concurrent requests; enforced via Redis | P0 |
| 227 | API Key Rotation | Support key rotation: create new key, grace period where both old and new work, revoke old key | P1 |
| 228 | API Key Expiry | Support key expiry: configurable TTL, background cleanup of expired keys, warning events before expiry | P1 |
| 229 | API Key Usage Tracking | Track per-key usage: request count, token count, cost, last used timestamp; available via admin API | P1 |

### OAuth Token Management (230-239)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 230 | OAuth Token Storage | Store OAuth tokens (access + refresh) encrypted in PostgreSQL with provider, scopes, expiry | P1 |
| 231 | OAuth Token Refresh | Implement automatic token refresh: detect expiring tokens, refresh before expiry, update stored tokens | P1 |
| 232 | OAuth Token Refresh Worker | Background worker that scans for tokens expiring within configurable window and proactively refreshes | P1 |
| 233 | OAuth Provider Config | Define OAuth provider configuration: client ID/secret (encrypted), auth URL, token URL, scopes, redirect URI | P1 |
| 234 | OAuth Authorization Flow | Implement OAuth 2.0 authorization code flow: redirect to provider, handle callback, exchange code for tokens | P1 |
| 235 | OAuth PKCE Support | Implement PKCE (Proof Key for Code Exchange) for OAuth flows to prevent authorization code interception | P1 |
| 236 | OAuth Token Revocation | Implement token revocation: revoke at provider, delete locally, update credential status | P1 |
| 237 | OAuth State Management | Generate and validate cryptographic state parameter for OAuth flows; prevent CSRF in OAuth callbacks | P1 |
| 238 | OAuth Multi-Provider | Support multiple OAuth providers simultaneously: GitHub, Google, custom OIDC; per-user provider linking | P2 |
| 239 | OAuth Token Encryption | Encrypt OAuth tokens at rest using envelope encryption; decrypt only when needed for API calls | P1 |

### CSRF Protection (240-244)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 240 | CSRF Token Generation | Generate per-session CSRF tokens using cryptographically secure random bytes | P0 |
| 241 | CSRF Middleware | Implement CSRF middleware: validate token on state-changing requests (POST/PUT/DELETE), reject on mismatch | P0 |
| 242 | CSRF Double Submit Cookie | Implement double-submit cookie pattern: set CSRF token in cookie + require in header/body | P0 |
| 243 | CSRF SameSite Cookie | Set `SameSite=Strict` on session cookies; `SameSite=Lax` on CSRF cookies | P0 |
| 244 | CSRF API Key Bypass | Skip CSRF validation for API key authenticated requests (API keys are inherently CSRF-safe) | P0 |

### Auth Middleware (250-259)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 250 | Authentication Middleware | Implement authentication middleware: extract credentials from Authorization header, validate, set subject in context | P0 |
| 251 | Bearer Token Auth | Support `Bearer` token authentication: session tokens and API keys | P0 |
| 252 | API Key Auth Header | Support API key in `Authorization: Bearer cc_live_...` and `X-API-Key` headers | P0 |
| 253 | Auth Context Propagation | Set authenticated `Subject` in request context; available to all downstream handlers | P0 |
| 254 | Authorization Middleware | Implement authorization middleware: check subject's role/scopes against required permissions for endpoint | P0 |
| 255 | Rate Limit Middleware | Implement per-subject rate limiting middleware: check Redis rate counters, return 429 with Retry-After header | P0 |
| 256 | Request ID Middleware | Generate unique request ID, set in context and response header `X-Request-ID`, propagate to all internal calls | P0 |
| 257 | Audit Logging Middleware | Log all authenticated requests: subject, action, resource, IP, user agent, request ID, timing | P0 |
| 258 | CORS Middleware | Implement CORS middleware: configurable allowed origins (NO wildcard in production), methods, headers, credentials | P0 |
| 259 | IP Allow/Deny Middleware | Optional IP-based access control: configurable allow/deny lists per exposure or globally | P2 |

### Admin Identity Endpoints (260-269)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 260 | POST /admin/users | Create user endpoint: validate input, create user, return user (without password) | P0 |
| 261 | GET /admin/users | List users endpoint: paginated, filtered by role/status, admin only | P0 |
| 262 | GET /admin/users/:id | Get user by ID endpoint: return user details, admin or self only | P0 |
| 263 | PUT /admin/users/:id | Update user endpoint: update fields, admin only (except self-update of display name) | P0 |
| 264 | DELETE /admin/users/:id | Soft delete user endpoint: mark deleted, revoke sessions/keys, admin only | P1 |
| 265 | POST /admin/api-keys | Create API key endpoint: generate key, return full key ONCE, store hash only | P0 |
| 266 | GET /admin/api-keys | List API keys endpoint: return prefix, name, scopes, status (never full key) | P0 |
| 267 | DELETE /admin/api-keys/:id | Revoke API key endpoint: mark as revoked, immediate effect | P0 |
| 268 | POST /auth/login | Login endpoint: validate credentials, create session, return session token | P0 |
| 269 | POST /auth/logout | Logout endpoint: revoke current session, clear cookies | P0 |

### Security Tests (270-279)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 270 | API Key Hash/Verify Tests | Test API key generation, hashing, and verification: correct hash, wrong key rejection, timing-safe comparison | P0 |
| 271 | Password Hash Tests | Test password hashing: correct verification, wrong password rejection, different hashes for same password | P0 |
| 272 | Session Lifecycle Tests | Test session creation, validation, expiry, revocation, cleanup | P0 |
| 273 | CSRF Protection Tests | Test CSRF token generation, validation, rejection of missing/invalid tokens, API key bypass | P0 |
| 274 | Auth Middleware Tests | Test authentication middleware: valid token, expired token, invalid token, missing token, wrong scheme | P0 |
| 275 | Authorization Tests | Test authorization: admin access, operator restrictions, viewer restrictions, scope enforcement | P0 |
| 276 | Rate Limit Tests | Test per-subject rate limiting: under limit, at limit, over limit, reset after window | P0 |
| 277 | Timing Attack Tests | Verify timing-safe comparison for API keys and passwords: consistent timing regardless of match position | P1 |
| 278 | Token Entropy Tests | Verify session tokens and API keys have sufficient entropy: minimum 256 bits of randomness | P1 |
| 279 | Concurrent Auth Tests | Test concurrent authentication: race conditions in session creation/revocation, API key creation/revocation | P1 |

### Service-to-Service Auth (280-285)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 280 | Internal Service Token | Implement internal service-to-service authentication: shared HMAC-signed tokens for inter-service calls | P1 |
| 281 | Runner Authentication | Implement runner-to-API authentication: runner presents signed token to validate sandbox execution results | P1 |
| 282 | Worker Authentication | Implement worker-to-API authentication: worker validates identity when calling internal APIs | P1 |
| 283 | Service Token Rotation | Support service token rotation: configurable rotation interval, overlapping validity window | P2 |
| 284 | mTLS Support | Optional mTLS for service-to-service communication: certificate-based mutual authentication | P2 |
| 285 | Service Identity Validation | Validate service identity claims against registered service catalog; reject unknown services | P2 |
