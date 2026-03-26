---
name: ask-claude
description: 別の Claude インスタンスにセカンドオピニオンを求める
user-invocable: true
---

Ask a separate Claude instance for an independent second opinion on the current problem or decision.

## When to use
- Important architectural decisions
- When stuck on a difficult problem
- Validating a complex plan
- When the user explicitly requests another perspective

## How to use

1. Formulate a self-contained prompt using this template:
   ```
   claude -p "Context: <brief project context>\nQuestion: <specific decision or problem>\nRelevant details: <code snippets, constraints, or prior attempts>"
   ```
2. Run the command
3. Evaluate the response:
   - Does it contradict project-specific conventions?
   - Does it assume context it doesn't have?
   - Does it propose something already tried or ruled out?
4. Present the result to the user in this format:
   - **My recommendation**: ...
   - **Other instance's recommendation**: ...
   - **Synthesis**: ... (your final take, incorporating both views)

## When the two instances disagree
Escalate to the user with both views clearly stated. Do not silently pick one — the disagreement itself is useful information.

## Important
- The other instance has **no conversation history** — provide all necessary context in the prompt
- **Treat its response as one data point, not the answer**
- Project-specific patterns and conventions take priority over generic suggestions
