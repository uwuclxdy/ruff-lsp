#!/usr/bin/env bash
# Detect installed ruff-lsp integrations and print/perform removal steps.
#
# Two modes:
#   uninstall.sh           — dry run; prints what would be removed
#   uninstall.sh --remove  — deletes drop-in plugin dirs only
#                            (never edits user settings.json files — JSON merge
#                            reversal is unsafe without a real parser)

set -euo pipefail

c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_red=$'\033[31m'; c_dim=$'\033[2m'; c_reset=$'\033[0m'

REMOVE=0
[[ "${1:-}" == "--remove" ]] && REMOVE=1

have() { command -v "$1" >/dev/null 2>&1; }
exists() { [[ -e "$1" ]]; }

# Returns 0 if the path was/would be removed.
maybe_rm() {
  local target="$1"
  if [[ ! -e "$target" ]]; then
    return 1
  fi
  if [[ $REMOVE -eq 1 ]]; then
    rm -rf -- "$target"
    printf '  %sremoved%s  %s\n' "$c_red" "$c_reset" "$target"
  else
    printf '  %swould remove%s  %s\n' "$c_yellow" "$c_reset" "$target"
  fi
  return 0
}

note_manual() {
  local tool="$1" path="$2" keys="$3"
  printf '  %smanual%s      %s — delete keys [%s] from %s\n' "$c_dim" "$c_reset" "$tool" "$keys" "$path"
}

if [[ $REMOVE -eq 1 ]]; then
  printf '\n%sUninstall mode: --remove. Drop-in plugin dirs will be deleted.%s\n' "$c_red" "$c_reset"
else
  printf '\n%sDry run. Pass --remove to actually delete drop-in plugin dirs.%s\n' "$c_yellow" "$c_reset"
fi
printf '%sUser settings.json files are NEVER auto-edited — those entries are listed for manual cleanup.%s\n\n' "$c_dim" "$c_reset"

# --- Drop-in plugin dirs (safe to delete) -----------------------------------

printf '%sDrop-in plugin directories%s\n' "$c_yellow" "$c_reset"

found_any=0
for p in \
  "$HOME/.claude/plugins/ruff-lsp" \
  "$HOME/.config/goose/plugins/ruff-lsp" \
  "$HOME/.agents/plugins/ruff-lsp"
do
  if maybe_rm "$p"; then found_any=1; fi
done
[[ $found_any -eq 0 ]] && printf '  %snone found%s\n' "$c_dim" "$c_reset"

# --- Settings.json entries (must be edited by hand) -------------------------

printf '\n%sSettings file entries (manual cleanup)%s\n' "$c_yellow" "$c_reset"

if have codex || exists "$HOME/.codex/config.toml"; then
  note_manual 'Codex CLI' "$HOME/.codex/config.toml" '[[hooks]] entries with command containing "ruff"'
fi

if exists "$HOME/.gemini/settings.json"; then
  note_manual 'Gemini CLI' "$HOME/.gemini/settings.json" 'mcpServers.ruff'
fi

if exists "$HOME/.aider.conf.yml"; then
  note_manual 'Aider' "$HOME/.aider.conf.yml" 'lint-cmd, auto-lint'
fi

if exists "$HOME/.config/opencode/opencode.json"; then
  note_manual 'OpenCode' "$HOME/.config/opencode/opencode.json" 'lsp.ruff'
fi

if exists "$HOME/.config/crush/crush.json" || exists "$PWD/.crush.json" || exists "$PWD/crush.json"; then
  note_manual 'Crush' "$HOME/.config/crush/crush.json or <repo>/.crush.json" 'lsp.ruff'
fi

printf '\n%sDone.%s\n' "$c_green" "$c_reset"
[[ $REMOVE -eq 0 ]] && printf '  Rerun with --remove to delete drop-in plugin dirs.\n'
