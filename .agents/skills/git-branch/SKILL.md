---
name: git-branch
description: 変更内容を確認してブランチを作成
user-invocable: true
---

Review the current state and create an appropriate branch.

1. Run `git status` and `git diff` to understand what has changed
2. Autonomously decide the most appropriate branch name based on the changes
3. Create the branch

Naming convention:
- Prefix: feat/fix/refactor/docs/chore/test
- Format: {prefix}/{specific-content-in-kebab-case}
- Examples: feat/user-auth, fix/login-error, refactor/api-client
