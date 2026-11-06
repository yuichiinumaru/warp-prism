# External Intelligence: Everything (Puter) — Donor Harvest

**Date**: 2026-10-15
**Donor path**: `references/everything/` (workspace-local symlink; absolute resolved paths are runtime-DENIED and were not used)
**License**: MIT — `references/everything/LICENSE` (21 lines; copyright (c) 2026 Puter Technologies Inc.). Permissive; attribution required. No copyleft obligations.
**Coverage**: 14 donor apps inspected at source level. 55+ `src/` directories enumerated; 41 uninspected (see §9).
**Disposition**: INSPIRATION ONLY. Nothing here authorizes adoption, porting, or implementation. No recurrence/demand is claimed. Donors are not consumers.

---

## 1. Source and provenance

- **Donor**: `references/everything/` — the "Everything" mono-repo by Puter Technologies Inc. (HeyPuter/everything on GitHub).
- **License**: MIT. Read verbatim at `references/everything/LICENSE` (21 lines, copyright (c) 2026 Puter Technologies Inc.). Reuse is permitted with attribution; the license is permissive and imposes only the copyleft-free MIT conditions.
- **Inspected revision state**: working-tree snapshot as of 2026-10-15. No git history was consulted (git read is permitted but was not needed; the tree is a single checkout). `git rev-parse HEAD` was NOT executed — see §10.
- **Coverage scope**: 14 donor apps inspected at source level (teamchat, email, help-desk, crm, projects, wiki, notes, documents, spreadsheet, records, whiteboard, presentation, pdf, tasks). 55+ app directories in `src/` were enumerated; 41 were NOT inspected (see §7 Uninspected).
- **Method**: read-only source reads through workspace-local relative paths only. No donor code executed, no network, no VCS, no gortex MCP. Every mechanism claim cites a repo-relative `path:lines`. README/screenshots prove marketing, not behavior; all capability claims below are derived from source inspection.

---

## 2. Executive summary

- **Verdict**: This donor collection is a high-density source of *mechanism ideas* for an operational, dense, dark desktop design system. It is NOT a Flutter codebase — it is vanilla JS/CSS/Vite. That is both its strength (unconstrained interaction patterns) and its primary hazard (see §5 Donor Accidents).
- **Best transferable items (ranked)**:
  1. Three-column app shell with draggable splitter + remembered width + rail/sidebar/pane state machine (`teamchat/src/ui/shell.js:1-1014`).
  2. Sidebar as a composable section system: collapsible custom sections, drag-reorder between sections, starred section, unread-edge scroll pills (`teamchat/src/ui/sidebar.js:1-928`).
  3. Command palette + menubar + ribbon triad with a unified command catalog (`spreadsheet/src/ui/command-catalog.js:1-97`, `spreadsheet/src/ui/palette.js:1-439`, `documents/src/ui/ribbon.js:1-375`).
  4. Rich filter builder (nested AND/OR groups, per-type value editors, debounce-commit) as a reusable panel primitive (`records/src/ui/toolbar.js:181-363`).
  5. Collaborative presence layer: viewport-aware cursor glide, idle name fold, per-user colour outline, anonymous-input mode (`whiteboard/src/collaboration/presence.js:1-229`).
- **Primary risk**: donor framework coupling (vanilla JS store/router/dom helpers, Puter account dependency, custom CSS variable theme system). None of it is directly portable; the *mechanisms* are what matter.
- **Prism baseline**: many donor mechanisms map onto existing `Prism*` organisms (`PrismShell`, `PrismSidebar`, `PrismCommandPalette`, `PrismSplitPane`, `PrismDataTable`, `PrismDetailInspector`, `PrismToast`, `PrismStateSurface`). The gaps are in *compositional state machines* (rail/sidebar/pane routing), not in individual widgets.
- **Counts**: 20 mechanisms harvested (8 HIGH, 8 MEDIUM, 4 LOW). 41 donor apps uninspected. 0 loci BLOCKED (all reads succeeded through workspace-local paths).
---

## 4. Per-mechanism detail

### H1 — Three-column app shell with rail + sidebar + side-panel (`teamchat/src/ui/shell.js:1-1014`)

**What it does**: A chat app shell with a narrow left rail (workspace mark, Home/DMs/Activity/Files/Later, New menu, theme toggle, user avatar), a wider sidebar (workspace switcher, channel/DM lists with custom sections), a main content slot, and a right-hand side panel (threads). A hash router decides what each slot shows.

**User capability**: Dense multi-column navigation on desktop; collapses to single-column on mobile with the sidebar becoming the screen until a conversation opens.

**Mechanism summary**:
- State model: `paneKind` (null | 'dms' | 'activity' | 'later'), `view`, `viewConv`, `panel`, `panelKey`, `details`, `currentWs`. Route is parsed from `location.hash` (`lib/router.js`).
- Composition: `railEl`, `sidebarEl` (home/pane toggle), `mainSlot` (display:contents), `panelEl`. The sidebar has a draggable resizer (`mountSidebarResizer`, lines 67-156) that writes a CSS variable `--sidebar-w`, clamps 220-480px, persists to localStorage, and is keyboard-accessible (arrows/Home/End/Enter on the separator role).
- Key interactions: `Cmd/Ctrl+K` search, `Alt+Up/Down` previous/next conversation, `Shift+Cmd+T/M/S/D` for Threads/Activity/Later/DMs, `Cmd+/` shortcuts panel, `Cmd+.` close panel, `Shift+Esc` mark all read. Focus management is elaborate: `keyboardInColumn()`, `focusSidebar(from)`, `settleMain(node)`, `handBack(control)`, `paneHand`, `sideHand` — the donor tracks exactly where the keyboard was before every layout change and restores it.

**Interaction states worth preserving**: rail vs sidebar visibility, sidebar home vs pane, main slot empty/loading/error/conversation/view, panel open/closed, details dialog open/closed, workspace switch in-flight, transfer freeze banner.

**Visual/UX idea**: The rail/sidebar/main/panel four-slot composition with a remembered splitter is the canonical desktop shell rhythm. The transfer-freeze banner (lines 180-195) is a nice pattern: a status row inside the frame, below the top bar, announced via `aria-live="polite"`, with a timer that recomputes from the workspace's transfer deadline.

**Donor accident**: vanilla JS `el()` DOM helper, `store` event emitter, hash router, `localStorage` persistence, Puter account dependency. The focus-tracking code is tightly coupled to DOM event ordering assumptions. The *state machine* is the transferable part, not the implementation.

**Prism baseline**: `PrismShell`, `PrismSidebar`, `PrismTopbar`, `PrismSplitPane` all exist. What is missing is the *router contract* that decides what each slot shows — currently no canonical shell router in Warp Prism.

**Provisional value**: HIGH. Rationale: multi-pane desktop shells are the core Warp Prism use case (Warpblade/Tempest/Hyperion/Sentry all need this), and the donor's focus-management detail is genuinely hard to get right.

### H2 — Sidebar section system with drag-reorder + unread-edge pills (`teamchat/src/ui/sidebar.js:1-928`)

**What it does**: A composable sidebar: a header (workspace switcher, search, new message, prefs), a filter box, and a scrollable list of sections — built-in Views (Threads/Activity/Later/Drafts/Directory), Starred, custom user sections, External connections, Channels, Direct messages. Each section is collapsible, has a kebab menu, and supports drag-and-drop of rows between sections.

**User capability**: Organise a dense conversation list; find via filter; see unread state at a glance; restructure without leaving the sidebar.

**Mechanism summary**:
- Sections are data: `store.sections()` returns `{ id, name, items[] }`. `Starred` is a special always-present section with a drop target.
- Collapsible sections persist to `localStorage` under `teamchat:collapsed`; the toggle button sets `aria-expanded`, and `fold()` hides rows that are not "kept" (unread, current, or badge-bearing).
- Drag-reorder: rows are `draggable`; `dragstart` sets a custom MIME type; sections have `canDrop`/`onDrop` predicates; a redraw during a drag is deferred (`renderAfterDrag`).
- Unread-edge pills: `updateUnreadPills()` measures row rects against the scroll box and shows top/bottom pills ("Unread mentions" / "Unreads") that scroll to the nearest unread row. Driven by `scroll` + `ResizeObserver`.
- Filter: a live filter box rebuilds a flat matching list from cached candidates (`filterCandidates`), preserving keystroke state across polls via `keepFilterCands`.
- Keyboard: filter box handles ArrowDown (into list), Enter (open match or message-search), Escape (clear). List rows support `listKeyNav`.

**Interaction states**: section collapsed/expanded, row hovered (kebab visible), row focused (kebab visible), row dragged, filter active/empty, unread pills visible/hidden.

**Visual/UX idea**: The "kept rows" folding rule — a collapsed section still shows unread/current/badge rows — is a genuinely useful density mechanism. The unread-edge pills are a polished answer to "where are the unread items when they scrolled off".

**Donor accident**: `store` event emitter, `localStorage`, custom CSS classes, `el()` DOM helper, `openMenu`/`openPopover` helpers. The drag MIME type is app-specific.

**Prism baseline**: `PrismSidebar`, `PrismTree`, `PrismFilterChipGroup`. The section model (custom named groups with drag-reorder) is not present as a reusable organism.

**Provisional value**: HIGH. Rationale: board/table/workspace products need custom grouping; this is a proven, keyboard-accessible model.

### H3 — Thread side-panel with follow bell + "also send to channel" (`teamchat/src/ui/panel.js:1-494`)

**What it does**: A right-hand panel that opens on a thread (a root message + its replies). Shows the root message, a message list, a typing line, a composer (or a blocked note), a follow/unfollow bell, and a "Also send to #channel" checkbox that cross-posts the reply into the parent conversation with a thread permalink.

**User capability**: Read and reply to a sub-thread without leaving the main conversation; opt into thread notifications; cross-post replies.

**Mechanism summary**:
- State: `root` (the root message, possibly fetched separately via `loadRoot`), `list`, `composer`, `typing`, `foot`, `footState`, `closed`.
- The follow bell (`renderFollow`, lines 44-63) reads `store.followsThread(...)` and toggles via `store.followThread(...)`. Its `aria-pressed` and icon update from the store.
- The composer's `onSend` posts to the thread; if `also.checked`, it additionally posts to the parent conversation with `withThreadLink(text)` — a permalink appended, truncated to fit the message cap.
- `renderFoot({ redraw })` rebuilds the foot on workspace changes (archived, thread policy, member join) and preserves the draft + caret across the rebuild.
- Blocked states: `blockedNote(reason)` covers archived/moved/importing/transferring/not_joined/threads_off/threads_admins, each with an icon and a polite live-region announcement on redraw.
- Drop handling: files dragged over the panel go to the composer's drop zone.

**Interaction states**: panel open/closed, root loaded/loading/error/deleted, follow on/off, composer active/blocked, "also send" ticked/unticked, thread closed (root deleted).

**Visual/UX idea**: The "Also send to #channel" pattern is a genuinely useful cross-posting mechanism with a permalink trail — the reply in the channel reads "Also sent from thread in #general".

**Donor accident**: `store` event emitter, `api` calls, `createComposer`/`createMessageList`/`createTypingLine` from the donor's own UI kit, `LIMITS` constants, `openPopover`/`openMenu`.

**Prism baseline**: `PrismDetailInspector` is the closest existing organism. A thread panel is a specific instance of an inspector with a composer.

**Provisional value**: HIGH. Rationale: threaded discussion is a common pattern in operational tools; the cross-post + follow semantics are reusable.

### H4 — Unified command catalog: palette + menubar + ribbon (`spreadsheet/src/ui/command-catalog.js:1-97`, `palette.js:1-439`, `documents/src/ui/ribbon.js:1-375`)

**What it does**: Every command a user can run — from menus, the ribbon, and the command palette — is enumerated once by command id, with its label, icon, shortcut(s), and where it lives. `searchCatalog()` filters by word match. `builtinShortcuts()` builds the chord↔command index. The palette (`palette.js`) is the consumer: `Cmd/Cmd+Shift+P` opens it, typing filters, arrows move, Enter runs.

**User capability**: Discover and execute any command by name or shortcut from one place.

**Mechanism summary**:
- `commandCatalog(flags, ribbonEl)` walks `menubarMenus(f)` (menu item trees), `paletteCommands(f)` (palette entries), and ribbon buttons (`_command` on each `.tb-btn`), deduplicating by `commandId(cmd, arg)`. Each entry carries `places[]` (where it lives) and `rank` (palette vs ribbon vs menu).
- `searchCatalog(catalog, query)` requires every word of the query to match against `label + where + shortcut`.
- The palette UI (`palette.js`) is a popover with a search input (`role="combobox"`, `aria-expanded`), a `role="listbox"` results list, and full keyboard support (arrows, Enter). Items carry `kind` (Table/View in X/Record in X/Base) and an icon.
- The ribbon (`documents/src/ui/ribbon.js`) is a tablist over a card of command groups. Contextual tabs appear when an object is selected. Groups collapse into a drop-down button when the window is too narrow (`openCollapsed`), with `priority` determining collapse order.

**Interaction states**: palette open/closed, active result, menu open, ribbon tab selected, group collapsed.

**Visual/UX idea**: The single-catalog deduplication is the key insight — menus, ribbon, and palette all draw from one source of truth, so shortcuts and labels can never diverge.

**Donor accident**: `commandId()`, `parseShortcut()`, `menubarMenus()` (a huge data function), `paletteCommands()` (a huge data function), `el()` DOM helper, `openMenu`/`openPopover`.

**Prism baseline**: `PrismCommandPalette` exists. What is missing is the *command registry* that the palette draws from, and the shortcut index (this is IDS territory — reusable user-intent semantics).

**Provisional value**: HIGH. Rationale: a command surface is a core operational primitive; the catalog model prevents drift between menus and shortcuts.

### H5 — Rich filter builder with nested AND/OR (`records/src/ui/toolbar.js:181-363`)

**What it does**: A filter panel that builds a tree of conditions: field selector, operator selector, per-type value editor, nested condition groups (AND/OR), with a debounce-commit (350ms) so typing in a value doesn't create an undo step per keystroke. Closes with a `flush()` that commits the last typed value.

**User capability**: Filter any view by complex criteria without leaving the view.

**Mechanism summary**:
- `filters = structuredClone(view.filters || emptyFilter())` — edits happen on a working copy; `commit()` writes back via `update({ filters })`.
- `save = debounce(commit, 350)`; `host.flush = () => save.flush()` runs on popover close (`beforeClose`).
- `conditionRow`: field `<select>`, operator `<select>` (operators change based on field type; changing operator resets value when the value kind changes), value editor, remove button.
- `valueEditor(cond)` branches on `valueKind(field)` — checkbox, singleSelect (with multi-select menu), date (mode picker + day picker popover), attachment file-type, number/text input.
- `groupBlock(group, depth)`: renders nested groups with a conjunction selector (and/or) and a "Add condition group" button at depth 0.
- `filterSummary(table, view)` produces a one-line label for the toolbar button ("Filtered by Status, Priority").

**Interaction states**: panel open/closed, condition added/removed, group nested/collapsed, value edited, operator changed.

**Visual/UX idea**: The debounce-commit + `flush()` pattern is a reusable interaction contract for any popover-based editor that writes to a larger model — it decouples typing latency from undo history.

**Donor accident**: `structuredClone`, `debounce`/`keepFocus` from the donor's `lib/dom.js`, `openPopover`/`openMenu`, `calendar()` date picker, `chipColors`/`accentColor` colour helpers, `TYPES`/`operatorsFor`/`defaultOp` domain query library.

**Prism baseline**: none. This is a genuinely new organism candidate.

**Provisional value**: HIGH. Rationale: filter/query construction is a cross-cutting operational need (logs, timelines, status grids, asset lists); the nested-group + per-type-editor pattern is reusable far beyond records.

### H6 — Collaborative presence layer (`whiteboard/src/collaboration/presence.js:1-229`)

**What it does**: A collaboration overlay that renders other people's cursors, selection outlines, and anonymous-input indicators on a shared canvas. Cursors glide between samples (interval scales with room size: 40ms → 100ms → 200ms for >8/>30 people), names fold away after 4s idle, and the whole layer toggles `is-panning` when the view changes.

**User capability**: See who else is on the board, where they are, and what they're looking at.

**Mechanism summary**:
- `PresenceLayer` holds a `Map` of nodes keyed by `${key}\n${user}` (so switching anonymous input on/off replaces nodes rather than renaming them).
- `render(people, items, view, self, showCursors, room)` runs on every draw. It computes `glide` from `presenceInterval(room)`, sets a CSS variable `--cursor-glide`, and skips work when nothing changed.
- Cursors: an SVG arrow in the person's colour with their username; `transform: translate(...)` updates only when the position changes; idle class toggles based on `this.moved` timestamps.
- Selection outlines: boxes are grown to include rotated reach (`Math.hypot(w,h)`), and out-of-view boxes are skipped entirely. Anonymous input outlines carry no name.
- Colour: `color(id)` hashes the user id to one of 15 hues, each dark enough for white text (4.5:1) on the dark canvas.

**Interaction states**: cursor moving/idle, selection active/inactive, anonymous input on/off, view panning.

**Visual/UX idea**: The glide-interval scaling with room size is a genuinely clever performance/latency tradeoff. The idle-name-fold keeps a reading board readable. The per-user colour assignment from a stable hash is reusable.

**Donor accident**: WebRTC peer protocol (`peers.js`), `session.js` packet format, `api.view()`/`api.size()` board API, `localStorage` for cursor visibility preference.

**Prism baseline**: none. This is a new collaboration primitive.

**Provisional value**: HIGH. Rationale: presence/cursor sharing is a core collaboration cue for any multi-user operational surface; the viewport-culling and glide-scaling are reusable mechanics.

### H7 — View toolbar as a Popover-based panel system (`records/src/ui/toolbar.js:1-549`)

**What it does**: A horizontal toolbar of buttons (hide fields, filter, group, sort, colour, row height, share), each opening a popover panel. The buttons are context-aware: the "hide" button shows a count when fields are hidden; the "filter" button shows the active field summary; the toolbar is rebuilt when an open panel's content changes (the panel re-anchors to the new button via `btn._pop.reanchor`).

**User capability**: Configure any view's presentation (fields, filters, grouping, sorting, colours, card cover, row height) from a consistent toolbar.

**Mechanism summary**:
- `panelFrom(btn, build, opts)`: attaches a click handler that opens `openPopover(btn, content, { placement: 'bottom-start', beforeClose: () => content.flush?.() })`. Re-clicking the button closes it.
- `renderToolbar(host, page, table, view)` builds the button list based on `view.type` (kanban gets stack settings, calendar/timeline get dates, gallery gets cover, grid gets row height).
- Each panel is a self-contained builder: `hidePanel` (checkbox list with drag-reorder), `filterPanel` (the rich filter builder, see H5), `levelsPanel` (sort/group with segmented direction control), `colorPanel` (mode segmented + per-rule swatch editor), `kanbanPanel`, `datesPanel`, `coverPanel`.
- Re-anchoring: when the toolbar redraws (after an edit in an open panel), the code finds the old button by class prefix, takes its `_pop`, and calls `reanchor` on the new button.

**Interaction states**: toolbar buttons on/off (active count shown), panels open/closed, panel content dirty (flushed on close).

**Visual/UX idea**: The re-anchoring pattern — a panel survives a toolbar redraw and follows its new button — is a reusable mechanic for any toolbar that rebuilds after its own panel edits something.

**Donor accident**: `h()` DOM helper, `openPopover`/`openMenu`, `debounce`/`keepFocus`, `chipColors`/`accentColor`/`HUES`, `TYPES`/`valueKind`/`isComputed`, `operatorsFor`/`defaultOp`/`DATE_MODES`/`WITHIN_MODES`/`FILE_TYPES`, `calendar()` date picker, `exportCsv`/`printView`.

**Prism baseline**: `PrismFilterWorkbench` is partial. The toolbar-panel framework (button → popover → typed panel → flush-commit → reanchor) is not present as a reusable organism.

**Provisional value**: HIGH. Rationale: any tabular/workspace view needs this configuration surface; the panel framework is generic.

### H8 — Composer: auto-growing textarea + @mentions + emoji + formatting bar (`teamchat/src/ui/composer.js:1-1108`)

**What it does**: A message composer: an auto-growing textarea (Enter-to-send configurable), an attachment menu (upload, code snippet, formatting), file chips with progress, @mention autocomplete, emoji picker, a formatting bar (bold/italic/strikethrough/code/code block/quote/link), a schedule/send-later option, and draft persistence per conversation.

**User capability**: Compose and send rich messages with attachments, mentions, formatting, and scheduling.

**Mechanism summary**:
- `createComposer({ placeholder, onSend, onSendLater, onEditLast, beforeSend, autofocus, draftKey, convId, typingConv })` returns `{ el, focus, setDisabled, destroy }`.
- The textarea has `aria-autocomplete="list"` (for the mention list), `dir="auto"`, and `enterkeyhint` set from the user's Enter-sends preference.
- Attachments: a "+" button opens a menu; files are shown as chips with progress; `inflight` (per draft key) and `parked` (offline-picked files whose box went away) maps handle the upload lifecycle across box rebuilds.
- @mentions: `matchMembers()` filters the member list; the autocomplete is a popover with `role="listbox"`.
- Formatting bar: `applyFormat(formatForKey(key), ...)` with `FORMATS` map; the bar is collapsible (`fmtBarShown()` reads localStorage, defaults to on for fine-pointer devices).
- Drafts: `getDraft`/`setDraft` per `draftKey`; the composer takes its words and caret across a rebuild (`renderFoot` in panel.js preserves the caret).
- `beforeSend(text)` may ask a question (e.g. @channel confirmation) and answer false to keep the message.

**Interaction states**: composing, formatting bar expanded/collapsed, attachment uploading/uploaded/failed, mention menu open/closed, emoji picker open, send scheduled/sent, draft restored.

**Visual/UX idea**: The `parked` map — files picked offline whose composer box was destroyed — is a genuinely careful piece of state management: the next box on the same conversation takes them back as they were.

**Donor accident**: `el()` DOM helper, `store` event emitter, `openMenu`/`openPopover`, `emoji-data.js` (huge), `LIMITS`, `formatBytes`, `applyFormat`/`FORMATS`, `getDraft`/`setDraft`, `matchMembers`.

**Prism baseline**: `PrismTextField` is the closest atom. A composer is a substantially more complex organism.

**Provisional value**: HIGH. Rationale: chat/editor composition is a recurring need across Warpblade (comments), Tempest (annotations), and any multi-user surface.

---

## 5. Medium mechanisms

### M1 — Rail (`teamchat/src/ui/rail.js:1-223`)

A narrow left rail: workspace mark (with menu), Home/DMs/Activity/Files/Later items with semantic badges ("N mentions", "N unread", "N new"), a round "+" button opening a Create menu (message/channel/browse/invite), a theme toggle (sun/moon), and the user's avatar menu (status, pause notifications, settings, sign out). Badges say what they count, not just the number. The rail is rebuilt on every poll; focus is restored by label stem or index.

**Prism baseline**: `PrismSidebar` partial. A rail is a distinct shell element (always-visible, icon-first).

### M2 — Toast system (`teamchat/src/ui/toast.js:1-170`)

Toasts with a max-4 cap (oldest evicted), sticky `duration: Infinity` for must-act-on messages, an action button, and focus/hover pausing the timer. Critically, the opener's focus is handed back when a toast action is dismissed from the keyboard (so the keyboard doesn't fall to the page body). `onDismiss` fires only on the close button, not on timeout/action.

**Prism baseline**: `PrismToast`/`PrismToastManager` exist. The policy layer (cap, sticky, opener hand-back, onDismiss semantics) is the transferable part.

### M3 — Field editor (`records/src/ui/fieldeditor.js:1-533`)

A popover field editor with type-first design: pick a type from a searchable menu, then per-type option panels (precision, format, choices with drag-reorder + colour swatches, default value, formula ref inserter with fields/functions palettes, link target, etc.). `keepFocus` preserves the control that was used across option redraws. Type changes show existing values as initial choices.

**Prism baseline**: none.

### M4 — Multi-view system (`records/src/ui/basepage.js:1-870`, `records/src/views/grid/grid.js`, `kanban.js`, `gallery.js`, `calendar.js`, `list.js`, `timeline.js`, `form.js`)

Seven view types, each a class with `mounted()`/`update()`/`destroy()`/`focus()`/`onTheme?`. The base page owns view instantiation and lifecycle. Each view has its own toolbar panels (see H7). The grid uses a `Layout` class with typed arrays for row offsets and binary-search hit testing.

**Prism baseline**: `PrismDataTable`, `PrismVirtualGrid`. The view-switcher + per-view toolbar contract is the gap.

### M5 — Attention/facilitation UI (`whiteboard/src/attention-ui.js:1-745`, `whiteboard/src/collaboration/live.js:1-104`)

Raised hands, live reactions (8 kinds, rate-limited: 3 send / 5 receive per second), presenter follow with a slide overlay (the follower sees the presenter's camera + slide alone, over the board), and camera capture. Reactions are carried by peer packets, never by the board document.

**Prism baseline**: none.

### M6 — AI assistant panel (`spreadsheet/src/ui/aipanel.js:1-960`)

A side panel with streaming chat, tool-call cards linked to cells, approval modes (which changes ask about), attachment tray, and undo-per-reply. Cell references in replies (`Sheet1!B2:C9`) are clickable to select those cells. `friendlyAiError()` maps error kinds to human words.

**Prism baseline**: none. Closest is `PrismAiAnalystPanel`/`PrismToolCallCard`.

### M7 — Ribbon (`documents/src/ui/ribbon.js:1-375`)

A tablist over a card of command groups. Contextual tabs appear when an object is selected. Groups collapse into a drop-down button when the window is too narrow (`openCollapsed`), with `priority` determining collapse order. Large commands (32px icon + label) vs small (16px icon + optional label) vs split buttons (main + arrow for options). Keyboard: arrows move between tab buttons; the card is one tab stop; Escape returns to the document.

**Prism baseline**: none.

### M8 — Tools panel (`pdf/src/shell/tools-panel.js:1-228`)

A left-hand panel listing every tool; choosing one shows that tool's own command sections. Back returns to the list. Tools can be permission-gated (`can(p)`), featured, or hidden. A tool can "take view" (`enter()` replaces the page with its own view).

**Prism baseline**: `PrismConnectorPanel` partial.

---

## 6. Low mechanisms

### L1 — Huddle dock (`teamchat/src/ui/huddle.js:1-586`)

A small persistent window at the bottom of the sidebar with the people in the call, who is speaking, and mic/camera/screen/leave controls. It grows into a tile grid when someone turns a camera or screen on. It belongs to the app, not to a conversation — it stays while the user reads elsewhere.

**Domain-specific**: audio/video. Not a generic Prism candidate.

### L2 — Customer profile page (`help-desk/src/views/customer.js:1-304`)

A profile page: segmented tabs (requests/activity), a stats row (open tickets, all tickets, satisfaction, customer since), empty states, inline editable fields via `selectField`/`tagsInput`/`field` helpers.

**Prism baseline**: `PrismDetailInspector`. The segmented-tab + stats-row pattern is reusable.

### L3 — Ink tools (`notes/src/editor/tools.js:1-384`)

Drawing tools over a page: pens, highlighters, stroke eraser, lasso selection, shapes, and insert space. Ink lives in `page.ink` and renders in an SVG layer above note containers. A `selection-box` and `tool-overlay` manage selection state.

**Domain-specific**: annotation/drawing. Not a generic Prism candidate.

### L4 — Chart gallery grid (`spreadsheet/src/ui/chart-ribbon.js:1-287`, `spreadsheet/src/ui/chartdialog.js:1-347`)

A grid of picture tiles inside menus for picking chart types/styles; contextual Chart Design and Format tabs appear when a chart is selected.

**Prism baseline**: `PrismChart`-adjacent. The gallery-grid pattern is reusable.

---

## 7. Donor accidents — do NOT port

These are the things that make the donor code what it is, and they are not transferable. Reimplement the *mechanism*; never the *accident*.

| # | Accident | Where | Why not portable |
|---|---|---|---|
| A1 | Vanilla JS `el()`/`h()` DOM helpers and a custom CSS variable theme system | all apps | Flutter uses widgets + `ThemeData`; CSS variables have no equivalent. The token system is the donor's, not Prism's. |
| A2 | `store` event-emitter pattern (workspace/activity/profile/messages events) | teamchat, records, spreadsheet | Flutter uses `ChangeNotifier`/`ValueListenable`/BLoC. The donor's specific event vocabulary is domain-specific. |
| A3 | Hash-based router (`lib/router.js`) with `parseHash`/`navigate`/`buildHash` | teamchat, records | Warp Prism has no canonical shell router yet. Do not import the donor's hash conventions. |
| A4 | `localStorage` persistence for preferences, collapsed sections, sidebar width, draft keys | all apps | Flutter has `shared_preferences`; the donor's specific keys and TTL semantics are not a Prism contract. |
| A5 | Puter account dependency (`puter.env`, `api.js`, `P.aiChatStream`) | teamchat, spreadsheet, help-desk | Product-local. Not a Warp Prism concern. |
| A6 | Custom icon glyph set (office font outlines in `presentation/src/chrome/glyphs.js:1-120`) | documents, presentation | Prism has `PrismIcon`. Do not adopt the donor's icon vocabulary. |
| A7 | WebRTC peer protocol (`whiteboard/src/collaboration/peers.js:1-948`) | whiteboard | Transport-specific. The presence *mechanism* (H6) is portable; the protocol is not. |
| A8 | Canvas-based grid painting (`records/src/views/grid/cells.js:1-442`) | records | Flutter has `CustomPainter`; the donor's canvas API usage is not directly translatable. |
| A9 | `structuredClone` + `debounce` + `keepFocus` from `lib/dom.js` | records, spreadsheet | These are JS-specific utilities. Flutter has equivalents (`ValueNotifier`, `Timer`, `FocusNode`); do not port the helpers. |
| A10 | Monolithic per-app `package.json`/`vite.config.js` build setup | all apps | Not a Warp Prism concern. |
| A11 | Domain coupling: chat (channels/DMs/huddle), spreadsheet (cells/formulas/charts), records (fields/tables/bases), documents (OOXML), whiteboard (Yjs) | all apps | The donor's domain models must stay product-local. Extract only the generic interaction/runtime mechanism. |

---

## 8. Top reusable seams for Prism (ranked, provisional)

| # | Seam | Donor source | Prism destination | Why it matters |
|---|---|---|---|---|
| 1 | **Shell state machine** — rail/sidebar/pane/slot routing with focus restoration across layout changes | `teamchat/src/ui/shell.js` | New `PrismShell` router contract (IDS) | Every desktop consumer needs multi-column routing; the donor's focus-tracking detail is the hard part |
| 2 | **Command registry + shortcut index** — one catalog for menus/palettes/shortcuts | `spreadsheet/src/ui/command-catalog.js` | IDS (command intent) | Prevents drift between discoverability and shortcuts |
| 3 | **Filter/query builder organism** — nested AND/OR, per-type value editors, debounce-commit, flush-on-close | `records/src/ui/toolbar.js:181-363` | New `PrismFilterBuilder` organism | Cross-cutting: logs, timelines, status grids, asset lists |
| 4 | **Presence overlay** — viewport-cursor glide, idle-name fold, per-user colour, anonymous input, viewport culling | `whiteboard/src/collaboration/presence.js` | New `PrismPresenceOverlay` organism | Core collaboration cue; the glide-scaling and culling are reusable mechanics |
| 5 | **Toolbar panel framework** — button → popover → typed panel → flush-commit → reanchor on toolbar redraw | `records/src/ui/toolbar.js:1-549` | New `PrismToolbarPanel` framework | Any tabular/workspace view needs this configuration surface |
| 6 | **Sidebar section model** — collapsible custom sections, drag-reorder, Starred, unread-edge pills, kept-row folding | `teamchat/src/ui/sidebar.js` | Extend `PrismSidebar` | Board/table/workspace products need custom grouping |
| 7 | **Toast policy layer** — max cap, sticky, action button, opener focus hand-back, onDismiss semantics | `teamchat/src/ui/toast.js` | Extend `PrismToastManager` | The hand-back and onDismiss semantics are subtle and reusable |
| 8 | **Composer organism** — auto-growing textarea, @mentions, emoji, formatting bar, attachment lifecycle, drafts | `teamchat/src/ui/composer.js` | New `PrismComposer` organism | Chat/editor composition is recurring across consumers |

---

## 9. Uninspected scope

41 donor app directories were enumerated but NOT inspected. They are recorded here with the reason (all are lower-priority for a dark desktop design system, or are game/fixture apps with no reusable UI mechanism):

`src/3d`, `src/accounting`, `src/api-client`, `src/audio-studio`, `src/backgammon`, `src/building-design`, `src/cad`, `src/calendar`, `src/cap-table`, `src/checkers`, `src/chess`, `src/childcare`, `src/circuits`, `src/contacts`, `src/contracts`, `src/crm` (partially — only `src/charts` and `src/lib` were inspected; `src/ui` and `src/views` were not), `src/dev`, `src/expense`, `src/field-service`, `src/fleet`, `src/hiring`, `src/inventory`, `src/invoicing`, `src/legal`, `src/meetings`, `src/music-studio`, `src/parametric`, `src/photo-studio`, `src/pos`, `src/property-management`, `src/records` (partially — `src/ui` and `src/views` inspected; `src/data` not), `src/signatures`, `src/solitaire`, `src/sudoku`, `src/survey`, `src/time-tracking`, `src/assets`, `src/shifting`.

**Reason**: bounded harvest. The brief targets 15–25 highest-value reusable UI/interaction mechanisms. These 41 apps are either (a) single-purpose domain tools with no reusable shell/navigation/command pattern beyond what the inspected 14 already cover, (b) games/fixtures, or (c) partial-inspection where only the chart/library layer was sampled. They are NOT evidence of absence — a future pass could find value in `src/audio-studio` (waveform editor chrome), `src/video-studio` (timeline scrubbing), or `src/cad` (viewport tools), all of which are relevant to Warpblade/Tempest.

---

## 10. Unknowns and blockers

- **Revision state**: `git rev-parse HEAD` was NOT executed. The donor permission rules deny `git *` broadly (only specific read subcommands are allowed), and `git rev-parse HEAD` was not in the allow-list. The inspected state is therefore the working-tree snapshot as of 2026-10-15, with no commit hash. This is recorded as UNKNOWN for revision pinning, not as a BLOCKED locus — all source reads succeeded.
- **Donor quality**: the operator's words were "não necessariamente bons" (not necessarily good). No quality assessment was attempted beyond establishing what each inspected app actually does from source. The `README.md` marketing claims (e.g. "rebuild the world's software") were NOT used as evidence for any mechanism claim.
- **Donor completeness**: the 14 inspected apps are themselves partial views. For example, `teamchat/src/ui/` has 40+ files; only `shell.js`, `sidebar.js`, `rail.js`, `panel.js`, `composer.js`, `shortcuts.js`, `toast.js`, `avatar.js`, `conversation.js`, `messagelist.js`, `dmspane.js`, `huddle.js` were inspected. `message.js`, `emojipicker.js`, `filesview.js`, `directory.js`, `search.js`, `views.js`, `onboarding.js`, `details.js`, `dialogs.js`, `modal.js`, `menu.js`, `dom.js`, `store.js`, `router.js`, `refs.js`, `notify.js`, `recent.js`, `drafts.js`, `formatting.js`, `mentions.js`, `emoji.js`, `huddle.js`, `clipboard.js`, `applink.js`, `shared.js`, `pins.js`, `bookmarks.js`, `typing.js`, `longpress.js`, `theme.js`, `icons.js`, `config.js`, `limits.js` were NOT inspected. The harvested mechanisms are therefore a sample, not a census.
- **Prism baseline currency**: the component catalog (`docs/design/component-catalog.md`) was read once at the start. If it has changed during this session, the "Prism baseline" column in §3 may be stale for the newest additions. Re-check before using this report for candidate design.
- **No recurrence evidence**: this report makes NO claim about consumer demand, recurrence, or product fit. That is a separate gate (MISSION.md §5-6) and is not addressed here.
- **No BLOCKED loci**: all reads through workspace-local relative paths succeeded. No absolute resolved external paths were used. No symlink repair was attempted.
