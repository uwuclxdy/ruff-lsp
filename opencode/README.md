# OpenCode — ruff-lsp

**Status:** native LSP

OpenCode has a native `lsp` block in its config that accepts custom LSP server definitions. Ruff is not a built-in (the built-in Python server is `pyright`), so it must be declared as a custom entry with an explicit `extensions` array.

## File location

OpenCode merges config files in this precedence order (highest last wins):

- **Global:** `$XDG_CONFIG_HOME/opencode/opencode.json` (typically `~/.config/opencode/opencode.json`)
- **Project:** `<repo>/opencode.json` or `<repo>/opencode.jsonc` — safe to commit

For ruff diagnostics in every project, add the block to your global config. For per-repo opt-in, put it in `<repo>/opencode.json`.

## Config

Merge the following `lsp` key into your `opencode.json`. The object key `"ruff"` is the server ID (arbitrary, not a built-in ID).

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {
    "ruff": {
      "command": ["ruff", "server", "--stdio"],
      "extensions": [".py", ".pyi"]
    }
  }
}
```

### Zero-install variant

If `ruff` is not on the user's `PATH`, replace the `command` with:

```json
"command": ["uvx", "ruff", "server", "--stdio"]
```

Requires `uv` (`pip install uv` or the Astral installer).

### Pairing with Pyright

OpenCode's built-in `pyright` server handles type checking. Both run in parallel — no conflict. To activate both:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {
    "pyright": {},
    "ruff": {
      "command": ["ruff", "server", "--stdio"],
      "extensions": [".py", ".pyi"]
    }
  }
}
```

## Verify

1. Install ruff: `pip install ruff` (or confirm `ruff --version` works).
2. Add the config block above to `~/.config/opencode/opencode.json`.
3. Open a Python file with obvious violations:

   ```python
   import os
   x = 1 ;
   ```

4. OpenCode should report diagnostics for unused `import os` (F401) and the stray semicolon (E703).

## Caveats

- **`extensions` is required.** OpenCode enforces that custom (non-built-in) LSP entries declare an `extensions` array. Omitting it is a config validation error.
- **`--stdio` flag.** The `command` array is passed directly to the shell; `--stdio` is required for LSP-over-stdin/stdout transport.
- **Type checking is out of scope.** Ruff does not type-check. Pair with the built-in `pyright` entry (see above) for type diagnostics.
- **Project config.** Ruff auto-discovers `ruff.toml`, `.ruff.toml`, or `[tool.ruff]` in `pyproject.toml` from the workspace root. No `initializationOptions` are needed for default behavior.
- **Virtualenvs.** `ruff server` analyzes source syntactically — no venv activation required.
- **Minimum ruff version.** `ruff server` is stable since v0.5.3 (June 2024). Do not use the deprecated `ruff-lsp` Python wrapper.
- **`lsp: true` shorthand.** Setting `"lsp": true` enables only built-in servers; it does not include custom entries. You must use an object form to add ruff.
