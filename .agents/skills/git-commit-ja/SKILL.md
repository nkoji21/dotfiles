---
name: git-commit-ja
description: 変更内容を確認して自律的にコミット（日本語）
user-invocable: true
---

Review current changes and autonomously commit following Conventional Commits.

1. Run `git status`, `git diff`, and `git log --oneline -5` to understand the changes and context
2. Decide the commit message autonomously
3. Stage and commit using `git apply` (see below)

## Principle
- Write **Why** (why the change was made) in the commit message. Leave What to the diff.
- Each commit must be **independently revertable** without breaking other functionality.

## Commit Granularity
- 1 commit = 1 logical change
- Examine individual hunks, not entire files — split if needed
- Separate refactoring and feature additions
- Tests can be in the same commit as the main code
- Formatting-only changes should be separate

## Staging with git apply

Never use interactive commands like `git add -p`. Instead:

```bash
# 1. Generate patch for the target changes
git diff > patch.diff

# 2. Verify before applying (no file changes on failure)
git apply --cached --check patch.diff

# 3. Apply to staging area (equivalent to git add)
git apply --cached patch.diff
```

If `git apply --cached` fails, try in order:
1. `git apply --cached --whitespace=fix patch.diff`
2. `git apply --cached --ignore-space-change patch.diff`
3. Fall back to `git add <files>` for the specific files

## Commit Message Format
Conventional Commits v1.0.0

Format: `type(scope): description`
- scope: optional (e.g., `alacritty`, `vim`, `git`)
- **description: in Japanese** (e.g., `feat(alacritty): 透明度設定を追加`)

Types:
- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation only
- `style`: formatting, whitespace
- `refactor`: code change without bug fix or feature
- `perf`: performance improvement
- `test`: add/update tests
- `build`: build system, dependencies
- `chore`: other configs, tooling
- `ci`: CI configuration

Required footer:
```
Co-Authored-By: Claude <noreply@anthropic.com>
```
