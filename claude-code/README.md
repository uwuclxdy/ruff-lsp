# Claude Code — Ruff LSP

**Status:** native LSP plugin

Claude Code has first-class LSP plugin support since the plugins system shipped. This integration registers `ruff server` as a language server for `.py` and `.pyi` files.

## File location

Copy the plugin into a Claude Code plugin directory. Either:

- **Marketplace / shared:** drop `tools/claude-code/` into a marketplace repo and install via `/plugin`.
- **Local user plugin:** `~/.claude/plugins/ruff-lsp/.claude-plugin/plugin.json`
- **Project-scoped plugin:** `<repo>/.claude/plugins/ruff-lsp/.claude-plugin/plugin.json`

The manifest must live at `.claude-plugin/plugin.json` inside the plugin root.

## Config

Verbatim contents of `.claude-plugin/plugin.json`:

```json
{
  "name": "ruff-lsp",
  "version": "0.1.0",
  "description": "Ruff LSP integration for Claude Code.",
  "author": { "name": "ruff-lsp-everywhere" },
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

1. Install ruff: `pip install ruff` (or `uvx ruff --version`).
2. Install the plugin: `/plugin` → install from local path, or copy to `~/.claude/plugins/ruff-lsp/`.
3. Reload: `/reload-plugins`.
4. Check the LSP is running: `/plugin` → the plugin should not appear in the Errors tab. The doctor message `Executable not found in $PATH` means ruff isn't installed.
5. Smoke test — ask Claude to open a Python file with an obvious lint violation:

   ```python
   import os
   x = 1 ;
   ```

   Claude should see diagnostics for the unused `import os` (F401) and the stray semicolon (E702).

## Caveats

- **Type checking is out of scope.** Ruff does not type-check. Pair with `pyright-lsp` (available in the official marketplace) for type diagnostics. The two LSPs run side by side.
- **Project config.** Ruff auto-discovers `ruff.toml`, `.ruff.toml`, or `[tool.ruff]` in `pyproject.toml` from the workspace root. The `initializationOptions.settings` block above is only the fallback when no project config is present.
- **Virtualenvs.** `ruff server` does not need to import your project's packages — it analyzes source syntactically. No venv activation required.
- **Format-on-save.** LSP `textDocument/formatting` is supported, but whether Claude Code triggers it after edits is governed by the host, not this plugin.
- **Minimum ruff version.** `ruff server` is stable since v0.5.3 (June 2024). Older releases shipped only `ruff-lsp` (deprecated Python wrapper) — do not use it.
- **Reload after editing the manifest.** `/reload-plugins` picks up changes without restarting Claude Code.
