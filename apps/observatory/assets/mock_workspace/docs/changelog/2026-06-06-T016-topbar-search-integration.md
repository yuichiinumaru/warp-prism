---
id: 2026-06-06-T016-topbar-search-integration
date: 2026-06-06
project: warp-prism
task: T016
type: feature
skills:
  - design-system-harness
  - frontend-quality-harness
workflows:
  - gt-code-review
impact:
  - topbar
  - search
  - filtering
---

# Topbar Search Integration

Integrated DSTopbar search bar with workspace corpus filtering across all surfaces.

## Why

Users need to filter assets by name, tag, or kind from the persistent topbar. Without search integration, navigating large workspaces requires scrolling through unfiltered lists.

## Changed

- DSTopbar searchBar wired to workspace filter state
- Search queries filter agents, skills, workflows, and tasks by name and tags
- Search bar collapses below DSBreakpoints.narrow (600px)
- DSSearchBar molecule integrated with filter chip group

## Evidence

- Task T016 in review lane
- DSTopbar renders search bar on medium+ layouts
- Search bar hidden on narrow layouts per breakpoint contract
