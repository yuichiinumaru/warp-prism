# Screenshot Report: Dashboard — Provider Quota Page

**File**: `34_dashboard_quota.png`
**Page Title**: Provider Quota
**Subtitle**: "Configure rate limits and track quotas per API key and provider"
**Breadcrumb**: Dashboard > Quota
**Auto-refresh indicator**: "Auto-refreshing 59:59" (countdown timer, top-right with green dot).

---

## Summary Cards Row

Four horizontal metric cards:

| Card | Value | Color |
|------|-------|-------|
| TOTAL | **76** | Gray |
| CRITICAL | **19** | Red/coral |
| ALERT | **1** | Orange |
| HEALTHY | **15** | Green |

## Filter Tabs

### Type Filter
| Tab | Count |
|-----|-------|
| All | 76 (active, underlined) |
| Subscription | 28 |
| OAuth Free | 38 |
| API Key | 10 |

### Tier Filter
| Tab | Count |
|-----|-------|
| All | 76 (active, underlined) |
| Pro | 11 |
| Plus | 3 |
| Lite | 14 |
| Free | 24 |
| Unknown | 24 |

---

## Provider Groups

### OpenAI Codex (13 accounts)

Displayed as a grid of cards (4 columns). Each card contains:

- **Header**: Provider logo (green circle icon) + "OpenAI Codex" + plan badge ("+ Free" or "+ Plus") + copy icon.
- **Token status**: "Token expires in Xh Xm" or "Token expired" (red text for expired).
- **Progress bars**:
  - **Session** — green progress bar with percentage (e.g., "99% left", "98% left", "100% left").
  - **Weekly** — green/yellow progress bar (e.g., "0% left", "35% left").
- **Reset info**: "← reset in Xd Xh Xm" in gray text.
- **Footer**: "Updated HH:MM:SS" timestamp + action buttons: Edit, Cutout, Refresh icons.

#### Notable OpenAI Codex cards:
| Card | Session | Weekly | Token Status |
|------|---------|--------|--------------|
| Card 1 (top-left) | 99% left (green) | 0% left (red) | Expires in 8h 42m |
| Card 2 | 98% left (green) | — | Expires in 9d 22h |
| Card 3 | 98% left (green) | 0% left | Expires in 9d 22h |
| Card 4 | 98% left (green) | — | Expires in 10d |
| Card 5 | 100% left | — | Expires in 2h 20m |
| Card 6 | 100% left | — | Expires in 2d 2h |
| Card 7 | 100% left | — | Expires in 20d |
| Card 8 | 100% left | — | Expires in 20d |
| Card 9 | 100% left | — | Expires in 20d 2h |
| Card 10 (Plus) | 18% left (yellow) | — | Expires in 2d 20h |
| Card 11 (Plus) | 100% left | 35% left (yellow) | Expires in 2d 20h |
| Card 12 | 99% left | — | Expires in 2d 20h |
| Card 13 | 95% left (green) | — | Expires in 2d 20h |

---

### Gemini CLI (13 accounts)

#### Free Tier Cards (4-column grid)

Each card shows:
- **Header**: Gemini CLI logo (colorful "G" icon) + "Gemini CLI" + "+ Free" badge + copy icon.
- **Token status**: "Token expires in Xh Xm" or "Token expired" (red).
- **Per-model quota bars** — a detailed breakdown with green progress bars:

| Model | Quota |
|-------|-------|
| gemini-2.5-pro-preview | 0% left |
| gemini-3-flash-preview | 100% left |
| gemini-3.1-flash-lite-preview | 100% left |
| gemini-2.5-flash | 100% left |
| gemini-2.5-flash-lite | 100% left |
| gemini-2.5-pro | 0% left |
| gemini-3-pro-preview | 0% left |
| gemini-3.1-flash-lite | 100% left |

- **Footer**: Updated timestamp + Edit, Cutout, Refresh buttons.

#### Pro Tier Cards (4-column grid, second row)
- Similar layout with "+ Pro" badge.
- All show 100% left for most models.
- One card shows "Token expired" in red.

#### Unknown Tier Cards (2 cards)
- **Error state**: "Failed to refresh credentials. Please re-authorize the connection. — re-authorize this account" in red text.
- Button: "Refresh now".

---

### DeepSeek (5 accounts)

Cards show:
- **Header**: DeepSeek logo + "Deepseek (Insufficient Balance)" in red/orange text + badge + copy icon.
- **Balance**: "USD $0.00" displayed prominently.
- **Footer**: Updated timestamp + Edit, Cutout, Refresh buttons.

All 5 DeepSeek cards show $0.00 balance, indicating no credits remaining.

---

### Kiro AI (13 accounts)

Cards show:
- **Header**: Kiro AI logo (green "K" icon) + "Kiro AI" + "+ Free" badge + copy icon.
- **Credit bar**: Green progress bar showing "100% left" (e.g., "57/50", "51/50", "51/50").
- **Reset info**: "← reset in 20d 21h 44m" in gray text.
- **Footer**: Updated timestamp + Edit, Cutout, Refresh buttons.

Most Kiro AI cards show 100% left with healthy green bars.

---

## Sidebar

Identical persistent left sidebar. **Provider Quota** under the OMNIPROXY section is highlighted/active with a red/pink background indicator.
