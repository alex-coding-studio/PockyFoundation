#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
case "${1:-macos}" in
  macos) xcrun swift test ;;
  ios)
    destination="${POCKY_FOUNDATION_TEST_DESTINATION:-}"
    if [[ -z "$destination" ]]; then
      device_id="$(xcrun simctl list devices available -j | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((v["udid"] for k,vs in d["devices"].items() if ".iOS-" in k for v in vs if v["name"].startswith("iPhone")), ""))')"
      if [[ -z "$device_id" ]]; then echo "No available iOS Simulator; set POCKY_FOUNDATION_TEST_DESTINATION." >&2; exit 1; fi
      destination="platform=iOS Simulator,id=$device_id"
    fi
    derived="$(mktemp -d "${TMPDIR:-/tmp}/pocky-foundation-tests.XXXXXX")"
    trap 'rm -rf "$derived"' EXIT
    xcodebuild -scheme PockyFoundation -destination "$destination" -derivedDataPath "$derived" test
    xcodebuild -scheme PockyFoundation -destination "$destination" -derivedDataPath "$derived" \
      -configuration Release -only-testing:PockyFoundationTests/PKYThemeTraitTests test
    ;;
  *) echo "Usage: ./scripts/test.sh [macos|ios]" >&2; exit 2 ;;
esac
