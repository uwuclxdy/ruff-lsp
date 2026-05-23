# Cline — Ruff LSP

**Status:** host editor delegation (`charliermarsh.ruff` in VS Code)

Cline is a VS Code extension AI agent. It does not ship its own LSP client or lint runner — it reads diagnostics from VS Code's Problems panel, which is populated by whatever language server extensions are active in the host editor. Install the official Ruff extension (`charliermarsh.ruff`) and merge the settings snippet below; Cline will see the resulting diagnostics automatically.

## File location

Open the settings file with **Cmd/Ctrl+Shift+P → "Open User Settings (JSON)"**, or navigate to:

| OS | Path |
|---|---|
| macOS | `~/Library/Application Support/Code/User/settings.json` |
| Linux | `~/.config/Code/User/settings.json` |
| Windows | `%APPDATA%\Code\User\settings.json` |

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

`"ruff.nativeServer": "auto"` selects the Rust-based language server automatically and has been the default since ruff-vscode shipped native-server support in 2024.

## Verify

1. Install the Ruff extension: **Cmd/Ctrl+Shift+X** → search `charliermarsh.ruff` → Install.
2. Open a Python file with:

   ```python
   import os
   x = 1 ;
   ```

3. Expect two diagnostics in the Problems panel: `F401` (unused `os` import) and `E703` (statement ends with an unnecessary semicolon).
4. Cline reads diagnostics from the VS Code Problems panel — they appear in context when Cline analyzes or edits the file.

## Caveats

- **Diagnostic source.** Cline has no built-in lint runner. All Ruff diagnostics reach Cline through VS Code's Language Client infrastructure, populated by `charliermarsh.ruff`. Without that extension installed and active, Cline sees no Ruff output.
- **`.clinerules` hint.** You can reinforce linting expectations in a `.clinerules` file at the project root. For example, a rule like `"After editing Python files, check the VS Code Problems panel and fix any Ruff (F*, E*, W*) diagnostics before considering the task done."` nudges the agent to respect existing violations. Rules are picked up automatically by the VS Code extension, JetBrains plugin, and CLI.
- **No native LSP or MCP ruff integration.** As of May 2026, Cline has not added a built-in LSP client or a first-party ruff MCP server. It relies entirely on the host editor's extension ecosystem for language diagnostics. MCP servers in Cline are for external tool calls (databases, APIs, cloud infra), not editor language services.
- **Type checking.** Ruff does not type-check. Pair with the `ms-python.vscode-pylance` or `ms-pyright.pyright` extension for type diagnostics alongside Ruff lint/format. Both sets of diagnostics appear in the same Problems panel and are visible to Cline.
- **Interpreter selection.** If Ruff is installed only inside a virtual environment, set `"ruff.interpreter": ["/path/to/.venv/bin/python"]` or let the extension detect your selected Python interpreter automatically via the Python extension.
