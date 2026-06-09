# Unified Visibility System for Skills, Workflows, Tasks, and Changelog

## Executive synthesis

Your current harness already behaves less like a loose `.agents/` folder and more like a governed operating system for agentic work. The imported corpus exposes generated indexes for **38 skills**, **42 agents**, and **43 workflows**, and the updated skills corpus includes a large hierarchical surface with super-skills, sub-skills, skill-local workflows, domain-skills, and interaction-skills. At that scale, a simple file browser or static markdown list will underperform; what you need is a **workspace observatory** that can show hierarchy, cross-references, provenance, and change over time in one place. fileciteturn0file7 fileciteturn0file5 fileciteturn0file6

The most important design conclusion from `harness-architecture` is that skills are not flat documentation assets. The harness uses a **Lobe Gateway** pattern in which a super-skill root acts as an index, while execution knowledge lives in sub-skills and skill-local workflows. It also enforces a stronger governance layer than a normal docs system: ASW scorecards gate new assets, workflows are supposed to live in the narrowest canonical home, and harness-management is explicitly audit-first and read-only by default. That means the frontend should not merely “list files”; it should expose **asset class**, **hierarchy**, **canonical home**, **routing intent**, and **governance status**. fileciteturn0file7

The most important design conclusion from `project-management` is that tasks and changelog are also not generic kanban/wiki artifacts. Recurring work is supposed to become workflows, RF8 is the planning-to-contract layer for complex work, task identity is lane-neutral, `docs/tasks/tasklist.md` is generated rather than manually edited, and `docs/changelog/*.md` is the canonical append-only changelog ledger while `CHANGELOG.md`, `CHANGELOG-FULL.md`, `docs/changelog/index.md`, and per-project views are generated projections. In delegated waves, child agents return evidence, but the parent orchestrator is the single writer for tasklist/changelog/memory closeout. The UI therefore has to distinguish **source-of-truth files** from **generated read models** and should preserve that governance boundary in the interaction design. fileciteturn0file7

My recommendation is to build **one desktop-first Flutter application** that contains two tightly-coupled domains: a **Harness Map** for agents/skills/workflows and an **Execution Ledger** for tasks/changelog. The two should share one data backbone, one graph/search layer, one storytelling layer, and one design system. The result should feel like an “ultradark obsidian glass” observatory, but underneath it should be ruthlessly structured, auditable, keyboard-friendly, and performant. That combination matches both your existing governance model and Flutter’s best-practice architecture guidance around separation of concerns, layered structure, and adaptive UI. fileciteturn0file7 citeturn14view2turn14view3turn12view2turn12view4

## What your current harness implies about the frontend

The frontend should be designed around the rules your skills already encode, not around generic “project management app” assumptions.

First, `harness-architecture` treats the harness as a governed system, not as “a pile of ad-hoc Markdown.” It explicitly says new skills and workflows should pass an ASW scorecard gate, that super-skills use a root index plus sub-skills, that workflow placement should prefer the owning super-skill over global `.agents/workflows/`, and that child-vs-parent drift should be audited and classified rather than auto-rewritten. `harness-management` also distinguishes parent-canonical assets, child-local overlays, promotion candidates, conflicts, and convergence status. That directly implies the UI needs provenance chips like **parent-canonical**, **child-local**, **promotion candidate**, **conflict**, **same-key-different**, and **workflow-promote-to-skill**, not just tags like “file type.” fileciteturn0file7

Second, `project-management` bakes in a very specific execution worldview. It states that recurring operational patterns should become workflows; RF8 is the upstream planning contract for complex work; task creation should enforce anti-collision numbering and reproducibility-by-design; task references should be lane-neutral; and tasklist/changelog are canonical-via-engine, not manually maintained ledgers. In other words, your task system is less a kanban board and more a **governed evidence pipeline**. The frontend should therefore emphasize **proof**, **dependencies**, **verification commands**, **expected outputs**, **current lane**, **historical lane-at-time**, and **which orchestrator is allowed to publish**. fileciteturn0file7

Third, the agent layer is already operationally rich. The generated agent index shows specialized architect, builder, reviewer, and researcher roles, plus orchestrators like `architect-orchestrator` and `builder-orchestrator`. The index also shows that many agents are disciplinary specialists, not generic assistants. A visibility system should therefore not show “agents” as a flat persona gallery. It should instead show **which assets each agent depends on**, **which workflows each role commonly enters**, and **which skill families dominate the current operating model**. fileciteturn0file5

The practical outcome is that the UI should model four different relationship types at minimum:

| Relationship type | Meaning in your system |
| --- | --- |
| **contains** | super-skill → sub-skill, skill → skill-local workflow |
| **routes-to** | gateway skill → sub-skill or workflow |
| **depends-on** | task/workflow/agent → skill/rule/script/reference |
| **governance-status** | canonical, overlay, promotion candidate, generated, append-only, read-only audit |

That relational model is much closer to your imported files than a naive tree explorer would be. fileciteturn0file7

## The skill and workflow visibility frontend

The skill side should center on a **Harness Map** with three synchronized views: **catalog**, **graph**, and **detail**.

The **catalog view** should break the workspace into top-level tabs for **Skills**, **Agents**, and **Workflows**, with saved filters for families such as super-skills, flat skills, browser-harness domains, orchestration agents, reviewer agents, and generated/global workflows. Because your skills use frontmatter with descriptions, triggers, related skills, sub-skill indexes, and explicit workflow associations, a catalog card can already expose much more than a title: it can show asset class, parent family, trigger density, workflow count, related-skills count, and provenance. That aligns directly with how `harness-architecture` expects new assets to be written and indexed. fileciteturn0file7

The **graph view** should be the differentiator. I would implement three graph modes:

- **Containment graph**: super-skill → sub-skills → local workflows.
- **Operational graph**: agents → primary skills → primary workflows.
- **Governance graph**: parent-canonical vs child-local vs promotion-candidate assets.

This matters because the root `SKILL.md` in the super-skill pattern is intentionally an index, not a full implementation, while sub-skills carry the action knowledge. A graph makes that architecture legible at a glance in a way a folder tree does not. fileciteturn0file7

The **detail view** for a skill should have six panels, all on one screen:

| Panel | What it should show |
| --- | --- |
| **Identity** | name, description, triggers, tags, canonical home |
| **Role in the harness** | gateway, flat execution skill, review harness, provider harness, etc. |
| **Sub-structure** | sub-skills, local workflows, references, scripts |
| **Incoming links** | agents/workflows/other skills that cite or route to it |
| **Operational usage** | common trigger phrases, likely entry workflow, boundary cases |
| **Governance** | scorecard evidence, archive lineage, drift flags, generated-index presence |

That last panel is especially important because your system already distinguishes “what exists” from “what is allowed to mutate.” A good visibility tool should make broken assumptions obvious before they become operational drift. fileciteturn0file7

I would also add a **Pathfinder** feature specifically for “how do I use this thing?” Given any selected skill, the UI should answer: **which agents tend to load it, which workflows mention it, which neighboring skills it routes into, and what evidence or scripts it expects**. That is the exact cognitive gap people hit in a mature harness: not “what files exist,” but “what is the right entry path?” The maturity of your current agent index strongly suggests this will save more time than another static index page. fileciteturn0file5 fileciteturn0file7

A final point: I would keep the initial release strictly **read-only**. That is fully consistent with `harness-management`, which emphasizes audit-first passes and reviewable suggestions rather than blind mutation. Later, if you want managed write actions, the UI should invoke the canonical scripts and workflows rather than directly editing generated or governed surfaces. fileciteturn0file7

## The task and changelog visibility frontend

The task and changelog side should center on an **Execution Ledger** rather than a normal kanban board.

The **task surface** should start with a lane board, because your tasks clearly live in canonical lanes under `docs/tasks/{00-planning,01-open,02-doing,03-review,04-completed}` and `docs/tasks/tasklist.md` is a built projection over those lanes. But the board should not stop at lane columns. Every task card should expose: task number, action type when present, dependency count, verification readiness, last evidence touch, review/fix-loop state, and whether its current lane matches its declared state. That last point is important because the skills explicitly warn against tasks in `03-review/` still declaring active work states. fileciteturn0file7

The **task detail page** should be more forensic than pretty. It should have a header with the lane-neutral identity (`Task NNNN` plus slug), followed by sections for contract, dependencies, validation commands, evidence, and lifecycle. Because `create-tasks` requires exact verification commands, expected semantic outputs, related-task references, and RF8 provenance for complex work, the frontend should parse and elevate those fields instead of burying them in markdown body text. The result should feel closer to a case file than a note. fileciteturn0file7

The **changelog surface** should not be designed as a dumb chronological feed. Your changelog engine explicitly says that `docs/changelog/*.md` is the canonical append-only ledger and that generated views like `CHANGELOG.md`, `CHANGELOG-FULL.md`, `docs/changelog/index.md`, and `docs/changelog/views/<project>.md` are projections. So the UI should preserve two modes: **Ledger mode** for canonical source entries and **Story mode** for grouped, derived narratives by project, milestone, task, or release. That mirrors your own architecture instead of flattening it. fileciteturn0file7

This is where UX research on storytelling becomes valuable. Recent research found that data stories can improve efficiency of comprehension tasks and improve effectiveness for single-insight comprehension compared with conventional visualizations, while DashGuide showed that guided dashboard tours can help users navigate interactions and understand the data model of a dashboard more effectively. For your use case, that means the changelog surface should not simply offer filters; it should offer **guided stories** such as “What changed in harness governance this month?”, “Which tasks clustered around a skill migration?”, and “Why did this review wave expand?” citeturn19academia0turn19academia1

I would therefore implement three changelog views:

| View | Best use |
| --- | --- |
| **Timeline** | exact historical sequence, append-only audit reading |
| **Project story** | per-project generated view with highlights and milestones |
| **Impact story** | change → affected tasks → affected skills/workflows/agents |

The **Impact story** view is the one that makes the whole system feel alive. It connects a changelog entry to the task that motivated it, the workflow that operationalized it, and the skill or harness area it mutated. That is where your project-management model and your harness-architecture model finally meet. fileciteturn0file7

## The best single system for both domains

The best answer to your items two through four is not “two apps with shared styling.” It is one system with two modes over one normalized graph.

I would structure the product as an **ASW Observatory** with four top-level workspaces:

| Workspace | Core question |
| --- | --- |
| **Map** | What exists and how is it related? |
| **Operate** | What work is active, blocked, or ready for review? |
| **History** | What changed, why, and with what proof? |
| **Governance** | What is canonical, generated, local, stale, or risky? |

Under the hood, the observatory should normalize everything into one graph model:

```text
Asset
├─ kind: agent | skill | subskill | workflow | task | changelog | rule | script | reference
├─ path
├─ canonicality: parent-canonical | child-local | generated | append-only | archive
├─ metadata
└─ edges[]
   ├─ contains
   ├─ routes-to
   ├─ depends-on
   ├─ references
   ├─ changed-by
   └─ proves
```

That model matches your actual workspace much better than separate “docs viewer” and “task viewer” apps would. A changelog entry can `changed-by` a task, that task can `depends-on` a workflow, that workflow can `routes-to` a skill, and that skill can be `contains` a sub-skill family. The value here is not just visualization; it is **navigable causality**. fileciteturn0file7

From a workflow point of view, I would release it in three phases.

The **first phase** should be read-only and local. It scans `.agents/agents`, `.agents/skills`, `.agents/workflows`, `docs/tasks`, and `docs/changelog`, builds a normalized index, and exposes search, graph, filters, and storytelling views. No mutation. No write-back. No accidental governance bypass. That is the safest and fastest path to usefulness. fileciteturn0file7

The **second phase** should add guided overlays and analyst features: bookmarks, personal notes, “spotlight tours,” saved graph layouts, and diagnostic views like “orphan workflows,” “skills with no agent affinity,” “tasks referencing stale lane paths,” or “assets with heavy incoming reference load.” Research on dashboard tours and embedded annotations suggests these kinds of guided interpretation layers improve how people navigate complex dashboards and relate findings to one another. citeturn19academia1turn19academia2

The **third phase** can add controlled execution hooks, but only by calling your canonical engines. For example, the UI can expose buttons like **Rebuild tasklist**, **Validate changelog**, **Run ASW audit**, or **Compare child harnesses**, but those actions should shell out to your existing scripts, not synthesize file writes directly. That preserves the governance model you already encoded in the skills. fileciteturn0file7

## Flutter atomic design and UX recommendations

The design system should follow an explicit atomic model, because your domain itself is hierarchical and compositional. Brad Frost’s atomic design frames interfaces as **atoms, molecules, organisms, templates, and pages**, and emphasizes that this is a mental model for understanding both the parts and the whole of a system at once. That maps unusually well onto your workspace because you already think in skill gateways, sub-skills, workflows, and orchestrated surfaces. citeturn24view0

For this app, I would map atomic design like this:

| Atomic layer | In this product |
| --- | --- |
| **Atoms** | typography tokens, icon tokens, status dots, badges, chips, dividers, canonicality colors |
| **Molecules** | searchable filter bars, provenance pills, trigger chips, evidence rows, mini task cards |
| **Organisms** | graph canvas, task lane board, changelog timeline, skill detail panel, guided-tour overlay |
| **Templates** | Harness Map template, Execution Ledger template, Story Mode template |
| **Pages** | concrete project/workspace instances with real content loaded |

That should live on top of Flutter’s theme system. Official Flutter guidance recommends centralizing app-wide styles in `ThemeData`, using `colorScheme` and `textTheme` as primary theme surfaces, and `ThemeExtension` for custom additions to `ThemeData`, typically custom color sets. For your case, `ThemeExtension` is exactly the right place to encode domain semantics such as **parent-canonical**, **child-local**, **promotion candidate**, **generated**, **append-only**, **blocked**, **review**, and **proof-complete** colors. citeturn7view5turn8view0turn9view0

For app architecture, the official Flutter guide recommends separation of concerns with **UI layer** and **Data layer**, further split into views/view models and repositories/services, with an optional domain layer for more complex app logic. It also recommends an MVVM-style one-to-one pairing between views and view models, and stresses well-defined interfaces and boundaries for maintainability, scale, and testability. That is a very strong fit here: use a data layer for file scanning and parsing, a domain layer for graph normalization and narration, and a UI layer for explorers/story views. citeturn14view2turn14view3

For routing and state, I would keep the architecture pragmatic rather than maximalist. Flutter’s own state-management guidance says the right choice depends on app complexity and team preference, and that community packages can reduce boilerplate and support clearer, more consistent architectures. In this specific case, **Riverpod** is a strong fit because the app will juggle async parsing, cached projections, derived filters, and testable separation between logic and UI; **go_router** is a strong fit because it is a declarative router with deep linking, data-driven routes, and `ShellRoute`, and it is published by `flutter.dev`. citeturn14view0turn22view1turn22view0

For the actual component-development workflow, **Widgetbook** is worth adopting early. Its documentation and pub package describe it as a sandbox for building widgets and screens in isolation, mocking hard-to-reach states, cataloging widgets in one place, and—through Widgetbook Cloud—running visual/golden review workflows. For a system where a single detail panel may have dozens of states across skill/task/changelog entities, that is extremely valuable. citeturn15view0turn15view2

For charts and graphing, a practical package stack is:

| Concern | Recommended package | Why it fits |
| --- | --- | --- |
| Routing | `go_router` | Declarative URL-based routing, deep linking, nested navigation, and `ShellRoute`; maintained under `flutter.dev`. citeturn22view0 |
| State/data orchestration | `flutter_riverpod` | Separates logic from UI, handles async/error/loading flows cleanly, and is pitched as testable, scalable, and reusable. citeturn22view1 |
| UI sandbox/catalog | `widgetbook` | Isolated widget/screen development, edge-state mocking, shared catalog, golden/visual review support. citeturn15view0turn15view2 |
| Charts | `fl_chart` | Highly customizable charting with line, bar, pie, scatter, and radar support. citeturn23view0 |
| Relationship graph | `graphview` | Supports hierarchical tree layouts, force-directed graphs, Sugiyama layered graphs, and auto-zoom/animation. citeturn23view2turn23view3 |

For adaptive UX, follow Flutter’s current guidance very closely. Flutter’s docs distinguish **responsive** design as fitting the UI into the available space and **adaptive** design as making the UI usable in that space; their best-practices pages recommend breaking down large widgets into smaller ones, not locking orientation, avoiding orientation-based top-level layout switches, not keying layout off device type, and switching navigation patterns such as bottom navigation versus `NavigationRail` according to available space. That maps directly to your product: on narrow widths use a bottom-nav or compact sidebar model; on wide screens use a permanent left rail plus a right-side inspector. citeturn10view4turn12view2turn12view4

For the **look and feel**, I would implement your “ultradark obsidian glass, 5% hacker, 5% protoss” request as a restrained palette rather than a maximal effect stack. Use a near-black base, one cool luminous accent, one warm warning accent, and a semantic status palette. Use glass only on high-value surfaces such as modal inspectors, not everywhere. Flutter’s performance docs warn that `saveLayer()` can be expensive, that opacity and clipping are costly, and that large lists/grids should use lazy builders and avoid unnecessary intrinsic layout passes. In practice, that means: minimal blur, no gratuitous translucent nesting, fixed density rules, lazy list/grid builders, and performance profiling from the start. If you do glassmorphism, do **sparse glassmorphism**. citeturn26view1turn26view2turn26view3

For accessibility, W3C’s WCAG guidance requires at least **4.5:1 contrast** for normal text and **3:1** for large text, and Flutter’s accessibility materials explicitly point to WCAG as a core standard. So even in an ultradark aesthetic, the typography and semantic controls cannot be vague-glow-on-near-black. Your hacker/protoss polish should come from accent edges, subtle motion, and iconography—not from compromising readability. Also ensure complete keyboard navigation, because Flutter’s adaptive guidance calls out keyboard support and accessible navigation as especially important on larger devices. citeturn20view0turn7view7turn12view2

The last UX recommendation is the most domain-specific: treat the product as a **storytelling console**, not just an admin dashboard. Research suggests data stories improve comprehension efficiency, and guided dashboard tours can materially help dashboard users understand interactions and extract insight. For your app, that means every major surface should answer three questions in one screen: **what exists**, **what matters right now**, and **why this changed**. The UI should constantly move users from overview to relationship to evidence. That is the right product shape for a harness this dense. citeturn19academia0turn19academia1

## Open questions and limitations

I can design the frontend direction with high confidence from the imported skills, workflows, and agent indexes, but I did **not** re-parse the full live `docs/tasks/` and `docs/changelog/` corpora in this pass. So the proposed parsers and visual contracts are strong at the governance level, but historical edge cases in older task headers, legacy changelog entries, and project-specific task conventions may still need one validation sweep against the actual live directories before implementation begins. fileciteturn0file7

I would also treat symlinked child-project surfaces as a first-class technical risk. `harness-management` clearly expects parent-canonical reuse, child-local overlays, and convergence audits. The frontend therefore needs safe path-resolution rules and provenance indicators from the first version, otherwise it will mislead you by presenting mirrored files as independent assets. fileciteturn0file7

With those caveats, the core answer is clear: **build one desktop-first Flutter observatory, keep version one read-only, model the workspace as a graph plus ledger, and let the UI reflect your governance doctrine instead of flattening it.** That is the direction most faithful to how your harness already thinks. fileciteturn0file7