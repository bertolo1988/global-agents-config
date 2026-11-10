# global-config-claude-opencode

Global config files for claude and opencode.

## Install

```sh
./install.sh
```

The script copies the files to their locations:

| File | Target |
| --- | --- |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |

`CLAUDE_CONFIG_DIR` overrides `~/.claude` and `XDG_CONFIG_HOME` overrides `~/.config`.

Re-run the script after editing the files here to refresh the installed copies. A copy that already matches is left untouched. Symlinks left by older versions of the script are replaced with plain files.

When a target differs, the script asks before replacing it, and a confirmed replacement is renamed to `<name>.bak.<timestamp>` first. Pass `--yes` to replace without asking. Without a terminal to answer on, differing files are left untouched and the script exits 1.
