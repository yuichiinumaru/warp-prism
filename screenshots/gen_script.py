#!/usr/bin/env python3
import subprocess, time, os

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

os.makedirs(DIR, exist_ok=True)

code = f"""
const {{ chromium }} = require('playwright');

(async () => {{
  const browser = await chromium.launch({{ headless: true }});
  const ctx = await browser.newContext({{
    viewport: {{ width: 2160, height: 3840 }},
    deviceScaleFactor: 1,
  }});
  const page = await ctx.newPage();

  // Login
  await page.goto('{BASE}/login');
  await page.waitForLoadState('networkidle');
  await page.fill('input[type="password"]', 'CHANGEME');
  await page.press('input[type="password"]', 'Enter');
  await page.waitForURL('**/home', {{ timeout: 10000 }});
  console.log('Logged in');

  const pages = {repr(pages)};

  for (let i = 0; i < pages.length; i++) {{
    const p = pages[i];
    const url = '{BASE}/' + p;
    const safe = p.replace(/\\//g, '_');
    const path = '{DIR}/' + String(i+1).padStart(2,'0') + '_' + safe + '.png';

    console.log(`[${{i+1}}/${{pages.length}}] ${{p}}`);
    await page.goto(url);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1500);
    await page.screenshot({{ path, fullPage: true }});
  }}

  console.log('All done');
  await browser.close();
}})();
"""

with open(f"{DIR}/take_all.js", "w") as f:
    f.write(code)

print("Script written. Run with: node screenshots/take_all.js")
