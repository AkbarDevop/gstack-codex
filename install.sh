#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
FORCE=0
MODE="auto"
SELF_TEST=0
SKIP_BROWSER_BUILD=0
SKIP_BROWSER_DOWNLOAD=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --force                  Replace existing installed skills
  --mode auto|copy|link    Install strategy. Default: auto
  --self-test              Run a post-install browse smoke test
  --skip-browser-build     Skip browse/setup
  --skip-browser-download  Skip Playwright Chromium download during setup
  --help                   Show this help

Environment:
  CODEX_HOME               Override the Codex home directory (default: ~/.codex)
EOF
}

copy_skill() {
  local src="$1"
  local dest="$2"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude node_modules --exclude dist "$src/" "$dest/"
  else
    cp -R "$src"/. "$dest"
    rm -rf "$dest/node_modules" "$dest/dist"
  fi
}

run_self_test() {
  local browse_bin="$SKILLS_DIR/browse/dist/browse"
  local output

  echo "Running browse self-test..."
  "$browse_bin" goto https://example.com >/dev/null
  output="$("$browse_bin" text)"
  if [[ "$output" != *"Example Domain"* ]]; then
    echo "Self-test failed: browse did not return Example Domain content" >&2
    exit 1
  fi
  "$browse_bin" stop >/dev/null 2>&1 || true
  echo "browse self-test passed"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      ;;
    --mode)
      shift
      MODE="${1:-}"
      ;;
    --self-test)
      SELF_TEST=1
      ;;
    --skip-browser-build)
      SKIP_BROWSER_BUILD=1
      ;;
    --skip-browser-download)
      SKIP_BROWSER_DOWNLOAD=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

skills=(
  browse
  plan-ceo-review
  plan-eng-review
  review
  ship
  retro
)

mkdir -p "$SKILLS_DIR"

case "$MODE" in
  auto)
    case "$REPO_DIR" in
      "$SKILLS_DIR"/*) INSTALL_MODE="link" ;;
      *) INSTALL_MODE="copy" ;;
    esac
    ;;
  copy|link)
    INSTALL_MODE="$MODE"
    ;;
  *)
    echo "Invalid install mode: $MODE" >&2
    usage >&2
    exit 1
    ;;
esac

for skill in "${skills[@]}"; do
  src="$REPO_DIR/$skill"
  dest="$SKILLS_DIR/$skill"

  if [[ ! -d "$src" ]]; then
    echo "Missing skill directory: $src" >&2
    exit 1
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ "$FORCE" -ne 1 ]]; then
      echo "Skill already exists: $dest" >&2
      echo "Re-run with --force to replace existing installed skills." >&2
      exit 1
    fi
    rm -rf "$dest"
  fi

  if [[ "$INSTALL_MODE" == "link" ]]; then
    ln -s "$src" "$dest"
  else
    mkdir -p "$dest"
    copy_skill "$src" "$dest"
  fi

  echo "Installed $skill ($INSTALL_MODE)"
done

if [[ "$SKIP_BROWSER_BUILD" -ne 1 ]]; then
  chmod +x "$SKILLS_DIR/browse/setup"
  if [[ "$SKIP_BROWSER_DOWNLOAD" -eq 1 ]]; then
    BROWSE_SKIP_BROWSER_DOWNLOAD=1 "$SKILLS_DIR/browse/setup"
  else
    "$SKILLS_DIR/browse/setup"
  fi
fi

if [[ "$SELF_TEST" -eq 1 ]]; then
  run_self_test
fi

echo
echo "Installed gstack-codex skills into $SKILLS_DIR"
echo "Restart Codex to pick up new skills."
