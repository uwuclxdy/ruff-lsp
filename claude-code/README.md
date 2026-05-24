# Claude Code — ruff-lsp

**Status:** native LSP plugin

Claude Code has first-class LSP plugin support since the plugins system shipped. This integration registers `ruff server` as a language server for `.py` and `.pyi` files.

## Install

Three options, easiest first:

1. **Marketplace install (recommended).** This repo ships a `.claude-plugin/marketplace.json` at the root:

   ```
   /plugin marketplace add uwuclxdy/ruff-lsp
   /plugin install ruff-lsp@ruff-lsp
   ```

2. **Local user plugin.** Copy the `claude-code/` directory contents into `~/.claude/plugins/ruff-lsp/`, so the final layout is `~/.claude/plugins/ruff-lsp/.claude-plugin/plugin.json`.

3. **Project-scoped plugin.** Same as above but at `<repo>/.claude/plugins/ruff-lsp/.claude-plugin/plugin.json`.

The manifest must live at `.claude-plugin/plugin.json` inside the plugin root.

## Config

Verbatim contents of `.claude-plugin/plugin.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-plugin-manifest.json",
  "name": "ruff-lsp",
  "displayName": "ruff-lsp",
  "version": "0.1.1",
  "description": "ruff-lsp integration for Claude Code. Real-time Python linting, formatting, and diagnostics via `ruff server`.",
  "author": {
    "name": "uwuclxdy",
    "email": "37777261+uwuclxdy@users.noreply.github.com"
  },
  "homepage": "https://github.com/uwuclxdy/ruff-lsp",
  "repository": "https://github.com/uwuclxdy/ruff-lsp",
  "license": "MIT",
  "keywords": ["python", "ruff", "lsp", "lint", "format", "diagnostics"],
  "lspServers": {
    "ruff": {
      "command": "ruff",
      "args": ["server"],
      "extensionToLanguage": {
        ".py": "python",
        ".pyi": "python"
      },
      "transport": "stdio",
      "restartOnCrash": true,
      "maxRestarts": 3,
      "initializationOptions": {
        "settings": {
          "lint": { "enable": true },
          "format": { "preview": false }
        }
      }
    }
  }
}
```

### Zero-install variant

If `ruff` is not on the user's `PATH`, swap the `command`/`args` to:

```json
"command": "uvx",
"args": ["ruff", "server"]
```

This fetches and runs ruff on demand via `uv`'s tool runner. Requires `uv` (`pipx install uv` or the Astral installer).

## Verify

1. Install ruff: `pip install ruff` (or `uvx ruff --version`). Minimum version: 0.5.3.
2. Install the plugin (see [Install](#install) above).
3. Reload: `/reload-plugins`.
4. Check the LSP is running: open `/plugin` and confirm `ruff-lsp` shows no errors. If you see `Executable not found in $PATH`, ruff is not installed on `PATH` — install it or switch to the `uvx` variant below.
5. Smoke test — ask Claude to open a Python file with an obvious lint violation:

   ```python
   import os
   x = 1 ;
   ```

   Claude should see diagnostics for the unused `import os` (F401) and the stray semicolon (E703).

## Caveats

- **Type checking is out of scope.** Ruff does not type-check. Pair with `pyright-lsp` (available in the official marketplace) for type diagnostics. The two LSPs run side by side.
- **Project config.** Ruff auto-discovers `ruff.toml`, `.ruff.toml`, or `[tool.ruff]` in `pyproject.toml` from the workspace root. The `initializationOptions.settings` block above is only the fallback when no project config is present.
- **Virtualenvs.** `ruff server` does not need to import your project's packages — it analyzes source syntactically. No venv activation required.
- **Format-on-save.** LSP `textDocument/formatting` is supported, but whether Claude Code triggers it after edits is governed by the host, not this plugin.
- **Minimum ruff version.** `ruff server` is stable since v0.5.3 (June 2024). Older releases shipped only `ruff-lsp` (deprecated Python wrapper) — do not use it.
- **Reload after editing the manifest.** `/reload-plugins` picks up changes without restarting Claude Code.
