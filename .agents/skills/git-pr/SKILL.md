---
name: git-pr
description: ブランチの変更を確認して自律的にPRを作成（英語）
user-invocable: true
---

Review current branch changes and autonomously create a PR as draft.

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
