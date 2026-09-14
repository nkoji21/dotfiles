---
name: git-pr
description: Review branch changes and autonomously open a PR (English)
user-invocable: true
allowed-tools: Bash
---

Review current branch changes and autonomously create a PR as draft.

**Current branch (source repo):** `!`git branch --show-current``

**Commits since main (source repo):**
```
!`git log --oneline main..HEAD`
```

**Diff stat (source repo):**
```
!`git diff --stat main..HEAD`
```

## Arguments

If a `--path <dir>` argument is provided (e.g. invoked as `git-pr --path /tmp/feat-foo`), all git and gh commands must be run inside that directory by prepending `cd <dir> &&` to every Bash command. This overrides the current working directory.

## Hard Requirements

- Always create the PR as a draft. Use `gh pr create --draft`.
- Check whether a PR template exists before writing the body. If one exists,
  follow it.
- Never pass a Markdown PR body inline through the shell. Write the body to a
  temporary file and use `gh pr create --body-file <file>` or
  `gh pr edit --body-file <file>`.
- After creating the PR, verify it with:
  `gh pr view --json isDraft,title,body,baseRefName,headRefName,url`

1. Run `git log --oneline main..HEAD` and `git diff main...HEAD` to understand the changes
2. **Granularity check** (skip if `--path` was provided — the caller already performed this check): Before writing the PR, assess whether the changes belong to a single concern:
   - Group changed files by what they do (feature, test, config, infra, docs, etc.)
   - If changes span 2+ unrelated concerns (e.g. a feature AND an infra fix), stop and tell the user which concerns were identified and suggest splitting into separate PRs. Do not create the PR until the user confirms to proceed as-is or asks you to split.
   - A PR is appropriately sized if a reviewer can understand it in one sitting. More than ~400 changed lines or 3+ unrelated concerns is a signal to split.
3. If a PR template exists in the project, follow it
4. Autonomously decide the PR title and body, then create it with
   `gh pr create --draft --body-file <file>`
5. Verify the created PR with
   `gh pr view --json isDraft,title,body,baseRefName,headRefName,url`

## What goes in the body

Write only what a reviewer cannot get from the diff. Aim for 15–25 lines;
over 30 is a signal to cut, not to reformat.

- **Context**: links only — issue, design doc, Figma, Slack thread. If the
  design intent is already written on the issue (e.g. as a comment), link that
  comment; never restate it.
- **Summary**: 1–3 lines saying what changed.
- **Notes**: only facts the reviewer needs and cannot see in the diff — an API
  limitation you worked around, a deliberate deviation from the spec, a known
  gap with its issue link. One or two items at most. Omit the section entirely
  when there is nothing.
- **Screenshots** when UI changed.

Never write: why the design is the way it is (that lives on the issue or in
Figma), a commit-by-commit history of how you got here, products you took
inspiration from, apologies or caveats about what you did not do, or prose
that paraphrases the diff. Template sections such as "implementation approach"
or "review points" may be answered with "none" — never pad them to look
complete.

## PR Format (if no template exists)

close #{issue_number}
(Remove this line if no related issue exists)

## Summary
What changed, in 1–3 lines.

## Notes
Only what the reviewer cannot see in the diff. Remove if unnecessary.

**Write all content in English.**
**For readability, wrap long lines with a newline at natural break points (e.g. after a period or comma) so no line exceeds ~80 characters. Do not add blank lines between list items.**
