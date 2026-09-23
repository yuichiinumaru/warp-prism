#!/usr/bin/env python3
"""
Static Flutter↔Rust boundary validator.

Mechanism, not authority.

Input: JSON config describing roots and forbidden import/dependency patterns.
Output: JSON receipt.
Exit:
  0 = no configured violations found
  1 = configured boundary violation(s) found
  2 = execution/configuration error

This script does NOT prove runtime integration, soundness, or task acceptance.
"""
from __future__ import annotations
import argparse
import json
import re
import sys
from pathlib import Path
from typing import Iterable

TEXT_SUFFIXES = {".dart", ".rs", ".toml"}

DEFAULT_RULES = {
    "dart_forbidden_patterns": [
        r"package:flutter_rust_bridge/",
        r"\bfrb_generated\b",
        r"\bfrb_generated\.dart\b",
    ],
    "rust_forbidden_patterns": [
        r"\bflutter_rust_bridge\b",
    ],
}

def iter_files(roots: list[Path], suffixes: set[str]) -> Iterable[Path]:
    seen = set()
    for root in roots:
        if not root.exists():
            continue
        if root.is_file():
            candidates = [root]
        else:
            candidates = root.rglob("*")
        for p in candidates:
            if p.is_file() and p.suffix in suffixes:
                rp = p.resolve()
                if rp not in seen:
                    seen.add(rp)
                    yield p

def scan(paths: list[Path], patterns: list[str], label: str) -> list[dict]:
    compiled = [(pat, re.compile(pat)) for pat in patterns]
    violations = []
    for path in iter_files(paths, TEXT_SUFFIXES):
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for lineno, line in enumerate(text.splitlines(), 1):
            for raw, rx in compiled:
                if rx.search(line):
                    violations.append({
                        "scope": label,
                        "file": str(path),
                        "line": lineno,
                        "pattern": raw,
                        "text": line.strip()[:500],
                    })
    return violations

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True, help="JSON config path")
    ap.add_argument("--json", action="store_true", help="Emit JSON (default; retained for interface consistency)")
    args = ap.parse_args()

    try:
        cfg = json.loads(Path(args.config).read_text(encoding="utf-8"))
        dart_roots = [Path(p) for p in cfg.get("dart_ui_roots", [])]
        rust_roots = [Path(p) for p in cfg.get("rust_domain_roots", [])]

        dart_patterns = cfg.get("dart_forbidden_patterns", DEFAULT_RULES["dart_forbidden_patterns"])
        rust_patterns = cfg.get("rust_forbidden_patterns", DEFAULT_RULES["rust_forbidden_patterns"])

        violations = []
        violations.extend(scan(dart_roots, dart_patterns, "dart_ui"))
        violations.extend(scan(rust_roots, rust_patterns, "rust_domain"))

        receipt = {
            "schema": "flutter-rust-boundary-imports/v1",
            "evidence_scope": "STATIC_BOUNDARY",
            "config": str(Path(args.config)),
            "roots": {
                "dart_ui_roots": [str(p) for p in dart_roots],
                "rust_domain_roots": [str(p) for p in rust_roots],
            },
            "violations": violations,
            "status": "PASS" if not violations else "FAIL",
            "limits": [
                "Does not prove runtime/native crossing.",
                "Does not prove semantic ownership automatically.",
                "Regex patterns require project-specific calibration.",
            ],
        }
        print(json.dumps(receipt, indent=2))
        return 0 if not violations else 1
    except Exception as e:
        print(json.dumps({
            "schema": "flutter-rust-boundary-imports/v1",
            "status": "BLOCKED",
            "error": f"{type(e).__name__}: {e}",
        }, indent=2))
        return 2

if __name__ == "__main__":
    raise SystemExit(main())
