# Development Workflow

## First-time setup

Run the setup script, which enforces tool versions and installs git hooks:

```
./scripts/setup-development.sh
```

It checks Git, Python 3.10+, and uv; runs `uv self update`; syncs the environment with
`uv sync --all-groups --all-packages`; ensures prek is present; and installs prek hooks.
There is **no git-lfs** and **no database migration** step (unlike the reference project).

## Project initialization (one-time, if starting from empty)

```
uv init --lib --python=3.10 ./
```

Then configure `src/` layout under the `cynosure` namespace (see structure.md), set the
build backend to hatchling + hatch-vcs, and add dev dependencies:

```
uv add --dev ruff ty pytest pytest-cov hypothesis prek commitizen
```

## Everyday commands (always via `uv run`)

- Lint + autofix: `uv run ruff check --fix src tests`
- Format: `uv run ruff format src tests`
- Type-check: `uv run ty check src tests`
- Test: `uv run pytest tests`
- Property-based tests run under pytest via hypothesis.

## Testing philosophy

- Every correctness property identified during design becomes an **executable property**
  validated with **hypothesis** (property-based testing).
- Aim for three artifacts per feature: the specification (correctness properties), a
  conforming implementation, and a test suite that evidences conformance.
- Keep unit tests fast and deterministic; gate any environment-dependent tests behind
  markers.

## Commits & hooks

- Conventional commits enforced via commitizen (commit-msg hook).
- prek runs ruff (lint + format), standard file checks, uv-lock, and osv-scanner on
  commit/push. Do not use `--no-verify` unless explicitly asked.
- Only create commits when the user explicitly asks.

## Safe-by-default behavior

Cynosure must never write assets into a repository unless installation is explicitly
**enabled** in config. Default operation is check/report only. Honor this in code and in
tests.
