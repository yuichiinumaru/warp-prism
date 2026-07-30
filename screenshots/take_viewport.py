#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import time, os

DIR = "/home/sephiroth/working/behemoth/diegosouzapw-omniroute/screenshots"
BASE = "http://localhost:22000"

pages = [
    "dashboard", "dashboard/a2a", "dashboard/activity",
    "dashboard/agent-skills", "dashboard/analytics",
    "dashboard/analytics/combo-health", "dashboard/analytics/compression",
    "dashboard/analytics/evals", "dashboard/analytics/search",
    "dashboard/analytics/utilization", "dashboard/api-endpoints",
    "dashboard/api-manager", "dashboard/audit", "dashboard/audit/a2a",
    "dashboard/audit/mcp", "dashboard/batch", "dashboard/batch/files",
    "dashboard/cache", "dashboard/cache/media", "dashboard/changelog",
    "dashboard/combos", "dashboard/combos/live", "dashboard/endpoint",
    "dashboard/health", "dashboard/logs", "dashboard/logs/console",
    "dashboard/logs/proxy", "dashboard/mcp", "dashboard/memory",
    "dashboard/omni-skills", "dashboard/plugins", "dashboard/provider-stats",
    "dashboard/providers", "dashboard/quota", "dashboard/runtime",
    "dashboard/settings/advanced", "dashboard/settings/ai",
    "dashboard/settings/appearance", "dashboard/settings/feature-flags",
    "dashboard/settings/general", "dashboard/settings/resilience",
    "dashboard/settings/routing", "dashboard/settings/security",
    "dashboard/settings/sidebar", "dashboard/system/proxy",
    "dashboard/webhooks", "docs", "home",
]

with sync_playwright() as p:
    browser = p.chromium.launch(
        executable_path="/usr/bin/brave",
        headless=True,
        args=["--no-sandbox", "--disable-gpu"],
    )
    ctx = browser.new_context(
        viewport={"width": 2160, "height": 3840},
        device_scale_factor=1,
    )
    page = ctx.new_page()

    # Login
    page.goto(f"{BASE}/login")
    page.wait_for_load_state("load")
    page.fill('input[type="password"]', "CHANGEME")
    page.press('input[type="password"]', "Enter")
    page.wait_for_url("**/home", timeout=10000)
    print(f"Logged in: {page.url}")

    # Screenshots
    for i, pg in enumerate(pages):
        url = f"{BASE}/{pg}"
        safe = pg.replace("/", "_")
        path = f"{DIR}/{i+1:02d}_{safe}.png"
        print(f"[{i+1}/{len(pages)}] {pg}")
        page.goto(url)
        page.wait_for_load_state("load")
        time.sleep(2)
        page.screenshot(path=path, full_page=True)

    print("All done")
    browser.close()
