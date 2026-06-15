---
name: git-commit
description: Review changes and autonomously commit (English). ALSO trigger this skill proactively when you (Claude) are about to commit changes — never run `git commit` directly, always invoke this skill instead.
user-invocable: true
allowed-tools: Bash
---

Review current changes and autonomously create fine-grained, independently
revertable commits following Conventional Commits.

**Working tree status (source repo):**
```
!`git status --short`
```

**Diff stat (source repo):**
```
!`git diff --stat HEAD`
```

## Arguments

- `--path <dir>`: run every git command inside `<dir>` by prepending `cd <dir> &&`
  to each Bash command. This overrides the current working directory (e.g. invoked
  as `git-commit --path /tmp/feat-foo`).
- `--push`: push to remote after all commits are complete (default: off). See the
  **Push** section below.

1. Run `git status`, `git diff HEAD`, and `git log --oneline -10` to understand the
   changes and context
2. Decide commit boundaries and messages autonomously
3. Stage and commit each unit using `git apply --cached` (see below)

## Core Philosophy — Revertability First

Each commit must be **revertable independently** without breaking other
functionality. Prefer smaller, granular commits over large groupings — split by
hunks within files, not just whole files.

- **Tiny commits are expected.** A single review comment, one wording correction,
  one reference-file extraction, one symlink sync, or one formatting pass can each
  be its own commit when independently revertable. PR branches are squash-merged
  later, so don't worry about granularity being too fine.
- **Tiny does not mean incomplete.** For moves, renames, or extractions, one commit
  must include *both* sides: remove/update the old location, add the new location,
  update references, and sync generated links. Never commit only the destination of
  a move while leaving the source/reference cleanup for later.
- **Don't `--amend` away review history.** PR branches are squash-merged, so keep
  review fixes as small follow-up commits that can be reverted independently. Amend
  only for unpublished local mistakes or when the user explicitly asks.

For concrete good and bad examples, read `references/revertable-commits.md`.

## Commit Granularity
- 1 commit = 1 logical change
- Examine individual hunks, not entire files — split if needed
- Separate refactoring and feature additions
- Tests can be in the same commit as the main code
- Formatting-only changes should be separate (`chore(xxx): format` or `chore: format`)

## Staging with git apply

Never use interactive commands like `git add -p` or `git add --interactive` —
Claude Code cannot handle them. Instead:

```bash
# 1. Generate patch for the target changes
git diff > patch.diff

# 2. Verify before applying (no file changes on failure)
git apply --cached --check patch.diff

# 3. Apply to staging area (equivalent to git add)
git apply --cached patch.diff
```

When a patch fails, needs whitespace handling, or must be staged without touching
unrelated hunks, read `references/git-apply.md`.

## Commit Message Format
Conventional Commits v1.0.0

Format: `type(scope): description`
- **type**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`,
  `ci`, `chore`, `revert`
- **scope**: optional (e.g., `alacritty`, `vim`, `git`)
- **description: in English** — convey Why, not just What, but keep it short

Examples:
```
# Too vague (What only)
fix(git): remove deprecated option

# Better (Why in subject)
fix(git): remove deprecated option to prevent startup warning
```

Body is optional. If you feel a body is necessary, the commit is likely too large —
consider splitting it.

Do not add a `Co-Authored-By` or any agent-identifying footer. This skill is shared
across Claude / Codex / Cursor, so hardcoding a single agent name would mislabel
commits made by the others.

## Quality Checks
- Can this be reverted without breaking other functionality?
- Is this the smallest logical unit?
- Does the message clearly explain the change (Why)?
- Does it match the project's commit patterns, scopes, and style?
- No debugging statements or commented-out code without explanation

## Push (only if `--push`)

After all commits are complete, push to remote. Let repository git hooks run; if a
pre-commit or pre-push hook runs format, sync, lint, typecheck, or tests, treat
those as part of the normal validation path and fix any failures in a new small
commit.

Never push to `main`/`master` directly — create a feature branch first.

Read `references/push.md` for the exact branch/upstream checks and push commands.
