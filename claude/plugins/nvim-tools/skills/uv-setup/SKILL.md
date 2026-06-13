---
name: uv-setup
description: Bootstrap a new Python project with uv the right way — asks the project type up front, then uv init, packaged layout, pinned Python version, a type checker (pyright by default), ruff + pyright pre-commit hooks, run/build/validate docs, and a multi-stage Dockerfile for services. Use when starting a new Python project, scaffolding a repo, or asked to "set up" or "initialize" a Python project. For day-to-day work in an existing project, use uv-develop instead.
---

# Setting up a uv project

Scaffold every new Python project with `uv`. Work top to bottom; confirm choices with
the user where noted. After setup, day-to-day work follows the **uv-develop** skill, and
the pre-commit baseline comes from the **pre-commit-setup** skill.

## 0. Ask the user what kind of project this is

Do this **before scaffolding** — the answer changes packaging, the build step, and
whether to containerize. Don't assume; ask:

- **Library / package** (imported by others, published to an index) → packaged,
  `uv build` matters, validate the wheel, usually no Dockerfile.
- **Application / CLI** (run directly, not published) → packaged for a clean entry point,
  no wheel publishing, Dockerfile optional.
- **Service** (web/API/long-running, deployed as a container) → packaged **and**
  containerized (step 7).
- **Script / throwaway** (one-off, not importable) → the only case for a bare,
  non-packaged `uv init`.

Also confirm the **Python version** (step 3) and **type checker** (step 4) while you're
asking. Use the answers to decide which of the steps below apply.

## 1. Quickstart with `uv init`

Follow the uv quickstart (<https://docs.astral.sh/uv/guides/projects/>). Create the
project as a **packaged** project unless the user clearly wants a throwaway script:

```bash
uv init --package <project-name>      # packaged app / library (the usual choice)
# uv init <project-name>              # bare, non-packaged — only for scripts/experiments
```

`uv init --package` produces a `src/` layout, a `[project]` table with a `[build-system]`,
and a `[project.scripts]` entry point — the correct base for anything that will be
imported, tested, or distributed. Then create the environment:

```bash
cd <project-name>
uv sync
```

## 2. Confirm the project is packaged correctly

In `pyproject.toml`, **`tool.uv.package = true` should be set for almost every project**
(libraries, CLIs, anything importable or testable from a clean install). Leave it unset
or `false` only for a genuinely non-importable script collection.

Verify:

- A `[build-system]` table exists (uv defaults to `hatchling`).
- Source lives under `src/<package>/` with an `__init__.py`.
- `[project]` has `name`, `version`, `description`, `requires-python`, and `readme`.

```toml
[tool.uv]
package = true
```

## 3. Pin the Python version

Pin to a recent **stable** Python so contributors and CI all match. As of 2026 a safe
default is **3.13** (3.14 is fine if the user wants the newest; avoid pre-releases).
Confirm the version with the user, then:

```bash
uv python pin 3.13          # writes .python-version
```

Keep `requires-python` in `pyproject.toml` consistent with the pin, e.g.
`requires-python = ">=3.13"`. Commit `.python-version`.

### Verify `.gitignore` does the right thing

`uv init` writes a `.gitignore`, but confirm these three invariants — they're easy to
break and silently wrong:

- **`.python-version` is NOT ignored.** It must be committed so contributors and CI pin
  the same interpreter. A bare-name pattern with no slash (e.g. a stray `.python-version`
  or an over-broad `*.version`-style rule) would swallow it — make sure none does.
- **`.venv` IS ignored, no matter how nested.** A pattern with no leading slash
  (`.venv/`) already matches at every depth (`.venv/`, `pkg/.venv/`, `a/b/.venv/`). Don't
  anchor it with a leading slash (`/.venv`), which would only ignore the top-level one.
- **`__pycache__` IS ignored at any depth** — same reasoning: `__pycache__/` (no leading
  slash) matches nested caches too.

Verify with `git check-ignore` (exit `1`/no output = not ignored):

```bash
git check-ignore -v .python-version          # expect: no match (exit 1) — it's committed
git check-ignore .venv a/b/.venv             # expect: both printed — ignored at any depth
git check-ignore a/__pycache__/x.pyc         # expect: printed — ignored at any depth
```

If `git check-ignore .python-version` prints a match, find the offending rule (the `-v`
flag shows which file/line) and remove or tighten it.

## 4. Set up a type checker (pyright by default)

Default to **pyright**. Ask the user if they prefer another checker (e.g. mypy, ty);
otherwise use pyright.

```bash
uv add --dev pyright
```

Add a config block to `pyproject.toml` and verify it runs clean:

```toml
[tool.pyright]
include = ["src", "tests"]
typeCheckingMode = "standard"   # bump to "strict" for new code if the user wants it
venvPath = "."
venv = ".venv"
```

```bash
uv run pyright
```

## 5. Add ruff + pyright pre-commit hooks

Add the linters as dev deps and wire up pre-commit. Use the official mirrors and pin to a
tagged `rev` (check each repo's latest release rather than guessing):

- ruff: <https://github.com/astral-sh/ruff-pre-commit>
- pyright: <https://github.com/RobertCraigie/pyright-python>

```bash
uv add --dev ruff pre-commit
```

`.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.x.x            # use the latest tagged release
    hooks:
      - id: ruff-check     # lint
        args: [--fix]
      - id: ruff-format    # format
  - repo: https://github.com/RobertCraigie/pyright-python
    rev: vX.Y.Z            # use the latest tagged release
    hooks:
      - id: pyright
```

This skill covers the project-specific linting hooks. For the standard hygiene hooks
(trailing whitespace, end-of-file newline, YAML checks, etc.) and installing the git hook,
use the **pre-commit-setup** skill. Finish with:

```bash
uv run pre-commit install
uv run pre-commit run --all-files
```

## 6. Document run / build / validate

Add a README section so anyone can work the project. **Every command uses `uv`.**

### How to run

```bash
uv sync --frozen          # reproduce the locked environment
uv run -m pytest          # tests
uv run <entry-point>      # or `uv run python -m <package>`
```

### How to build (library / distributable code only)

```bash
uv build                  # builds sdist + wheel into dist/
```

### How to validate the build

```bash
# Confirm the wheel installs and imports cleanly in an isolated env:
uv run --isolated --no-project --with dist/<name>-<ver>-py3-none-any.whl \
  python -c "import <package>; print(<package>.__version__)"

# Optional: check distribution metadata
uvx twine check dist/*
```

## 7. Containerize (if the project ships as a container/service)

Use a multi-stage build so the final image contains the app and its venv but **not**
`uv` itself. Base it on
<https://github.com/astral-sh/uv-docker-example/blob/main/multistage.Dockerfile>.

**Get the Python version right — this is the part that breaks silently.** The builder
image, the final image, and the project's pinned version must all be the **same** Python
release. The builder copies `/app/.venv` into the final image, and the venv hard-codes the
interpreter path; if the final image's Python differs (even `3.12` vs `3.13`) the app
fails to start. Substitute the version you pinned in step 3 (3.13 here) in **both**
`FROM` lines:

```dockerfile
# Build stage: uv image matching the pinned Python version.
FROM ghcr.io/astral-sh/uv:python3.13-trixie-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV UV_NO_DEV=1               # omit dev dependencies
ENV UV_PYTHON_DOWNLOADS=0     # use the image's interpreter, don't fetch one

WORKDIR /app
# Install deps first (cached layer) without the project, then the project itself.
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

# Final stage: plain python image — MUST be the same version as the builder above.
FROM python:3.13-slim-trixie

RUN groupadd --system --gid 999 nonroot \
 && useradd --system --gid 999 --uid 999 --create-home nonroot

COPY --from=builder --chown=nonroot:nonroot /app /app
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
USER nonroot
WORKDIR /app

# Replace with this project's entry point (e.g. the console script or `python -m <pkg>`).
CMD ["<entry-point>"]
```

Notes:

- `uv sync --locked` is the container equivalent of `--frozen`: it installs from
  `uv.lock` and fails if the lock is stale, so the image matches what's committed.
- Add a `.dockerignore` (at least `.venv`, `__pycache__`, `.git`, `dist`) so the build
  context stays small and the host venv never leaks into the image.
- Keep the version in the Dockerfile, `.python-version`, and `requires-python` in lockstep
  — bump them together.

Build and smoke-test:

```bash
docker build -t <name> .
docker run --rm <name>
```

If you change the Python version later, update both `FROM` lines and re-test.

## Setup checklist

- [ ] asked the user the project type (library / app / service / script)
- [ ] `uv init --package` (or justified bare init)
- [ ] `tool.uv.package = true` and a real `src/` layout
- [ ] `.python-version` pinned to a stable release; `requires-python` matches
- [ ] `.gitignore` checked: `.python-version` committed, `.venv` + `__pycache__` ignored at any depth
- [ ] type checker installed and `uv run pyright` is clean
- [ ] ruff + pyright pre-commit hooks pinned to tagged revs; `pre-commit install` run
- [ ] README documents run / build / validate, all via `uv`
- [ ] Dockerfile added if it's a service/container (versions in lockstep with the pin)
- [ ] `uv run -m pytest` green
