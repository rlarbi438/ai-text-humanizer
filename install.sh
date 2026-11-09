#!/usr/bin/env bash
# Copy every skill in ./skills into ~/.claude/skills.
# Skips skills you already have unless you pass --force.
set -euo pipefail
src="$(cd "$(dirname "$0")" && pwd)/skills"
dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
force=0
[ "${1:-}" = "--force" ] && force=1
mkdir -p "$dest"
for dir in "$src"/*/; do
  name="$(basename "$dir")"
  if [ -e "$dest/$name" ] && [ "$force" -eq 0 ]; then
    echo "skip     $name (already installed; use --force to replace)"
    continue
  fi
  rm -rf "$dest/$name"
  cp -R "$dir" "$dest/$name"
  echo "install  $name"
done
echo "Done. Restart Claude Code to load the skills."
