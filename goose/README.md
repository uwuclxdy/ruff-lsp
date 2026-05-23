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

The `AfterFileEdit` event fires after each successful file edit, and the matcher is matched against the edited file path. `\\.pyi?$` restricts the rule to `.py` and `.pyi` files only.

### `scripts/ruff-fix.sh`

```sh
#!/usr/bin/env sh
set -euf

# Goose passes the AfterFileEdit event as JSON on stdin. The matcher target
# for AfterFileEdit is the edited file path, exposed as `.matcher_context`.
# Fall back to linting the whole project if the payload is missing or jq is
# unavailable.

payload=$(cat)
file=""
if command -v jq >/dev/null 2>&1; then
  file=$(printf '%s' "$payload" | jq -r '.matcher_context // empty')
fi

if [ -n "$file" ] && [ -e "$file" ]; then
  ruff check --fix --quiet "$file"
else
  ruff check --fix --quiet .
fi
```

Make it executable:

```sh
chmod +x ~/.agents/plugins/ruff-lint/scripts/ruff-fix.sh
```

## Verify

1. Install ruff: `pip install ruff` or `pipx install ruff`. `jq` is recommended (`apt install jq` / `brew install jq`) so the script can target the single edited file; without it the script falls back to linting the whole tree.
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

- **No inline diagnostics.** There is no LSP client in goose, so ruff violations are never shown as inline annotations. The hook auto-fixes what it can; unfixable rules (E501, etc.) are silently ignored unless you add a second hook step that runs `ruff check` (without `--fix`) and writes its output somewhere goose can read.
- **Autofix only.** Rules that ruff cannot auto-fix are not reported back to goose by this hook. Pipe `ruff check` output into a file or `stderr` if you need the agent to see unfixed violations.
- **Hook timing.** The `AfterFileEdit` event fires after each individual file edit, not after a batch. On multi-file refactors goose may re-read files before the hook finishes; this is harmless.
- **Payload format.** Hook input arrives as JSON on stdin. Fields include `event`, `session_id`, `matcher_context` (the edited file path for `AfterFileEdit`), `tool_name`, `tool_input`, and `working_dir`. See the [official hooks reference](https://goose-docs.ai/docs/guides/context-engineering/hooks) for the full schema.
- **No type checking.** Ruff does not type-check. There is no Pyright integration for goose at this time.
- **Minimum ruff version.** Requires ruff ≥ 0.5.3 for stable `ruff check --fix` behavior.
