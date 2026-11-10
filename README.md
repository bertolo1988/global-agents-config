# global-config-claude-opencode

Global config files for claude and opencode.

## Install

From a checkout:

```sh
./install.sh
```

Or without one:

```sh
curl -fsSL https://raw.githubusercontent.com/bertolo1988/global-config-claude-opencode/main/install.sh | bash
```

Either way the script copies the files to their locations:

| File | Target |
| --- | --- |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |

Without a checkout the files are downloaded from GitHub. `REF` selects the branch or tag to download from (default `main`), and `CLAUDE_CONFIG_DIR` overrides `~/.claude` while `XDG_CONFIG_HOME` overrides `~/.config`.

Re-run the script (or the curl command) to refresh the installed copies. A copy that already matches is left untouched. When run from a checkout, symlinks left by older versions of the script are replaced with plain files.

When a target differs, the script asks before replacing it, and a confirmed replacement is renamed to `<name>.bak.<timestamp>` first. Pass `--yes` to replace without asking. Without a terminal to answer on, differing files are left untouched and the script exits 1.
