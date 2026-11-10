#!/usr/bin/env bash
# Installs the global instruction files by symlinking them from this repository,
# so the repo stays the single source of truth for both agents.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
opencode_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
stamp="$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<'EOF'
Usage: ./install.sh

Symlinks the global instruction files into place:
  claude/CLAUDE.md   -> ~/.claude/CLAUDE.md
  opencode/AGENTS.md -> ~/.config/opencode/AGENTS.md

CLAUDE_CONFIG_DIR overrides ~/.claude and XDG_CONFIG_HOME overrides ~/.config.
An existing file is renamed to <name>.bak.<timestamp> before it is replaced.
EOF
}

link() {
  local src="$1" dest="$2" backup

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    printf 'ok     %s\n' "$dest"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup="$dest.bak.$stamp"
    mv "$dest" "$backup"
    printf 'backup %s\n' "$backup"
  fi

  ln -s "$src" "$dest"
  printf 'link   %s -> %s\n' "$dest" "$src"
}

case "${1:-}" in
  "") ;;
  -h | --help) usage; exit 0 ;;
  *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
esac

for src in "$repo/claude/CLAUDE.md" "$repo/opencode/AGENTS.md"; do
  [ -f "$src" ] || { echo "missing source file: $src" >&2; exit 1; }
done

link "$repo/claude/CLAUDE.md" "$claude_dir/CLAUDE.md"
link "$repo/opencode/AGENTS.md" "$opencode_dir/AGENTS.md"
