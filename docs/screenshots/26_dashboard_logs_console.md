# Dashboard: Console Logs

**Page Title:** Console Logs
**Subtitle:** Application stdout output and debug logs
**Breadcrumb:** Dashboard > Logs > Console

---

## Left Sidebar

The sidebar is identical to other dashboard pages. Light gray/white background with a red/pink square icon labeled **Cybernetics-Core** v1.2.28 at the top. Navigation sections:

### OMNIPROXY
- Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy

### ANALYTICS
- Usage, Combo Health, Utilization, Cache, Compression, Search, Eval, Provider Stats

### MONITORING
- Activity, Logs, Proxy Logs, **Console Logs** (currently selected, highlighted in red/pink text), Audit Log, MCP Audit, A2A Audit

### AGENTIC FEATURES
- Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins

### OTHER FEATURES
- Media, Batch Jobs, Files

### CONFIGURATION
- (collapsed)

### HELP
- Docs, Issues, Changelog

Bottom: Green **Restart** button, Red **Shut...** button.

---

## Top Bar

- "Quick nav" search with `Ctrl+/` hint
- EN language selector
- Bell, warning triangle, and user/settings icons

---

## Page Header

- **Heading:** "Console Logs" with a red terminal icon to the left
- **Breadcrumb:** Dashboard > Logs > Console

---

## Filters and Controls

### Row 1:
- **All Levels** dropdown — filter by log level
- **Search input:** placeholder "Search logs..."
- **Auto-scroll** toggle button (with a lightning bolt icon, appears active/enabled in green)
- **Refresh** button (circular arrow icon)
- **500 entries** — total entry count badge
- **Last 1h** — time range indicator
- **Updated 7:14:58 PM** — last update timestamp

---

## Console Output Area

The main content area is a large terminal-style panel with a **dark navy/black background**. It displays log entries in a monospaced font with color-coded formatting.

### Log Entry Format:
Each line follows the pattern:
```
HH:MM:SS.mmm [LEVEL] [Category] [Message details]
```

### Observed Log Entries:

The console is filled with repeated **error-level** entries, all related to encryption/decryption failures. The entries are:

- **Timestamps:** All clustered around `18:14:39.112` through `18:14:39.1xx` (sub-second burst)
- **Level:** `ERROR` — displayed in **red** text
- **Category:** `[Encryption]` — displayed in **yellow/orange** text
- **Message format:** `[Encryption] Decryption failed. Ciphertext prefix: enc:v1:<hex>... . Auth tag validation likely failed.`

### Color Coding:
- **Red** — ERROR level entries (dominant in this view)
- **Green** — INFO level entries (occasional, visible as green `[INFO]` tags)
- **Yellow/Orange** — Category tags like `[Encryption]`
- **White/Light gray** — Timestamp and message body text

### Representative Log Lines (paraphrased from visible content):

```
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:780e28044a0e5e40b79f12... . Auth tag validation likely failed.
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:317e9ef174d110b7b71be... . Auth tag validation likely failed.
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:16077ee47f450000716c48... . Auth tag validation likely failed.
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:6581e8374eaa32d0e7dee1... . Auth tag validation likely failed.
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:afccbf2fabb8ac969914e9... . Auth tag validation likely failed.
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:1509fbc81ab05b4ede4b008... . Auth tag validation likely failed.
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:420b8c2de3c6a52ae78e1f... . Auth tag validation likely failed.
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:6d8f0f7eac5dbe8af04f0b... . Auth tag validation likely failed.
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:4939bd827659a7fb029b0f... . Auth tag validation likely failed.
18:14:39.112 ERROR [Encryption] [Encryption] Decryption failed. Ciphertext prefix: enc:v1:d5b6d846781e721f84ae73f8... . Auth tag validation likely failed.
```

The entries continue in a long scrollable list with the same pattern — each showing a unique `enc:v1:<hex>` ciphertext prefix but the identical error message about auth tag validation failure.

### Log Characteristics:
- **Volume:** The visible portion shows 500+ entries (as indicated by the "500 entries" badge).
- **Time span:** All entries appear to be from the same burst at approximately `18:14:39` on the current day.
- **Severity:** All visible entries are ERROR level.
- **Root cause pattern:** Every entry indicates a decryption failure where the auth tag validation likely failed, suggesting a key mismatch, corruption, or encryption version incompatibility.
- **Auto-scroll:** The auto-scroll feature is enabled (green indicator), meaning the view follows new entries as they appear.

### Scrollbar:
A vertical scrollbar on the right side of the console panel indicates the content extends beyond the visible viewport. The scrollbar thumb is positioned near the middle, suggesting significant content above and below the current view.

---

## Key Observations

1. **Encryption failures are the dominant issue:** The entire console output is filled with decryption errors, each with a unique ciphertext prefix but identical error message.
2. **Burst pattern:** All 500+ errors occurred within the same sub-second timestamp window (`18:14:39.1xx`), suggesting a batch operation or concurrent request storm triggered the failures.
3. **Auth tag validation:** The error message specifically mentions "Auth tag validation likely failed," which points to GCM/AES-GCM authentication tag mismatches — possibly due to wrong encryption keys, corrupted ciphertext, or version mismatches.
4. **No other log levels visible:** The visible portion of the console shows only ERROR entries with occasional green INFO tags, indicating the encryption subsystem was the primary source of errors during this period.
5. **Debugging context:** This view is useful for real-time debugging of application-level stdout/stderr output, as opposed to the structured Request Logs or Proxy Logs views.
