const { chromium } = require('playwright');

const BASE = 'http://localhost:22000';
const DIR = '/home/sephiroth/working/behemoth/diegosouzapw-omniroute/screenshots';

const pages = [
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
];

(async () => {
  const browser = await chromium.launch({ headless: true });
  const ctx = await browser.newContext({
    viewport: { width: 2160, height: 3840 },
    deviceScaleFactor: 1,
  });
  const page = await ctx.newPage();

  // Login
  await page.goto(`${BASE}/login`);
  await page.waitForLoadState('networkidle');
  await page.fill('input[type="password"]', 'CHANGEME');
  await page.press('input[type="password"]', 'Enter');
  await page.waitForURL('**/home', { timeout: 10000 });
  console.log('Logged in');

  for (let i = 0; i < pages.length; i++) {
    const p = pages[i];
    const safe = p.replace(/\//g, '_');
    const path = `${DIR}/${String(i+1).padStart(2,'0')}_${safe}.png`;

    console.log(`[${i+1}/${pages.length}] ${p}`);
    await page.goto(`${BASE}/${p}`);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1500);
    await page.screenshot({ path, fullPage: true });
  }

  console.log('All done');
  await browser.close();
})();
