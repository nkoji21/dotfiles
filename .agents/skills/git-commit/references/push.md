# Push Reference

Run in `sh`/`zsh` (this repo's shell). Do NOT use fish syntax.

When invoked with `--path <dir>`, prepend `cd <dir> &&` to every command below so
the push targets that repository, not the current working directory.

## 1. Check the current branch before any push

```bash
current_branch=$(git branch --show-current)
if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
  echo "On $current_branch — stop. Create a feature branch before pushing."
  exit 1
fi
```

If the current branch is `main` or `master`, stop and create a feature branch
before pushing. The `exit 1` above guarantees execution halts instead of falling
through to the push step.

## 2. Check if the branch has an upstream

```bash
git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
```

- **If this succeeds** (an upstream exists), push directly:

  ```bash
  git push
  ```

- **If this fails** (no upstream), ask the user whether to set upstream and push:
  - If yes: `git push -u origin HEAD`
  - If no: skip pushing.

## 3. Hooks

Let repository git hooks run. If a pre-push hook runs format, sync, lint,
typecheck, or tests and one fails, fix it in a new small commit and push again —
treat hook failures as part of the normal validation path, not as errors to bypass.
