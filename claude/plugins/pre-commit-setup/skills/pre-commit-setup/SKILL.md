---
name: pre-commit-setup
description: Stand up pre-commit in a repository with the standard hygiene hooks — trailing-whitespace, end-of-file newline, YAML/JSON/TOML checks, large-file and merge-conflict guards — then install the git hook and run it across the repo. Use when adding pre-commit to a project, asked to "set up pre-commit" or "add commit hooks", or to establish baseline formatting hygiene. Language-specific linters (ruff, pyright, etc.) are layered on top by the relevant project-setup skill.
---

# Setting up pre-commit

This skill establishes the **baseline** pre-commit config: the language-agnostic hygiene
hooks every repo should have (end-of-line/whitespace normalization, file checks). Project-
specific linters and formatters (e.g. ruff + pyright from the **uv-setup** skill) are
appended to the same `.pre-commit-config.yaml`, not configured here.

## 1. Install pre-commit

Use the project's package manager so the dependency is tracked. In a uv project:

```bash
uv add --dev pre-commit
```

If it isn't a uv project (or has no package manager to track the dependency), **ask the
user** how they want pre-commit installed (`pipx install pre-commit`,
`brew install pre-commit`, system package, etc.) rather than picking for them — but
recommend tracking it as a dev dependency wherever that's possible.

## 2. Create the baseline config

If `.pre-commit-config.yaml` doesn't exist, create it with the standard hooks from
<https://github.com/pre-commit/pre-commit-hooks>. Pin `rev` to that repo's **latest
tagged release** (don't guess — check the tags):

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0          # use the latest tagged release
    hooks:
      - id: trailing-whitespace      # strip trailing whitespace
      - id: end-of-file-fixer        # ensure exactly one trailing newline
      - id: mixed-line-ending        # normalize line endings (LF)
        args: [--fix=lf]
      - id: check-yaml               # validate YAML syntax
      - id: check-toml               # validate TOML syntax
      - id: check-json               # validate JSON syntax
      - id: check-added-large-files  # block accidental large blobs
      - id: check-merge-conflict     # block leftover conflict markers
      - id: check-case-conflict      # catch case-insensitive filename clashes
```

If the file already exists, merge these in rather than overwriting other repos' hooks.
Tags read clearly but are mutable; for stronger guarantees pin to commit SHAs — see the
supply-chain note in step 4.

## 3. Install the git hook and run it

```bash
uv run pre-commit install          # wire up the .git/hooks/pre-commit hook
uv run pre-commit run --all-files  # apply to the whole repo once
```

(Drop the `uv run` prefix if pre-commit is installed globally rather than as a dev dep.)

The first `run --all-files` will likely modify files (fixing whitespace, newlines, line
endings). That's expected — review the changes, then **commit them** so the working tree
is clean and future commits only show real diffs.

## 4. Keep it healthy (without blindly trusting upstream)

Pre-commit hooks run arbitrary code from third-party repos on every commit, so treat
updates as a supply-chain surface:

- **Don't auto-accept `autoupdate`.** Plain `pre-commit autoupdate` moves each `rev` to
  the latest tag, and git tags are *mutable* — a compromised or coerced maintainer can
  re-point a tag at malicious code. Pulling "the latest tag" blind is the exact risk.
- **Pin to immutable commit SHAs.** Use `uv run pre-commit autoupdate --freeze`, which
  resolves each hook to the underlying 40-char commit hash (keeping the tag as a comment).
  A SHA can't be moved, so the pin is reproducible.
- **Review every bump before committing.** When a `rev` changes, look at the upstream diff
  (compare the old SHA/tag to the new one) and confirm the tag/release is signed or comes
  from the expected maintainer before accepting. Update deliberately, not on a schedule.
- Hooks run automatically on `git commit`; run `pre-commit run --all-files` manually after
  editing the config.
- In CI, run `pre-commit run --all-files` to enforce the same checks on every push.

## Checklist

- [ ] pre-commit installed (tracked as a dev dependency where possible)
- [ ] `.pre-commit-config.yaml` has the baseline hygiene hooks, `rev` pinned to a tag
- [ ] `pre-commit install` run; `pre-commit run --all-files` passes
- [ ] formatting fixes from the first run committed
