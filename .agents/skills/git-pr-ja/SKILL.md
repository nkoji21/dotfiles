---
name: git-pr-ja
description: Review branch changes and autonomously open a PR (Japanese)
user-invocable: true
allowed-tools: Bash, Skill
---

Before creating a PR, read `.agents/skills/git-pr/SKILL.md` and follow it
completely. The Japanese rules below are additional hard requirements, not a
replacement for `/git-pr`.

## Hard Requirements

- Use `/git-pr` to create the PR.
- Create a draft PR. Use `gh pr create --draft`.
- Check whether a PR template exists before writing the body. If one exists,
  follow it.
- If no template exists, use the `/git-pr` default body structure:
  `close`, `Summary`, `Changes`, and `Notes`.
- Write the PR title and body in Japanese.
- Never pass a Markdown PR body inline through the shell. Write the body to a
  temporary file and use `gh pr create --body-file <file>` or
  `gh pr edit --body-file <file>`.
