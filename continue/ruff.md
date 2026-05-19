---
name: Ruff lint and format
alwaysApply: true
---

Always fix Ruff lint and format violations before finishing a task.
When the editor shows F401 (unused import), E302 (blank lines), E711/E712
(comparison to None/True/False), or similar Ruff diagnostics, resolve them
in the same edit. Do not leave `# noqa` suppressions unless the caller
explicitly requests them.
