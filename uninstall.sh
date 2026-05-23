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

vscode_has_ext() {
  local ext="$1" cli
  for cli in code cursor windsurf code-insiders codium; do
    if have "$cli" && "$cli" --list-extensions 2>/dev/null | grep -qix "$ext"; then
      return 0
    fi
  done
  return 1
}

vscode_settings_path() {
  case "$(uname -s)" in
    Darwin) echo "$HOME/Library/Application Support/Code/User/settings.json" ;;
    Linux)  echo "$HOME/.config/Code/User/settings.json" ;;
    *)      echo "${APPDATA:-}/Code/User/settings.json" ;;
  esac
}

cursor_settings_path() {
  case "$(uname -s)" in
    Darwin) echo "$HOME/Library/Application Support/Cursor/User/settings.json" ;;
    Linux)  echo "$HOME/.config/Cursor/User/settings.json" ;;
    *)      echo "${APPDATA:-}/Cursor/User/settings.json" ;;
  esac
}

windsurf_settings_path() {
  case "$(uname -s)" in
    Darwin) echo "$HOME/Library/Application Support/Windsurf/User/settings.json" ;;
    Linux)  echo "$HOME/.config/Windsurf/User/settings.json" ;;
    *)      echo "${APPDATA:-}/Windsurf/User/settings.json" ;;
  esac
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

if exists "$HOME/.config/zed/settings.json"; then
  note_manual 'Zed' "$HOME/.config/zed/settings.json" 'lsp.ruff, languages.Python.language_servers, formatter, format_on_save'
fi

cs="$(cursor_settings_path)"
if exists "$cs"; then
  note_manual 'Cursor' "$cs" 'ruff.*, "[python]" formatter overrides, editor.codeActionsOnSave ruff entries'
fi

ws="$(windsurf_settings_path)"
if exists "$ws"; then
  note_manual 'Windsurf' "$ws" 'ruff.*, "[python]" formatter overrides, editor.codeActionsOnSave ruff entries'
fi

vs="$(vscode_settings_path)"
if exists "$vs"; then
  if vscode_has_ext github.copilot || vscode_has_ext saoudrizwan.claude-dev \
     || vscode_has_ext continue.continue || vscode_has_ext sourcegraph.cody-ai \
     || vscode_has_ext rooveterinaryinc.roo-cline || vscode_has_ext rooveterinaryinc.roo-code; then
    note_manual 'VS Code (Copilot/Cline/Roo/Continue/Cody)' "$vs" 'ruff.*, "[python]" formatter, editor.codeActionsOnSave ruff entries'
  fi
fi

# --- Companion files --------------------------------------------------------

printf '\n%sCompanion files%s\n' "$c_yellow" "$c_reset"
companion_found=0
# Continue rule files: global (rare) and project-scoped.
for p in "$HOME/.continue/rules/ruff.md" "$PWD/.continue/rules/ruff.md"; do
  if maybe_rm "$p"; then companion_found=1; fi
done
[[ $companion_found -eq 0 ]] && printf '  %snone found%s\n' "$c_dim" "$c_reset"

# --- Extension uninstall (suggestion only — never auto-run) -----------------

printf '\n%sCharliermarsh Ruff extension (keep unless you want pure removal)%s\n' "$c_yellow" "$c_reset"
shown=0
for cli in code cursor windsurf code-insiders codium; do
  if have "$cli" && "$cli" --list-extensions 2>/dev/null | grep -qix 'charliermarsh.ruff'; then
    printf '  %ssuggested%s   %s --uninstall-extension charliermarsh.ruff\n' "$c_dim" "$c_reset" "$cli"
    shown=1
  fi
done
[[ $shown -eq 0 ]] && printf '  %snot installed in any detected editor%s\n' "$c_dim" "$c_reset"

printf '\n%sDone.%s\n' "$c_green" "$c_reset"
[[ $REMOVE -eq 0 ]] && printf '  Rerun with --remove to delete drop-in plugin dirs.\n'
