# Gemini CLI — Ruff LSP

**Status:** lint-cmd / MCP tool

Gemini CLI is a terminal-first AI agent (not an editor). It has no built-in LSP
client and no plugin system for language servers. Linting is wired in through
MCP: declare `ruff server` as an MCP stdio server in `settings.json`, then ask
Gemini to lint files naturally — it will call the MCP tool and surface the
diagnostics in its response.

## File location

Global (all projects):

```
~/.gemini/settings.json
```

Project-scoped (takes precedence over user settings):

```
<repo>/.gemini/settings.json
```

## Config

Add an `mcpServers` block. The server alias must not contain underscores (Gemini
CLI parses Fully Qualified Names on the first `_` after the `mcp_` prefix, which
breaks policy enforcement when the alias itself has underscores).

```json
{
  "mcpServers": {
    "ruff": {
      "command": "ruff",
      "args": ["server"],
      "env": {}
    }
  }
}
```

### Zero-install variant

If `ruff` is not on `PATH`, use `uvx` (requires `uv`):

```json
{
  "mcpServers": {
    "ruff": {
      "command": "uvx",
      "args": ["ruff", "server"],
      "env": {}
    }
  }
}
```

Ruff auto-discovers `ruff.toml`, `.ruff.toml`, or `[tool.ruff]` in
`pyproject.toml` from the working directory upward.

## Verify

1. Add the `mcpServers` block above to `~/.gemini/settings.json`.
2. Start Gemini CLI. Run `/mcp` to confirm the `ruff` server appears and is
   connected.
3. Create a file `smoke.py` with:

   ```python
   import os
   x = 1 ;
   ```

4. Ask: `"Lint smoke.py with ruff"`. Gemini should report F401 (unused import
   `os`) and E702 (statement ends with a semicolon).
5. If the server is not found, run `/mcp reload` to force re-discovery.

## Caveats

- **No native LSP.** Gemini CLI has no LSP client; there are no real-time
  inline diagnostics while editing. Linting is on-demand via the MCP tool call.
- **No autofix in-band.** Ruff's `--fix` flag is not exposed through
  `ruff server`'s MCP interface. To apply fixes, ask Gemini to run
  `ruff check --fix <file>` as a shell command, or use a `ShellTool` call.
- **No Pyright.** Gemini CLI offers no type-checking integration; pair with a
  separate editor if type diagnostics are needed.
- **Alias naming.** Avoid underscores in the server alias key (use `ruff`, not
  `ruff_server`) — see the [warning in the official docs][warn].
- **Minimum ruff version.** `ruff server` (MCP-compatible stdio mode) is stable
  since v0.5.3 (June 2024). Do not use the deprecated `ruff-lsp` wrapper.

[warn]: https://github.com/google-gemini/gemini-cli/blob/main/docs/reference/configuration.md
