# Cody — Ruff LSP

**Status:** host editor delegation (`charliermarsh.ruff` extension)

Cody is an AI coding assistant extension that runs inside VS Code (and JetBrains/Visual Studio). It has no lint engine of its own — diagnostics come from whichever language server extensions the host editor loads. In VS Code, install the official Ruff extension (`charliermarsh.ruff`) and Cody will see Ruff diagnostics inline the same way the editor does.

## File location

Open the VS Code settings file with **Cmd/Ctrl+Shift+P → "Open User Settings (JSON)"**, or navigate to:

| OS | Path |
|---|---|
| macOS | `~/Library/Application Support/Code/User/settings.json` |
| Linux | `~/.config/Code/User/settings.json` |
| Windows | `%APPDATA%\Code\User\settings.json` |

For VS Code Insiders, replace `Code` with `Code - Insiders`.

## Config

1. Install the Ruff extension: **Cmd/Ctrl+Shift+X** → search `charliermarsh.ruff` → Install.
2. Merge the snippet below into your User Settings JSON:

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

`"ruff.nativeServer": "auto"` selects the Rust-based `ruff server` automatically (default since ruff-vscode 2024). Do not use the legacy Python-based `ruff-lsp` — it is deprecated.

## Verify

1. Install the extension: **Cmd/Ctrl+Shift+X** → search `charliermarsh.ruff` → Install.
2. Open (or create) a Python file with:

   ```python
   import os
   x = 1 ;
   ```

3. Expect two diagnostics inline: `F401` (unused `os` import) and `E703` (statement ends with an unnecessary semicolon).
4. Save — Ruff auto-removes the unused import, drops the semicolon, and reformats the file.

## Caveats

- **Product status.** Cody is actively maintained and published on the VS Code Marketplace. Sourcegraph migrated the `sourcegraph/cody` GitHub repo to a private codebase; a frozen pre-migration snapshot is preserved at [`sourcegraph/cody-public-snapshot`](https://github.com/sourcegraph/cody-public-snapshot). Install the extension via the Marketplace — the snapshot repo is reference-only and not the upstream source.
- **Cody is not a linter.** Cody provides chat, completions, and code edits. It surfaces the same diagnostic squiggles that VS Code already shows from language server extensions — it does not add its own lint pass.
- **JetBrains.** The JetBrains Cody plugin uses IntelliJ's built-in inspection and any installed Python plugins (e.g., the Ruff plugin from the JetBrains Marketplace) for diagnostics. Ruff LSP configuration for IntelliJ is separate from the VS Code snippet above.
- **Type checking.** Ruff does not type-check. Pair with `ms-pyright.pyright` or `detachhead.basedpyright` for type diagnostics alongside Ruff lint/format.
- **Native server is the default.** `"ruff.nativeServer": "auto"` has been the out-of-the-box default since late 2024. Force `"on"` only if you need to pin to the native server regardless of workspace-trust state.
