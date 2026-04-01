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
2. **Granularity check**: Before writing the PR, assess whether the changes belong to a single concern:
   - Group changed files by what they do (feature, test, config, infra, docs, etc.)
   - If changes span 2+ unrelated concerns (e.g. a feature AND an infra fix), stop and tell the user which concerns were identified and suggest splitting into separate PRs. Do not create the PR until the user confirms to proceed as-is or asks you to split.
   - A PR is appropriately sized if a reviewer can understand it in one sitting. More than ~400 changed lines or 3+ unrelated concerns is a signal to split.
3. If a PR template exists in the project, follow it
4. Autonomously decide the PR title and body, then create it with `gh pr create --draft`

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
**For readability, wrap long lines with a newline at natural break points (e.g. after a period or comma) so no line exceeds ~80 characters. Do not add blank lines between list items.**
