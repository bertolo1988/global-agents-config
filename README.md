# global-config-claude-opencode

Global config files for claude and opencode.

## Install

```sh
./install.sh
```

The script symlinks the files into place, so this repo stays the single source of truth:

| File                 | Target                         |
| -------------------- | ------------------------------ |
| `claude/CLAUDE.md`   | `~/.claude/CLAUDE.md`          |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |

`CLAUDE_CONFIG_DIR` overrides `~/.claude` and `XDG_CONFIG_HOME` overrides `~/.config`. Running the script again is a no-op.

When a target already exists, the script asks before replacing it, and a confirmed replacement is renamed to `<name>.bak.<timestamp>` first. Pass `--yes` to replace without asking. Without a terminal to answer on, existing files are left untouched and the script exits 1.

## Caveats

- Defaults to Typescript and Node.js

- Stores worktrees at ~/code/tmp
