# GitHub Copilot — Ruff LSP

**Status:** host editor delegation (`charliermarsh.ruff` in VS Code; JetBrains Ruff plugin for IntelliJ/PyCharm)

## File location

**VS Code** — merge the snippet into your user or workspace `settings.json`:

- User settings: `~/.config/Code/User/settings.json` (Linux) / `%APPDATA%\Code\User\settings.json` (Windows) / `~/Library/Application Support/Code/User/settings.json` (macOS)
- Workspace settings: `<repo>/.vscode/settings.json`

**JetBrains** — install the [Ruff plugin](https://plugins.jetbrains.com/plugin/20574-ruff) from the marketplace (`Settings → Plugins → Marketplace → Ruff`). Enable "Run ruff on save" and "Use ruff as formatter" in `Settings → Tools → Ruff`.

## Config

Merge into VS Code `settings.json`:

```json
{
  "ruff.nativeServer": "on",
  "[python]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": {
      "source.fixAll.ruff": "explicit",
      "source.organizeImports.ruff": "explicit"
    }
  }
}
```

`ruff.nativeServer: "on"` forces the Rust-based `ruff server` (stable since v0.5.3). The default `"auto"` also works but is less explicit. Do not set it to `"off"` — that falls back to the deprecated Python `ruff-lsp` wrapper.

## Verify

1. Install the extension: `ext install charliermarsh.ruff`
2. Install ruff: `pip install ruff` (or `uvx ruff`). Minimum version: 0.5.3.
3. Open a Python file containing:

   ```python
   import os
   x = 1 ;
   ```

4. Expect two diagnostics: `F401` (unused `import os`) and `E703` (statement ends with an unnecessary semicolon). Both appear in the Problems panel and inline as squiggles.
5. GitHub Copilot Chat reads these diagnostics from the VS Code API automatically — reference them with `@workspace` or paste the error into the chat.

## Caveats

- **Copilot does not run an LSP itself.** Ruff diagnostics originate from the `charliermarsh.ruff` extension via `ruff server`. Copilot reads them through VS Code's diagnostic and language APIs — no additional wiring needed.
- **Pyright coexistence.** Ruff does not type-check. Install `ms-python.vscode-pylance` (bundles Pyright) alongside this extension for type diagnostics. The two language servers run side by side without conflict.
- **`@workspace` vs file-level.** Copilot Chat's `@workspace` context includes open-file diagnostics. For project-wide lint summaries, run `ruff check .` in the terminal and paste the output.
- **Organize imports and isort rules.** `source.organizeImports.ruff` only reorders imports in the editor. To also enforce import order when running `ruff check` from the CLI, add `extend-select = ["I"]` to your `ruff.toml` or `pyproject.toml`.
- **JetBrains.** The JetBrains Ruff plugin exposes diagnostics to AI Assistant (JetBrains' Copilot equivalent) the same way — configure it under `Settings → Tools → Ruff`.
