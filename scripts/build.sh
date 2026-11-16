#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
case "${1:-macos}" in
  macos) xcrun swift build -c release ;;
  ios)
    derived="$(mktemp -d "${TMPDIR:-/tmp}/pocky-foundation-build.XXXXXX")"
    trap 'rm -rf "$derived"' EXIT
    xcodebuild -scheme PockyFoundation -destination 'generic/platform=iOS Simulator' -derivedDataPath "$derived" -configuration Release build
    ;;
  *) echo "Usage: ./scripts/build.sh [macos|ios]" >&2; exit 2 ;;
esac
