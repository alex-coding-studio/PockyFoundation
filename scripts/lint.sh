#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ -d .tools/bin ]]; then
  PATH="$PWD/.tools/bin:$PATH"
fi

require_version() {
  local pinned
  pinned="$(sed -n "s/^  $2: //p" .github/workflows/ci.yml)"
  if ! command -v "$1" >/dev/null || [[ "$("$1" "${@:3}")" != "$pinned" ]]; then
    echo "$1 $pinned is required (pinned in .github/workflows/ci.yml); run ./scripts/bootstrap.sh." >&2
    exit 1
  fi
}
require_version swiftformat SWIFTFORMAT_VERSION --version
require_version swiftlint SWIFTLINT_VERSION version

case "${1:-}" in
  --fix) swiftformat Sources Tests Package.swift ;;
  "") ;;
  *) echo "Usage: ./scripts/lint.sh [--fix]" >&2; exit 2 ;;
esac

swiftformat Sources Tests Package.swift --lint
swiftlint lint --strict --quiet
for script in scripts/*.sh .githooks/*; do bash -n "$script"; done
python3 scripts/check-public-content.py
