import time, os, json

BASE = "http://localhost:22000"
DIR = "/home/sephiroth/working/behemoth/diegosouzapw-omniroute/screenshots"
os.makedirs(DIR, exist_ok=True)

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

new_tab(f"{BASE}/login")
wait_for_load()
time.sleep(1)
js('const i=document.querySelector(\'input[type="password"]\');if(i){const s=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,\'value\').set;s.call(i,\'CHANGEME\');i.dispatchEvent(new Event(\'input\',{bubbles:true}));const f=i.closest(\'form\');if(f)f.dispatchEvent(new Event(\'submit\',{cancelable:true,bubbles:true}));}')
time.sleep(3)
print(f"Logged in: {page_info()['url']}")

cdp("Emulation.setDeviceMetricsOverride", {"width": 2160, "height": 3840, "deviceScaleFactor": 1, "mobile": False})
time.sleep(1)

for idx, page in enumerate(pages):
    url = f"{BASE}/{page}"
    safe = page.replace("/", "_")
    path = f"{DIR}/{idx+1:02d}_{safe}.png"
    print(f"[{idx+1}/{len(pages)}] {page}")
    goto_url(url)
    wait_for_load()
    time.sleep(1.5)
    capture_screenshot(path=path, full=True)

print("All done")
