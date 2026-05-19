# ruff-lsp-everywhere

Ship [ruff](https://docs.astral.sh/ruff/) LSP integration across the 15 most popular AI coding assistants. Each tool gets a copy-pasteable config that wires up `ruff server` (the native Rust LSP built into the ruff binary — `ruff-lsp` the Python wrapper is deprecated).

## Status

All 15 tools researched and implemented. Each `<tool>/README.md` has the verbatim config, install path, verification command, and caveats.

| Tool | LSP mechanism | Autofix on save | Pyright friendly | Status |
| --- | --- | --- | --- | --- |
| Claude Code | native LSP plugin (`plugin.json` `lspServers`) | via LSP code actions | yes (side-by-side with `pyright-lsp`) | done |
| Codex CLI | unsupported (no LSP subsystem) — `PostToolUse` hook workaround | via hook, async (not on-save) | n/a | done |
| Gemini CLI | MCP stdio tool (no LSP client in tree) | via shell `ruff check --fix` | n/a | done |
| Aider | lint-cmd (`--lint-cmd "python: ruff check --fix"`) | yes (after each edit) | n/a | done |
| OpenCode | native LSP (`lsp` block, custom server entry) | via LLM (diagnostics feed the model) | yes (built-in `pyright`) | done |
| Crush (Charm) | native LSP (`crush.json` `lsp` key) | no (diagnostics only) | no | done |
| Goose | hook (`AfterFileEdit`) — no LSP client | yes (`ruff check --fix`) | n/a | done |
| Cursor | host editor extension (`charliermarsh.ruff`) | yes (`editor.codeActionsOnSave`) | yes (pair with Pyright) | done |
| Windsurf | host editor extension (`charliermarsh.ruff`) | yes | yes | done |
| Zed | native LSP (built-in ruff, `lsp.ruff`) | yes (`format_on_save` + `code_actions_on_format`) | yes (alongside basedpyright/pyright) | done |
| GitHub Copilot | host editor extension (`charliermarsh.ruff`) | yes (`source.fixAll.ruff`, `source.organizeImports.ruff`) | yes | done |
| Cline | host editor extension (`charliermarsh.ruff`); `.clinerules` for AI hints | yes | yes | done |
| Roo Code | host editor extension (`charliermarsh.ruff`) — **EOL 2026-05-15**, fork: Zoo Code | yes | yes | done |
| Continue | host editor extension (`charliermarsh.ruff`) + `.continue/rules/ruff.md` | yes | yes | done |
| Cody (Sourcegraph) | host editor extension (`charliermarsh.ruff`) | yes | yes | done |

## Conventions

- `ruff server` is always the LSP command. `uvx ruff server` is documented per-tool when the user is unlikely to have ruff globally installed.
- Each `<tool>/README.md` follows the same format: **Status**, **File location**, **Config** (verbatim), **Verify**, **Caveats**.
- For type checking, install Pyright LSP alongside. Where the tool has an official Pyright plugin we link to it.

## Repo layout

```
ruff-lsp-everywhere/
├── README.md
├── claude-code/
│   ├── README.md
│   └── .claude-plugin/
│       └── plugin.json
├── codex-cli/ ...                    # one dir per tool
└── scripts/
    ├── install-all.sh                # detect installed tools, print merge instructions
    └── uninstall.sh                  # detect existing integrations, delete drop-ins, list manual cleanup
```
