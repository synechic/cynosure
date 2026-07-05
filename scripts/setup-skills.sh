#!/usr/bin/env bash

set -exu -o pipefail

# Installs one or more skills from a single skills.sh marketplace repo.
# Usage: add_skills <repo> <skill> [<skill> ...]
# Each skill is installed separately via `npx skills add` with a shared repo and agent target.
add_skills() {
    local repo="$1"
    shift
    for skill in "$@"; do
        npx skills add "$repo" --agent kiro-cli --skill "$skill" --yes
    done
}

# Architectural guidance — DDD and hexagonal architecture patterns.
add_skills ccheney/robust-skills \
    clean-ddd-hexagonal

# Python development — coding standards, design patterns, tooling, and best practices.
add_skills wshobson/agents \
    architecture-patterns \
    python-anti-patterns \
    python-background-jobs \
    python-code-style \
    python-configuration \
    python-design-patterns \
    python-error-handling \
    python-packaging \
    python-performance-optimization \
    python-project-structure \
    python-resilience \
    python-testing-patterns \
    python-type-safety \
    uv-package-manager

# FullStack guardian and security skills.
add_skills jeffallan/claude-skills \
    security-reviewer

# GitHub Copilot skills.
add_skills github/awesome-copilot \
    conventional-commit
