---
name: fix-ci
description: CIの失敗を自動診断して修正する。gh CLIでGitHub Actionsのログをフェッチしてエラーを解析・修正。
user-invocable: true
---

Let's fix whatever error we can find in CI using the `gh` CLI.

**Current branch:** `!`git branch --show-current``

**PR check status:**

```
!`gh pr checks 2>/dev/null || echo "No PR found for current branch"`
```

## Steps

1. **Analyse the check status above**: Identify which actions are failing
2. If nothing is broken, bail.
3. Fetch the logs for the broken action using `gh run view <run-id> --log-failed`
4. Make a quick plan on what needs to be fixed
5. Fix the error
6. Commit the fix using `/git-commit`
