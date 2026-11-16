# PockyFoundation Project Context

## Purpose and foundation

PockyFoundation is a standalone, public Swift package for semantic design values and pure
layout computation on iOS 17+ and macOS 14+. SwiftPM tools version 6.0 and Swift 6 language
mode are defined in Package.swift. There is one library product/target, PockyFoundation,
and one test target, PockyFoundationTests. The official SwiftPM library generator establishes
the directory layout; Package.swift is the source of truth. There are no package dependencies.

CoreGraphics and Foundation supply value types; QuartzCore supplies the thin CALayer adapter.
No colors, themes, typography, haptics, UIKit/AppKit views, device queries, resources, storage,
services, ports, credentials, or database migrations belong to this package.

## Structure and policy

Sources/PockyFoundation is grouped by semantic domain, with matching test directories.
README.md documents the role catalogue and platform values. docs/PROJECT.md owns verification.
Public types use the PKY prefix. Public API has English DocC comments; internal implementation
has no explanatory comments. Native adapters outside CALayer remain in consuming packages.
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
pull requests. Do not publish tags, releases, or alter consumers without explicit scope.
All direct dependency, toolchain, CI, or foundation changes belong to Setup and update this
context when its stable facts change. Public API evolution preserves source compatibility
within a declared release policy. Version tagging policy remains owner-controlled.
