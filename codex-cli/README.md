# Codex CLI — ruff-lsp

**Status:** unsupported — no LSP subsystem; closest workaround is a `PostToolUse` hook or an `AGENTS.md` standing instruction

Codex CLI (the Rust rewrite at `openai/codex`) is a terminal-based agentic coding assistant, not an editor. Its `config.toml` schema has no `lsp_servers`, `language_servers`, or diagnostics field. There is no way to register `ruff server` as a language server.

Two workarounds exist: (1) a `PostToolUse` hook that auto-runs `ruff check --fix` after Codex edits files, or (2) a standing instruction in `AGENTS.md` so the agent always runs ruff after modifying Python files.

## File location

Hooks load from any of these layers; later layers override earlier ones for the same event:

- `~/.codex/config.toml` (inline `[[hooks.*]]`)
- `~/.codex/hooks.json`
- `<repo>/.codex/config.toml` (only when the project layer is trusted)
- `<repo>/.codex/hooks.json` (only when the project layer is trusted)

If a single layer contains both `hooks.json` and inline `[hooks]`, Codex loads both and warns. Pick one per layer.

## Config

### Option A — PostToolUse hook (automatic, runs after Codex edits files)

Add to `~/.codex/config.toml`:

```toml
# Fires after Codex applies a patch. The matcher accepts `apply_patch`,
# `Edit`, or `Write` as aliases for the same underlying tool; `tool_name`
# in the payload is always `apply_patch`.
[[hooks.PostToolUse]]
matcher = "apply_patch|Edit|Write"

[[hooks.PostToolUse.hooks]]
type = "command"
# Codex passes the event payload as JSON on stdin. tool_input.command
# isn't a file list, so re-lint changed Python files via mtime: ruff is
# fast enough to scan the whole tree on each edit.
command = "ruff check --fix --quiet . 2>/dev/null || true"
async = true
timeout = 30
statusMessage = "ruff"
```

To also catch shell-driven edits (e.g. `sed -i` from a Bash tool call), add a second matcher group:

```toml
[[hooks.PostToolUse]]
matcher = "^Bash$"

[[hooks.PostToolUse.hooks]]
type = "command"
command = "ruff check --fix --quiet . 2>/dev/null || true"
async = true
timeout = 30
statusMessage = "ruff"
```

### Option B — Standing instructions via `AGENTS.md` (simpler, model-driven)

The top-level `instructions` field in `config.toml` is reserved for future use. Use an `AGENTS.md` file at the repo root (or `~/.codex/AGENTS.md` for user-global scope) instead:

```markdown
# AGENTS.md

After writing or modifying any Python file, always run:

    ruff check --fix <file>

and surface any remaining violations as a follow-up message.
```

This relies on model compliance rather than a deterministic hook.

## Verify

Open a Python session with `codex` and ask it to write a file containing `import os\nx = 1 ;` — then check that it runs `ruff check --fix` and reports or fixes F401 (unused import) and E703 (statement ends with an unnecessary semicolon).

## Caveats

- **No LSP, no live diagnostics.** There is no editor viewport; ruff violations are only surfaced when the hook or model explicitly runs ruff.
- **`matcher` is matched against `tool_name`, not file path.** Canonical tool names are `Bash`, `apply_patch`, and MCP names like `mcp__server__tool`. `apply_patch` also accepts `Edit` and `Write` as matcher aliases, but the hook payload always reports `tool_name: "apply_patch"`. File-extension filtering must happen inside the shell command.
- **Hooks do not intercept everything.** `WebSearch` and richer `unified_exec` flows are not currently routed through `PostToolUse`.
- **Hook payload arrives on stdin as JSON.** Fields include `session_id`, `hook_event_name`, `cwd`, `tool_name`, `tool_input`, and `tool_response`. Use `jq` on `$(cat)` if your hook needs them.
- **No format-on-save.** `ruff format` can be appended to the hook command (`ruff format --quiet .`) but runs after the fact, not inline with edits.
- **Pyright.** Codex CLI has no LSP at all, so Pyright is absent. Type checking requires a separate hook command, or a note in `AGENTS.md`.
- **Minimum ruff version.** Use ruff ≥ 0.5.3 for `ruff check --fix`. The deprecated `ruff-lsp` Python wrapper does not apply here.
- **Sources.** Hooks schema verified against [`codex-rs/config/src/hook_config.rs`](https://github.com/openai/codex/blob/main/codex-rs/config/src/hook_config.rs) and the [Hooks](https://developers.openai.com/codex/hooks) and [Advanced Configuration](https://developers.openai.com/codex/config-advanced) pages of the official Codex docs.
