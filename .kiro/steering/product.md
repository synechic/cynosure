# Product: Cynosure

Cynosure /ˈsaɪnəʃʊər/ (SY-nuh-shoor) — the fixed star all others steer by; the single
point that draws the eye and holds the course.

## What it is

Cynosure is a Python library with a CLI that establishes the core API/SDK and git-hook
entry points for its own ecosystem. It is the "core" of a namespace ecosystem
(`cynosure.*`), modeled after how OpenTelemetry's Python packages are organized: this
repository owns the API, SDK, CLI, and pre-commit/prek hook entry points, while other
`cynosure.*` packages plug in on top.

**Synechic** is the GitHub organization that hosts this project — it is _not_ a runtime
namespace. The importable runtime namespace is `cynosure.*`. This core distribution
exposes only `cynosure.core` (a.k.a. `cynosure.api`), `cynosure.sdk`, and `cynosure.cli`.

The author and owner is **Shane R. Spencer** (Synechic on GitHub).

## The problem it solves

AI coding assistants (Claude Code, Kiro, Codex, Cursor, Gemini CLI, and dozens more)
each expect their skills, agent definitions, and hooks in different project-local and
global directory layouts. Cynosure redistributes and maintains these static assets
(skills as markdown, hooks, agent definitions) into the correct locations for whichever
agents a repository targets, and provides gate checks (pre-commit hooks) that confirm
those assets — and the tools that distribute them — are correctly in place and current.

## Core behaviors

- **Entry-point driven distribution.** Defined entry points return a structured
  result (e.g. a list of data classes describing files) that declares every file to be
  placed into the current repository. Cynosure resolves those declarations and places
  files only when installation is **enabled**.
- **Topic-based compatibility.** Every distributable file carries topics (and
  anti-topics / negative topics) that describe which agents/harnesses it applies to and
  which it must be excluded from. A generic mapper infers topics from files where
  possible. Topics are namespaced with a prefix (e.g. `aicodeassist:`).

- **Configuration with clear precedence.** Behavior is configured via, in order:
  `pyproject.toml` `[tool.cynosure]` (wins outright — if present, others are ignored),
  then `.cynosure.toml`, then `cynosure.toml` (last preference).
- **Gate checks & local tooling.** Ships pre-commit/prek hook definitions that ensure
  static-content and migration-style tooling has run correctly, plus agent-specific
  local hooks (Kiro hooks, Claude hooks) that nudge developers to keep dev dependencies
  and distributed assets up to date. The CLI is invoked as `cynosure`, and as `cs` where
  that short name is available/unambiguous.

## Scope notes

- The long list of supported agents (their `--agent` slugs and project/global skill
  paths) is a target catalog, not a fixed set of "supported" integrations. Most agents
  are handled generically; some need dedicated classes for migrations/updates. A
  Base/Standard system class handles file transfers, gate checks, and tooling
  requirements uniformly.
- Assets are essentially static files (markdown skills, hook configs, agent defs).
  Cynosure's job is correct placement, compatibility filtering, and freshness checks —
  not authoring the content itself.
