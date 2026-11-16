# Engineering

## Environment and commands

Use a Swift 6-capable Xcode with iOS Simulator and macOS SDKs. The package deployment
targets are iOS 17 and macOS 14; deployment targets and test-runtime versions are distinct.
Open Package.swift in Xcode to debug tests. The package starts no app or network service.
Swift Testing is bundled with the toolchain; no test dependency installation is required.

| Entry point | Evidence |
| --- | --- |
| `./scripts/lint.sh` | Pinned SwiftFormat/SwiftLint, script syntax, public-content hygiene |
| `./scripts/lint.sh --fix` | Format owned Swift sources, then run lint |
| `./scripts/test.sh macos` | Executed host Swift Testing tests |
| `./scripts/test.sh ios` | Executed package tests on an available iOS Simulator |
| `./scripts/build.sh macos` | Release library build for macOS |
| `./scripts/build.sh ios` | Release library build for generic iOS Simulator |

POCKY_FOUNDATION_TEST_DESTINATION can select a specific Simulator destination. Without it,
the test entry selects an available iPhone simulator. Build/test scripts never launch the
Simulator UI or replace a running application. iOS DerivedData is temporary and cleaned
on exit. CI runs lint and both platform build/test entry points on macos-26, installing
pinned, checksum-verified formatter/linter binaries. The formatter language configuration
is inherited unchanged from the reference rules; Package.swift owns compiler language mode.

## Acceptance and test value

The initial acceptance is: complete platform-neutral role/geometry coverage; documented
platform values; UIKit/AppKit only under platform conditions; deterministic width/height masonry,
grid input safety, optional rounding/capping, and caller-owned appearance/coordinate handling;
portable tooling and a clean, independently reviewed initial commit with MIT licensing.

Existing pure arithmetic, width/split, grid and masonry scenarios were migrated. View-hosted
UIKit/SwiftUI rendering scenarios remain outside this package. Exact role-value restatements
are replaced with relationship checks. New safety cases protect nonfinite input from invalid
geometry or integer conversion traps, fractional height/cap behavior from layout drift, and
coordinate/appearance handling from inverted or stale shadows. Compilers and constant-value
tests cannot catch those transformations. Existing geometry examples supply the remaining
coverage; no mutation checks or pixel-value tests are required.

CALayer adapter tests prove numeric conversion and preservation of caller-owned geometry;
they do not prove screen rendering. Consumer application migration, unchanged GalleryX
compilation, and AnyDock visual acceptance are separate deliveries. No consumer is changed
by this baseline. API types ending in Placement avoid colliding with native layout wrappers;
consumers must remove their original role definitions before re-exporting this module.

The public-content gate rejects nonportable paths, personal email addresses, symbolic links,
private context, and non-English source documentation. Lint has no inherited suppression
baseline. The shadow-assignment rule is excluded only for the dedicated CALayer adapter and its property assertions,
which must assign the native shadow properties. No machine-specific tooling provider is required.

## Delivery

The pre-commit hook checks lint and refuses commits on main after its initial commit.
Publish the complete initial baseline only after independent exact-commit approval and
explicit initial-push authorization. Later fixes use pull requests. The auto-merge workflow
squash-merges the approved current head only after CI succeeds and needs-acceptance is absent.
Only reviewers with write, maintain, or admin permission count; stale approvals and current
change requests prevent merging. CI completion and removing needs-acceptance retry the merge.
After a workflow merge, CI is dispatched on main because the workflow token does not trigger
push workflows. PR and approval requirements, required CI, administrator enforcement, and
conversation resolution are enabled on main. No tags or releases are produced implicitly.

External issues and pull requests are not accepted; forks remain welcome under MIT. GitHub
interactions are restricted to collaborators for the maximum supported duration; that limit
expires and must be renewed by the owner. Configuration follows the reference app's workflow
trigger, runner, concurrency, permissions, and pinned-tool installation, with dual-platform
package build/test entry points as the intentional difference.
