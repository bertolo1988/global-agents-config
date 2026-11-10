#!/usr/bin/env bash
# Installs the global instruction files by symlinking them from this repository,
# so the repo stays the single source of truth for both agents.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
opencode_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
stamp="$(date +%Y%m%d-%H%M%S)"
assume_yes=0
skipped=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [--yes]

Symlinks the global instruction files into place:
  claude/CLAUDE.md   -> ~/.claude/CLAUDE.md
  opencode/AGENTS.md -> ~/.config/opencode/AGENTS.md

CLAUDE_CONFIG_DIR overrides ~/.claude and XDG_CONFIG_HOME overrides ~/.config.

When a target already exists, the script asks before replacing it. A confirmed
replacement is renamed to <name>.bak.<timestamp> first. Pass --yes to replace
without asking; without a terminal to answer on, existing files are left alone.
EOF
}

confirm() {
  [ -t 0 ] || return 1
  local reply
  printf 'replace %s? [y/N] ' "$1"
  read -r reply || { printf '\n'; return 1; }
  case "$reply" in
    [yY] | [yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

link() {
  local src="$1" dest="$2" backup

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    printf 'ok     %s\n' "$dest"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$assume_yes" -eq 0 ] && ! confirm "$dest"; then
      printf 'skip   %s (kept as is)\n' "$dest"
      skipped=$((skipped + 1))
      return
    fi

    backup="$dest.bak.$stamp"
    mv "$dest" "$backup"
    printf 'backup %s\n' "$backup"
  fi

  ln -s "$src" "$dest"
  printf 'link   %s -> %s\n' "$dest" "$src"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -y | --yes) assume_yes=1 ;;
    -h | --help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

for src in "$repo/claude/CLAUDE.md" "$repo/opencode/AGENTS.md"; do
  [ -f "$src" ] || { echo "missing source file: $src" >&2; exit 1; }
done

link "$repo/claude/CLAUDE.md" "$claude_dir/CLAUDE.md"
link "$repo/opencode/AGENTS.md" "$opencode_dir/AGENTS.md"

if [ "$skipped" -gt 0 ]; then
  echo "install.sh: $skipped file(s) not installed; run with --yes to replace them" >&2
  exit 1
fi
