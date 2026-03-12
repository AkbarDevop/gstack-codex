---
name: ship
version: 1.0.0
description: |
  Release workflow for Codex. Sync with the default branch, run the project's
  ship-gate checks, perform a pre-landing review, push the branch, and open a PR
  without unnecessary back-and-forth.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Ship Workflow

Use this workflow when the user says "ship it", "push this branch", "open the PR", or otherwise asks for release-engineer behavior.

## Codex Notes

- Codex does not use slash commands. Trigger this workflow by user intent or explicit mention of `ship`.
- If the workflow needs user input, ask directly in a concise plain-text message.
- When this workflow needs the review checklist, read the installed `review/checklist.md`, typically `~/.codex/skills/review/checklist.md`.

This workflow should run straight through once the branch is ready. Do not create friction unless the branch is unsafe to ship.

## Only stop for

- Current branch is the default branch
- Merge conflicts that cannot be cleanly resolved
- Missing GitHub auth for push or PR creation
- Required validation fails
- A critical review issue needs a user decision
- Version or release semantics are genuinely ambiguous

## Never stop for

- Uncommitted changes that belong in the PR
- Small commit-message wording decisions
- The absence of a version file or changelog in repositories that do not use them

## Step 1: Discover repository conventions

Determine the default branch in this order:

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
```

If both fail, fall back to `main`.

Read the local guidance that defines how this repo ships. Prioritize:

1. `AGENTS.md`, `CLAUDE.md`, or other repo guidance files
2. CI config in `.github/workflows/`
3. `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, `justfile`, `Procfile`
4. Release files such as `VERSION`, `CHANGELOG.md`, or `RELEASE.md`

From those files, infer:

- Required validation commands for a ship gate
- Whether lint/build are mandatory alongside tests
- Whether version bumping or changelog updates are part of the repo's normal release flow
- Whether prompt/eval suites are mandatory for certain files

## Step 2: Pre-flight

1. Run `git branch --show-current`. If already on the default branch, abort.
2. Run `git status --short`.
3. Fetch the default branch:

```bash
git fetch origin <base-branch> --quiet
```

4. Summarize what is being shipped:

```bash
git diff origin/<base-branch>...HEAD --stat
git log origin/<base-branch>..HEAD --oneline
```

## Step 3: Merge the latest default branch before testing

Merge `origin/<base-branch>` into the current branch so validation runs against the merged state:

```bash
git merge origin/<base-branch> --no-edit
```

If there are merge conflicts:

- Auto-resolve only when the resolution is obvious and low-risk
- Otherwise stop and show the conflicts

## Step 4: Run the ship gate

Run the validation commands required by this repo. Determine them using this precedence:

1. Explicit commands from repo guidance
2. Commands already enforced in CI
3. Well-known manifest scripts or build files

Typical candidates:

- `npm test`, `pnpm test`, `bun test`, `yarn test`
- `npm run lint`, `npm run build`
- `pytest`, `cargo test`, `go test ./...`, `make test`, `just test`

Rules:

- Run independent commands in parallel when reasonable
- Do not invent validations the repo clearly does not use
- Do not skip validations the repo clearly does use
- If a command fails, stop and show the failure

## Step 4.5: Run evals only when the repo expects them

If repo guidance or file patterns indicate prompt/eval requirements, run the relevant eval suites before shipping.

Use local guidance, CI, and file patterns to decide whether evals are mandatory. If the repo has no eval culture or no prompt-related files changed, skip this step and say so briefly.

## Step 5: Pre-landing review

Run the installed `review` workflow against `origin/<base-branch>`.

If it finds critical issues:

- Present each critical issue separately
- Recommend the safest option first
- If the user wants fixes, apply them and re-run the relevant validation

If only informational issues exist, include them in the PR summary and continue.

## Step 6: Release metadata

Only do release bookkeeping when the repository already uses it.

If a managed version file exists, update it using the repo's established versioning style.

If a changelog exists and is maintained manually, update it from the actual diff and commit history.

Do not create a new `VERSION` or `CHANGELOG.md` convention if the repo does not already have one.

If the correct bump level is ambiguous and the repo clearly cares about version semantics, ask the user.

## Step 7: Commit any remaining changes cleanly

If there are uncommitted changes after validation, review, or release bookkeeping:

- Group them into small, coherent commits
- Keep each commit independently valid
- Follow the repository's existing commit style when clear
- Prefer conventional commits when the repo already uses them

Do not rewrite existing branch history unless the user asked for that.

## Step 8: Push

Push the current branch with upstream tracking if needed:

```bash
git push -u origin <current-branch>
```

Never force-push as part of this workflow.

## Step 9: Open the pull request

Create a PR with `gh pr create`.

The PR body should include:

- A concise summary of the shipped changes
- Validation results
- Pre-landing review findings, or "No issues found"
- Notes about evals if they ran

Output the PR URL as the final result.

## Important Rules

- Do not ship from the default branch.
- Do not skip required validation.
- Do not skip pre-landing review.
- Do not invent release conventions that the repo does not already have.
- The goal is: the user says "ship it" and the next useful thing they see is either a blocker with specifics or a PR URL.
