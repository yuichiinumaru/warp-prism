import time, sys

BASE = "http://localhost:22000"
DIR = "/home/sephiroth/working/behemoth/diegosouzapw-omniroute/screenshots"

pages = [
    "dashboard",
    "dashboard/a2a",
    "dashboard/activity",
    "dashboard/agent-skills",
    "dashboard/analytics",
    "dashboard/analytics/combo-health",
    "dashboard/analytics/compression",
    "dashboard/analytics/evals",
    "dashboard/analytics/search",
    "dashboard/analytics/utilization",
    "dashboard/api-endpoints",
    "dashboard/api-manager",
    "dashboard/audit",
    "dashboard/audit/a2a",
    "dashboard/audit/mcp",
    "dashboard/batch",
    "dashboard/batch/files",
    "dashboard/cache",
    "dashboard/cache/media",
    "dashboard/changelog",
    "dashboard/combos",
    "dashboard/combos/live",
    "dashboard/endpoint",
    "dashboard/health",
    "dashboard/logs",
    "dashboard/logs/console",
    "dashboard/logs/proxy",
    "dashboard/mcp",
    "dashboard/memory",
    "dashboard/omni-skills",
    "dashboard/plugins",
    "dashboard/provider-stats",
    "dashboard/providers",
    "dashboard/quota",
    "dashboard/runtime",
    "dashboard/settings/advanced",
    "dashboard/settings/ai",
    "dashboard/settings/appearance",
    "dashboard/settings/feature-flags",
    "dashboard/settings/general",
    "dashboard/settings/resilience",
    "dashboard/settings/routing",
    "dashboard/settings/security",
    "dashboard/settings/sidebar",
    "dashboard/system/proxy",
    "dashboard/webhooks",
    "docs",
    "home",
]

batch_start = int(sys.argv[1]) if len(sys.argv) > 1 else 0
batch_end = int(sys.argv[2]) if len(sys.argv) > 2 else len(pages)

for i in range(batch_start, batch_end):
    page = pages[i]
    url = f"{BASE}/{page}"
    safe = page.replace("/", "_")
    path = f"{DIR}/{i+1:02d}_{safe}.png"

    print(f"[{i+1}/{len(pages)}] {url}")
    goto_url(url)
    wait_for_load()
    time.sleep(1.5)
    capture_screenshot(path=path, full=True)
