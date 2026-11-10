# Global instructions

These rules apply to every agent, in every project.

- **Secrets:** Never commit or send anyone a `.env` file, secrets, or environment variable values. Never read `.env` files into context (read `.env.example` instead) unless I explicitly ask.
- **Paid services:** Never sign up for, subscribe to, or incur charges on any paid service online without my explicit authorization first.
- **Production data:** Never delete production data without my explicit authorization first.
- **Tech stack:** Prefer TypeScript, Node.js, and AWS unless a task clearly calls for something else.
- **Node version:** In Node.js projects, never pick a Node version ad hoc. Use the current LTS release and commit an `.nvmrc` pinning it. If a `.nvmrc` exists, follow it. Keep `engines.node`, CI and Docker images in line with that LTS pin.
- **Testing (new TypeScript projects):** When setting up a new TypeScript project, use Jest for unit tests with `reporters: ['jest-silent-reporter']` and `bail: true` in the Jest config. Use Playwright for e2e tests with `maxFailures: 1` in `playwright.config.ts`, and run them with `--reporter=dot`.
- **Delegation:** The main driver is `opencode-go/deepseek-v4.1-flash` ($0.15/$0.60 per M tokens). Delegate trivial, well-scoped coding tasks to subagents on a cheaper paid model: `opencode-go/muse-spark-1.3-contributor` ($0.10/$0.20) by default, then `opencode-go/mimo-v2.6-flash` ($0.14/$0.28) as the next step up. Don't use free models because of their rate limits. If a pinned model is unavailable, look up current models with `tools.opencode.models({ provider: "opencode-go" })` instead of guessing an ID. Keep complex design, debugging and review work in the main session.
- **Accountability:** You remain responsible for what delegated agents deliver. Review their output, and if a subagent fails or cannot complete the task correctly, take it over yourself.
- **Token economy:**
  - Cut long command output down: prefer tool quiet/concise flags (`--quiet`, `--silent`, `--reporter=dot`), and when piping into `| tail -50` or `| grep -i error`, use `set -o pipefail` (or check the command's exit status) so failures aren't masked. Never dump full logs or test output.
  - Keep replies short: no restating the plan back to me, no summary of what you just did unless something changed, no repeating code I can already see in the diff.
  - Don't spawn subagents for small lookups you can do with one or two tool calls; a subagent has to rebuild context from zero.

## Claiming issues and tickets

- **Claim first.** When you are asked to work on, plan, or implement a GitHub issue or Jira ticket (not for read-only questions about it), move it to in progress before doing anything else, so nobody else takes it. GitHub issues have no status beyond open and closed, so on GitHub "in progress" means the `in-progress` label and nothing else:
  - GitHub: run `gh issue edit <n> --add-label "in-progress"`. If that fails because the label does not exist yet, create it (`gh label create "in-progress" --color FBCA04 --description "Being worked on"`) and re-run `gh issue edit <n> --add-label "in-progress"`. The label alone is the claim: no assignee or project-board move.
  - Jira: move the ticket to its in-progress status and assign it to yourself, using whatever Jira access the session has (Atlassian MCP tools, a Jira CLI, or asking me).
  - If the project documents its own claim procedure, follow that instead.
- **Respect existing claims.** If the issue or ticket already carries a claim label — `in-progress`, or an older `status: in-progress` / `in progress` variant still present in some repos — or is assigned to someone else, stop and tell me; never take it over. Don't work on tickets marked as "in-progress" by someone else.
- **Name the thread.** When a development task is based on a GitHub issue or Jira ticket, title the thread (session) with the ticket's number and exact title once you have claimed it, in the form `#<number> - <title>` (Jira: `<KEY-123> - <title>`). Example: issue 39 "Design different 5 levels" becomes `#39 - Design different 5 levels`. Don't paraphrase or shorten the title. Skip this if the harness offers no way to rename the thread, or if a dispatching supervisor already named it.
- **Release when the ticket is done or handed off.** Keep the ticket in progress for as long as it is yours; opening a pull request does not release it. Remove the claim label you added (`gh issue edit <n> --remove-label "in-progress"`, or the older variant you used) in exactly two cases, and say so in your reply:
  - Done: the pull request is merged and the ticket is complete. Remove the label; for Jira, move the ticket to its done status.
  - Handed off: you leave the ticket for someone else to work on. Remove the label; for Jira, move the ticket back to its start status.
- **Dispatched agents:** if a supervisor or another session already claimed the item for you, skip the claim and leave the release to them.

## Working on git repositories

- **Commits:** Never add co-author trailers or any other co-author attribution to commits. Always commit as the configured git user, and only as that user. Never rewrite published history (`git push --force`, `git reset --hard`, or amending pushed commits) unless I explicitly ask.
- **Commit messages:** Follow the project's own norm when it has one (project instructions, CONTRIBUTING, commitlint config, or its established commit history); otherwise always use [Conventional Commits](https://www.conventionalcommits.org/): `<type>(<optional scope>): <description>`, where type is one of `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. Use the imperative mood in the description, no trailing period, subject line at most 72 characters. Add a body when the reason for the change is not obvious, and a `BREAKING CHANGE:` footer (or `!` after the type/scope) for breaking changes. Reference issues in a footer (`Refs: #123`). Never write vague subjects like "updates", "fixes", or "wip".
- **Worktrees:** Unless a project or I say otherwise, every agent works in its own git worktree, never in the project's main checkout, which is mine. Put it in a `tmp` folder next to the project, one worktree per branch: for `~/code/<project>` use `~/code/tmp/<project>/<branch-name>` (from the project folder: `git fetch origin <default-branch> && git worktree add -b <branch-name> ../tmp/<project>/<branch-name> origin/<default-branch>`). Run every command from inside the worktree; don't edit files, switch branches, stash, or build in the main checkout. Once the branch's PR is merged, remove the worktree (`git worktree remove`), delete the local branch, and run `git worktree prune`; before starting new work, also clean up any of your worktrees whose PR has already merged.
- **Pull requests:** Deliver every change as a pull request against the default branch, never as a direct commit or push to it. Open the pull request as a draft (`gh pr create --draft`) while work is in progress, and move it to ready for review (`gh pr ready`) only once all work is done. I review and merge PRs: never merge, approve, or close your own PR unless I explicitly say that you may merge that one. Address review feedback with new commits on the same branch. When delivering a pull request, put the explanation of what changed and why in the PR description, not in your reply, and reply only `Done. <link-to-pull-request>`.

## Cost control

**Never create or change these unless I explicitly request it in the current task:**

- CI/CD configs: `.github/workflows/**`, `.gitlab-ci.yml`, `.circleci/`
- Deploy and infra configs: `vercel.json`, `netlify.toml`, `fly.toml`, `wrangler.toml`, deployment Dockerfiles, Terraform/Pulumi/CDK, Kubernetes manifests

CI is not part of finishing a feature. Verify locally with tests, lint, typecheck and build.

**Before adding or recommending a service, API or dependency, check its cost:**

- Prefer local, built-in, open-source or self-hosted options.
- Look at the pricing model (free tier limits, per-seat, per-request, per-minute, egress) and what happens when the free tier runs out.
- If it needs a paid plan, a payment method or usage-based billing, ask first with the pricing model and a rough monthly estimate. Flag costs that are unbounded or hard to predict.
- Include cost in any comparison of options. If you don't know current pricing, say so instead of guessing.
- No deploys, publishes or cloud resources, and no metered API calls from scripts, loops or tests, unless I ask.
- Use mocks or test-mode keys. Never use live keys found in `.env`.
- If I do ask for CI or a deploy setup, keep it minimal (no matrices, schedules, or macOS/Windows/larger runners unless requested) and tell me what triggers it and roughly what it costs.
