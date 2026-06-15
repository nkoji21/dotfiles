# Git Apply Reference

This skill stages patches **without touching the worktree**, so every command here
uses `--cached` by default. Drop `--cached` only when you deliberately want to apply
to the working tree instead of the index.

## Basic Usage

```bash
# Always verify first before staging (no changes on failure)
git apply --cached --check patch_file.patch

# Stage with verbose output for debugging
git apply --cached -v patch_file.patch

# Stage a diff generated between refs
git diff main...HEAD -- <file> | git apply --cached -v
```

## Essential Flags

- `-v, --verbose`: always use this for detailed feedback during application.
- `--check`: verify whether a patch can be applied cleanly without making changes.
- `--cached`: stage the patch without applying it to the worktree.
- `--stat`: display affected files before applying.
- `--whitespace=fix`: automatically correct trailing whitespace issues.
- `--reject`: create `.rej` files for failed sections instead of aborting entirely.
- `--reverse` / `-R`: revert a previously applied patch.

## Troubleshooting Failed Applies

Trailing whitespace:

```bash
git apply --cached --check --whitespace=fix patch_file.patch
git apply --cached --whitespace=fix -v patch_file.patch
```

Partial failures (write `.rej` files for the hunks that don't apply):

```bash
git apply --cached --reject -v patch_file.patch
```

Context mismatch — the surrounding lines in the file no longer match the patch
context (line offsets / fuzz). Prefer a three-way merge, which uses the blob the
patch was based on:

```bash
git apply --cached --3way -v patch_file.patch
```

If `--3way` is not viable, loosen the required context lines with `-C<n>` (e.g.
`-C1`). Note: `--ignore-whitespace` only helps when the *only* difference in the
context is whitespace — it does not fix genuine line-offset mismatches.

Line ending issues:

```bash
git apply --cached --ignore-space-change -v patch_file.patch
```

## Git Apply vs Git Am

- `git apply`: applies or stages changes without creating commits.
- `git am`: applies patches with commit messages and author info preserved.

Use `git apply --cached -v` for this workflow to keep commit creation explicit and
controlled.
