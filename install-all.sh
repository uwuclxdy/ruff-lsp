#!/usr/bin/env bash
# Detect installed AI coding tools and print the matching ruff-lsp config path.
#
# This script does NOT mutate user config — JSON merges are fragile and editors
# often have running processes that rewrite settings.json. Instead it tells you
# what to copy or merge and where.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COPY=0
[[ "${1:-}" == "--copy" ]] && COPY=1

c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_dim=$'\033[2m'; c_reset=$'\033[0m'

have() { command -v "$1" >/dev/null 2>&1; }
exists() { [[ -e "$1" ]]; }

print_tool() {
  local name="$1" status="$2" hint="$3"
  printf '  %-14s %s%s%s  %s\n' "$name" "$c_green" "$status" "$c_reset" "$hint"
}

print_miss() {
  local name="$1"
  printf '  %-14s %s%s%s\n' "$name" "$c_dim" "not detected" "$c_reset"
}

printf '\n%sScanning for installed AI coding tools...%s\n\n' "$c_yellow" "$c_reset"

if have claude || [[ -d "$HOME/.claude" ]]; then
  print_tool 'Claude Code' 'found' "copy $REPO_ROOT/claude-code/.claude-plugin → ~/.claude/plugins/ruff-lsp/.claude-plugin"
else
  print_miss 'Claude Code'
fi

if have codex || [[ -f "$HOME/.codex/config.toml" ]]; then
  print_tool 'Codex CLI' 'found' "see $REPO_ROOT/codex-cli/README.md (PostToolUse hook)"
else
  print_miss 'Codex CLI'
fi

if have gemini || [[ -f "$HOME/.gemini/settings.json" ]]; then
  print_tool 'Gemini CLI' 'found' "merge mcpServers from $REPO_ROOT/gemini-cli/README.md into ~/.gemini/settings.json"
else
  print_miss 'Gemini CLI'
fi

if have aider; then
  print_tool 'Aider' 'found' "copy $REPO_ROOT/aider/.aider.conf.yml → ~/.aider.conf.yml"
else
  print_miss 'Aider'
fi

if have opencode; then
  print_tool 'OpenCode' 'found' "merge $REPO_ROOT/opencode/opencode.json into ~/.config/opencode/opencode.json"
else
  print_miss 'OpenCode'
fi

if have crush; then
  print_tool 'Crush' 'found' "merge $REPO_ROOT/crush/crush.json into ~/.config/crush/crush.json"
else
  print_miss 'Crush'
fi

if have goose; then
  print_tool 'Goose' 'found' "see $REPO_ROOT/goose/README.md (hooks/ plugin layout)"
else
  print_miss 'Goose'
fi

printf '\n%sruff availability%s\n' "$c_yellow" "$c_reset"
if have ruff; then
  printf '  %sruff%s  %s\n' "$c_green" "$c_reset" "$(ruff --version)"
elif have uvx; then
  printf '  %sruff%s  %s\n' "$c_yellow" "$c_reset" "not in PATH — uvx ruff server will fetch on demand"
else
  printf '  %sruff%s  not found; install with: pip install ruff  (or pipx install uv)\n' "$c_dim" "$c_reset"
fi

printf '\n%sDone.%s\n' "$c_yellow" "$c_reset"
[[ $COPY -eq 1 ]] && printf '  (--copy flag accepted but no-op pending JSON merge support.)\n'
