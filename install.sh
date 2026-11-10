#!/usr/bin/env bash
# Installs the global instruction files by copying them into place, so each
# agent reads a plain file in its own config directory. Runs from a checkout
# or piped straight from curl, downloading the files when there is no checkout.
set -euo pipefail

script_path="${BASH_SOURCE[0]:-}"
script_dir=""
if [ -n "$script_path" ] && [ -f "$script_path" ]; then
  script_dir="$(cd "$(dirname "$script_path")" && pwd)"
fi

claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
opencode_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
stamp="$(date +%Y%m%d-%H%M%S)"
ref="${REF:-main}"
raw_base="https://raw.githubusercontent.com/bertolo1988/global-config-claude-opencode/$ref"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

usage() {
  cat <<'EOF'
Usage: ./install.sh
       curl -fsSL <raw-url> | bash

Copies the global instruction files into place:
  claude/CLAUDE.md   -> ~/.claude/CLAUDE.md
  opencode/AGENTS.md -> ~/.config/opencode/AGENTS.md

From a checkout the local files are copied; when piped from curl they are
downloaded from GitHub first. REF overrides the branch or tag to download
from (default: main).

CLAUDE_CONFIG_DIR overrides ~/.claude and XDG_CONFIG_HOME overrides ~/.config.

Re-run the script to refresh the installed copies. A target that already
matches is left untouched; a differing target is backed up to
<name>.bak.<timestamp> and replaced.
EOF
}

source_file() {
  local rel="$1" file
  if [ -n "$script_dir" ] && [ -f "$script_dir/$rel" ]; then
    printf '%s\n' "$script_dir/$rel"
    return
  fi

  command -v curl >/dev/null 2>&1 || {
    echo "install.sh: curl is required to install without a checkout" >&2
    exit 1
  }

  file="$stage/$(basename "$rel")"
  if ! curl -fsSL "$raw_base/$rel" -o "$file"; then
    echo "install.sh: failed to download $raw_base/$rel" >&2
    exit 1
  fi
  printf '%s\n' "$file"
}

install_file() {
  local src="$1" dest="$2" backup

  mkdir -p "$(dirname "$dest")"

  if [ -f "$dest" ] && [ ! -L "$dest" ] && cmp -s "$src" "$dest"; then
    printf 'ok     %s\n' "$dest"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup="$dest.bak.$stamp"
    mv "$dest" "$backup"
    printf 'backup %s\n' "$backup"
  fi

  cp "$src" "$dest"
  printf 'copy   %s\n' "$dest"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h | --help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

install_file "$(source_file claude/CLAUDE.md)" "$claude_dir/CLAUDE.md"
install_file "$(source_file opencode/AGENTS.md)" "$opencode_dir/AGENTS.md"
