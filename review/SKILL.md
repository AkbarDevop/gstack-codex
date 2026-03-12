---
name: review
version: 1.0.0
description: |
  Pre-landing review workflow for Codex. Analyze the diff against the default
  branch for structural bugs, trust-boundary issues, race conditions, missing
  tests, and other problems that often survive CI.
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
---

# Pre-Landing Review

Use this workflow when the user asks to review a branch, audit a diff, or run a pre-landing check before pushing or opening a PR.

## Codex Notes

- Codex does not use slash commands. Trigger this workflow by user intent or explicit mention of `review`.
- Read `checklist.md` from this skill directory before commenting on the diff.
- If the workflow needs user input, ask directly in a concise plain-text message.

## Step 1: Resolve the base branch

Determine the repository's default branch in this order:

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
```

If both fail, fall back to `main`.

Store the result as `<base-branch>`.

## Step 2: Check whether there is anything to review

1. Run `git branch --show-current`.
2. If the current branch is `<base-branch>`, check whether there are uncommitted changes or commits ahead of `origin/<base-branch>`.
3. Run:

```bash
git fetch origin <base-branch> --quiet
git diff origin/<base-branch> --stat
```

If there is no diff, output:

```text
Pre-Landing Review: Nothing to review.
```

Then stop.

## Step 3: Read the checklist

Read `checklist.md` from this skill directory.

If the file cannot be read, stop and report the error.

## Step 4: Get the full diff

Fetch the latest base branch, then read the full diff:

```bash
git fetch origin <base-branch> --quiet
git diff origin/<base-branch>
```

This includes committed and uncommitted changes against the latest remote base branch.

## Step 5: Two-pass review

Apply the checklist in two passes:

1. `CRITICAL`: SQL/data safety, race conditions, trust-boundary failures, security-sensitive bugs
2. `INFORMATIONAL`: The remaining checklist categories

Follow the checklist output format exactly. Respect the suppressions. Do not flag issues already addressed in the diff.

## Step 6: Output findings

Always output every real finding.

- If critical issues exist, output them first and ask the user about each critical issue separately:
  - `A: Fix it now`
  - `B: Acknowledge and leave it`
  - `C: False positive`
- If only informational issues exist, output them and stop.
- If no issues exist, output:

```text
Pre-Landing Review: No issues found.
```

If the user chooses `A` for any critical issue, apply the fix, re-run the minimal relevant validation for the touched files, and summarize what changed.

## Important Rules

- Read the full diff before commenting.
- Be terse. One line for the problem, one line for the fix.
- Only flag real problems.
- Default to read-only unless the user explicitly asks you to fix a critical issue.
- Never commit, push, or open a PR as part of `review`.
