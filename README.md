# global-config-claude-opencode

Global config files for claude and opencode.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/bertolo1988/global-config-claude-opencode/main/install.sh | bash
```

Copies the config files into place:

| File                 | Target                         |
| -------------------- | ------------------------------ |
| `claude/CLAUDE.md`   | `~/.claude/CLAUDE.md`          |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |

The files are downloaded from GitHub; `REF` selects the branch or tag (default `main`). Override target roots with `CLAUDE_CONFIG_DIR` (`~/.claude`) and `XDG_CONFIG_HOME` (`~/.config`). Re-run the curl command to refresh installed copies: matching copies are untouched, and differing targets are backed up to `<name>.bak.<timestamp>` and replaced. The script prints one line per file (`created`, `updated`, or `already up to date`) and a closing summary.
