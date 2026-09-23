#!/usr/bin/env python3
"""
Run configured bridge evidence commands and emit a machine-readable receipt.

Config JSON:
{
  "checks": [
    {"name":"cargo-test", "scope":"RUST_SEMANTICS",
     "argv":["cargo","test","-p","example_core"], "cwd":"."}
  ]
}

Exit:
  0 = every configured command exited 0
  1 = one or more commands executed and failed
  2 = collector/configuration error

This is an evidence collector, not an acceptance gate.
"""
from __future__ import annotations
import argparse
import json
import subprocess
import time
from pathlib import Path

def tail(s: str, n: int = 12000) -> str:
    return s[-n:]

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--output", required=True)
    ap.add_argument("--timeout", type=int, default=300)
    args = ap.parse_args()

    try:
        cfg = json.loads(Path(args.config).read_text(encoding="utf-8"))
        checks = cfg.get("checks", [])
        if not isinstance(checks, list):
            raise ValueError("checks must be a list")

        results = []
        any_fail = False

        for item in checks:
            name = item["name"]
            scope = item.get("scope", "UNCLASSIFIED")
            argv = item["argv"]
            cwd = item.get("cwd")
            timeout = int(item.get("timeout", args.timeout))

            if not isinstance(argv, list) or not argv or not all(isinstance(x, str) for x in argv):
                raise ValueError(f"{name}: argv must be a non-empty string list")

            started = time.time()
            try:
                cp = subprocess.run(
                    argv,
                    cwd=cwd,
                    text=True,
                    capture_output=True,
                    timeout=timeout,
                    check=False,
                )
                result = {
                    "name": name,
                    "scope": scope,
                    "argv": argv,
                    "cwd": cwd,
                    "exit_code": cp.returncode,
                    "duration_s": round(time.time() - started, 3),
                    "stdout_tail": tail(cp.stdout),
                    "stderr_tail": tail(cp.stderr),
                    "status": "PASS" if cp.returncode == 0 else "FAIL",
                }
                if cp.returncode != 0:
                    any_fail = True
            except subprocess.TimeoutExpired as e:
                any_fail = True
                result = {
                    "name": name,
                    "scope": scope,
                    "argv": argv,
                    "cwd": cwd,
                    "duration_s": round(time.time() - started, 3),
                    "status": "BLOCKED",
                    "error": f"timeout after {timeout}s",
                    "stdout_tail": tail((e.stdout or "") if isinstance(e.stdout, str) else ""),
                    "stderr_tail": tail((e.stderr or "") if isinstance(e.stderr, str) else ""),
                }
            results.append(result)

        receipt = {
            "schema": "flutter-rust-bridge-evidence/v1",
            "status": "PASS" if not any_fail else "FAIL",
            "checks": results,
            "limits": [
                "PASS means configured commands exited successfully.",
                "Each check's scope states what it may contribute evidence toward.",
                "This receipt does not grant independent task acceptance.",
            ],
        }
        out = Path(args.output)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
        print(json.dumps({"status": receipt["status"], "output": str(out), "checks": len(results)}, indent=2))
        return 0 if not any_fail else 1
    except Exception as e:
        print(json.dumps({"status": "BLOCKED", "error": f"{type(e).__name__}: {e}"}, indent=2))
        return 2

if __name__ == "__main__":
    raise SystemExit(main())
