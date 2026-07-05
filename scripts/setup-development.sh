#!/usr/bin/env bash

set -eu -o pipefail

cd "$(dirname "$0")"

# Runs a command to check a tool's version against a minimum requirement.
# Exits with an error if the tool is missing or below the required version.
# Usage: require_version <name> <command> <req_major> [req_minor]
require_version() {
    local name="$1"
    local cmd="$2"
    local req_major="$3"
    local req_minor="${4:-0}"

    local raw
    if ! raw=$(eval "$cmd" 2>&1); then
        echo "Error: $name is not installed. Please install $name to continue."
        exit 1
    fi

    local full
    full=$(echo "$raw" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    local major="${full%%.*}"
    local minor
    minor=$(echo "$full" | cut -d. -f2)

    if [ "$major" -lt "$req_major" ] || { [ "$major" -eq "$req_major" ] && [ "$minor" -lt "$req_minor" ]; }; then
        echo "Error: $name version ${req_major}.${req_minor} or higher is required. Current version: $raw. Please update your $name installation."
        exit 1
    fi
}

# ┏━╸╻╺┳╸
# ┃╺┓┃ ┃
# ┗━┛╹ ╹
# Ensure that git is properly installed.
require_version "Git" "git --version" 2 30

# ┏━┓╻ ╻╺┳╸╻ ╻┏━┓┏┓╻
# ┣━┛┗┳┛ ┃ ┣━┫┃ ┃┃┗┫
# ╹   ╹  ╹ ╹ ╹┗━┛╹ ╹
# Cynosure targets Python 3.10+. uv provisions/pins the interpreter from the
# project's requires-python range, so we only require a baseline 3.10 here.
require_version "python3" "python3 --version" 3 10

# uv manages the Python virtual environment and workspace package resolution.
require_version "uv" "uv --version" 0 11

# Pull the latest uv release, then sync all workspace packages to their locked versions.
uv self update

# This will sync all packages including development dependencies and any feature extras.
uv sync --all-groups --all-packages

# ┏━┓┏━┓┏━╸╻┏
# ┣━┛┣┳┛┣╸ ┣┻┓
# ╹  ╹┗╸┗━╸╹ ╹
# We use prek to manage git hooks for linting, testing, and commit message validation.
# This step ensures that the hooks are installed and up to date.
require_version "prek" "uv run prek --version" 0 3

# Install git hooks via prek. Hooks enforce linting on commit/push and validate
# conventional commit message formatting.
uv run prek install \
    --prepare-hooks \
    -t pre-commit \
    -t pre-push \
    -t commit-msg
