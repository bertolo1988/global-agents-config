# global-config-claude-opencode

Global config files for claude and opencode.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/bertolo1988/global-config-claude-opencode/main/install.sh | bash
```

The script copies the files to their locations:

| File | Target |
| --- | --- |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |

The files are downloaded from GitHub. `REF` selects the branch or tag to download from (default `main`); `CLAUDE_CONFIG_DIR` overrides `~/.claude` and `XDG_CONFIG_HOME` overrides `~/.config`.

Re-run the curl command to refresh the installed copies. A copy that already matches is left untouched.

When a target differs, the script asks before replacing it, and a confirmed replacement is renamed to `<name>.bak.<timestamp>` first. Pass `--yes` to replace without asking. Without a terminal to answer on, differing files are left untouched and the script exits 1.
