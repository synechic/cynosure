# Domain Concepts

Shared vocabulary for Cynosure. Use these terms consistently across specs, code, and
docs.

## Distributable file

A single static asset to be placed into a repository: a skill (markdown), a hook
definition, an agent definition, or similar. Represented as a typed data class carrying:

- **content/source** — where the file's bytes come from.
- **destination intent** — what kind of asset it is (skill, hook, agent def), which the
  distribution engine maps to concrete per-agent paths.
- **topics** — positive compatibility tags (see below).
- **anti-topics** — negative/exclusion tags that must suppress placement even if a
  positive topic matched.
- **version range** (optional) — the range of the relevant agent/tool the file cares
  about.

## Provider entry point

A Python entry point (from Cynosure itself or a companion `cynosure.*` package) that
returns a **structured result** — a collection of distributable-file data classes.
Providers declare _what_ to distribute; the engine decides _whether_ and _where_.

## Topics & anti-topics

- **Topic**: a namespaced compatibility tag. Always prefixed, e.g. `aicodeassist:claude`,
  `aicodeassist:kiro`, or wildcards like `aicodeassist:*`, `harness:*`, `agents:*`.
- **Anti-topic (negative topic)**: a tag that _excludes_ a file from an otherwise
  matching context. Example: a file tagged `aicodeassist:*` (applies broadly) with
  anti-topic `aicodeassist:claude` (never applies to Claude).
- **Matching rule (intended semantics):** a file is eligible for a target when at least
  one of its topics matches the target's configured topics AND none of its anti-topics
  match. Anti-topics take precedence over topics. Wildcards match within their prefix
  namespace.

Examples:

- `tell_claude_how_to_do_xyz.md` → topic `aicodeassist:claude` (+ optional version range).
- `do_this_when_not_using_claude.md` → topic `aicodeassist:*` (or `harness:*` /
  `agents:*`) + anti-topic `aicodeassist:claude`.

## Topic mapper

A generic component that infers topics from files (by name, path, front-matter, or
declared metadata) so providers don't have to tag everything by hand. Mapper output is
merged with any explicitly declared topics. Topics should always end up prefixed.

## Agent catalog

The set of known AI coding assistants and their project-local / global asset paths
(e.g. Claude Code → `.claude/skills/` and `~/.claude/skills/`; Kiro CLI → `.kiro/skills/`
and `~/.kiro/skills/`). This is a **target catalog**, not a promise of first-class
support for each. Most agents are handled by the generic Base/Standard system class;
a few need dedicated subclasses for migrations/updates. The full slug→path table lives
in the project README and drives path resolution.

## Base/Standard system class

The uniform mechanism that performs, for any agent:

1. **File transfer** — placing distributable files at the resolved paths (only when
   installation is **enabled**).
2. **Gate checks** — pre-commit/prek hooks verifying assets and prerequisite tooling
   are present and current.
3. **Tooling requirements** — ensuring dev dependencies (often internally developed or
   distributed via "awesome lists" / `cynosure.*` namespace packages published under the
   Synechic GitHub org) are installed and up to date, via local agent hooks (Kiro hooks,
   Claude hooks) that invoke `cynosure` (or `cs`).

## Enablement

Cynosure only writes files when installation is **enabled** in configuration. Absent
explicit enablement, it operates in a check/report mode (safe by default).
