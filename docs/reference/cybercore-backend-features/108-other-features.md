# Feature Catalog: Other Features

> **Series**: 108
> **Source**: diegosouza-omniroute sidebar + cybernetics-core + OmniRoute analysis
> **Purpose**: Sidebar-discoverable features from reference repos
> **Total Features**: 16

## Media

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 108-001 | Image Generation | 22 providers | diegosouza-omniroute | `open-sse/handlers/imageGeneration.ts` | ❌ GAP (014-001) |
| 108-002 | Audio Transcription (STT) | 10 providers | diegosouza-omniroute | `open-sse/handlers/audioTranscription.ts` | ❌ GAP (014-010) |
| 108-003 | Audio Speech (TTS) | 15 providers | diegosouza-omniroute | `open-sse/handlers/audioSpeech.ts` | ❌ GAP (014-015) |
| 108-004 | Video Generation | 11 providers | diegosouza-omniroute | `open-sse/handlers/videoGeneration.ts` | ❌ GAP (014-020) |
| 108-005 | Music Generation | 5 providers | diegosouza-omniroute | `open-sse/handlers/musicGeneration.ts` | ❌ GAP (014-025) |

## Batch

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 108-006 | Batch Processing | OpenAI-compatible /v1/batches | diegosouza-omniroute | `src/lib/batches/` | ❌ GAP (014-045) |
| 108-007 | Batch Cost Estimator | Estimate cost before execution | diegosouza-omniroute | `src/lib/batches/costEstimator.ts` | ❌ GAP |
| 108-008 | Batch Job Management | Status, retry, cancel | diegosouza-omniroute | `src/app/api/batches/` | ❌ GAP |

## Files

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 108-009 | File Operations | /v1/files for batch inputs | diegosouza-omniroute | `src/app/api/v1/files/` | ❌ GAP (014-048) |
| 108-010 | File Storage | DB-backed file metadata | diegosouza-omniroute | `src/lib/db/files.ts` | ❌ GAP |

## Plugins

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 108-011 | Plugin Loader | Discovers from ~/.omniroute/plugins/ | diegosouza-omniroute | `src/lib/plugins/loader.ts` | ✅ 1200 |
| 108-012 | Plugin Manager | Lifecycle management | diegosouza-omniroute | `src/lib/plugins/manager.ts` | ✅ 1210 |
| 108-013 | Plugin Sandbox | Sandboxed execution | diegosouza-omniroute | `src/lib/plugins/sandbox.ts` | ✅ 1230 |
| 108-014 | Plugin Signing | Cryptographic signing | diegosouza-omniroute | `src/lib/plugins/signing.ts` | ❌ GAP |
| 108-015 | Plugin Marketplace | Discovery and installation | diegosouza-omniroute | `src/lib/plugins/marketplace.ts` | ❌ GAP |
| 108-016 | Plugin Dev Mode | Development mode for authoring | diegosouza-omniroute | `src/lib/plugins/devMode.ts` | ❌ GAP |

## Gamification (N/A — excluded from Go engine)

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| — | Leaderboard | User ranking | diegosouza-omniroute | `src/lib/gamification/` | ⛔ N/A |
| — | XP System | Experience points | diegosouza-omniroute | `src/lib/gamification/` | ⛔ N/A |
| — | Badges | Achievement badges | diegosouza-omniroute | `src/lib/gamification/` | ⛔ N/A |
| — | Streaks | Activity streaks | diegosouza-omniroute | `src/lib/gamification/` | ⛔ N/A |
| — | Profile | User profile | diegosouza-omniroute | `src/lib/gamification/` | ⛔ N/A |
| — | Tokens | Token management | diegosouza-omniroute | `src/lib/gamification/` | ⛔ N/A |
