from __future__ import annotations
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]

class ScriptTests(unittest.TestCase):
    def run_script(self, script: str, *args: str):
        return subprocess.run(
            [sys.executable, str(SCRIPTS / script), *args],
            text=True,
            capture_output=True,
        )

    def test_boundary_validator_detects_forbidden_import(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            dart = root / "ui"
            rust = root / "core"
            dart.mkdir()
            rust.mkdir()
            (dart / "x.dart").write_text("import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';\n")
            (rust / "lib.rs").write_text("pub fn ok() {}\n")
            cfg = root / "cfg.json"
            cfg.write_text(json.dumps({
                "dart_ui_roots": [str(dart)],
                "rust_domain_roots": [str(rust)],
            }))
            cp = self.run_script("validate_boundary_imports.py", "--config", str(cfg))
            self.assertEqual(cp.returncode, 1, cp.stdout + cp.stderr)
            data = json.loads(cp.stdout)
            self.assertEqual(data["status"], "FAIL")
            self.assertTrue(data["violations"])

    def test_codegen_snapshot_compare_clean_then_drift(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            gen = root / "gen"
            gen.mkdir()
            f = gen / "api.dart"
            f.write_text("a")
            manifest = root / "manifest.json"

            a = self.run_script("audit_frb_codegen.py", "snapshot", "--root", str(gen), "--manifest", str(manifest))
            self.assertEqual(a.returncode, 0, a.stdout + a.stderr)

            b = self.run_script("audit_frb_codegen.py", "compare", "--root", str(gen), "--manifest", str(manifest))
            self.assertEqual(b.returncode, 0, b.stdout + b.stderr)

            f.write_text("b")
            c = self.run_script("audit_frb_codegen.py", "compare", "--root", str(gen), "--manifest", str(manifest))
            self.assertEqual(c.returncode, 1, c.stdout + c.stderr)

    def test_evidence_collector(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            cfg = root / "cfg.json"
            out = root / "receipt.json"
            cfg.write_text(json.dumps({
                "checks": [
                    {"name": "python-ok", "scope": "NATIVE_CALL",
                     "argv": [sys.executable, "-c", "print('ok')"]}
                ]
            }))
            cp = self.run_script(
                "collect_bridge_evidence.py",
                "--config", str(cfg),
                "--output", str(out),
            )
            self.assertEqual(cp.returncode, 0, cp.stdout + cp.stderr)
            data = json.loads(out.read_text())
            self.assertEqual(data["checks"][0]["status"], "PASS")

if __name__ == "__main__":
    unittest.main()
