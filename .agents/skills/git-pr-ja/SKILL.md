---
name: git-pr-ja
description: Review branch changes and autonomously open a PR (Japanese)
user-invocable: true
---

Review current branch changes and autonomously create a PR as draft.

**Current branch:** `!`git branch --show-current``

**Commits since main:**
```
!`git log --oneline main..HEAD`
```

**Diff stat:**
```
!`git diff --stat main...HEAD`
```

1. Run `git log --oneline main..HEAD` and `git diff main...HEAD` to understand the changes
2. If a PR template exists in the project, follow it
3. Autonomously decide the PR title and body, then create it with `gh pr create --draft`

## PR Format (if no template exists)

close #{issue_number}
（関連issueがない場合はこの行を削除）

## Summary
なぜこの変更をしたか。実装内容ではなく動機を書く。

## Changes
変更の方針・構造レベルの概要のみ。実装詳細はFile Changesで確認できるので書かない。

## Notes
レビュアーに伝えるべき特記事項。不要なら削除。

**日本語で記述。**
**簡潔に。実装詳細はdiffに任せる。**
