---
name: pr-flow
description: Full PR workflow - branch, commit, open draft PR, AI review loop, then squash-merge. Use when you want end-to-end automation from staged changes to merged PR.
user-invocable: true
allowed-tools: Bash, Skill, Agent
---

Orchestrate the full pull request workflow from staged changes to squash-merged PR.

## Phase 1: Worktree

Use the Skill tool to invoke the `git-worktree` skill.


It will return a worktree path (e.g. `/tmp/feat-foo`) and a branch name. Store both:
- `WORKTREE_PATH` — absolute path to the worktree
- `BRANCH_NAME` — the branch created inside the worktree

## Phase 2: Commit

Capture the current HEAD sha before committing (the worktree always starts at main's HEAD, so this detects whether git-commit created a new commit):
```
BEFORE_SHA=$(git -C $WORKTREE_PATH rev-parse HEAD)
```

Use the Skill tool to invoke the `git-commit` skill with args `--path $WORKTREE_PATH`.

After the skill completes, check whether a commit was made:
```
AFTER_SHA=$(git -C $WORKTREE_PATH rev-parse HEAD)
```

If `BEFORE_SHA == AFTER_SHA`, clean up the worktree and stop:
```
git worktree remove --force $WORKTREE_PATH
```
Note: `--force` discards any uncommitted state in the worktree (e.g. `patch.diff` created by git-commit). This is intentional — the source repo's working tree is untouched.
Inform the user that there was nothing to commit, and that their original changes remain in the source repo untouched.

## Phase 3: Open PR

Use the Skill tool to invoke the `git-pr` skill with args `--path $WORKTREE_PATH`.

After the skill completes, capture the PR URL into a variable:
```
PR_URL=$(cd $WORKTREE_PATH && gh pr view --json url --jq '.url')
```

If `gh pr create` failed because a PR already exists, retrieve the existing PR URL with the same command.

Use `$PR_URL` in every subsequent `gh pr comment` and `gh pr merge` call.

## Phase 4: Review Loop

You may apply fixes at most **3 times**. Track the iteration count starting at 0. The reviewer subagent is invoked once per iteration, so it runs up to 4 times total (3 fix iterations + 1 final review).

### 4a. Launch reviewer subagent

Use the Agent tool to launch the `pr-reviewer` subagent with this prompt (substitute the actual PR URL):

```
Review the PR at <PR_URL>. Run `gh pr diff <PR_URL>` to get the diff. Analyze it for bugs, logic errors, security issues, and style/convention violations. Return structured findings exactly as your instructions specify — the REVIEW_RESULT block only, no prose outside it.
```

### 4b. Validate and post the review comment

Before posting, verify that the subagent's response contains a `REVIEW_RESULT` ... `END_REVIEW_RESULT` block. If the block is absent or malformed, post this warning instead and proceed to Phase 5:
```
gh pr comment $PR_URL --body "[AI-generated review by Claude Code] Warning: reviewer returned malformed output. Skipping auto-fix. Please review manually."
```

Otherwise, post the findings:
```
gh pr comment $PR_URL --body "[AI-generated review by Claude Code]

<formatted review findings here>"
```

Format findings as a markdown list. Each item: severity label (`must-fix` / `suggestion` / `nitpick`), file/location, description.

### 4c. Evaluate findings

- **No issues** (including `issues: []`) or **only `suggestion`/`nitpick`**: proceed to Phase 5.
- **`must-fix` issues exist AND iteration < 3**:
  - Read each flagged file before editing. Fix each `must-fix` issue.
  - Capture HEAD sha before invoking git-commit:
    ```
    FIX_BEFORE=$(git -C $WORKTREE_PATH rev-parse HEAD)
    ```
  - Use the Skill tool to invoke `git-commit` with args `--path $WORKTREE_PATH` to commit the fixes.
  - Check if the commit actually happened:
    ```
    FIX_AFTER=$(git -C $WORKTREE_PATH rev-parse HEAD)
    ```
  - If `FIX_BEFORE == FIX_AFTER` (nothing was committed): post a comment explaining the fix could not be committed, clean up the worktree (`git worktree remove --force $WORKTREE_PATH`), then stop. Do NOT loop.
  - Increment iteration count and return to step 4a.
- **`must-fix` issues exist AND iteration == 3**:
  - Post comment:
    ```
    gh pr comment $PR_URL --body "[AI-generated review by Claude Code] Reached maximum auto-fix iterations (3 fix attempts). Remaining must-fix issues require manual attention."
    ```
  - Clean up the worktree:
    ```
    git worktree remove --force $WORKTREE_PATH
    ```
  - Clean up the worktree:
    ```
    git worktree remove --force $WORKTREE_PATH
    ```
  - Stop. Do NOT proceed to merge.

## Phase 5: LGTM + Merge

Post the LGTM comment:
```
gh pr comment $PR_URL --body "[AI-generated LGTM by Claude Code]

No must-fix issues found. Proceeding to auto-merge."
```

Mark the PR as ready for review (required before merging a draft PR):
```
gh pr ready <PR_URL>
```

Trigger squash merge:
```
gh pr merge <PR_URL> --squash --auto
```

If the merge command fails, report the exact error to the user and stop. Do not retry automatically.

After a successful merge, clean up the worktree:
```
git worktree remove --force $WORKTREE_PATH
```

Report the final PR URL and merge status to the user.
