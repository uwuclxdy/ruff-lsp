# Crush — Ruff LSP

**Status:** native LSP

Crush (by Charm) has first-class LSP support via its `lsp` config key. Each entry is keyed by an arbitrary name and maps to an `LSPConfig` object with `command`, `args`, `env`, `filetypes`, `root_markers`, `init_options`, and `options` fields.

## File location

Crush resolves config in this priority order (first found wins):

1. `.crush.json` — project root
2. `crush.json` — project root
3. `$HOME/.config/crush/crush.json` — global user config

Add the ruff block to whichever file you use (or create `$HOME/.config/crush/crush.json` for a user-global setup).

## Config

Merge this block into your existing `crush.json` / `.crush.json`:

```json
{
  "$schema": "https://charm.land/crush.json",
  "lsp": {
    "ruff": {
      "command": "ruff",
      "args": ["server"],
      "filetypes": ["py", "pyi"],
      "root_markers": ["pyproject.toml", "ruff.toml", ".ruff.toml", ".git"]
    }
  }
}
```

### Zero-install variant

If `ruff` is not on the user's `PATH`, swap `command`/`args` to:

```json
"command": "uvx",
"args": ["ruff", "server"]
```

Requires `uv` (`pipx install uv` or the [Astral installer](https://docs.astral.sh/uv/getting-started/installation/)).

## Verify

1. Install ruff: `pip install ruff` (or confirm `ruff --version`).
2. Drop the config snippet into `.crush.json` at your project root (or global config).
3. Open Crush in the same project.
4. Create a Python file with obvious violations:

   ```python
   import os
   x = 1 ;
   ```

   Crush should surface diagnostics for the unused `import os` (F401) and the stray semicolon (E702).

## Caveats

- **Type checking is out of scope.** Ruff does not type-check. Pair with `pyright` (add a separate `lsp.pyright` entry) for type diagnostics.
- **Project config.** Ruff auto-discovers `ruff.toml`, `.ruff.toml`, or `[tool.ruff]` in `pyproject.toml` from the workspace root.
- **Minimum ruff version.** `ruff server` is stable since v0.5.3 (June 2024). Do not use the deprecated `ruff-lsp` Python wrapper.
- **`filetypes` field.** The schema accepts extension strings without the leading dot (e.g. `"py"`, not `".py"`).
- **No `init_options` needed for basic use.** `ruff server` reads project config automatically; `init_options`/`options` can be added for advanced overrides.
