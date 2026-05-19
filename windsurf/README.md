# Windsurf — Ruff LSP

**Status:** host editor delegation (`charliermarsh.ruff` extension)

Windsurf is a VS Code fork by Codeium. Install the official Ruff extension (`charliermarsh.ruff`) from Windsurf's built-in Extensions panel and merge the settings snippet below into your User Settings JSON.

## File location

Open the settings file with **Cmd/Ctrl+Shift+P → "Open User Settings (JSON)"**, or navigate to:

| OS | Path |
|---|---|
| macOS | `~/Library/Application Support/Windsurf/User/settings.json` |
| Linux | `~/.config/Windsurf/User/settings.json` |
| Windows | `%APPDATA%\Windsurf\User\settings.json` |

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

`"ruff.nativeServer": "auto"` selects the Rust-based language server automatically when ruff ≥ 0.5.3 is installed and no legacy Python-only settings are active.

## Verify

1. Install the extension: **Cmd/Ctrl+Shift+X** → search `charliermarsh.ruff` → Install.
2. Open (or create) a Python file with:

   ```python
   import os
   x = 1 ;
   ```

3. Expect two diagnostics: `F401` (unused `os` import) and `E702` (statement ends with a semicolon).
4. Save — Ruff auto-removes the unused import, drops the semicolon, and reformats the file.

## Caveats

- **Extension marketplace.** Windsurf ships its own internal extension panel — you cannot install directly from the VS Marketplace or Open VSX. Search `charliermarsh.ruff` inside Windsurf's Extensions panel (Cmd/Ctrl+Shift+X); Windsurf mirrors popular extensions including the Ruff extension. If it is not found, install from a `.vsix`: download from [open-vsx.org/extension/charliermarsh/ruff](https://open-vsx.org/extension/charliermarsh/ruff), then run **"Extensions: Install from VSIX..."** from the command palette.
- **Settings path.** Windsurf stores user settings under `Windsurf/` (not `Code/`), so VS Code and Windsurf configs are independent. Import from VS Code during onboarding (command palette → "Import Settings from VS Code") to carry over an existing Ruff config.
- **Native server is the default.** `"auto"` has been the out-of-the-box default since ruff-vscode shipped native-server support in 2024. Force `"on"` only if you want to pin to the native server regardless of workspace-trust state.
- **Type checking.** Ruff does not type-check. Pair with `ms-pyright.pyright` or `detachhead.basedpyright` for type diagnostics alongside Ruff lint and format.
