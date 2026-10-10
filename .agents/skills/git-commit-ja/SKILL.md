---
name: git-commit-ja
description: Review changes and autonomously commit (Japanese). ALSO trigger this skill proactively when you (Claude) are about to commit changes — never run `git commit` directly, always invoke this skill instead.
user-invocable: true
allowed-tools: Bash, Skill
---

Use `/git-commit` to perform the commit (granularity, revertability, `git apply`
staging, and references all apply unchanged). It also forwards any `--path` /
`--push` arguments. The reference docs live under
`.agents/skills/git-commit/references/` (this skill has none of its own).

## Language override (this skill takes precedence)

`/git-commit` instructs English commit messages. When this skill runs, **the
following language rules override that** — re-confirm them right before writing each
message:

- **type**: English Conventional Commits type (`feat`, `fix`, `docs`, `refactor`,
  `chore`, …).
- **scope**: English (e.g. `alacritty`, `vim`, `git`).
- **description**: 日本語で書く。基本は短い What。差分や issue から理由が読めない
  とき（他の案から選んだ、回避策、一時的なコード、読んだ人が直したくなりそう）
  だけ Why を足す。

Examples:

```
# What だけで十分（理由は変更や issue から分かる）
feat(render): ESC と×ボタンで終了する

# Why を足す（理由が差分から読めない）
fix(alacritty): 起動時警告を消すため非推奨オプションを削除
```
