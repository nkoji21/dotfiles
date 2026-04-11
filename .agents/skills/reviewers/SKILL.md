---
name: reviewers
description: "Multi-agent code review with dynamic personas and confidence-scored findings. Spawns 2-4 reviewers tailored to the diff, then a defender/consolidator (Opus) that verifies each finding against source and explains every adoption and rejection decision."
argument-hint: "[path or file filter]"
user-invocable: true
allowed-tools: "Agent Bash Read Glob Grep"
---

# Multi-Agent Review

Perform a thorough multi-agent code review on the current branch using
dynamic personas tailored to the actual diff content.

## Dynamic Context

Base branch:

```!
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"
```

Changed files:

```!
git diff $(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main)...HEAD --name-only 2>/dev/null || echo "(no changes)"
```

Recent commits:

```!
git log $(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main)...HEAD --oneline 2>/dev/null || echo "(no commits)"
```

Diff stat (for focus analysis):

```!
git diff $(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main)...HEAD --stat 2>/dev/null || echo "(no changes)"
```

Diff preview for focus analysis (first 200 lines):

```!
git diff $(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main)...HEAD -- "$ARGUMENTS" 2>/dev/null | head -200 || echo "(no diff)"
```

## Instructions

Follow these steps exactly. Emit the step header before each step so the user
can track progress.

---

### Step 1: Focus Analysis

Emit: `### Step 1/3 — Focus Analysis`

Read `agents/focus-analyzer.md` before launching this agent.

Launch **1 agent** (model: haiku) with:
- The prompt from `agents/focus-analyzer.md`
- The diff stat output shown above
- The recent commits shown above
- The diff preview shown above (first 200 lines — for scope analysis only)

Wait for the result. Then display it verbatim — the persona table, rationale,
and any coverage warning must be shown to the user BEFORE proceeding to Step 2.

If the agent fails or returns no personas, abort and output:
```
Step 1 failed — could not determine review focus. Re-run the review.
```

---

### Step 2: Parallel Review

Emit: `### Step 2/3 — Parallel Review`

Read `agents/reviewer.md`, `rules/checklist.md`, and `examples/output-format.md`
before launching reviewers.

Determine N = the number of personas from Step 1 (minimum 2, maximum 4).

Launch **N pr-reviewer agents in a single message** (parallel execution).

Each reviewer receives:
- The base prompt from `agents/reviewer.md`
- Their specific persona definition (injected into the `[PERSONA INJECTED BY ORCHESTRATOR]` placeholder)
- The cross-cutting checklist from `rules/checklist.md`
- The output format reference from `examples/output-format.md`
- The focus areas from Step 1
- The **full diff** (run fresh — do NOT reuse the truncated preview):
  `git diff BASE...HEAD -- "$ARGUMENTS"`
  where BASE is the detected base branch from Dynamic Context above

Reviewers work independently and do not see each other's results.

After all reviewers complete, display the Individual Verdicts table:

```
#### Individual Verdicts

| Reviewer   | Verdict | Findings | Top Concern |
|------------|---------|----------|-------------|
| R1 [Name]  | ...     | N        | ...         |
| R2 [Name]  | ...     | N        | ...         |
...
```

Do not show full findings here — only the summary. Full findings appear in
Step 3 after defense verification.

**Partial failure handling**: If a reviewer fails or returns malformed output,
mark them as FAILED in the table and add a degraded coverage warning blockquote.
Minimum 2 successful reviewers required to proceed. If fewer than 2 succeed:

```
## Multi-Agent Review

ABORT — Only N/N reviewers succeeded (minimum 2 required). Re-run the review.
```

---

### Step 3: Defense & Consolidation

Emit: `### Step 3/3 — Consolidated Review`

Read `agents/consolidator.md` and `examples/output-format.md` before launching.

Launch **1 general-purpose agent** (model: opus) with:
- The prompt from `agents/consolidator.md`
- The output format from `examples/output-format.md`
- All reviewer results from Step 2
- The changed files list from Dynamic Context above
- The detected base branch (so it can run `git diff` if needed for verification)

The consolidator will:
1. Read source files to verify each finding (defense step)
2. Merge and deduplicate findings
3. Assign ratio-based confidence scores
4. Output findings with Source + Defense notes
5. Include a `<details>` block with Adopted/Rejected reasoning

Display the consolidator's full output directly to the user. This is the final
review.
