---
name: git-branch
description: Review changes and create a branch
user-invocable: true
allowed-tools: Bash
---

Review the current state and create an appropriate branch.

**Current branch:** `!`git branch --show-current``

**Working tree status:**
```
!`git status --short`
```

**Diff stat:**
```
!`git diff --stat`
```

1. Run `git status` and `git diff` to understand what has changed
2. Autonomously decide the most appropriate branch name based on the changes
3. Create the branch

Naming convention:
- Prefix: feat/fix/refactor/docs/chore/test
- Format: {prefix}/{specific-content-in-kebab-case}
- Examples: feat/user-auth, fix/login-error, refactor/api-client
