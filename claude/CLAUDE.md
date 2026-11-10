# Global instructions

These rules apply to every agent, in every project.

- **Secrets:** Never commit, share, or read `.env` files, secrets, or environment variable values into context (read `.env.example` instead) unless I explicitly ask.
- **Paid services:** Never sign up for, subscribe to, or incur charges on any paid service online without my explicit authorization first.
- **Production data:** Never delete production data without my explicit authorization first.
- **Tech stack:** Prefer TypeScript, Node.js, and AWS unless a task clearly calls for something else.
- **Node version:** Follow `.nvmrc` if present; otherwise pin the current LTS release in `.nvmrc` and keep `engines.node`, CI, and Docker images aligned to it.
- **Testing (new TypeScript projects):** Use Jest for unit tests (`reporters: ['jest-silent-reporter']`, `bail: true`) and Playwright for e2e tests (`maxFailures: 1` in `playwright.config.ts`, run with `--reporter=dot`).
- **Delegation:** Delegate trivial, well-scoped coding tasks to subagents on a cheaper model: Sonnet (`model: "sonnet"`) by default, or Haiku (`model: "haiku"`) for purely mechanical work (renames, boilerplate, simple searches). Keep complex design, debugging, and review in the main session.
- **Accountability:** You remain responsible for delegated work: review subagent output, and take over if a subagent fails.
- **Token economy:**
  - Prefer quiet/concise flags (`--quiet`, `--silent`, `--reporter=dot`). When piping into `| tail -50` or `| grep -i error`, use `set -o pipefail` (or check exit status) so failures aren't masked. Never dump full logs or test output.
  - Keep replies short: don't restate plans, summarize unchanged work, or repeat code visible in the diff.
  - Don't spawn subagents for 1–2 tool call lookups.

## Claiming issues and tickets

- **Claim first:** Before planning or working on a GitHub issue or Jira ticket (skip for read-only questions), follow the project's claim procedure if documented; otherwise:
  - GitHub: run `gh issue edit <n> --add-label "in-progress"` (if missing, run `gh label create "in-progress" --color FBCA04 --description "Being worked on"` first). Do not change assignees or project boards.
  - Jira: move the ticket to in-progress and assign it to yourself (via MCP, CLI, or asking me).
- **Respect existing claims:** If an issue or ticket already has `in-progress` (or `status: in-progress` / `in progress`) or is assigned to someone else, stop and tell me; never take it over.
- **Name the thread:** Once claimed, rename the session to the exact `#<number> - <title>` (Jira: `<KEY-123> - <title>`) without paraphrasing, if supported and not already named by a supervisor.
- **Release when done or handed off:** Keep the claim while open (opening a PR does not release it). Remove the `in-progress` label (`gh issue edit <n> --remove-label "in-progress"`) and say so in your reply only when:
  - Done: PR is merged and the ticket is complete (Jira: move to done).
  - Handed off: leaving the ticket for someone else (Jira: move back to start status).
- **Dispatched agents:** If a supervisor or another session already claimed the item, skip claiming and releasing.

## Working on git repositories

- **Commits:** Commit only as the configured git user; never add co-author trailers. Never rewrite published history (`git push --force`, `git reset --hard`, amending pushed commits) unless I explicitly ask.
- **Commit messages:** Follow the project's convention if one exists; otherwise use [Conventional Commits](https://www.conventionalcommits.org/) (`<type>(<optional scope>): <description>`, imperative mood, <=72 chars, no trailing period, body when non-obvious, `BREAKING CHANGE:` or `!` for breaking changes, `Refs: #123` footer). Never use vague subjects (`updates`, `fixes`, `wip`).
- **Worktrees:** Unless told otherwise, never work in the main checkout. Use one worktree per branch at `~/code/tmp/<project>/<branch-name>`:
  `git fetch origin <default-branch> && git worktree add -b <branch-name> ../tmp/<project>/<branch-name> origin/<default-branch>`
  Run all commands inside the worktree. Before starting new work and once a PR merges, remove merged worktrees (`git worktree remove`), delete their local branches, and run `git worktree prune`.
- **Pull requests:** Deliver all changes as a PR against the default branch, never a direct commit/push. Open as a draft (`gh pr create --draft`), mark ready (`gh pr ready`) when complete, and address feedback with new commits. Never merge, approve, or close your own PR unless I explicitly allow it for that PR. Put the change explanation in the PR description and reply only `Done. <link-to-pull-request>`.

## Cost control

**Never create or change these unless I explicitly request it in the current task:**

- CI/CD configs: `.github/workflows/**`, `.gitlab-ci.yml`, `.circleci/`
- Deploy and infra configs: `vercel.json`, `netlify.toml`, `fly.toml`, `wrangler.toml`, deployment Dockerfiles, Terraform/Pulumi/CDK, Kubernetes manifests

Verify locally with tests, lint, typecheck, and build. If asked for CI/deploy, keep it minimal (no unrequested matrices, schedules, or macOS/Windows/larger runners) and state its triggers and rough cost.

**Before adding or recommending a service, API, or dependency, check its cost:**

- Prefer local, built-in, open-source, or self-hosted options.
- Check the pricing model (free tier limits, per-seat/request/minute/egress, overage behavior) and include cost in any comparison. Don't guess unknown pricing.
- Ask first with the pricing model and a rough monthly estimate if it requires a paid plan, payment method, or usage-based billing; flag unbounded or unpredictable costs.
- No deploys, publishes, cloud resources, or metered API calls in scripts, loops, or tests unless I ask.
- Use mocks or test-mode keys, never live keys from `.env`.
