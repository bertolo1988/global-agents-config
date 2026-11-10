# global-config-claude-opencode

Global config files for claude and opencode.

## Install

```sh
./install.sh
```

The script symlinks the files into place, so this repo stays the single source of truth:

| File | Target |
| --- | --- |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |

`CLAUDE_CONFIG_DIR` overrides `~/.claude` and `XDG_CONFIG_HOME` overrides `~/.config`. An existing file at a target is renamed to `<name>.bak.<timestamp>` before it is replaced. Running the script again is a no-op.
