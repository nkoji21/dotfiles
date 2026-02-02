---
name: commit
description: 変更をコミット（日本語、Conventional Commits準拠）
---

Review current changes and create a commit following Conventional Commits.
---
name: commit
description: 変更をコミット（日本語、Conventional Commits準拠）
---

Review current changes and create a commit following Conventional Commits.
**Important**: Propose the message only. Do not run `git commit` unless the user explicitly requests execution.

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
- `chore`: build process, configs
- `ci`: CI configuration

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
- `chore`: build process, configs
- `ci`: CI configuration

