# Engineering

## Environment and commands

Use a Swift 6-capable Xcode with iOS Simulator and macOS SDKs. The package deployment
targets are iOS 26 and macOS 14; deployment targets and test-runtime versions are distinct.
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

## Color-value migration

`Color/` contains platform-neutral role enums and palettes storing the native `PKYColor` alias.
System palettes preserve UIKit behavior and provide AppKit mappings documented in README.md.
The macOS standard/grouped hierarchy uses windowBackgroundColor, controlBackgroundColor, and
underPageBackgroundColor; opaque separator, secondary prominent fill, and media placeholder use
gridColor, secondaryLabelColor, and quaternarySystemFill. Accent colors remain caller-owned.
The shared focus scrim role preserves the migrated iOS opacity without a private constant or
lint suppression. Theme core is described below; consumer adoption remains a separate delivery.

Color tests compare supplied colors and native system mappings, preserve iOS contrast and
opposite-appearance behavior, and verify macOS content distinctions, grouped/standard equality,
background appearance changes, and inverse luminance reversal under aqua/darkAqua. They do not
assert fixed visual components; opacity-role tests assert ranges and relative emphasis. The
macOS cases cover new mapping mistakes that the compiler cannot detect. CI's Xcode 26.6 remains
the compatibility gate; a newer local SDK passing does not establish that compatibility.

## Typography-value migration

`Typography/` and `Theme/PKYTheme` provide shared font roles and an immutable color/typography
palette. iOS public font APIs retain the original custom-face fallback order, native text styles,
fixed scaling, Dynamic Type ceilings, and reference-size handling. UIKit control bindings remain
outside the package until their delivery step. The existing UIFont monospaced-digit adapter is
reused; AppKit receives its own native adapter.

macOS maps roles to the same native text-style names, using NSFont preferred sizes for both
system and custom families. Scaling compiles but is ignored; explicit reference sizes are used
as supplied. Weight, italic, rounded system design, and monospaced digits preserve their native
traits. Custom faces keep the requested/upright/nearest/system fallback order.

Migrated iOS tests retain mapping, fallback, composition, scaling, and state checks while removing
fixed visual-size assertions. New macOS cases cover native size ordering, ignored scaling,
modifier descriptors, number-spacing features, reference-size precedence, and unavailable-face
fallback. These scenarios protect platform transformations that compilation alone cannot verify.
The older CI toolchain remains the compatibility gate; package tests do not prove app rendering.

## Theme-core migration

`Theme/` now contains iOS Context, trait snapshots, typed notifications, SwiftUI bridging,
dynamic colors, and view/layer update bindings. Public iOS logic is preserved from the frozen
source, including DEBUG diagnostics, Release fallback/logging, Observation invalidation,
window appearance, registration reuse, and one-shot visible-update deferral. Theme binding and diagnostic
implementation APIs use Pocky SPI, with private setters and internal helpers
remaining constrained. No ordinary public wrapper exposes those implementation APIs.

The fallback recipe compiles on both platforms. Its macOS variant uses native controlAccentColor
for both accent levels, white foreground, and fixed system typography. `NSColor.pky*` maps every
semantic color getter to that default theme. Runtime contexts, bindings, and diagnostics are
excluded from macOS; native dynamic colors retain their platform appearance behavior.

Migrated tests cover notifications, Observation, snapshots, trait/environment bridging, context
appearance persistence, and window overrides. Context appearance cases use a separate suite from
the existing storage-value tests. An SPI binding scenario reuses the original pending-visible-update
state checks without importing components. New macOS cases protect default accent/policy and
complete semantic getter routing. Debug tests do not execute Release diagnostic branches; the
Release build and source comparison establish the corresponding compile and preservation evidence.
App rendering, Pocky integration, and consumer SPI/dependency changes remain separate deliveries.

## UIKit typography and sheet migration

iOS label, text-field, and text-view typography roles, button title typography, attributed-text
rebuilding, the standard sheet style with its iOS 26.1 paper background, and the inset-grouped
list section move unchanged onto the theme-core bindings. Their registration probes become
Pocky SPI. Migrated sheet cases check detents, grabber, edge attachment, and background
reapplication on theme change; one SPI case checks registration reuse and release across modules.
Font, selection, and component behavior remains covered by the Pocky component suites.

## Delivery

The pre-commit hook checks lint and refuses commits on main after its initial commit.
Publish the complete initial baseline only after independent exact-commit approval and
explicit initial-push authorization. Later fixes use pull requests. The auto-merge workflow
squash-merges the approved current head only after CI succeeds and needs-acceptance is absent.
Only reviewers with write, maintain, or admin permission count; stale approvals and current
change requests prevent merging. CI completion and removing needs-acceptance retry the merge.
After a workflow merge, CI is dispatched on main because the workflow token does not trigger
push workflows. PR and approval requirements and required CI are enabled on main; resolving
review conversations is not required. Administrators may bypass them, so the owner can merge an approved PR whose
CI is queued after its gates pass locally. No tags or releases are produced implicitly.

External issues and pull requests are not accepted; forks remain welcome under MIT. GitHub
interactions are restricted to collaborators for the maximum supported duration; that limit
expires and must be renewed by the owner. Configuration follows the reference app's workflow
trigger, runner, concurrency, permissions, and pinned-tool installation, with dual-platform
package build/test entry points as the intentional difference.
