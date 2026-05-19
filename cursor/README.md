# Cursor — Ruff LSP

**Status:** host editor delegation (`charliermarsh.ruff` extension)

Cursor is a VS Code fork. Install the official Ruff extension (`charliermarsh.ruff`) from the Extensions panel and merge the settings snippet below into your User Settings JSON.

## File location

Open the settings file directly with **Cmd/Ctrl+Shift+P → "Open User Settings (JSON)"**, or navigate to:

| OS | Path |
|---|---|
| macOS | `~/Library/Application Support/Cursor/User/settings.json` |
| Linux | `~/.config/Cursor/User/settings.json` |
| Windows | `%APPDATA%\Cursor\User\settings.json` |

## Config

Merge into your User Settings JSON:

```json
{
  "ruff.nativeServer": "auto",
  "[python]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit",
      "source.organizeImports": "explicit"
    }
  }
}
```

`"ruff.nativeServer": "auto"` is the default since ruff-vscode shipped native-server support in 2024. It selects the Rust-based language server automatically unless you've set legacy options that require the Python server.

## Verify

1. Install the extension: **Cmd/Ctrl+Shift+X** → search `charliermarsh.ruff` → Install.
2. Open (or create) a Python file with:

   ```python
   import os
   x = 1 ;
   ```

3. Expect two diagnostics inline: `F401` (unused `os` import) and `E702` (statement ends with a semicolon).
4. Save — Ruff auto-removes the unused import, drops the semicolon, and reformats the file.

## Caveats

- **Native server is the default.** `"ruff.nativeServer": "auto"` has been the out-of-the-box default since late 2024. The Python-based `ruff-lsp` backend is deprecated; force `"on"` only if you want to pin to the native server regardless of workspace-trust state.
- **Interpreter selection.** If Ruff is installed only inside a virtual environment, set `"ruff.interpreter": ["/path/to/.venv/bin/python"]` or let the extension detect your selected Python interpreter automatically.
- **Type checking.** Ruff does not type-check. Pair with Pyright via the `ms-pyright.pyright` extension or `detachhead.basedpyright` for type diagnostics alongside Ruff lint/format.
- **Cursor extensions.** Cursor can install VS Code–compatible extensions from the Open VSX Registry or the VS Marketplace (depending on Cursor version). If the Marketplace is unavailable, search Open VSX for `charliermarsh.ruff`.
