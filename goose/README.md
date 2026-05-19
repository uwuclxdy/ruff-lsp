# Goose — Ruff (lint-cmd via hook)

**Status:** lint-cmd / hook

Goose is an MCP-based autonomous agent, not an editor. It has no LSP client and no mechanism to wire `ruff server` (stdio LSP) into its runtime. The closest native integration is the **hooks** system: goose runs a shell command after every successful file edit, which is the right place to invoke `ruff check --fix`.

## File location

Place the plugin directory at one of these locations:

| Scope | Path |
|---|---|
| User (all projects) | `~/.agents/plugins/ruff-lint/` |
| Project-scoped | `<repo>/.agents/plugins/ruff-lint/` |

The directory must contain `plugin.json` and `hooks/hooks.json`. The script at `scripts/ruff-fix.sh` is optional but keeps the hook command portable.

```
ruff-lint/
├── plugin.json
├── hooks/
│   └── hooks.json
└── scripts/
    └── ruff-fix.sh
```

## Config

### `plugin.json`

```json
{
  "name": "ruff-lint",
  "version": "0.1.0",
  "description": "Run ruff check --fix after goose edits Python files.",
  "author": { "name": "ruff-lsp-everywhere" }
}
```

### `hooks/hooks.json`

```json
{
  "hooks": {
    "AfterFileEdit": [
      {
        "matcher": "\\.pyi?$",
        "hooks": [
          {
            "type": "command",
            "command": "${PLUGIN_ROOT}/scripts/ruff-fix.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

The matcher `\\.pyi?$` fires on `.py` and `.pyi` files only. The hook runs after each successful edit, so goose sees ruff's fixes on the next read of the file.

### `scripts/ruff-fix.sh`

```sh
#!/usr/bin/env sh
set -euf
# GOOSE_TOOL_OUTPUT is a JSON payload set by goose containing tool context.
# The file path is passed as the matcher subject; fall back to stdin parsing
# if needed.  Running ruff on the whole project is safe and simpler.
ruff check --fix --quiet .
```

Make it executable:

```sh
chmod +x ~/.agents/plugins/ruff-lint/scripts/ruff-fix.sh
```

**TODO** — the exact environment variable goose injects with the edited file path is not documented in the public hooks spec. `ruff check --fix .` on the project root is the safe fallback; adjust to `ruff check --fix "$FILE"` once the payload variable name is confirmed.

## Verify

1. Install ruff: `pip install ruff` or `pipx install ruff`.
2. Copy the plugin directory to `~/.agents/plugins/ruff-lint/`.
3. Start a goose session in a Python project: `goose session`.
4. Ask goose to write a Python file with a lint violation, e.g.:
   ```
   write a file hello.py that imports os but never uses it
   ```
5. After goose edits the file, the hook runs. Confirm ruff removed the import:
   ```sh
   cat hello.py   # should not contain 'import os'
   ```
6. Check hook logs if available (goose CLI surfaces hook errors in the session output).

## Caveats

- **No inline diagnostics.** There is no LSP client in goose, so ruff violations are never shown as inline annotations. The hook auto-fixes what it can; unfixable rules (E501, etc.) are silently ignored unless you add `ruff check .` (without `--fix`) and pipe output back to goose via a tool.
- **Autofix only.** Rules that ruff cannot auto-fix are not reported unless you add a second hook step that runs `ruff check` and writes its output somewhere goose can read.
- **Hook timing.** The `AfterFileEdit` event fires after each individual file edit, not after a batch. On multi-file refactors goose may re-read files before the hook finishes; this is harmless.
- **File path env var unverified.** The hooks spec does not publicly document which environment variable carries the edited file path. The script above runs `ruff check --fix .` on the project root as a safe default. See the [goose hooks docs](https://goose-docs.ai/docs/guides/context-engineering/hooks) for updates.
- **No type checking.** Ruff does not type-check. There is no Pyright integration for goose at this time.
- **Minimum ruff version.** Requires ruff ≥ 0.5.3 for stable `ruff check --fix` behavior.
