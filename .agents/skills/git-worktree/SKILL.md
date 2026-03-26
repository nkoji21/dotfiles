---
name: git-worktree
description: 変更内容をもとにブランチ名を決定し、/tmp 配下に git worktree を作成して変更ファイルをコピーする
user-invocable: true
allowed-tools: Bash
---

Create a git worktree for the current changes so they can be worked on in isolation without affecting the current branch.

1. Run `git status` and `git diff` to understand what has changed
2. Decide the most appropriate branch name based on the changes

   Naming convention:
   - Prefix: feat/fix/refactor/docs/chore/test
   - Format: `{prefix}/{specific-content-in-kebab-case}`
   - Examples: feat/user-auth, fix/login-error, refactor/api-client

3. Create a worktree at `/tmp/{branch-name}` on a new branch from `main`:
   ```
   git worktree add /tmp/{branch-name} -b {branch-name} main
   ```

4. Copy all modified/untracked files from the current working directory into the worktree, preserving directory structure:
   ```
   # For each changed file shown in git status (macOS-compatible):
   rsync -R {file} /tmp/{branch-name}/
   ```

5. Report the worktree path and branch name to the caller.

## Cleanup

The worktree must be removed by the caller after work is complete:
```
git worktree remove /tmp/{branch-name}
```
