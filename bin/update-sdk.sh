#!/usr/bin/env bash
# Syncs the vendored zkp-sdk-php into upload/system/library/zerokyc/vendor/zerokyc/zkp-sdk-php.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$ROOT/upload/system/library/zerokyc/vendor/zerokyc/zkp-sdk-php"
REF="${1:-main}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --depth 1 --branch "$REF" https://github.com/zerokyc-payments/zkp-sdk-php.git "$TMP/sdk"

rm -rf "$TARGET"
mkdir -p "$TARGET"
cp -R "$TMP/sdk/src" "$TARGET/src"
cp "$TMP/sdk/composer.json" "$TARGET/composer.json"
[ -f "$TMP/sdk/LICENSE" ] && cp "$TMP/sdk/LICENSE" "$TARGET/LICENSE"

echo "Updated vendored zkp-sdk-php to $REF"
