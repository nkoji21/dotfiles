---
name: git-commit-ja
description: 変更内容を確認して自律的にコミット（日本語）
user-invocable: true
---

Review current changes and autonomously commit following Conventional Commits.

1. Run `git status`, `git diff`, and `git log --oneline -5` to understand the changes and context
2. Decide the commit message autonomously
3. Run `git commit`

## Principle
- Write **Why** (why the change was made) in the commit message. Leave What to the diff.

## Commit Granularity
- 1 commit = 1 logical change
- Separate refactoring and feature additions
- Tests can be in the same commit as the main code
- Formatting-only changes should be separate

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
