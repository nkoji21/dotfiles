---
name: git-worktree
description: Create an isolated git worktree for a task — either before starting work (clean slate) or after uncommitted changes exist (rescue mode). Always use this before implementing any non-trivial change to prevent work from mixing on the current branch.
user-invocable: true
allowed-tools: Bash
---

Create a git worktree so that work stays isolated on its own branch and never
mixes with other changes on the current branch.

## When to use

- **Before starting implementation** (preferred): invoke this first, then do
  all editing inside the worktree.
- **After uncommitted changes exist** (rescue mode): moves changes out of the
  current branch into a clean worktree.

## Step 1: Detect mode

Run `git status --short` to check for uncommitted changes.

- **No changes** → "pre-work mode": create the worktree, report the path, stop.
  The caller does all editing inside the worktree from here.
- **Changes exist** → "rescue mode": infer branch name from the changes, create
  worktree, copy files, report the path.

## Step 2: Determine branch name

### Pre-work mode
Use the task description provided by the caller, or ask if none was given.

### Rescue mode
Run `git diff --name-only && git ls-files --others --exclude-standard` to see
what changed, then choose a branch name that describes the changes.

Naming convention:
- Prefix: `feat` / `fix` / `refactor` / `docs` / `chore` / `test`
- Format: `{prefix}/{specific-content-in-kebab-case}`
- Examples: `feat/user-auth`, `fix/login-error`, `refactor/sc-suspense-migration`

## Step 3: Create the worktree

```bash
git worktree add /tmp/{branch-name} -b {branch-name} main
```

## Step 4: Rescue mode only — copy changed files

Copy all modified and untracked files into the worktree, preserving directory
structure:

```bash
cd $(git rev-parse --show-toplevel)
# Modified files:
git diff --name-only | xargs -I{} rsync -R {} /tmp/{branch-name}/
# Untracked files:
git ls-files --others --exclude-standard | xargs -I{} rsync -R {} /tmp/{branch-name}/
```

After copying, verify the files landed correctly:

```bash
cd /tmp/{branch-name} && git status
```

## Step 5: Report

Always report:
- **Worktree path**: `/tmp/{branch-name}`
- **Branch name**: `{branch-name}`
- **Mode**: pre-work or rescue
- In rescue mode: list the files that were copied

In **pre-work mode**, explicitly tell the caller:
> All editing must happen inside `/tmp/{branch-name}`. Do not edit files in the
> original working directory.

## Cleanup

The worktree must be removed by the caller after the PR is merged:

```bash
git worktree remove /tmp/{branch-name}
```

Or force-remove if the branch is already gone:

```bash
git worktree remove --force /tmp/{branch-name}
```

## Related Skills

- `pr-flow` / `pr-flow-ja` — Full PR workflow that invokes this skill in Phase 1
