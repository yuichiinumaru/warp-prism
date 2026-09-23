#!/usr/bin/env python3
"""
FRB generated-tree drift auditor.

Mechanism, not authority.

Modes:
- snapshot: write a hash manifest for configured/generated roots.
- compare: compare current roots to a prior manifest.

Exit:
  0 = snapshot created / comparison clean
  1 = drift found
  2 = execution/config error

This intentionally does NOT invoke FRB codegen. Dependency/workflow policy owns
when/how generation is executed. Typical use:
  1) snapshot
  2) run authorized codegen
  3) compare
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def inventory(roots: list[Path]) -> dict[str, dict]:
    out = {}
    for root in roots:
        if not root.exists():
            continue
        if root.is_file():
            candidates = [root]
            base = root.parent
        else:
            candidates = root.rglob("*")
            base = root
        for p in candidates:
            if p.is_file():
                key = f"{root}::{p.relative_to(base)}"
                out[key] = {"sha256": sha256(p), "size": p.stat().st_size}
    return dict(sorted(out.items()))

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["snapshot", "compare"])
    ap.add_argument("--root", action="append", default=[], help="Generated root/file; repeatable")
    ap.add_argument("--manifest", required=True)
    args = ap.parse_args()

    try:
        roots = [Path(p) for p in args.root]
        current = inventory(roots)
        manifest_path = Path(args.manifest)

        if args.mode == "snapshot":
            data = {
                "schema": "frb-codegen-inventory/v1",
                "evidence_scope": "CODEGEN_REPRO_BASELINE",
                "roots": [str(r) for r in roots],
                "files": current,
            }
            manifest_path.parent.mkdir(parents=True, exist_ok=True)
            manifest_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
            print(json.dumps({"status": "PASS", "manifest": str(manifest_path), "files": len(current)}, indent=2))
            return 0

        before = json.loads(manifest_path.read_text(encoding="utf-8"))
        old = before.get("files", {})
        added = sorted(set(current) - set(old))
        removed = sorted(set(old) - set(current))
        changed = sorted(k for k in set(old) & set(current) if old[k] != current[k])

        drift = {"added": added, "removed": removed, "changed": changed}
        status = "PASS" if not any(drift.values()) else "FAIL"
        print(json.dumps({
            "schema": "frb-codegen-drift/v1",
            "evidence_scope": "CODEGEN_REPRO",
            "status": status,
            "drift": drift,
            "limits": ["Comparison proves generated-tree stability only; it does not prove native runtime behavior."],
        }, indent=2))
        return 0 if status == "PASS" else 1
    except Exception as e:
        print(json.dumps({"status": "BLOCKED", "error": f"{type(e).__name__}: {e}"}, indent=2))
        return 2

if __name__ == "__main__":
    raise SystemExit(main())
