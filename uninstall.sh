#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"

skills=(
  browse
  plan-ceo-review
  plan-eng-review
  review
  ship
  retro
)

for skill in "${skills[@]}"; do
  target="$SKILLS_DIR/$skill"
  if [[ -e "$target" || -L "$target" ]]; then
    rm -rf "$target"
    echo "Removed $target"
  fi
done

echo "gstack-codex skills removed from $SKILLS_DIR"
