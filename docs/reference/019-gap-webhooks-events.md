# Feature Catalog: Gap — Webhooks & Events

> **Series**: 1900
> **EPICs**: EPIC-1900 (Webhook Dispatcher), EPIC-1910 (Event Subscriptions), EPIC-1920 (External Notifications)
> **Gap Source**: diegosouza-omniroute (HMAC-signed webhook delivery, 7 event types, exponential backoff)
> **Total Features**: 25

## Gap Analysis Summary

Our catalog has an event bus skeleton (1B4-1B5), outbox pattern (1B0-1B3), SSE admin events (1100-1109), and budget alert webhook (81D at P2). However, we lack:

- **External webhook dispatcher** — delivering events to external HTTP endpoints
- **Webhook HMAC signing** — cryptographic verification of webhook authenticity
- **Webhook retry management** — exponential backoff, dead letter queue
- **Webhook subscription management** — per-subscriber event type filtering, URL configuration
- **Webhook delivery tracking** — delivery status, retry history, failure alerts

The diegosouza reference has a full webhook system with 7 event types, HMAC-signed delivery, and exponential backoff retry.

## Classification Guide

- **CORE**: Webhook dispatcher with HMAC signing — needed for external integration
- **EXTENDED**: Advanced delivery management, dead letter queue, subscription filtering
- **ECOSYSTEM**: Webhook marketplace, third-party integrations

---

## Features

### Webhook Dispatcher (1900-1909)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1900 | Webhook Endpoint Model | Define `WebhookEndpoint` entity: ID, name, URL, secret (for HMAC), events subscribed, status (active/paused/disabled), retry config, created, updated | CORE | P2 | EPIC-1900 (new) |
| 1901 | Webhook Endpoint Repository | Implement `WebhookEndpointRepository` — Create, GetByID, Update, Delete, ListByEvent, ListActive with PostgreSQL | CORE | P2 | EPIC-1900 |
| 1902 | Webhook Delivery Model | Define `WebhookDelivery` entity: ID, endpoint ID, event type, event ID, payload, status (pending/delivered/failed/expired), attempts, next retry, response code | CORE | P2 | EPIC-1900 |
| 1903 | Webhook HMAC Signing | Sign webhook payloads with HMAC-SHA256: use per-endpoint secret, include timestamp in signature to prevent replay, set `X-Webhook-Signature` header | CORE | P2 | EPIC-1900 |
| 1904 | Webhook Delivery Worker | Background worker for webhook delivery: dequeue pending deliveries, POST to endpoint, handle response, schedule retry on failure | CORE | P2 | EPIC-1900 |
| 1905 | Webhook Retry Strategy | Implement exponential backoff retry: configurable initial delay (1s), max retries (10), max delay (1h), jitter; mark as failed after max retries | CORE | P2 | EPIC-1900 |
| 1906 | Webhook Payload Format | Define webhook payload format: event type, event ID, timestamp, data (event-specific), webhook ID, delivery attempt number | CORE | P2 | EPIC-1900 |
| 1907 | Webhook Timeout | Enforce webhook delivery timeout: configurable per endpoint (default 10s), treat timeout as failure, retry | CORE | P2 | EPIC-1900 |
| 1908 | Webhook Delivery Logging | Log all webhook deliveries: endpoint, event, attempt, response code, response time, success/failure | CORE | P2 | EPIC-1900 |
| 1909 | Webhook Security | Webhook delivery security: validate endpoint URL (SSRF guard), TLS required in production, user-agent identification | CORE | P2 | EPIC-1900 |

### Event Subscriptions (1910-1919)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1910 | Webhook Event Types | Define webhook event types: `provider.status_changed`, `credential.rotated`, `credential.expiring`, `policy.changed`, `circuit.state_changed`, `quota.threshold_reached`, `execution.failed` | CORE | P2 | EPIC-1910 (new) |
| 1911 | Event Type Filtering | Subscribe to specific event types per endpoint: only deliver events matching subscription filter | CORE | P2 | EPIC-1910 |
| 1912 | Event Data Schemas | Define per-event-type data schemas: what fields are included for each event type, consistent structure | CORE | P2 | EPIC-1910 |
| 1913 | Webhook Admin Endpoints | Admin REST endpoints for webhook management: create/update/delete endpoints, list deliveries, retry failed, test endpoint | CORE | P2 | EPIC-1910 |
| 1914 | Webhook Test Delivery | Support test webhook delivery: send test event to registered endpoint, verify connectivity and signature validation | CORE | P2 | EPIC-1910 |
| 1915 | Webhook Pause/Resume | Pause and resume webhook endpoints: temporarily stop delivery without losing queued events, resume delivery on unpause | EXTENDED | P2 | EPIC-1910 |
| 1916 | Dead Letter Queue | Implement dead letter queue: move permanently failed deliveries to DLQ for manual inspection and retry | EXTENDED | P3 | EPIC-1910 |
| 1917 | Delivery History | Store webhook delivery history: last N deliveries per endpoint with status, response, timing; queryable via admin API | CORE | P2 | EPIC-1910 |
| 1918 | Auto-Disable on Failure | Auto-disable webhook endpoints after consecutive failures: configurable threshold, emit admin notification, require manual re-enable | EXTENDED | P2 | EPIC-1910 |
| 1919 | Webhook Subscription Tests | Test suite for webhook system: HMAC signing, delivery, retry, event filtering, auto-disable, DLQ | CORE | P2 | EPIC-1910 |

### External Notifications (1920-1924)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1920 | Slack Notification Channel | Implement Slack notification channel: post events to Slack webhook URL, formatted messages, channel selection per event type | EXTENDED | P3 | EPIC-1920 (new) |
| 1921 | Email Notification Channel | Implement email notification channel: send event notifications via SMTP, configurable recipients per event type | EXTENDED | P3 | EPIC-1920 |
| 1922 | PagerDuty Integration | Implement PagerDuty integration: trigger incidents for critical events (circuit breaker trips, credential failures, security events) | EXTENDED | P3 | EPIC-1920 |
| 1923 | Notification Channel Config | Configure notification channels per event type: which channels receive which events, severity mapping (info/warning/critical) | EXTENDED | P3 | EPIC-1920 |
| 1924 | Notification Rate Limiting | Rate limit notifications: prevent notification storms, aggregate similar events, configurable cooldown per event type per channel | EXTENDED | P3 | EPIC-1920 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 1900 (Webhook Model) | 1B0-1B5 (Outbox & Events) | Webhooks consume from the outbox/event bus |
| 1903 (HMAC Signing) | 400-409 (Crypto Primitives) | Uses HMAC primitives from crypto package |
| 1909 (Webhook Security) | 1C0-1C8 (SSRF & Network) | Webhook delivery uses SSRF guard for URL validation |
| 1910 (Event Types) | 1B0 (Event Type Registry) | Webhook events extend internal event types |
| 1914 (Test Delivery) | 1100-1109 (SSE Admin Events) | Different delivery mechanism; SSE is push, webhook is pull |
| 1920-1922 (Notification Channels) | 1164 (Alert Notification Config) | Notification channels are concrete implementations of alert config |
