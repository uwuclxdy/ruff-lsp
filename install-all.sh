#!/usr/bin/env bash
# Detect installed AI coding tools and print the matching ruff-lsp config path.
#
# This script does NOT mutate user config — JSON merges are fragile and editors
# often have running processes that rewrite settings.json. Instead it tells you
# what to copy or merge and where. For drop-in plugins (Claude Code, Crush,
# OpenCode) it offers to copy when there is no existing config to clobber.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COPY=0
[[ "${1:-}" == "--copy" ]] && COPY=1

c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_dim=$'\033[2m'; c_reset=$'\033[0m'

have() { command -v "$1" >/dev/null 2>&1; }
exists() { [[ -e "$1" ]]; }

vscode_has_ext() {
  # Pass the publisher.extension id, e.g. charliermarsh.ruff.
  # Checks each known VS Code variant CLI.
  local ext="$1" cli
  for cli in code cursor windsurf code-insiders codium; do
    if have "$cli" && "$cli" --list-extensions 2>/dev/null | grep -qix "$ext"; then
      return 0
    fi
  done
  return 1
}

print_tool() {
  local name="$1" status="$2" hint="$3"
  printf '  %-18s %s%s%s  %s\n' "$name" "$c_green" "$status" "$c_reset" "$hint"
}

print_miss() {
  local name="$1"
  printf '  %-18s %s%s%s\n' "$name" "$c_dim" "not detected" "$c_reset"
}

printf '\n%sScanning for installed AI coding tools...%s\n\n' "$c_yellow" "$c_reset"

# --- CLI agents -------------------------------------------------------------

if have claude || [[ -d "$HOME/.claude" ]]; then
  print_tool 'Claude Code' 'found' "copy $REPO_ROOT/claude-code/.claude-plugin → ~/.claude/plugins/ruff-lsp/.claude-plugin"
else
  print_miss 'Claude Code'
fi

if have codex || [[ -f "$HOME/.codex/config.toml" ]]; then
  print_tool 'Codex CLI' 'found' "see $REPO_ROOT/codex-cli/README.md (PostToolUse hook workaround)"
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

# --- Editors with native LSP -----------------------------------------------

if have zed || exists "$HOME/.config/zed"; then
  print_tool 'Zed' 'found' "merge $REPO_ROOT/zed/settings.json into ~/.config/zed/settings.json"
else
  print_miss 'Zed'
fi

# --- VS Code forks (host editor delegation) --------------------------------

cursor_settings() {
  case "$(uname -s)" in
    Darwin) echo "$HOME/Library/Application Support/Cursor/User/settings.json" ;;
    Linux)  echo "$HOME/.config/Cursor/User/settings.json" ;;
    *)      echo "$APPDATA/Cursor/User/settings.json" ;;
  esac
}

windsurf_settings() {
  case "$(uname -s)" in
    Darwin) echo "$HOME/Library/Application Support/Windsurf/User/settings.json" ;;
    Linux)  echo "$HOME/.config/Windsurf/User/settings.json" ;;
    *)      echo "$APPDATA/Windsurf/User/settings.json" ;;
  esac
}

vscode_settings() {
  case "$(uname -s)" in
    Darwin) echo "$HOME/Library/Application Support/Code/User/settings.json" ;;
    Linux)  echo "$HOME/.config/Code/User/settings.json" ;;
    *)      echo "$APPDATA/Code/User/settings.json" ;;
  esac
}

if have cursor || exists "$(cursor_settings)"; then
  if vscode_has_ext charliermarsh.ruff; then
    print_tool 'Cursor' 'ruff ext present' "merge $REPO_ROOT/cursor/settings.json into $(cursor_settings)"
  else
    print_tool 'Cursor' 'found' "install charliermarsh.ruff, then merge $REPO_ROOT/cursor/settings.json"
  fi
else
  print_miss 'Cursor'
fi

if have windsurf || exists "$(windsurf_settings)"; then
  print_tool 'Windsurf' 'found' "install charliermarsh.ruff via in-app panel, merge $REPO_ROOT/windsurf/settings.json"
else
  print_miss 'Windsurf'
fi

# --- VS Code extensions (Copilot, Cline, Roo, Continue, Cody) --------------

if vscode_has_ext github.copilot; then
  if vscode_has_ext charliermarsh.ruff; then
    print_tool 'GitHub Copilot' 'ruff ext present' "merge $REPO_ROOT/github-copilot/settings.json"
  else
    print_tool 'GitHub Copilot' 'copilot present' "install charliermarsh.ruff, merge $REPO_ROOT/github-copilot/settings.json"
  fi
else
  print_miss 'GitHub Copilot'
fi

if vscode_has_ext saoudrizwan.claude-dev; then
  print_tool 'Cline' 'found' "merge $REPO_ROOT/cline/settings.json into $(vscode_settings)"
else
  print_miss 'Cline'
fi

if vscode_has_ext rooveterinaryinc.roo-cline || vscode_has_ext rooveterinaryinc.roo-code; then
  print_tool 'Roo Code' 'found' "merge $REPO_ROOT/roo-code/settings.json (also applies to Zoo Code)"
else
  print_miss 'Roo Code'
fi

if vscode_has_ext continue.continue; then
  print_tool 'Continue' 'found' "merge $REPO_ROOT/continue/settings.json; drop ruff.md into <project>/.continue/rules/"
else
  print_miss 'Continue'
fi

if vscode_has_ext sourcegraph.cody-ai; then
  print_tool 'Cody' 'found' "merge $REPO_ROOT/cody/settings.json into $(vscode_settings)"
else
  print_miss 'Cody'
fi

# --- Ruff availability check ------------------------------------------------

printf '\n%sruff availability%s\n' "$c_yellow" "$c_reset"
if have ruff; then
  printf '  %sruff%s  %s\n' "$c_green" "$c_reset" "$(ruff --version)"
elif have uvx; then
  printf '  %sruff%s  %s\n' "$c_yellow" "$c_reset" "not in PATH — uvx ruff server will fetch on demand"
else
  printf '  %sruff%s  not found; install with: pip install ruff  (or pipx install uv)\n' "$c_dim" "$c_reset"
fi

printf '\n%sDone.%s\n' "$c_yellow" "$c_reset"
printf '  --copy is reserved for future auto-copy support; for now configs are listed for manual merge.\n'
[[ $COPY -eq 1 ]] && printf '  (--copy flag accepted but no-op pending JSON merge support.)\n'
