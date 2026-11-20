#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

tools=".tools/bin"
work="$(mktemp -d "${TMPDIR:-/tmp}/pocky-foundation-tools.XXXXXX")"
trap 'rm -rf "$work"' EXIT
mkdir -p "$tools"

pinned() {
  sed -n "s/^  $1: //p" .github/workflows/ci.yml
}

install() {
  local name="$1" url="$2" checksum="$3"
  shift 3
  curl -fsSL -o "$work/$name.zip" "$url"
  echo "$checksum  $work/$name.zip" | shasum -a 256 -c - >/dev/null
  unzip -o -q "$work/$name.zip" "$@" -d "$tools"
  chmod +x "$tools/$name"
}

swiftformat_version="$(pinned SWIFTFORMAT_VERSION)"
swiftlint_version="$(pinned SWIFTLINT_VERSION)"
install swiftformat \
  "https://github.com/nicklockwood/SwiftFormat/releases/download/$swiftformat_version/swiftformat.zip" \
  "$(pinned SWIFTFORMAT_SHA256)"
install swiftlint \
  "https://github.com/realm/SwiftLint/releases/download/$swiftlint_version/portable_swiftlint.zip" \
  "$(pinned SWIFTLINT_SHA256)" swiftlint
echo "Installed SwiftFormat $swiftformat_version and SwiftLint $swiftlint_version into $tools."
