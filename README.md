# global-config-claude-opencode

Global config files for claude and opencode.

## Install

```sh
./install.sh
```

Copies the config files into place:

| File | Target |
| --- | --- |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |

Override target roots with `CLAUDE_CONFIG_DIR` (`~/.claude`) and `XDG_CONFIG_HOME` (`~/.config`). Re-run after editing to refresh installed copies (matching copies are untouched; older symlinks are replaced with plain files). Differing targets are backed up to `<name>.bak.<timestamp>` after confirmation (pass `--yes` to skip the prompt; non-interactive runs without `--yes` leave differing files untouched and exit `1`).
