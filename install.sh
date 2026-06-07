#!/usr/bin/env bash
# Install the journal-this skill into your Claude Code (or Codex) skills directory.
#
#   ./install.sh              # -> ~/.claude/skills/journal-this   (Claude Code, default)
#   ./install.sh --codex      # -> ~/.agents/skills/journal-this   (Codex)
#   SKILLS_DIR=/custom/path ./install.sh   # -> /custom/path/journal-this
#
# Re-running is safe: it replaces any existing install in place.
set -euo pipefail

src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills/journal-this"

if [ "${1:-}" = "--codex" ]; then
  dest_root="${SKILLS_DIR:-$HOME/.agents/skills}"
else
  dest_root="${SKILLS_DIR:-$HOME/.claude/skills}"
fi
dest_dir="$dest_root/journal-this"

if [ ! -f "$src_dir/SKILL.md" ]; then
  echo "error: skill source not found at $src_dir" >&2
  echo "run this script from inside a journal-this clone." >&2
  exit 1
fi

mkdir -p "$dest_root"
rm -rf "$dest_dir"
cp -R "$src_dir" "$dest_dir"

echo "Installed journal-this -> $dest_dir"
echo "Reload Claude Code (/reload-plugins, or restart), then type /journal-this."
