#!/usr/bin/env bash
# Installs the global instruction files by copying them into place, so each
# agent reads a plain file in its own config directory. Runs from a checkout
# or piped straight from curl, downloading the files when there is no checkout.
set -euo pipefail

repo="bertolo1988/global-config-claude-opencode"
ref="${REF:-main}"
raw_base="https://raw.githubusercontent.com/$repo/$ref"

script_path="${BASH_SOURCE[0]:-}"
script_dir=""
if [ -n "$script_path" ] && [ -f "$script_path" ]; then
  script_dir="$(cd "$(dirname "$script_path")" && pwd)"
fi

claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
opencode_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
stamp="$(date +%Y%m%d-%H%M%S)"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

created=0
updated=0
unchanged=0
backups=0

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
<name>.bak.<timestamp> and replaced. The script prints one line per target
saying whether it was created, updated or already up to date, then a summary.
EOF
}

# Prints a path relative to $HOME so output stays readable.
show() {
  case "$1" in
    "$HOME"/*) printf '~%s\n' "${1#"$HOME"}" ;;
    *) printf '%s\n' "$1" ;;
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
  local src="$1" dest="$2" backup="" action n

  if ! mkdir -p "$(dirname "$dest")"; then
    echo "install.sh: failed to create $(show "$(dirname "$dest")")" >&2
    exit 1
  fi

  if [ -f "$dest" ] && [ ! -L "$dest" ] && cmp -s "$src" "$dest"; then
    printf 'file %s already up to date\n' "$(show "$dest")"
    unchanged=$((unchanged + 1))
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup="$dest.bak.$stamp"
    n=1
    while [ -e "$backup" ] || [ -L "$backup" ]; do
      n=$((n + 1))
      backup="$dest.bak.$stamp.$n"
    done
    if ! mv "$dest" "$backup"; then
      echo "install.sh: failed to back up $(show "$dest") to $(show "$backup")" >&2
      exit 1
    fi
    action=updated
  else
    action=created
  fi

  if ! cp "$src" "$dest"; then
    echo "install.sh: failed to write $(show "$dest")" >&2
    exit 1
  fi

  printf 'file %s %s successfully\n' "$(show "$dest")" "$action"
  if [ "$action" = updated ]; then
    printf '  previous version kept at %s\n' "$(show "$backup")"
    backups=$((backups + 1))
    updated=$((updated + 1))
  else
    created=$((created + 1))
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h | --help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ -n "$script_dir" ] && [ -f "$script_dir/claude/CLAUDE.md" ]; then
  printf 'install.sh: installing global instruction files from %s\n\n' "$script_dir"
else
  printf 'install.sh: installing global instruction files from github.com/%s (%s)\n\n' "$repo" "$ref"
fi

install_file "$(source_file claude/CLAUDE.md)" "$claude_dir/CLAUDE.md"
install_file "$(source_file opencode/AGENTS.md)" "$opencode_dir/AGENTS.md"

printf '\n'
if [ "$created" -eq 0 ] && [ "$updated" -eq 0 ]; then
  printf 'Done: %d file(s) already up to date, nothing changed.\n' "$unchanged"
  exit 0
fi

printf 'Done: %d file(s) installed (%d created, %d updated)' \
  "$((created + updated))" "$created" "$updated"
if [ "$unchanged" -gt 0 ]; then
  printf ', %d already up to date' "$unchanged"
fi
printf '.\n'
if [ "$backups" -gt 0 ]; then
  printf 'Backups use the suffix .bak.%s.\n' "$stamp"
fi
printf 'Start a new Claude Code or OpenCode session to pick up the new instructions.\n'
