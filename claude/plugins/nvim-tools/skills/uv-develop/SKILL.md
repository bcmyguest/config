---
name: uv-develop
description: Day-to-day Python development with uv — managing dependencies and running tests. Use whenever working in a Python project that has a pyproject.toml/uv.lock, or whenever installing packages, running tests, or running Python code. Always prefer uv over pip, python, virtualenv, poetry, or pipenv.
---

# Developing with uv

`uv` is the package manager and runner for **every** Python project on this machine.
Never fall back to bare `python`, `pip`, `pip-tools`, `virtualenv`, `poetry`, or
`pipenv`. If a project has a `pyproject.toml`, drive it with `uv`.

If the project does not yet exist or is not set up, use the **uv-setup** skill first.

## Initial setup of an existing project

When you clone or first open a project, reproduce the locked environment exactly:

```bash
uv sync --frozen
```

`--frozen` installs straight from `uv.lock` without re-resolving or updating the lock
file. Use it on initial setup and in CI so the environment matches what is committed.
Only drop `--frozen` when you intend to change dependencies (see below).

## Running tests (do this after every change)

```bash
uv run -m pytest
```

Run the suite after **every** code change — not just at the end. `uv run` executes
inside the project's environment, so there is no separate activate step.

### Test discipline (TDD, non-negotiable)

- Tests describe the intended behavior. When a test fails, **fix the code**, not the
  test.
- **Never** edit, weaken, skip, `xfail`, or delete a test merely to make it pass. That
  hides the bug instead of fixing it.
- Legitimate reasons to change a test: the requirements genuinely changed, or the test
  itself is provably wrong. In both cases say so explicitly and explain why before
  touching it.
- Prefer writing the failing test first, then the implementation that makes it green.
- Narrow the run while iterating (`uv run -m pytest path/to/test_x.py::test_y`), but
  always finish with the full `uv run -m pytest` green before considering work done.

## Managing dependencies

Add and remove packages through uv so `pyproject.toml` and `uv.lock` stay in sync:

```bash
uv add <package>                 # runtime dependency
uv add --dev <package>           # dev-only (pytest, ruff, pyright, ...)
uv add '<package>>=2,<3'         # with a version constraint
uv remove <package>              # drop a dependency
```

`uv add`/`uv remove` re-resolve and rewrite the lock file automatically — never hand-edit
`uv.lock`, and don't `uv pip install` into the environment (that change won't be tracked).

To pull in upstream updates deliberately, run `uv sync` (without `--frozen`) or
`uv lock --upgrade`, then review the lock diff and run the tests.

## Quick reference

| Task                         | Command                          |
| ---------------------------- | -------------------------------- |
| Reproduce locked env         | `uv sync --frozen`               |
| Run the test suite           | `uv run -m pytest`               |
| Run any script/module        | `uv run -m <module>` / `uv run <script>` |
| Add a dependency             | `uv add <pkg>`                   |
| Add a dev dependency         | `uv add --dev <pkg>`             |
| Remove a dependency          | `uv remove <pkg>`                |
| Update + relock deliberately | `uv lock --upgrade && uv sync`   |
