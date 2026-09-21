# Flutter Reference Repo Sweep — Architectural Patterns Report

> **Date**: 2026-06-08
> **Author**: architects (subagent)
> **Scope**: 37 archived Flutter/Dart repos in `.archive/flutter-reference-repos-20260608/`
> **Purpose**: Extract frontend component patterns not yet captured in flutter-harness or task tree

---

## Top Reference Repos

| # | Repo | Architectural Value |
|---|------|-------------------|
| 1 | `dart_agent_core` | **Critical** — full Dart-native agent framework with streaming, eval, skills, controller hooks |
| 2 | `skill_tree` | **High** — custom RenderObject graph/tree/DAG visualization |
| 3 | `achieve-flutter-architecture` | **High** — production fintech architecture (6yr, 30+ features): DataPage lifecycle, caching, EventBus |
| 4 | `abhishek_doshi_portfolio` | **High** — responsive sections, animated stats, hover cards, values system |
| 5 | `flutter-binance-ui` | **Medium-High** — data-dense financial dashboard |
| 6 | `cocktails-demo` | **Medium** — parallax scroll, custom page transitions |
| 7 | `SkillSync-Flutter` | **Medium** — notification tiles, review cards, star rating, theme provider |
| 8 | `conalyz_cli` | **Medium** — Flutter accessibility static analysis tool (AST-based) |
| 9 | `agent-skills` | **Medium** — scenario→slice decomposition, session state, UI verification |
| 10 | `flutter-forge` | **Medium** — Mason templates + Clean Architecture + BDD testing |

---

## Critical Finding: `dart_agent_core`

The single most valuable repo. A **published Dart-native agent framework** (v1.0.13 on pub.dev) with:
- Full agentic loop with streaming, tool use, planning, skills, sub-agents
- Controller hooks for UI integration (approve/block tool calls, observe events)
- Typed streaming events: `modelChunkMessage`, `fullModelMessage`, `functionCallRequest`, `functionCallResult`, `modelRetrying`
- PlanState model: `PlanStep` with statuses (pending, in_progress, completed, cancelled)
- Dynamic skill toggle (forceActivate vs optional)
- Loop detector with confidence scoring
- EpisodicMemory with context compression
- Complete eval framework (EvalRunner, trials, graders, pass@k, transcript recording)

**Should be treated as primary reference architecture for Warp Prism agent runtime integration.**

---

## New Patterns NOT in Existing Flutter Harness

### Agent/Operational UI Patterns (MISSING from harness)

| Pattern | Source | Description |
|---------|--------|-------------|
| AgentController EventBus | `dart_agent_core` | Pub/sub with typed events (BeforeRun, BeforeLLM, BeforeTool, AfterTool, PlanChanged, AgentStopped) |
| Streaming text display | `dart_agent_core` | Incremental chunk assembly from stream events |
| Plan/progress display | `dart_agent_core` | Checklist with status icons per PlanStep |
| Tool call visualization | `dart_agent_core` | Expandable card: tool name, args JSON, result, success/fail |
| Skill toggle UI | `dart_agent_core` | Activate/deactivate agent skills at runtime |
| Loop detection warnings | `dart_agent_core` | Tool call signature tracking + LLM-based diagnosis |
| Context compression indicators | `dart_agent_core` | EpisodicMemory summary + original messages |
| Eval dashboard patterns | `dart_agent_core` | Trials, graders, pass@k metrics, markdown reports |
| Transcript viewer | `dart_agent_core` | Run listing, trial display, diff, export |
| Scenario→Slice decomposition | `agent-skills` | Knowledge as atomic capability slices |
| UI verification guards | `agent-skills` | `trtc_verify_ui.py` enforces minimum UI class usage per file |

### Graph/Tree Visualization (PARTIAL in harness)

| Pattern | Source | Description |
|---------|--------|-------------|
| Generic typed graph widget | `skill_tree` | `SkillTree<EdgeType, NodeType, IdType>` — type-safe |
| Custom RenderObject layout | `skill_tree` | `RenderSkillTree` with custom `performLayout` |
| Layered tree delegate | `skill_tree` | Layer-based positioning for kanban-like views |
| Positioned tree delegate | `skill_tree` | Absolute positioning for free-form graphs |
| Edge path builders | `skill_tree` | Cubic bezier, spline, polyline edge rendering |
| SkillTreeTheme via InheritedWidget | `skill_tree` | Theme propagation for graph components |
| Node reachability/unlockability | `skill_tree` | Graph traversal for prerequisite gates |

### Data-Dense Admin UI Patterns (MISSING from harness)

| Pattern | Source | Description |
|---------|--------|-------------|
| DataPage lifecycle | `achieve` | `onLoad`, `onRefresh`, `buildPage` — auto loading/error/retry |
| OperationRunnerState | `achieve` | `runOperation()` with overlay, error dialog, analytics |
| OverlayManager (app-level) | `achieve` | Global overlay survives screen disposal |
| PageReloaded EventBus | `achieve` | Child widgets independently refresh |
| Visibility-triggered animations | `portfolio` | `AnimationController.forward()` when >30% visible |
| Animated stat counter | `portfolio` | `IntTween` + `AnimatedBuilder` for metrics |
| Hover card pattern | `portfolio` | Default state + `onHoverChild` overlay |
| Section component model | `portfolio` | `section/{models,views,widgets}/` + barrel file |
| Notification tile | `SkillSync` | Type→icon mapping, unread dot, swipe-to-dismiss |
| Review card with async loading | `SkillSync` | Skeleton during load, `timeAgo` formatter |
| Parallax scroll card | `cocktails-demo` | `AnimatedPositioned` in Stack with scroll offset |
| Carousel with data models | `flutter-binance-ui` | Market data carousel with Candle model |

### Design Token Patterns

| Pattern | Source | Description |
|---------|--------|-------------|
| Dedicated values directory | `portfolio` | Separate files: colors, sizes, styles, strings, images, radius, shadows |
| Named size constants | `portfolio` | `Sizes.TEXT_SIZE_96`, `Sizes.ELEVATION_4` etc. |
| Shadow tokens | `portfolio` | Dedicated `shadows.dart` file |
| Multi-font TextTheme | `portfolio` | Different Google Fonts per text style level |
| Caching mixin (4 strategies) | `achieve` | `runPersistedQuery`, `runSecureQuery`, `runEphemeralQuery`, `runOperation` |

### Testing Patterns

| Pattern | Source | Description |
|---------|--------|-------------|
| BDD with Gherkin syntax | `flutter-forge` | `bdd_widget_test` for Given-When-Then |
| Eval runner with trials | `dart_agent_core` | Bounded concurrency, per-trial timeout, grader pipeline |
| Transcript recording | `dart_agent_core` | `EvalTranscriptRecorder` captures events for replay |
| Accessibility AST analysis | `conalyz_cli` | Rule-based accessibility engine with WCAG references |

---

## Recommended ADS Additions (Organisms)

| Component | Pattern Source | Purpose |
|-----------|--------------|---------|
| **AgentStatusBadge** | `SkillSync` + `dart_agent_core` | Status dot + label for agent state |
| **PlanProgressDisplay** | `dart_agent_core` PlanState | Checklist with status icons |
| **StreamingMessageView** | `dart_agent_core` StreamingEvent | Incremental text display |
| **ToolCallCard** | `dart_agent_core` ExecutionToolResult | Expandable card with args/result |
| **SkillToggle** | `dart_agent_core` | Activate/deactivate skills |
| **NotificationTile** | `SkillSync` | Type→icon, unread, swipe-to-dismiss |
| **HoverInfoCard** | `portfolio` SkillCard | Default + hover overlay |
| **AnimatedStatCounter** | `portfolio` | Counting metrics on visibility |
| **SkillNode / SkillEdge** | `skill_tree` | Graph visualization for DAGs |

---

## Harness Gap: Missing Sub-skill

**No sub-skill covers agent-specific UI patterns.** A new `agent-operational-ui` sub-skill should cover:
- Streaming text rendering
- Tool call visualization
- Plan/progress display
- Agent lifecycle state indicators
- Skill management UI
- Model usage/token visualization
- Loop detection / health warnings
- Context compression indicators
- Eval dashboard / transcript viewer
