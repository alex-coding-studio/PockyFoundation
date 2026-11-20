# Engineering

## Environment and commands

Use Xcode 26 or later with iOS Simulator and macOS SDKs. The package deployment
targets are iOS 26 and macOS 14; deployment targets and test-runtime versions are distinct.
APIs from newer SDKs, such as the iOS 26.1 sheet paper background, are compiled conditionally
so earlier Xcode 26 releases still build.
Open Package.swift in Xcode to debug tests. The package starts no app or network service.
Swift Testing is bundled with the toolchain; no test dependency installation is required.

| Entry point | Evidence |
| --- | --- |
| `./scripts/bootstrap.sh` | Installs the pinned, checksum-verified SwiftFormat/SwiftLint into `.tools/bin` |
| `./scripts/lint.sh` | Pinned SwiftFormat/SwiftLint, script syntax, public-content hygiene |
| `./scripts/lint.sh --fix` | Format owned Swift sources, then run lint |
| `./scripts/test.sh macos` | Executed host Swift Testing tests |
| `xcrun swift run --package-path scripts/CheckReadmeValues CheckReadmeValues "$PWD/README.md"` | Checks the README platform-value table against the public API on macOS |
| `./scripts/test.sh ios` | Executed package tests on an available iOS Simulator |
| `./scripts/build.sh macos` | Release library build for macOS |
| `./scripts/build.sh ios` | Release library builds for generic iOS Simulator, including app-extension-only API |

POCKY_FOUNDATION_TEST_DESTINATION can select a specific Simulator destination. Without it,
the test entry selects an available iPhone simulator. Build/test scripts never launch the
Simulator UI or replace a running application. iOS DerivedData is temporary and cleaned
on exit. CI runs lint and both platform build/test entry points on macos-26 with the newest
installed Xcode, recording its version, and installs the pinned, checksum-verified formatter and
linter through the same bootstrap script. `./scripts/lint.sh` prefers tools in `.tools/bin`.
Older Xcode releases are not tested in CI. Package.swift owns compiler language mode.

## Testing approach

Tests assert relationships for visual roles rather than exact visual measurements; pure
mathematical placement examples may assert computed frames. CI runs the README check as a
separate documentation step; it reports missing rows and values that differ from the public API.
Safety cases protect nonfinite input from invalid geometry or integer conversion traps,
fractional height/cap behavior from layout drift, and coordinate/appearance handling from
inverted or stale shadows.

Color tests compare supplied colors and native system mappings, preserve iOS contrast and
opposite-appearance behavior, and verify macOS content distinctions, grouped/standard equality,
background appearance changes, and inverse luminance reversal under aqua/darkAqua. Typography
tests cover native text styles, custom-face fallback, Dynamic Type ceilings, Bold Text, reference
sizes, macOS preferred sizes, and SwiftUI parity with UIKit resolution. Theme tests cover
notifications, Observation, snapshots, trait/environment bridging, appearance persistence, and
scene trait overrides. Package tests have no connected scene, so scene overrides run against
window and view trait overrides through the same internal helpers. The iOS test entry point also
runs the theme trait suite in Release to exercise missing-injection fallback.

CALayer adapter tests prove numeric conversion and preservation of caller-owned geometry; they do
not prove screen rendering, and package tests do not prove application UI or minimum-OS runtime
behavior. CI's newest installed Xcode is the verification toolchain; local results with a
different Xcode are not CI evidence. API types ending in Placement avoid colliding with native
layout wrappers.

The public-content gate rejects nonportable paths, personal email addresses, symbolic links,
private context, and non-English source comments. Implementation comments are allowed when they
explain why code is written a certain way. Lint has no inherited suppression baseline. The
shadow-assignment rule is excluded only for the dedicated CALayer adapter and its property
assertions, which must assign the native shadow properties.

## Delivery

The pre-commit hook checks lint and refuses commits on main. Changes use work branches and pull
requests. The auto-merge workflow squash-merges the approved current head only after CI succeeds
and needs-acceptance is absent. Only reviewers with write, maintain, or admin permission count;
stale approvals and current change requests prevent merging. CI completion and removing
needs-acceptance retry the merge. After a workflow merge, CI is dispatched on main because the
workflow token does not trigger push workflows. PR and approval requirements and required CI are
enabled on main; resolving review conversations is not required. Administrators may bypass them,
so the owner can merge an approved PR whose CI is queued after its gates pass locally. No tags or
releases are produced implicitly.

External issues and pull requests are not accepted; forks remain welcome under MIT. GitHub
interactions are restricted to collaborators for the maximum supported duration; that limit
expires and must be renewed by the owner.
