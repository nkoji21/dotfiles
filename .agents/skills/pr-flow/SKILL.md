---
name: pr-flow
description: Full PR workflow - branch, commit, open draft PR, AI review loop, then squash-merge. Use when you want end-to-end automation from staged changes to merged PR.
user-invocable: true
allowed-tools: Bash, Skill, Agent
---

Orchestrate the full pull request workflow from staged changes to squash-merged PR.

## Phase 1: Branch

Use the Skill tool to invoke the `git-branch` skill.

## Phase 2: Commit

Use the Skill tool to invoke the `git-commit` skill.

After the skill completes, verify a commit was actually made by running `git log --oneline -1`.
If the HEAD has not moved (nothing to commit), stop and inform the user.

## Phase 3: Open PR

Use the Skill tool to invoke the `git-pr` skill.

After the skill completes, capture the PR URL:
```
gh pr view --json url --jq '.url'
```

If `gh pr create` failed because a PR already exists, retrieve the existing PR URL with the same command.

Store this URL — you will use it in every subsequent `gh pr comment` and `gh pr merge` call.

## Phase 4: Review Loop

You may run this loop at most **3 times**. Track the iteration count.

### 4a. Launch reviewer subagent

Use the Agent tool to launch the `pr-reviewer` subagent with this prompt:

```
Review the current PR. Run `gh pr diff` to get the diff. Analyze it for bugs, logic errors, security issues, and style/convention violations. Return structured findings as your instructions specify.
```

### 4b. Post the review comment

Post the subagent's structured result as a PR comment:

```
gh pr comment <PR_URL> --body "[AI-generated review by Claude Code]

<formatted review findings here>"
```

Format findings as a markdown list. Each item: severity label (`must-fix` / `suggestion` / `nitpick`), file/location, description.

### 4c. Evaluate findings

- **No issues** or **only `suggestion`/`nitpick`**: proceed to Phase 5.
- **`must-fix` issues exist AND iteration < 3**:
  - Fix each `must-fix` issue by editing the relevant files.
  - Use the Skill tool to invoke `git-commit` to commit the fixes.
  - Increment iteration count and return to step 4a.
- **`must-fix` issues exist AND iteration == 3**:
  - Post comment: `gh pr comment <PR_URL> --body "[AI-generated review by Claude Code] Reached maximum auto-fix iterations (3). Remaining must-fix issues require manual attention."`
  - Stop. Do NOT proceed to merge.

## Phase 5: LGTM + Merge

Post the LGTM comment:
```
gh pr comment <PR_URL> --body "[AI-generated LGTM by Claude Code]

No must-fix issues found. Proceeding to auto-merge."
```

Trigger squash merge:
```
gh pr merge <PR_URL> --squash --auto
```

Report the final PR URL and merge status to the user.
