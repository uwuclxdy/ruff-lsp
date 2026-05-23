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
