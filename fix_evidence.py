with open("docs/tasks/02-doing/1305-warp-prism-catalog-contract-expansion.md", "r") as f:
    text = f.read()

import re
old_evidence = re.search(r'## Completion Evidence\n\n- \*\*Files created/modified\*\*:.*?\n---', text, flags=re.DOTALL)
if old_evidence:
    new_evidence = """## Completion Evidence

- **Files created/modified**:
  - `apps/catalog/test/widget_test.dart` — expanded from 1 smoke test to 9 contract tests (using Prism* API)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` — fixed layout overflow for scale test
  - `docs/changelog/2026-06-09-task-1305-catalog-contract-expansion.md` — localized changelog entry
- **Tests or validation commands**:
  - `cd apps/catalog && dart format --output=none --set-exit-if-changed test/widget_test.dart` → PASS (0 changed)
  - `cd apps/catalog && flutter analyze test/widget_test.dart` → PASS (0 issues)
  - `cd apps/catalog && flutter test --concurrency=1 test/widget_test.dart` → PASS (9/9)
- **Local changelog entry**:
  `docs/changelog/2026-06-09-task-1305-catalog-contract-expansion.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-30 (Wave 2 Fixes)

---"""
    text = text.replace(old_evidence.group(0), new_evidence)
    
with open("docs/tasks/02-doing/1305-warp-prism-catalog-contract-expansion.md", "w") as f:
    f.write(text)
