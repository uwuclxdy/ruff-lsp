# Continue — Ruff LSP

**Status:** host editor delegation (`charliermarsh.ruff`) + optional Continue rule hint

Continue is a VS Code / JetBrains AI extension. It does not run its own language server — lint diagnostics come from whichever LSP the host editor has registered. Install the official Ruff extension in VS Code and merge the settings snippet below; Continue will surface those diagnostics automatically when you use `@Problems` or `@diff` as context.

## File location

**VS Code settings** (merge into User Settings JSON):

| OS | Path |
|---|---|
| macOS | `~/Library/Application Support/Code/User/settings.json` |
| Linux | `~/.config/Code/User/settings.json` |
| Windows | `%APPDATA%\Code\User\settings.json` |

**Continue rule hint** (optional — instructs the AI to respect ruff findings):

| Scope | Path |
|---|---|
| Global | `~/.continue/rules/ruff.md` |
| Project | `<repo>/.continue/rules/ruff.md` |

## Config

### VS Code settings.json (Ruff extension)

Merge into User Settings JSON after installing `charliermarsh.ruff`:

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

### Continue rule hint — `.continue/rules/ruff.md`

Drop this file at the global or project path to inject a system-prompt instruction for every Agent/Chat/Edit session:

```markdown
---
name: Ruff lint and format
alwaysApply: true
---

Always fix Ruff lint and format violations before finishing a task.
When the editor shows F401 (unused import), E302 (blank lines), E711/E712
(comparison to None/True/False), or similar Ruff diagnostics, resolve them
in the same edit. Do not leave `# noqa` suppressions unless the caller
explicitly requests them.
```

Rules are `.md` files placed in `.continue/rules/`. They are concatenated into the system message for Agent, Chat, and Edit requests in lexicographical order. No entry in `config.yaml` is required for local rules — they are picked up automatically.

## Verify

1. Install `charliermarsh.ruff` in VS Code: **Cmd/Ctrl+Shift+X** → search `charliermarsh.ruff` → Install.
2. Install ruff: `pip install ruff` (or `uvx ruff --version`).
3. Open (or create) a Python file with:

   ```python
   import os
   x = 1 ;
   ```

4. Expect two inline diagnostics: `F401` (unused `os` import) and `E703` (statement ends with an unnecessary semicolon).
5. Open the Continue panel and type `@Problems` — the violations should appear as context.
6. Ask Continue to fix the file; it should resolve both violations.

## Caveats

- **config.json → config.yaml migration.** Continue migrated from `config.json` to `config.yaml` (schema `v1`) in 2024–2025. The `.continue/rules/` directory approach used here works with both the old and new config system — no `config.yaml` entry is required for local rule files.
- **`config.yaml` `rules:` block.** If you manage your assistant through Continue Mission Control (Hub), reference the rule via `uses: file://path/to/ruff.md` in `config.yaml`. The inline `.continue/rules/` approach is simpler for local-only setups.
- **Pyright pairing.** Ruff does not type-check. Pair with the `ms-pyright.pyright` or `detachhead.basedpyright` extension for type diagnostics alongside Ruff lint/format.
- **JetBrains.** Continue for IntelliJ/PyCharm delegates to the host IDE's inspections. Install the [Ruff plugin](https://plugins.jetbrains.com/plugin/20574-ruff) from the JetBrains Marketplace; Continue will surface inspection results the same way.
- **`@Problems` context provider.** Continue's `@Problems` built-in context provider reads the host editor's diagnostic list. With `charliermarsh.ruff` active, Ruff diagnostics appear there automatically — no additional configuration needed.
