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
assume_yes=0
skipped=0
ref="${REF:-main}"
raw_base="https://raw.githubusercontent.com/bertolo1988/global-config-claude-opencode/$ref"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

usage() {
  cat <<'EOF'
Usage: ./install.sh [--yes]
       curl -fsSL <raw-url> | bash -s -- [--yes]

Copies the global instruction files into place:
  claude/CLAUDE.md   -> ~/.claude/CLAUDE.md
  opencode/AGENTS.md -> ~/.config/opencode/AGENTS.md

From a checkout the local files are copied; when piped from curl they are
downloaded from GitHub first. REF overrides the branch or tag to download
from (default: main).

CLAUDE_CONFIG_DIR overrides ~/.claude and XDG_CONFIG_HOME overrides ~/.config.

Re-run the script to refresh the installed copies.
A target that already matches is left untouched. When a target differs, the
script asks before replacing it; a confirmed replacement is renamed to
<name>.bak.<timestamp> first. Pass --yes to replace without asking; without a
terminal to answer on, differing files are left alone.
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

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    # Left behind by an older version of this script; just drop the link.
    rm -f "$dest"
  elif [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$assume_yes" -eq 0 ] && ! confirm "$dest"; then
      printf 'skip   %s (kept as is)\n' "$dest"
      skipped=$((skipped + 1))
      return
    fi

    backup="$dest.bak.$stamp"
    mv "$dest" "$backup"
    printf 'backup %s\n' "$backup"
  fi

  cp "$src" "$dest"
  printf 'copy   %s\n' "$dest"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -y | --yes) assume_yes=1 ;;
    -h | --help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

install_file "$(source_file claude/CLAUDE.md)" "$claude_dir/CLAUDE.md"
install_file "$(source_file opencode/AGENTS.md)" "$opencode_dir/AGENTS.md"

if [ "$skipped" -gt 0 ]; then
  echo "install.sh: $skipped file(s) not installed; run with --yes to replace them" >&2
  exit 1
fi
