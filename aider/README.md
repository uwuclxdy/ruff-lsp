# Aider — Ruff (lint-cmd, no LSP)

**Status:** lint-cmd

Aider has no LSP layer. It runs a configurable lint command against every file it edits, then feeds any errors back to the model to self-repair before committing. `ruff check --fix` fits this model exactly: ruff auto-removes fixable violations and exits non-zero when unfixable ones remain, giving aider something to act on.

## File location

**CLI flag** — pass on the command line each time, or add to a shell alias:

```
aider --lint-cmd "python: ruff check --fix" ...
```

**YAML config** — persists the setting without repeating it on every invocation. Aider searches for `.aider.conf.yml` in order:

1. `~/.aider.conf.yml` (home directory — user-global)
2. `<repo>/.aider.conf.yml` (git repo root — project-scoped, commit this one)
3. Current working directory

Files found in all three locations are merged; later files take priority.

## Config

### CLI

```sh
aider --lint-cmd "python: ruff check --fix"
```

The `python: ` prefix tells aider to run this command only against Python files. Aider passes the edited filenames as positional arguments; ruff accepts them directly.

### `.aider.conf.yml`

```yaml
# Lint Python files with ruff after every edit.
# auto-lint is true by default; shown here for explicitness.
auto-lint: true
lint-cmd:
  - "python: ruff check --fix"
```

A copy of this snippet is provided as `.aider.conf.yml` in this directory for easy adoption.

## Verify

1. Install ruff: `pip install ruff` (or `uvx ruff --version`).
2. Create a throwaway Python file with known violations:

   ```python
   import os
   x = 1 ;
   ```

3. Add the file and start aider with the lint command:

   ```sh
   aider --lint-cmd "python: ruff check --fix" bad.py
   ```

4. Ask aider to make any trivial change (e.g. "add a comment"). After the edit, aider runs ruff, which removes the stray semicolon (E703) and flags the unused import (F401). Aider feeds those diagnostics back to the model and produces a follow-up fix before committing.
5. Confirm the committed file has neither violation: `ruff check bad.py` should exit 0.

## Caveats

- **No real-time diagnostics.** There is no LSP, so violations are invisible while typing. Lint runs only after aider finishes an edit cycle.
- **`--auto-lint` vs `--lint-cmd` interaction.** `--auto-lint` (default: `true`) controls whether the lint command runs automatically after edits. Setting `--lint-cmd` without disabling `--auto-lint` is the correct setup; both flags are needed. To run lint manually instead, set `auto-lint: false` and use `/lint` in the aider chat.
- **Autofix behavior.** `ruff check --fix` rewrites the file before reporting remaining errors. Aider sees only the unfixable violations and attempts to resolve them. The fixable ones are silently corrected by ruff itself.
- **Non-Python files.** The `python: ` language prefix limits the command to `.py` / `.pyi` files. To lint other languages, add additional `lint-cmd` entries with their own language prefix, or omit the prefix to apply ruff to all files (not recommended — ruff will reject non-Python files with an error).
- **`ruff server` does not apply here.** Aider cannot consume LSP protocol output. Do not substitute `ruff server` for `ruff check`.
- **Type checking.** Ruff does not type-check. Aider has no LSP slot for pyright or mypy either; run them separately in CI.
