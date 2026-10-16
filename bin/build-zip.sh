#!/usr/bin/env bash
# Build an installable OpenCart 2.3 Extension Installer archive:
#   dist/zerokyc-pay.ocmod.zip
#
# OpenCart 2.3 expects `upload/` at the root of the `.ocmod.zip` archive.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$DIST" "$STAGE/upload"

cp -R "$ROOT/upload/." "$STAGE/upload/"

# Ensure no dev artifacts leak into the release archive
find "$STAGE" -name '.DS_Store' -delete 2>/dev/null || true
find "$STAGE" -name '*.swp' -delete 2>/dev/null || true

ZIP="$DIST/zerokyc-pay.ocmod.zip"
rm -f "$ZIP"
(
  cd "$STAGE"
  zip -rq "$ZIP" upload
)

echo "Built $ZIP ($(wc -c <"$ZIP" | tr -d ' ') bytes)"
