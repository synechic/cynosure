# Project Structure & Namespace

## Namespace ecosystem (`cynosure.*`)

Modeled after OpenTelemetry Python. This repository is the **core**: it owns the API,
SDK, CLI, and hook entry points. Other packages extend it under the shared `cynosure`
namespace.

**Synechic** is only the GitHub organization that hosts the project; it is _not_ a
runtime/import namespace. The importable namespace is `cynosure.*`.

- `cynosure` is a **PEP 420 implicit namespace package** — no `__init__.py` at the
  namespace root, so multiple distributions can contribute submodules.
- This core distribution exposes **only** these public modules:
  - `cynosure.core` (a.k.a. `cynosure.api`) — the stable public API surface.
  - `cynosure.sdk` — concrete implementations behind the API.
  - `cynosure.cli` — the `cynosure` / `cs` command-line interface.
- Companion packages (skill libraries, agent-specific adapters) publish as separate
  distributions that add their own `cynosure.<name>` modules and register entry points
  that Cynosure discovers.

## Source layout (`src/` layout)

```
src/
  cynosure/                    # namespace root — NO __init__.py (PEP 420)
    core/                      # stable public API surface (a.k.a. cynosure.api)
    sdk/                       # concrete implementations behind the API
    cli/                       # `cynosure` / `cs` command-line interface
tests/
scripts/
```

Internal implementation modules (config discovery + precedence, the distributable-file
data model, the topic model/mapper/anti-topic matching, the file-placement engine with
the Base/Standard system class, and the pre-commit/prek + agent-hook entry points) live
**inside `cynosure.sdk`** (with the thin, stable facade re-exported from `cynosure.core`).
Only `core`, `sdk`, and `cli` are public; anything deeper is an implementation detail.

Exact internal submodule names may evolve during design; the intent is: **a stable
`cynosure.core` surface, `cynosure.sdk` implementations behind it, and a `cynosure.cli`
entry point.**

## Entry points & plugins

- Distribution content is contributed through Python **entry points**. A provider
  (Cynosure itself or a companion `cynosure.*` package) exposes an entry point that
  returns a structured result (a list of data classes) describing every file to
  distribute, each annotated with topics/anti-topics and optional version ranges.
- Cynosure discovers these entry points, filters by the repository's configured topics,
  and — when enabled — places files into the correct agent paths.

## Configuration file precedence

Resolve config in this strict order (first match wins; later sources ignored entirely
once a Cynosure config is found in `pyproject.toml`):

1. `pyproject.toml` → `[tool.cynosure]` — **if present, others are ignored completely.**
2. `.cynosure.toml`
3. `cynosure.toml` (lowest preference)

Config defines the **topics** a repository maintains (e.g. `kiro`, `claude`), enables or
disables installation, and controls per-agent behavior.

## Conventions

- Keep the public `cynosure.core` (`cynosure.api`) surface import-light and
  dependency-free where possible; heavier logic belongs in `cynosure.sdk`.
- Data classes describing distributable files are the contract between providers and the
  distribution engine — keep them stable and well-typed.
- Base/Standard system class handles generic file transfer, gate checks, and tooling
  requirements; agent-specific subclasses exist only where migrations/updates demand it.
