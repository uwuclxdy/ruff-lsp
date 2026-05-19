#!/usr/bin/env sh
set -euf
# Run ruff auto-fix on the project root after goose edits a Python file.
# TODO: replace '.' with the specific edited file path once the goose hooks
# spec documents the env variable that carries it.
ruff check --fix --quiet .
