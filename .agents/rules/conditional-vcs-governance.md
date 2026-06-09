---
id: conditional-vcs-governance
title: Conditional VCS Governance
scope: universal
applies_to: [all-governed-repos]
triggers: [git, vcs, commit, push, branch, ci, pull request, jj, jujutsu]
priority: critical
status: active
---

# Conditional VCS Governance

## Purpose

Allow tightly governed Git operations when the user explicitly authorizes a
session or task to publish work, while preserving the historical safety lessons
that led to the original no-VCS rule.

## Default Mode

Agents default to **no VCS writes**.

Read-only diagnostics are allowed when needed to understand repository state:

- `git status`
- `git diff`
- `git log`
- `git show`
- `git blame`
- `git branch --show-current`
- `git remote -v`
- `git ls-files`
- `git rev-parse`

## Controlled Git Writes

The following commands require explicit user authorization for the current
session or task:

- `git add <explicit-reviewed-paths>`
- `git commit -m "<message>"`
- `git push origin <non-main-branch>`

Controlled writes require all gates below:

1. Run `git-worktree-hygiene` preflight and report the dirty surface.
2. Stage only an explicit allowlist of reviewed paths.
3. Never use `git add .`.
4. Confirm generated surfaces (`CHANGELOG.md`, tasklist, indexes) are current
   when they are part of the change.
5. Confirm secrets, large generated artifacts, build output, databases, and
   local caches are not staged.
6. Prefer branch/PR publication. Direct push to `main` is forbidden for agents
   unless the user explicitly overrides it in the same turn.
7. Treat CI and branch protection as the anti-damage gate for publication.

## Always Forbidden

Agents must not run:

- `git reset`
- `git restore`
- `git checkout -- <path>`
- `git clean`
- `git rm`
- `git stash`
- `git rebase`
- `git merge`
- `git cherry-pick`
- `git commit --amend`
- `git push --force`
- ref, tag, or branch deletion/manipulation
- `git config`
- `git init`

## Jujutsu Policy

`jj` remains disabled by default for agents. Do not use it until a dedicated
Jujutsu workflow and skill exist, including explicit protection against mixing
Git and Jujutsu operations in the same repository.

## Review Standard

Any VCS publication task must leave evidence of:

- explicit user authorization;
- preflight command output summary;
- staged path allowlist;
- validation commands;
- CI/PR link or reason CI is unavailable;
- rollback or revert strategy owned by a human.
