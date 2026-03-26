---
name: git-pr
description: Review branch changes and autonomously open a PR (English)
user-invocable: true
allowed-tools: Bash
---

Review current branch changes and autonomously create a PR as draft.

**Current branch (source repo):** `!`git branch --show-current``

**Commits since main (source repo):**
```
!`git log --oneline main..HEAD`
```

**Diff stat (source repo):**
```
!`git diff --stat main..HEAD`
```

## Arguments

If a `--path <dir>` argument is provided (e.g. invoked as `git-pr --path /tmp/feat-foo`), all git and gh commands must be run inside that directory by prepending `cd <dir> &&` to every Bash command. This overrides the current working directory.

1. Run `git log --oneline main..HEAD` and `git diff main...HEAD` to understand the changes
2. If a PR template exists in the project, follow it
3. Autonomously decide the PR title and body, then create it with `gh pr create --draft`

## PR Format (if no template exists)

close #{issue_number}
(Remove this line if no related issue exists)

## Summary
Why this change was made. Focus on motivation, not implementation.

## Changes
High-level overview of the approach — not implementation details (those are visible in File Changes).

## Notes
Anything the reviewer should be aware of. Remove if unnecessary.

**Write all content in English.**
**Keep it concise. Implementation details belong in the diff, not the PR description.**
