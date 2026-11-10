# global-config-claude-opencode

Global config files for claude and opencode.

## Install

```sh
./install.sh
```

Symlinks the config files into place so this repo stays the single source of truth:

| File | Target |
| --- | --- |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |

Override target roots with `CLAUDE_CONFIG_DIR` (`~/.claude`) and `XDG_CONFIG_HOME` (`~/.config`). Re-running is a no-op. Existing files are backed up to `<name>.bak.<timestamp>` after confirmation (pass `--yes` to skip the prompt; non-interactive runs without `--yes` leave existing files untouched and exit `1`).
