#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
FORCE=0

if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

skills=(
  browse
  plan-ceo-review
  plan-eng-review
  review
  ship
  retro
)

mkdir -p "$SKILLS_DIR"

for skill in "${skills[@]}"; do
  src="$REPO_DIR/$skill"
  dest="$SKILLS_DIR/$skill"

  if [[ ! -d "$src" ]]; then
    echo "Missing skill directory: $src" >&2
    exit 1
  fi

  if [[ -e "$dest" ]]; then
    if [[ "$FORCE" -ne 1 ]]; then
      echo "Skill already exists: $dest" >&2
      echo "Re-run with --force to replace existing installed skills." >&2
      exit 1
    fi
    rm -rf "$dest"
  fi

  cp -R "$src" "$dest"
done

chmod +x "$SKILLS_DIR/browse/setup"
"$SKILLS_DIR/browse/setup"

echo
echo "Installed gstack-codex skills into $SKILLS_DIR"
echo "Restart Codex to pick up new skills."
