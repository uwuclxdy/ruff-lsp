# Roo Code — Ruff LSP

**Status:** host editor delegation (`charliermarsh.ruff` in VS Code)

Roo Code is actively maintained at [`RooCodeInc/Roo-Code`](https://github.com/RooCodeInc/Roo-Code) (Apache 2.0). The community fork [Zoo Code](https://github.com/Zoo-Code-Org/Zoo-Code/) is also active. Both inherit the same VS Code host model and the ruff setup below applies to either.

## File location

Roo Code is a VS Code extension — it has no bundled LSP. Ruff integration comes from the `charliermarsh.ruff` extension. Merge the snippet into your VS Code settings:

- User settings: `~/.config/Code/User/settings.json` (Linux) / `%APPDATA%\Code\User\settings.json` (Windows) / `~/Library/Application Support/Code/User/settings.json` (macOS)
- Workspace settings: `<repo>/.vscode/settings.json`

## Config

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

`ruff.nativeServer: "on"` forces the Rust-based `ruff server` (stable since v0.5.3). The default `"auto"` also works but is less explicit. Do not set `"off"` — that falls back to the deprecated Python `ruff-lsp` wrapper.

## Verify

1. Install the extension: `ext install charliermarsh.ruff`
2. Install ruff: `pip install ruff` (minimum version: 0.5.3) or use `uvx ruff`.
3. Open a Python file containing:

   ```python
   import os
   x = 1 ;
   ```

4. Expect two diagnostics in the Problems panel: `F401` (unused `import os`) and `E703` (statement ends with an unnecessary semicolon), shown as inline squiggles.
5. Roo Code (or Zoo Code) reads diagnostics from VS Code's language API automatically — no extra wiring needed beyond the extension.

## Caveats

- **No bundled LSP.** Roo Code delegates entirely to VS Code's extension host. It has never shipped its own ruff runner, MCP-based ruff server, or custom lint hooks. All ruff diagnostics originate from `charliermarsh.ruff`.
- **Marketplace identity.** The VS Code extension publisher ID is `RooVeterinaryInc.roo-cline` (the original Cline-era id, kept for install URL stability). The GitHub repo lives at `RooCodeInc/Roo-Code`. The Zoo Code fork (`Zoo-Code-Org/Zoo-Code`) is configured identically.
- **`.roo/` config directory.** Roo Code uses `.roo/` for its own agent rules (system prompts, mode definitions). This is unrelated to ruff — ruff still reads `ruff.toml`, `.ruff.toml`, or `[tool.ruff]` in `pyproject.toml` from the workspace root.
- **MCP.** Roo Code supports MCP servers for extending agent capabilities, but there is no official or widely-used MCP server for ruff. Ruff integration remains extension-based.
- **Pyright pairing.** Ruff does not type-check. Install `ms-python.vscode-pylance` (bundles Pyright) alongside `charliermarsh.ruff` for type diagnostics. The two language servers run side by side without conflict.
- **Cline lineage.** Roo Code is a fork of Cline and shares the same VS Code host model. The ruff setup is identical to the Cline configuration.
