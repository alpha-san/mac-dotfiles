# CLAUDE.md

## Commits

- Follow Conventional Commits (`feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `perf`, `style`, `build`, `ci`).
- Include the task ID in the commit message. If the work has both a ClickUp task and a GitHub issue, prefer the ClickUp ID.
- Do NOT append Claude as a co-author to commits. Omit the `Co-Authored-By: Claude` trailer entirely.

## Pull Requests

### Title

- Follows Conventional Commits with a single-sentence summary.
- Ends with the task ID in parentheses:
  - ClickUp: `(CU-123)`
  - GitHub issue: `(GH-123)`
- If both exist, use the ClickUp ID.

Example: `feat: add nil guard to practice medications controller (CU-456)`

### Description

Use the following sections, in order:

1. **Background** — summary of the problem and any context a reviewer needs to understand why this change exists.
2. **Changelog** — the concrete changes made to the code.
3. **Context-specific section(s)** — zero or more sections named appropriately for what's actually in this PR. Pick a heading that describes the content rather than a generic label. Examples:
   - New service or cron task: add a section like `## Usage` with an example snippet.
   - Query optimization: add `## Benchmarks` with before/after numbers.
   - Migration: add `## Rollout` with risks and ordering.
   - Schema change: add `## Schema` with the new fields and their purpose.
   Skip this entirely if the PR has nothing custom to call out.
4. **Testing** — step-by-step instructions for another developer to verify the change locally.
5. **Post-deploy** — remaining TODOs, things to monitor, feature flags to flip, metrics to watch.

## Git Worktrees

- **Worktree directory:** always create new worktrees under `~/workspace/worktrees/<branch-name>`. Do not create worktrees inside the project directory (no `.worktrees/`), and do not use `~/.config/superpowers/worktrees/`. The `~/workspace/worktrees/` location keeps isolated workspaces alongside the main project checkouts under `~/workspace/` but in their own dedicated parent.
- When creating a worktree you also need to copy `config/master.key` from the main project checkout into the new worktree — it is gitignored, so git does not track it, so it is absent from a fresh worktree checkout. Without it, Rails credentials cannot decrypt and specs fail with `ActiveRecord::Encryption::Errors::Configuration`.
