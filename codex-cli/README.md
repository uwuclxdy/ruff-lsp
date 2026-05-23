# Codex CLI — Ruff LSP

**Status:** unsupported — no LSP subsystem; closest workaround is a `PostToolUse` hook or `instructions` field

Codex CLI (the Rust rewrite at `openai/codex`) is a terminal-based agentic coding assistant, not an editor. Its `~/.codex/config.toml` schema (verified from `codex-rs/config/src/config_toml.rs` at HEAD) has no `lsp_servers`, `language_servers`, or diagnostics field. There is no way to register `ruff server` as a language server.

Two workarounds exist: (1) a `PostToolUse` hook that auto-runs `ruff check --fix` after every tool call, or (2) embedding a standing instruction in `config.toml` so the agent always runs ruff after modifying Python files.

## File location

```
~/.codex/config.toml
```

Codex also reads a project-local `codex.toml` (or `.codex/config.toml`) in the working directory, which overrides the user config for project-specific hooks.

## Config

### Option A — PostToolUse hook (automatic, runs after every tool call)

Add to `~/.codex/config.toml`:

```toml
[[hooks.PostToolUse]]
# matcher is a regex matched against the tool name.
# Omit matcher (or use ".*") to fire after every tool call.
# Codex's shell tool is typically "Bash"; adjust if your build differs.
matcher = "Bash"

[[hooks.PostToolUse.hooks]]
type = "command"
# Runs ruff on all .py files changed in the last 5 seconds.
# Replace with `ruff check --fix .` to lint the whole working tree.
command = "find . -name '*.py' -newer /tmp/.codex-ruff-ts -exec ruff check --fix {} + 2>/dev/null; touch /tmp/.codex-ruff-ts"
async = true
timeout = 30
statusMessage = "ruff"
```

**TODO** — the exact tool name Codex uses for file writes is unverifiable from the public schema alone. `"Bash"` is the most likely value based on the test suite (`matcher = "^Bash$"`), but confirm by running `codex` once and inspecting hook debug output. Use `matcher = ".*"` as a safe fallback that fires after every tool call.

### Option B — Standing instructions (simpler, model-driven)

Add to `~/.codex/config.toml`:

```toml
instructions = """
After writing or modifying any Python file, always run:
  ruff check --fix <file>
and surface any remaining violations as a follow-up message.
"""
```

This relies on model compliance rather than a deterministic hook.

## Verify

Open a Python session with `codex` and ask it to write a file containing `import os\nx = 1 ;` — then check that it runs `ruff check --fix` and reports or fixes F401 (unused import) and E703 (statement ends with an unnecessary semicolon).

## Caveats

- **No LSP, no live diagnostics.** There is no editor viewport; ruff violations are only surfaced when the hook or model explicitly runs ruff.
- **PostToolUse matcher is tool-name only.** The `matcher` regex matches the Codex tool name, not the file path. You cannot filter to `.py` files at the hook-dispatch layer — the shell command itself must do the filtering.
- **No format-on-save.** `ruff format` can be appended to the hook command (`ruff format <files>`) but it runs after the fact, not inline with edits.
- **Pyright.** Codex CLI has no LSP at all, so Pyright is also absent. Type checking requires running `pyright` explicitly (e.g. a second hook command, or including it in `instructions`).
- **Minimum ruff version.** Use ruff ≥ 0.5.3 for `ruff check --fix`. Avoid the deprecated `ruff-lsp` Python wrapper.
- **Hook schema.** Verified against `codex-rs/config/src/hook_config.rs` at `openai/codex` main branch (May 2026). The `[hooks.PostToolUse]` TOML path matches the `HookEventsToml.post_tool_use` field with `#[serde(rename = "PostToolUse")]`.
