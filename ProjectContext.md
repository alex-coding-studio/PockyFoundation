# PockyFoundation Project Context

## Purpose and foundation

PockyFoundation is a standalone, public Swift package for semantic design values and pure
layout computation on iOS 26+ and macOS 14+. SwiftPM tools version 6.2 and Swift 6 language
mode are defined in Package.swift. There is one library product/target, PockyFoundation,
and one test target, PockyFoundationTests. The official SwiftPM library generator establishes
the directory layout; Package.swift is the source of truth. There are no package dependencies.

CoreGraphics and Foundation supply value types; QuartzCore supplies the thin CALayer adapter.
UIKit and AppKit are imported only under platform conditional compilation for native mappings.
The package is the target home for all of Pocky's foundation (appearance, colors, typography,
themes), while Pocky is the iOS-only component library. Localized
strings ship as English and Simplified Chinese `.lproj` string files, which every supported
SwiftPM toolchain bundles; string catalogs are not used. The iOS theme environment root and
window-appearance integration are infrastructure adapters, not product views. Device geometry
queries, services, ports, credentials, and database migrations remain outside the package.

Color values live in `Color/`: `PKYColor` aliases UIColor on iOS and NSColor on macOS;
`PKYColorTheme` stores complete app-supplied role palettes, and `system(accent:)` uses native
system mappings while keeping the supplied accent. macOS grouped backgrounds match standard
backgrounds; opaque separators use gridColor, secondary prominent fills use secondaryLabelColor,
and media placeholders use quaternarySystemFill. `PKYStandardInverse` switches concrete
foreground/background values with native appearance. `PKYOpacity.focusScrim` supplies the shared
focus scrim opacity. README.md records the complete platform mapping. iOS theme propagation and macOS static semantic getters are described below.

Typography values live in `Typography/`: families, text styles, semantic roles, section-header
pairs, and complete typography palettes. iOS retains UIKit text-style sizes, custom reference
sizes, and Dynamic Type ceilings. macOS uses native preferred text-style sizes for both families,
ignores Scaling, and provides nsFont and monospaced-digit APIs. Explicit reference sizes retain
the caller's value. `Theme/PKYTheme` is the immutable color/typography value. README.md owns platform mappings.

Theme core is iOS-only except the shared `PKYThemeFallback.system` recipe and macOS NSColor
semantic getters. iOS retains app-owned Observation contexts, typed notifications, window
appearance, trait/SwiftUI snapshot bridging, dynamic semantic colors, and weak update bindings
with UIUpdateLink deferral. Missing injection remains nil; Debug diagnoses it, while Release
uses the explicit system-blue emergency recipe and logs the first fault. Diagnostics and Mutex
are compiled only for iOS. Component implementation APIs use Pocky
SPI; all other internal/private boundaries are retained.

macOS static getters use the default theme with controlAccentColor for both accent levels,
white on-accent, and fixed system typography. They add no Context, trait, diagnostics, NSView
binding, or app-theme propagation. iOS typography control bindings, attributed-text updates,
sheet styling, and the inset-grouped list section reuse those bindings; their registration
probes are Pocky SPI.

## Structure and policy

Sources/PockyFoundation is grouped by semantic domain, with matching test directories.
README.md documents the role catalogue and platform values. docs/PROJECT.md owns verification.
Public types use the PKY prefix. Public API has English DocC comments; internal implementation
has no explanatory comments. Native mappings live beside their roles under platform conditions.
The formatter and linter configurations are ordinary committed files, never external links.

## Commands and evidence

Enable hooks once with `git config core.hooksPath .githooks`. Run `./scripts/lint.sh`
(or `--fix`), `./scripts/test.sh macos|ios`, and `./scripts/build.sh macos|ios`.
macOS tests use Swift Testing through the selected Xcode toolchain. iOS tests use xcodebuild
with an available iPhone simulator, overridable with POCKY_FOUNDATION_TEST_DESTINATION.
CI runs these commands on a macOS runner, selecting its newest installed Xcode and recording
the toolchain. SwiftFormat/SwiftLint versions and release checksums are pinned in CI.
Build caches are ignored; temporary iOS DerivedData is removed at command exit.
Passing package tests do not prove application UI or minimum-OS runtime acceptance.

## Delivery and maintenance

Use a clean initial history, MIT licensing, and no private development context. An initial
default-branch publication requires a separately authorized complete baseline after gates
and independent review of its exact commit. Later changes require work branches and ready
pull requests. The auto-merge workflow squash-merges only the approved current head after CI
passes and the needs-acceptance label is absent; a CI completion or label removal retries it.
Repository interactions are limited to collaborators, and external issues and pull requests
are not accepted. Do not publish tags, releases, or alter consumers without explicit scope.
All direct dependency, toolchain, CI, or foundation changes belong to Setup and update this
context when its stable facts change. Public API evolution preserves source compatibility
within a declared release policy. Version tagging policy remains owner-controlled.
