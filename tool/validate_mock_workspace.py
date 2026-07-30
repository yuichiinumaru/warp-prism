#!/usr/bin/env python3
"""Validate the mock workspace corpus against its manifest.

Reads assets/mock_workspace/manifest.yaml and walks the actual on-disk tree
to verify counts, required names, frontmatter presence, and pubspec alignment.

Exit code 0 = all checks pass, 1 = one or more failures.

Usage:
    python3 tool/validate_mock_workspace.py
    python3 tool/validate_mock_workspace.py --project-root apps/observatory
"""

import os
import re
import sys
import glob
import argparse
from pathlib import Path

try:
    import yaml
except ImportError:
    # Fallback: parse the simple manifest manually
    yaml = None


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def parse_manifest(path: Path) -> dict:
    """Read manifest.yaml — use PyYAML if available, else a simple parser."""
    text = path.read_text(encoding="utf-8")
    if yaml:
        return yaml.safe_load(text)

    # Minimal fallback parser for the known manifest structure
    import io
    data: dict = {}
    stack = [(data, -1)]
    for raw_line in text.splitlines():
        if not raw_line.strip() or raw_line.strip().startswith("#"):
            continue
        indent = len(raw_line) - len(raw_line.lstrip())
        line = raw_line.strip()

        # Pop stack to the correct parent level
        while len(stack) > 1 and indent <= stack[-1][1]:
            stack.pop()

        parent = stack[-1][0]

        if line.startswith("- "):
            # list item
            value = line[2:].strip().strip('"').strip("'")
            # find the most recent key that is a list
            if isinstance(parent, dict):
                for k in reversed(list(parent.keys())):
                    if isinstance(parent[k], list):
                        parent[k].append(value)
                        break
            elif isinstance(parent, list):
                parent.append(value)
        elif ":" in line:
            key, _, val = line.partition(":")
            key = key.strip().strip('"').strip("'")
            val = val.strip().strip('"').strip("'")
            if val == "":
                # Could be a dict or list child — peek at next line
                if isinstance(parent, dict):
                    parent[key] = {}
                    stack.append((parent[key], indent))
            else:
                if isinstance(parent, dict):
                    # Try int/float
                    try:
                        parent[key] = int(val)
                    except ValueError:
                        try:
                            parent[key] = float(val)
                        except ValueError:
                            parent[key] = val
    return data


def extract_frontmatter(text: str) -> dict | None:
    """Extract YAML frontmatter between --- delimiters."""
    if not text.startswith("---"):
        return None
    end = text.find("---", 3)
    if end == -1:
        return None
    fm_text = text[3:end].strip()
    if yaml:
        try:
            return yaml.safe_load(fm_text)
        except Exception:
            return {}
    # Minimal: just check non-empty
    return {"_raw": fm_text} if fm_text else {}


def basename_no_ext(path: str) -> str:
    return Path(path).stem


# ---------------------------------------------------------------------------
# Validators
# ---------------------------------------------------------------------------

def validate_counts(root: Path, manifest: dict) -> list[str]:
    """Validate file/directory counts against manifest."""
    errors = []
    counts = manifest.get("counts", {})

    # Agents
    agent_files = list((root / ".agents" / "agents").glob("*.md"))
    expected_agents = counts.get("agents", 0)
    if len(agent_files) != expected_agents:
        errors.append(
            f"agents: expected {expected_agents}, found {len(agent_files)}"
        )

    # Skills (directories with SKILL.md)
    skill_dirs = [
        d for d in (root / ".agents" / "skills").iterdir()
        if d.is_dir() and (d / "SKILL.md").exists()
    ]
    expected_skills = counts.get("skills", 0)
    if len(skill_dirs) != expected_skills:
        errors.append(
            f"skills: expected {expected_skills}, found {len(skill_dirs)}"
        )

    # Workflows
    workflow_files = list((root / ".agents" / "workflows").glob("*.md"))
    expected_workflows = counts.get("workflows", 0)
    if len(workflow_files) != expected_workflows:
        errors.append(
            f"workflows: expected {expected_workflows}, found {len(workflow_files)}"
        )

    # Tasks
    task_files = list((root / "docs" / "tasks").rglob("*.md"))
    expected_tasks = counts.get("tasks", 0)
    if len(task_files) != expected_tasks:
        errors.append(
            f"tasks: expected {expected_tasks}, found {len(task_files)}"
        )

    # Changelog
    changelog_files = list((root / "docs" / "changelog").glob("*.md"))
    expected_changelog = counts.get("changelog_entries", 0)
    if len(changelog_files) != expected_changelog:
        errors.append(
            f"changelog_entries: expected {expected_changelog}, found {len(changelog_files)}"
        )

    # Task lanes
    task_lane_dirs = [
        d for d in (root / "docs" / "tasks").iterdir()
        if d.is_dir()
    ]
    expected_lanes = counts.get("task_lanes", 0)
    if len(task_lane_dirs) != expected_lanes:
        errors.append(
            f"task_lanes: expected {expected_lanes}, found {len(task_lane_dirs)}"
        )

    return errors


def validate_required_names(root: Path, manifest: dict) -> list[str]:
    """Validate required agent/skill/workflow names exist."""
    errors = []

    # Agents
    for name in manifest.get("required_agents", []):
        path = root / ".agents" / "agents" / f"{name}.md"
        if not path.exists():
            errors.append(f"required agent missing: {name}")

    # Skills
    for name in manifest.get("required_skills", []):
        path = root / ".agents" / "skills" / name / "SKILL.md"
        if not path.exists():
            errors.append(f"required skill missing: {name}")

    # Workflows
    for name in manifest.get("required_workflows", []):
        path = root / ".agents" / "workflows" / f"{name}.md"
        if not path.exists():
            errors.append(f"required workflow missing: {name}")

    return errors


def validate_frontmatter(root: Path, manifest: dict) -> list[str]:
    """Validate that changelog entries have frontmatter with required fields."""
    errors = []
    required_fields = manifest.get("changelog_frontmatter_schema", [])

    changelog_dir = root / "docs" / "changelog"
    for md_file in sorted(changelog_dir.glob("*.md")):
        text = md_file.read_text(encoding="utf-8")
        fm = extract_frontmatter(text)
        if fm is None:
            errors.append(f"no frontmatter: {md_file.name}")
            continue
        if not fm:
            errors.append(f"empty frontmatter: {md_file.name}")
            continue
        # If we have PyYAML, check required fields
        if yaml and isinstance(fm, dict) and "_raw" not in fm:
            for field in required_fields:
                if field not in fm:
                    errors.append(
                        f"missing field '{field}' in {md_file.name}"
                    )

    return errors


def validate_task_lanes(root: Path, manifest: dict) -> list[str]:
    """Validate task lane IDs match manifest."""
    errors = []
    expected_lanes = {lane["id"] for lane in manifest.get("task_lanes", [])}
    actual_lanes = {
        d.name for d in (root / "docs" / "tasks").iterdir() if d.is_dir()
    }
    if expected_lanes and expected_lanes != actual_lanes:
        missing = expected_lanes - actual_lanes
        extra = actual_lanes - expected_lanes
        if missing:
            errors.append(f"missing task lanes: {sorted(missing)}")
        if extra:
            errors.append(f"unexpected task lanes: {sorted(extra)}")
    return errors


def validate_pubspec_alignment(project_root: Path, corpus_root: Path) -> list[str]:
    """Verify pubspec.yaml asset declarations match actual directories."""
    errors = []
    pubspec_path = project_root / "pubspec.yaml"
    if not pubspec_path.exists():
        errors.append("pubspec.yaml not found")
        return errors

    pubspec_text = pubspec_path.read_text(encoding="utf-8")

    # Extract asset paths from pubspec
    asset_pattern = re.compile(r"^\s+-\s+(assets/mock_workspace/\S*)", re.MULTILINE)
    declared_assets = asset_pattern.findall(pubspec_text)

    for asset_path in declared_assets:
        full_path = project_root / asset_path
        if asset_path.endswith("/"):
            if not full_path.is_dir():
                errors.append(f"pubspec declares missing dir: {asset_path}")
        else:
            if not full_path.is_file():
                errors.append(f"pubspec declares missing file: {asset_path}")

    # Also check that key directories exist
    key_dirs = [
        "assets/mock_workspace/.agents/agents",
        "assets/mock_workspace/.agents/skills",
        "assets/mock_workspace/.agents/workflows",
        "assets/mock_workspace/docs/tasks/00-planning",
        "assets/mock_workspace/docs/tasks/01-open",
        "assets/mock_workspace/docs/tasks/02-doing",
        "assets/mock_workspace/docs/tasks/03-review",
        "assets/mock_workspace/docs/tasks/04-completed",
        "assets/mock_workspace/docs/changelog",
    ]
    for d in key_dirs:
        full = project_root / d
        if not full.is_dir():
            errors.append(f"expected directory missing: {d}")

    return errors


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def resolve_default_project_root() -> Path:
    """Prefer monorepo app root when the historical package-root corpus moved.

    Layout after Melos migration:
      apps/observatory/assets/mock_workspace/manifest.yaml  (canonical)
    Historical layout:
      assets/mock_workspace/manifest.yaml  (repo/package root)
    """
    tool_parent = Path(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    monorepo_app = tool_parent / "apps" / "observatory"
    monorepo_manifest = monorepo_app / "assets" / "mock_workspace" / "manifest.yaml"
    legacy_manifest = tool_parent / "assets" / "mock_workspace" / "manifest.yaml"

    if monorepo_manifest.is_file():
        return monorepo_app
    if legacy_manifest.is_file():
        return tool_parent
    # Fall back to monorepo app when present so missing-corpus errors name the
    # live expected path rather than the abandoned root assets/ tree.
    if monorepo_app.is_dir():
        return monorepo_app
    return tool_parent


def main():
    parser = argparse.ArgumentParser(description="Validate mock workspace corpus")
    parser.add_argument(
        "--project-root",
        default=None,
        help=(
            "Project root containing assets/mock_workspace/ "
            "(default: apps/observatory when its manifest exists, else parent of tool/)"
        ),
    )
    args = parser.parse_args()

    project_root = Path(args.project_root) if args.project_root else resolve_default_project_root()
    corpus_root = project_root / "assets" / "mock_workspace"
    manifest_path = corpus_root / "manifest.yaml"

    print("=" * 60)
    print("Mock Workspace Corpus Validator")
    print("=" * 60)
    print(f"Project root : {project_root}")
    print(f"Corpus root  : {corpus_root}")
    print(f"Manifest     : {manifest_path}")
    print()

    if not manifest_path.exists():
        print("FATAL: manifest.yaml not found at", manifest_path)
        sys.exit(1)

    manifest = parse_manifest(manifest_path)
    print("Manifest loaded successfully.")
    print()

    all_errors: list[str] = []

    # 1. Counts
    print("--- Count Validation ---")
    count_errors = validate_counts(corpus_root, manifest)
    all_errors.extend(count_errors)
    if count_errors:
        for e in count_errors:
            print(f"  FAIL: {e}")
    else:
        print("  PASS: all counts match manifest")
    print()

    # 2. Required names
    print("--- Required Names ---")
    name_errors = validate_required_names(corpus_root, manifest)
    all_errors.extend(name_errors)
    if name_errors:
        for e in name_errors:
            print(f"  FAIL: {e}")
    else:
        print("  PASS: all required agents, skills, workflows present")
    print()

    # 3. Frontmatter
    print("--- Frontmatter Validation ---")
    fm_errors = validate_frontmatter(corpus_root, manifest)
    all_errors.extend(fm_errors)
    if fm_errors:
        for e in fm_errors:
            print(f"  FAIL: {e}")
    else:
        print("  PASS: all changelog entries have valid frontmatter")
    print()

    # 4. Task lanes
    print("--- Task Lane Validation ---")
    lane_errors = validate_task_lanes(corpus_root, manifest)
    all_errors.extend(lane_errors)
    if lane_errors:
        for e in lane_errors:
            print(f"  FAIL: {e}")
    else:
        print("  PASS: task lanes match manifest")
    print()

    # 5. Pubspec alignment
    print("--- Pubspec Alignment ---")
    pub_errors = validate_pubspec_alignment(project_root, corpus_root)
    all_errors.extend(pub_errors)
    if pub_errors:
        for e in pub_errors:
            print(f"  FAIL: {e}")
    else:
        print("  PASS: pubspec.yaml asset declarations align with disk")
    print()

    # Summary
    print("=" * 60)
    if all_errors:
        print(f"VALIDATION FAILED: {len(all_errors)} error(s)")
        print("=" * 60)
        sys.exit(1)
    else:
        print("VALIDATION PASSED: all checks OK")
        print("=" * 60)
        sys.exit(0)


if __name__ == "__main__":
    main()
