# gstack-codex

**gstack-codex turns Codex from one generic coding agent into a team of specialists you can invoke by name or intent.**

Six opinionated workflows for planning, review, shipping, browser QA, and engineering retrospectives, adapted from Garry Tan's original `gstack` for Claude Code and rebuilt around Codex's skill system.

## Quick Start

```bash
git clone https://github.com/AkbarDevop/gstack-codex.git ~/.codex/skills/gstack-codex
cd ~/.codex/skills/gstack-codex
./install.sh --self-test
```

Then restart Codex and use prompts like:

- `Use plan-ceo-review on this feature idea.`
- `Run review on my current branch.`
- `Use browse to test the signup flow on localhost:3000.`
- `Ship this branch if the checks pass.`

## Without gstack-codex

- The agent stays in one blended mode for everything
- Product planning, engineering planning, review, and shipping all feel the same
- "Review this branch" varies in depth every time
- "Ship it" often turns into manual release bookkeeping
- Browser QA still requires ad hoc commands or guesswork
- Retrospectives are manual and usually skipped

## With gstack-codex

| Skill | Mode | What it does |
|-------|------|--------------|
| `plan-ceo-review` | Founder / CEO | Reframe the problem, challenge the scope, and find the stronger product direction. |
| `plan-eng-review` | Eng manager / tech lead | Lock the architecture, data flow, edge cases, and test strategy before coding. |
| `review` | Paranoid staff engineer | Audit a diff against the default branch for real production risk, not style nits. |
| `ship` | Release engineer | Sync the default branch, run the repo's ship gate, push, and open the PR. |
| `browse` | QA engineer | Drive a real browser, inspect console and network logs, and validate live flows end to end. |
| `retro` | Engineering manager | Analyze commit history, work patterns, and shipping velocity over time. |

## Demo: one feature, multiple gears

I start almost every substantial feature in planning mode.

```text
You: I want to add seller photo upload to my marketplace so sellers can create listings faster.

You: Use plan-ceo-review on this idea.

Codex: "Photo upload" is not the product. The real job is helping a seller create a listing that actually sells.
       Here is the stronger version: identify the product from the image, draft the title and description,
       suggest the best hero image, and flag low-trust photos before publish.

You: Use plan-eng-review and turn that into a concrete implementation plan.

Codex: [architecture, state transitions, data flow, failure modes, test matrix]

You: implement it

You: run review on this branch

Codex: [finds structural bugs, race conditions, trust-boundary problems, test gaps]

You: fix them and ship it

Codex: [syncs the default branch, runs validation, pushes, opens the PR]

You: use browse on staging and test the listing flow

Codex: [navigates, fills forms, captures console/network issues, reports screenshots and failures]
```

That is the point of this repo. Explicit gears. Different brain for different work.

## What You Actually Say To Codex

You do not need special syntax, but naming the skill directly is the most reliable path.

### Planning

- `Use plan-ceo-review on this product idea.`
- `Use plan-eng-review on this implementation plan.`

### Review

- `Run review on my branch before I push.`
- `Audit this diff with the review workflow.`

### Shipping

- `Ship this branch if the checks pass.`
- `Push this branch and open the PR.`

### Browser QA

- `Use browse on http://localhost:3000 and test the auth flow.`
- `Use browse to inspect this docs page and extract the main content.`

### Retrospective

- `Run retro for the last 7 days.`
- `Run retro compare 14d.`

## How Codex invocation works

Codex does not use Claude slash commands.

You trigger these skills by:

- naming the skill directly, like `use review on this branch`
- asking for the workflow by intent, like `do a pre-landing review`
- letting Codex infer the right skill from the task, if the request clearly matches

Examples:

- `Use plan-ceo-review to challenge this feature idea.`
- `Use plan-eng-review on this architecture plan.`
- `Run review on my current branch.`
- `Ship this branch if the checks pass.`
- `Use browse to test the signup flow on staging.`
- `Run retro for the last 14 days.`

## Who this is for

This is for builders who already use Codex heavily and want consistent high-rigor workflows instead of one mushy generic mode.

It is especially useful if you:

- ship frequently
- want stronger planning before implementation
- care about structural review, not cosmetic review
- want browser QA without leaving the terminal
- like explicit operating modes for different phases of work

## Install

Requirements:

- Codex
- Git
- Bun 1.0+
- Network access during first setup so `browse` can download Chromium via Playwright

Recommended install:

```bash
git clone https://github.com/AkbarDevop/gstack-codex.git ~/.codex/skills/gstack-codex
cd ~/.codex/skills/gstack-codex
./install.sh --self-test
```

Why this path is recommended:

- if the repo lives under `~/.codex/skills`, `install.sh` uses symlinks by default, so upgrades are clean
- if you clone elsewhere, the installer falls back to copying the skill folders

Restart Codex after install so it picks up the new skills.

## What Happens During Install

`./install.sh` does four things:

1. installs the six skill folders into `~/.codex/skills`
2. chooses symlinks or copies depending on where you cloned the repo
3. builds the `browse` binary locally
4. runs an optional browser smoke test when you pass `--self-test`

If the repo lives under `~/.codex/skills`, symlink mode is the default so upgrades stay clean.

## Install options

```bash
./install.sh --force
./install.sh --mode copy
./install.sh --mode link
./install.sh --skip-browser-download
./install.sh --self-test
```

Environment override:

```bash
CODEX_HOME=/tmp/codex ./install.sh
```

## Upgrade

```bash
cd ~/.codex/skills/gstack-codex
git pull
./verify.sh
./install.sh --force --self-test
```

## Uninstall

```bash
cd ~/.codex/skills/gstack-codex
./uninstall.sh
```

## What gets installed

- skill folders in `~/.codex/skills/`
- `browse/dist/browse` compiled locally on your machine
- Playwright and Chromium for browser automation
- optional `agents/openai.yaml` metadata for a better skill UI surface

Nothing is added to your shell `PATH`. Nothing runs permanently in the background. The `browse` server starts on demand and shuts down after inactivity.

## Product status

### Strong today

- `browse` is working and self-testable
- `plan-ceo-review` and `plan-eng-review` are directly portable and useful
- `review` is now default-branch-aware instead of assuming `main`
- `retro` is useful across most git-based repos

### Still opinionated

- `ship` is much more generic than the original Claude-oriented version, but it still depends on the target repo having understandable release conventions
- `review/checklist.md` is strongest for web apps, LLM-heavy products, and repos where structural bugs matter more than formatting concerns

That is intentional. This project is trying to be sharp and useful, not bland and universal.

## Development

Local verification:

```bash
./verify.sh
```

What it does:

1. builds `browse`
2. runs the `browse` test suite
3. installs the skills into a clean temporary `CODEX_HOME`
4. runs a real `browse` smoke test against `https://example.com`

This repo is designed to work without GitHub Actions. `./verify.sh` is the source of truth before you push changes.

Recommended manual ship check:

```bash
./verify.sh
git status
git push
```

If you are iterating only on the browser skill:

```bash
cd browse
./setup
bun test
```

## Troubleshooting

### Bun is missing

Install it from `https://bun.sh`, then rerun:

```bash
cd ~/.codex/skills/gstack-codex
./install.sh --force
```

### Codex does not show the skills

- make sure the skills exist in `~/.codex/skills`
- restart Codex after install
- if a stale install exists, rerun `./install.sh --force`

### `browse` fails on first run

Rebuild it explicitly:

```bash
cd ~/.codex/skills/gstack-codex/browse
./setup
```

If Playwright is missing Chromium, `./setup` will install it.

### Existing skills collide with these names

Use:

```bash
./install.sh --force
```

Or remove the conflicting skill folders first.

## Why this exists

The original `gstack` is a strong idea: explicit cognitive modes for planning, review, QA, and shipping. But it is built for Claude Code's skill layout and interaction model.

`gstack-codex` exists to make the same operating model feel native in Codex:

- Codex skill folders instead of Claude skill folders
- Codex-friendly invocation by name or intent
- a real install script
- self-testable browser setup
- generic default-branch detection for review and shipping flows

## Roadmap

- make `ship` smarter about project-specific validation discovery
- add more battle-tested review heuristics outside Rails and LLM-heavy apps
- expand `browse` docs with richer QA recipes
- keep upstreaming the portable pieces back toward the original `gstack` where it makes sense

## Upstream

Original project: `https://github.com/garrytan/gstack`

This repo is MIT-licensed and based on that work, but it is intentionally a Codex-first product rather than a thin compatibility shim.
