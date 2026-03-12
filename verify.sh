#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="$(mktemp -d /tmp/gstack-codex-verify.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Building browse and running tests"
cd "$REPO_DIR/browse"
./setup
bun test

echo
echo "==> Verifying clean install into temporary CODEX_HOME"
CODEX_HOME="$TMP_DIR/codex" "$REPO_DIR/install.sh" --mode copy --self-test

echo
echo "Verification complete."
