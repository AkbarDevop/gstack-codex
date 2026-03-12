# gstack-codex

Codex-first port of Garry Tan's `gstack` workflow pack.

This repo packages six skills for Codex:

- `browse`
- `plan-ceo-review`
- `plan-eng-review`
- `review`
- `ship`
- `retro`

The goal is pragmatic compatibility, not a speculative rewrite. The original `gstack` is explicitly Claude Code-oriented; this repo adapts the same workflows to Codex's skill layout and interaction model.

## Status

- `browse` is working in Codex and builds from `browse/setup`
- The workflow skills install cleanly into `~/.codex/skills`
- Some workflows, especially `ship`, still assume repo conventions such as `VERSION`, `CHANGELOG.md`, or specific test commands. They are usable, but not universally portable yet

## Install

Requirements:

- Codex
- Git
- Bun 1.0+

Clone the repo anywhere, then run:

```bash
git clone https://github.com/AkbarDevop/gstack-codex.git ~/.codex/skills/gstack-codex
cd ~/.codex/skills/gstack-codex
./install.sh
```

That copies the six skills into `~/.codex/skills` and builds the `browse` binary.

Restart Codex after install so it picks up the new skills.

## Upgrade

```bash
cd ~/.codex/skills/gstack-codex
git pull
./install.sh --force
```

## Uninstall

```bash
rm -rf ~/.codex/skills/browse \
       ~/.codex/skills/plan-ceo-review \
       ~/.codex/skills/plan-eng-review \
       ~/.codex/skills/review \
       ~/.codex/skills/ship \
       ~/.codex/skills/retro
```

## Upstream

Original repo: `https://github.com/garrytan/gstack`

This port is MIT-licensed, based on the upstream project, and intended to prove a clean Codex install path before attempting any upstream compatibility PR.
