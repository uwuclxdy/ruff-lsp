# ruff-lsp

[ruff](https://docs.astral.sh/ruff/) `ruff server` integrations for AI coding assistants whose support isn't already shipped by their editor.

> Don't confuse this with [`astral-sh/ruff-lsp`](https://github.com/astral-sh/ruff-lsp). That project is the deprecated Python wrapper around the now-removed `ruff-lsp` binary, archived by Astral in favor of `ruff server` built into the `ruff` binary. This repo here uses the new `ruff server`.

## Scope

Excluded by design: editors that already ship ruff out of the box (Zed) and assistants that delegate to a host editor where Astral's official `charliermarsh.ruff` extension already covers things (Cursor, Windsurf, Cline, Continue, Roo Code, Cody, GitHub Copilot). For those, install the extension and stop here.

Included:

| Assistant   | Config dir     | Mechanism                               |
| ----------- | -------------- | --------------------------------------- |
| Claude Code | `claude-code/` | `lspServers` plugin manifest            |
| Codex CLI   | `codex-cli/`   | `PostToolUse` hook                      |
| Gemini CLI  | `gemini-cli/`  | MCP stdio server                        |
| Aider       | `aider/`       | `--lint-cmd` (replaces built-in flake8) |
| OpenCode    | `opencode/`    | Custom `lsp` entry                      |
| Crush       | `crush/`       | `lsp` block                             |
| Goose       | `goose/`       | `AfterFileEdit` hook plugin             |

See each `<tool>/README.md` for the verbatim snippet, install path, and verification.

## Install — Claude Code

```
/plugin marketplace add uwuclxdy/ruff-lsp
/plugin install ruff-lsp@ruff-lsp
```

You still need `ruff` (≥ 0.5.3) on `PATH`: `pip install ruff`, `pipx install ruff`, or `uv tool install ruff`. The `uvx ruff server` zero-install variant is documented in `claude-code/README.md`.

See other `README.md` files for more details:

- [`claude-code/README.md`](claude-code/README.md)
- [`codex-cli/README.md`](codex-cli/README.md)
- [`gemini-cli/README.md`](gemini-cli/README.md)
- [`aider/README.md`](aider/README.md)
- [`opencode/README.md`](opencode/README.md)
- [`crush/README.md`](crush/README.md)
- [`goose/README.md`](goose/README.md)

## Install — other assistants

Detect what you have and get per-tool merge instructions:

```sh
./install-all.sh
```

The script never edits config files. It prints what to copy where. `./uninstall.sh` does the inverse.

## Repo layout

```
ruff-lsp/
├── .claude-plugin/marketplace.json   # Claude Code marketplace
├── claude-code/                      # the plugin itself
├── <other 6 assistants>/
├── install-all.sh
├── uninstall.sh
└── LICENSE
```

## License

[MIT](LICENSE).
