# Tech Stack & Tooling

## Language & runtime

- **Python 3.10+.** Target a range, not a pin. Initialize with
  `uv init --lib --python=3.10 ./` so the project supports 3.10 and up.
- Prefer standard-library and typed data structures (`dataclasses`, `typing`,
  `pathlib`) for the core model. Use Pydantic only where config/validation genuinely
  benefits.

## Package management: uv

- **uv manages everything** — the virtualenv, dependency resolution, and running tools.
- Run every Python tool through `uv run`. Never call `python`, `python3`, `pip`,
  `ruff`, `ty`, or `pytest` directly; those bypass the locked environment.
- Add/remove dependencies with `uv add` / `uv remove` (these edit `pyproject.toml` and
  the lockfile). After manual `pyproject.toml` edits, run `uv lock`.
- `uv sync --all-groups --all-packages` syncs dev + extras.

| Want to               | Run                                                  |
| --------------------- | ---------------------------------------------------- |
| One-off script / REPL | `uv run python -c '...'` / `uv run python script.py` |
| Lint + autofix        | `uv run ruff check --fix src tests`                  |
| Format                | `uv run ruff format src tests`                       |
| Type-check            | `uv run ty check src tests`                          |
| Unit tests            | `uv run pytest tests`                                |
| Add / remove dep      | `uv add <pkg>` / `uv remove <pkg>`                   |
| Refresh lockfile      | `uv lock`                                            |

## Build backend: hatchling + hatch-vcs

- `build-backend = "hatchling.build"`, `requires = ["hatch-vcs", "hatchling"]`.
- Version is derived from git tags via `[tool.hatch.version]` `source = "vcs"`.
  The project uses `dynamic = ["version"]` — do not hard-code a version.

## Quality tools

- **ruff** for lint + format. Baseline config from the reference project:
  `line-length = 120`, `src = ["src", "tests"]`, lint select
  `["ASYNC", "B", "E", "F", "I", "N", "RUF", "SIM", "UP"]`, ignore `["E501"]`.
- **ty** for type checking (`uv run ty check src tests`).
- **pytest** for tests, with **hypothesis** for property-based testing of correctness
  properties. Coverage via `pytest-cov`.

## Git hooks: prek

- **prek** (a pre-commit-compatible runner) manages git hooks. Install with:
  ```
  uv run prek install --prepare-hooks -t pre-commit -t pre-push -t commit-msg
  ```
- Hook definitions live in `prek.toml` (pre-commit-compatible format). Cynosure both
  _consumes_ prek for its own repo hygiene and _exposes_ pre-commit/prek hook entry
  points as a product feature.
- Baseline hook repos to mirror from the reference: `uv-pre-commit` (uv-lock),
  `ruff-pre-commit` (ruff + ruff-format), `pre-commit-hooks` (standard file checks),
  `commitizen` (commit-msg / branch), `osv-scanner` (dependency vuln scan).

## Not used

- **No git-lfs.** Cynosure distributes text/markdown assets, not large binaries.
- No database / Alembic migrations (the reference project had these; Cynosure does not).

## Reference material

`downloads/int2x-backend/` is a sibling project to consult for uv/hatch/prek conventions
(`pyproject.toml`, `prek.toml`, `scripts/setup-development.sh`, `CLAUDE.md`). Adapt, do
not copy wholesale — Cynosure drops the DB, LFS, and web-framework pieces.
