# Project Workflow Preferences

This project uses `gstack-codex` as its workflow layer for Codex.

The skills are installed globally in `~/.codex/skills`. Prefer using them by intent even when the user does not name them explicitly.

## Default workflow routing

- Use `plan-ceo-review` when the task is product direction, feature framing, scope challenge, founder-mode thinking, or "what should we build?"
- Use `plan-eng-review` when the task is architecture review, execution planning, test planning, edge-case review, or "how should we build this?"
- Use `review` when the user asks for a review, pre-landing audit, branch audit, diff audit, or production-risk check.
- Use `ship` when the user says `ship it`, `push this branch`, `open the PR`, or otherwise asks for release-engineer behavior.
- Use `browse` when the task needs real browser QA, UI verification, local/staging flow testing, screenshots, console inspection, or live docs inspection that benefits from a browser.
- Use `retro` when the user asks for a retrospective, shipping analysis, work-pattern review, or velocity summary.

## Invocation style

Codex does not use slash commands here. Use the skill by name or by clear intent.

Examples:

- `Use plan-ceo-review on this feature idea.`
- `Use plan-eng-review on this implementation plan.`
- `Run review on this branch.`
- `Ship this branch if checks pass.`
- `Use browse on localhost:3000 and test the signup flow.`
- `Run retro for the last 14 days.`

## Fallback

If a skill is not available in the current Codex environment, say so briefly and continue with the closest best-effort behavior.
