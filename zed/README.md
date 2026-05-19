# Zed — Ruff LSP

**Status:** native LSP

Ruff is a built-in language server in Zed. No extension installation is needed — Zed ships with `ruff server` support out of the box. By default, `basedpyright` handles type checking and `ruff` handles formatting and linting.

## File location

`~/.config/zed/settings.json` on Linux and macOS (Zed uses the same path on both platforms via XDG conventions on Linux and `~/.config` on macOS as of Zed 0.160+).

Open it with `cmd-,` / `ctrl-,`.

## Config

Two blocks are required: `lsp.ruff` for server-level options, and `languages.Python` to control which servers are active and how formatting works.

```json
{
  "lsp": {
    "ruff": {
      "initialization_options": {
        "settings": {
          "lint": { "enable": true },
          "format": { "preview": false }
        }
      }
    }
  },
  "languages": {
    "Python": {
      "language_servers": ["ruff", "basedpyright", "..."],
      "formatter": {
        "language_server": {
          "name": "ruff"
        }
      },
      "code_actions_on_format": {
        "source.organizeImports.ruff": true
      },
      "format_on_save": "on"
    }
  }
}
```

The `"..."` sentinel tells Zed to keep any other already-registered language servers enabled; omit it to disable everything not explicitly listed.

## Verify

1. Install ruff: `pip install ruff` (or `uvx ruff --version`).
2. Open a Python file containing:

   ```python
   import os
   x = 1 ;
   ```

3. Expect two diagnostics: **F401** (`os` imported but unused) and **E702** (statement ends with a semicolon).
4. If no diagnostics appear, open the LSP log via the command palette: `editor: open language server logs`, select `ruff`, and check for startup errors.

## Caveats

- **`ruff server` only.** Zed's built-in integration targets the native `ruff server` command (stable since ruff v0.5.3, June 2024). The older `ruff-lsp` Python wrapper is deprecated and must not be used.
- **Side-by-side with basedpyright / pyright.** Because ruff does not type-check, run it alongside a type-checking server. The `language_servers` list supports any combination: `["ruff", "basedpyright", "..."]` or `["ruff", "pyright", "..."]`. Both servers receive diagnostics independently.
- **Disabling basedpyright.** To remove the default type checker entirely (e.g. switching to `ty`): `["ty", "!basedpyright", "ruff", "..."]`. The `!` prefix disables a server.
- **Format-on-save.** The `"format_on_save": "on"` key triggers Zed's two-phase formatter pipeline: first `code_actions_on_format` (import sorting via `source.organizeImports.ruff`), then the `formatter` (ruff's `textDocument/formatting`). Set either phase independently.
- **Project config takes precedence.** Ruff auto-discovers `ruff.toml`, `.ruff.toml`, or `[tool.ruff]` in `pyproject.toml` from the workspace root. The `initialization_options.settings` block above applies only when no project config is found.
- **`initialization_options` scope.** Settings placed here are Zed-specific and not shared with other editors or CLI invocations. For cross-tool consistency, prefer `ruff.toml` at the project level.
