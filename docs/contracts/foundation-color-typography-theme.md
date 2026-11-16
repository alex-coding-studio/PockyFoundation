# Delivery Contract: Color, Typography and Theme move to PockyFoundation

Status: proposed. Governs only this delivery; becomes a historical record once delivered or
abandoned.

## 1. Outcome

Pocky's Color, Typography and Theme foundation, plus `UISheetPresentationController+PKY`, live in
PockyFoundation. iOS code sits under `#if os(iOS)` with unchanged public API and behaviour; macOS
gets native AppKit mappings for the shared roles. Pocky keeps re-exporting PockyFoundation, so
GalleryX and Lumi compile with lockfile-only changes. The move ships in four ordered steps; each
step is one PockyFoundation PR plus release, one Pocky PR, and GalleryX and Lumi pin PRs.

## 2. Frozen source

| ID | Source | Identity |
| --- | --- | --- |
| SRC-1 | Owner brief relayed by the AnyDock architect (goal, settled and open decisions, required contract content) | Section 9 quotes the normative parts |
| SRC-2 | Architect follow-up: macOS accent decision | Section 9 |
| SRC-3 | Pocky sources and tests to move | `alex-coding-studio/Pocky` at `6dfa22d4a4e19f1e4a89ec2b37f53aefd42e7ee2` |
| SRC-4 | PockyFoundation baseline and contributor rules | this repository at `6f5c40e5324636886e98ae280a7757a881d09463` (tag 0.4.0, #7) |
| SRC-5 | Reference deliveries | PockyFoundation #2, #4, #5 (closed), #6, #7; Pocky #194, #195; GalleryX #3212 |
| SRC-6 | Architect follow-up: versions start at 0.5.0; move the `pkyInsetGroupedList` left by #7 in step 3 or 4 | Section 9 |

Source-to-clause mapping:

| Source requirement | Clauses |
| --- | --- |
| Move Color, Typography, Theme, sheet extension | S1, S2, S3, S4 inventories |
| iOS under `#if os(iOS)`; AppKit/UIKit only under `#if os(...)`; shared roles platform-neutral | C-02 |
| macOS native mappings for shared roles | S1-03, S1-04, S2-03, S3-04 |
| Public API source-compatible through `@_exported import`; redundant forwarders may drop | C-01, C-09 |
| macOS `.grouped(level)` maps like `.standard(level)` | S1-03 |
| `.lproj` strings, case-insensitive test lookup | C-07 (no new strings are expected) |
| Tests assert relationships | C-06 |
| CI is Xcode 26.6 | C-07 |
| Smallest safe steps, each PockyFoundation + Pocky + pin PRs | C-08, section 4 |
| Which internal members become public | section 6 |
| macOS accent is a theme parameter; default is `controlAccentColor`; `.pkyAccent` call sites unchanged | S1-03, S3-04 |
| Pocky ends with only PockyComponents | S4-03; X-1 |
| Versions 0.5.0 to 0.8.0; `pkyInsetGroupedList` moves | section 4 headings, S4-01 |

## 3. Common rules (every step)

- **C-01 API compatibility.** Every moved public or open declaration keeps its name, nesting,
  signature, argument labels, defaults, `@MainActor` isolation and conformances on iOS. No step
  drops a declaration unless this contract names it; none is named.
- **C-02 Platform boundary.** UIKit, AppKit and UIKit-bridged SwiftUI code compile only inside
  `#if os(iOS)` or `#if os(macOS)`. Role enums and value types that hold no native object compile
  on both platforms without conditions.
- **C-03 iOS behaviour.** iOS mappings, fallbacks, diagnostics, trait observation and update timing
  are byte-for-byte the same logic as SRC-3, apart from comment removal, documentation translation
  and availability annotations.
- **C-04 Availability.** Package deployment targets stay iOS 17 and macOS 14. A declaration that
  needs a newer API carries `@available` at the version that API needs (pending decision D-2).
  Pocky, GalleryX and Lumi target iOS 26, so annotations do not change their call sites.
- **C-05 Documentation.** Public API has English DocC comments; Pocky's Chinese inline comments
  are removed (PockyFoundation forbids implementation comments). Tool directives such as
  `swiftlint:disable:next` stay. README role tables, ProjectContext.md and docs/PROJECT.md describe
  the moved areas and their macOS values. Pocky updates ProjectContext.md, docs/ENGINEERING.md and
  the relevant docs/theme/*.md to say each area is provided by PockyFoundation.
- **C-06 Tests.** Tests move with their code, take English names, and assert relationships, input
  to output mapping, or state before and after a call, never exact sizes, colors or fonts.
  iOS-only tests sit under `#if os(iOS)`. New macOS tests cover each new mapping at the
  relationship level (section 5). A Pocky test that only depends on moved code moves; a test that
  depends on PockyComponents stays.
- **C-07 Toolchain.** Everything must build and test with CI's Xcode 26.6 (Swift 6.3). Do not use
  SDK symbols or language features newer than that toolchain; a local newer Xcode passing is not
  evidence. Resources stay `.lproj` string files; no String Catalogs.
- **C-08 Delivery triplet.** Per step, in order: (a) PockyFoundation PR, reviewed, merged, then a
  minor release tag; (b) Pocky PR that bumps `upToNextMinor` to that release, updates
  `Package.resolved`, deletes the moved files and tests in the same commit (no duplicate
  definitions ever coexist); (c) GalleryX and Lumi PRs that change only lockfile pins. Step 1's
  Pocky PR starts from a Pocky that already depends on 0.4.0 (the #7 follow-up). The next
  step's PockyFoundation PR may open before (b) and (c) merge, but its release waits until the
  previous step's Pocky PR has merged.
- **C-09 Consumers.** GalleryX and Lumi build and pass their tests with pin-only changes. If a
  consumer needs a source change, it must be a mechanical replacement listed in its PR, and any
  source change beyond that returns to Plan.
- **C-10 Layout.** Moved files keep their Pocky directory names under
  `Sources/PockyFoundation/{Color,Typography,Theme,UIKitExtensions}` and matching test
  directories. No new targets or package dependencies.

## 4. Steps

### Step 1: Color values (PockyFoundation 0.5.0)

Inventory: all of `Sources/Pocky/Color/` (`PKYBackgroundRole`, `PKYColorTheme` and its
`Accent`, `Background`, `Content`, `Filled`, `Media`, `Separator`, `Status` extensions,
`PKYColorTheme+System`, `PKYStandardInverse`); `Tests/PockyTests/Color/PKYColorThemeTests.swift`.

- **S1-01** The color types compile on both platforms. Stored and returned colors use a public
  platform color alias, `UIColor` on iOS and `NSColor` on macOS (name per decision D-5), so iOS
  signatures still read `UIColor`.
- **S1-02** `PKYColorTheme.system(accent:)` on iOS returns the same UIKit system colors as SRC-3,
  including the opposite-appearance `systemGray3` prominent fill and the 0.28 focus scrim.
- **S1-03** On macOS, `system(accent:)` maps:

  | Role | macOS |
  | --- | --- |
  | `standard` and `grouped` primary / secondary / tertiary | `windowBackgroundColor` / `controlBackgroundColor` / `underPageBackgroundColor` |
  | content primary / secondary / tertiary / quaternary / placeholder | `labelColor` / `secondaryLabelColor` / `tertiaryLabelColor` / `quaternaryLabelColor` / `placeholderTextColor` |
  | quiet fill primary ... quaternary | `systemFillColor` ... `quaternarySystemFillColor` (macOS 14) |
  | prominent primary / on primary | `labelColor` / `windowBackgroundColor` |
  | prominent secondary / on secondary | decision D-3 / `windowBackgroundColor` |
  | separator standard / opaque | `separatorColor` / decision D-3 |
  | accent primary, secondary, on accent | the `accent` argument, as on iOS |
  | status destructive / warning / success; on status | `systemRed` / `systemOrange` / `systemGreen`; white |
  | media placeholder | decision D-3 |
  | media content / content shadow / scrim / focus scrim; shadow | white / black / black / black at the iOS focus opacity; black |

- **S1-04** `PKYStandardInverse.inverse` and `onInverse` exist on macOS and resolve opposite
  luminance under `.aqua` and `.darkAqua`, matching the iOS relationship.
- **S1-05** Pocky deletes `Sources/Pocky/Color/` and the moved test; Pocky's Theme code and
  PockyComponents compile unchanged.

### Step 2: Typography values and `PKYTheme` (PockyFoundation 0.6.0)

Inventory: `Typography/PKYFontFamily`, `PKYSectionHeaderRole`, `PKYTextStyle` (with internal
`PKYFontWeight`), `PKYTypographyRole`, `PKYTypographyTheme`, `PKYTypographyTheme+System`;
`Theme/PKYTheme.swift`. Tests: `Typography/PKYTypographyThemeTests.swift`.
`UIFont.pkyMonospacedDigits` already ships in PockyFoundation 0.4.0 (#7) and is reused, not
moved again. `UIKit+PKYTypography.swift` stays for step 4.

- **S2-01** Shared on both platforms: `PKYTypographyRole` and its modifiers (`regular` ...
  `bold`, `italic`, `rounded`, `monospacedDigits`, `withReferenceSize`), `PKYSectionHeaderRole`,
  `PKYFontFamily` (`system`, `custom`), `PKYTypographyTheme` with `Scaling`, `PKYTextStyle` with
  its modifiers and SwiftUI `font`, and `PKYTheme`.
- **S2-02** iOS: `uiFont`, `uiFont(compatibleWith:)`, `uiFont(referenceSize:compatibleWith:)`,
  `PKYTypographyRole.uiFont(in:compatibleWith:referenceSize:)` and `UIFont.pkyMonospacedDigits`
  behave as in SRC-3, including custom-face fallback order and Dynamic Type ceilings.
- **S2-03** macOS adds `PKYTextStyle.nsFont`, `PKYTextStyle.nsFont(referenceSize:)`,
  `PKYTypographyRole.nsFont(in:referenceSize:)` and `NSFont.pkyMonospacedDigits`. Without a
  reference size the point size follows decision D-4. Weight, italic, rounded design and
  monospaced digits apply as on iOS. Custom faces load through `NSFont(name:size:)` with the same
  fallback order. `Scaling` compiles on macOS and is ignored there.
- **S2-04** Pocky deletes the moved files and tests; `UIKit+PKYTypography`, Theme code and
  PockyComponents compile unchanged.

### Step 3: Theme core (PockyFoundation 0.7.0)

Inventory: `Theme/PKYThemeTrait`, `PKYThemeEnvironmentKey`, `PKYThemeContext`,
`PKYThemeFallback` (with `PKYThemeDiagnostics`), `PKYThemeBinding`, `UIColor+PKYTheme`,
`UIColor+PKYSemantic`, `UIView+PKYThemeChange`, `PKYTheme+SwiftUI`. Tests:
`Theme/PKYThemeBridgeTests`, `PKYThemeContextTests`, `PKYThemeTraitTests`, and the
`PKYThemeContext` cases in `Appearance/PKYAppearanceTests` (after this step the Pocky file has no
remaining cases and is deleted).

- **S3-01** All inventory files are iOS-only, under `#if os(iOS)`, with C-03 behaviour: DEBUG
  missing-injection precondition and magenta, release fallback with one log, notifications,
  Observation invalidation, window appearance, trait-bridged SwiftUI environment, cell-reuse
  binding reuse and `UIUpdateLink` deferral.
- **S3-02** Former `package` members used by PockyComponents and its tests become reachable from
  the Pocky package per section 6 and decision D-1, without entering GalleryX or Lumi's normal
  API surface.
- **S3-03** Pocky gives PockyComponents and PockyComponentsTests the access section 6 requires,
  deletes the moved files and tests, and its remaining tests pass.
- **S3-04** macOS: `PKYThemeFallback.system` exists, built from S1-03 with accent primary and
  secondary `NSColor.controlAccentColor`, on accent white, and `.system(scaling: .fixed)`
  typography. `NSColor.pkyContent(_:)`, `pkyBackground(_:)`, `pkyAccent(_:)`, `pkySeparator(_:)`,
  `pkyOnAccent`, `pkyStatus(_:)` and `pkyOnStatus(_:)` exist with the iOS names and argument
  types, resolving from that default theme under decision D-6. iOS-only types (trait, context,
  binding, environment key) do not exist on macOS in this delivery.

### Step 4: UIKit typography bindings and sheet style (PockyFoundation 0.8.0)

Inventory: `Typography/UIKit+PKYTypography.swift`,
`UIKitExtensions/UISheetPresentationController+PKY.swift`, and
`NSCollectionLayoutSection.pkyInsetGroupedList(_:)`, which #7 left in Pocky's
`Layout/NSCollectionLayoutSection+PKY.swift` because it reads `UIColor.pkySeparator`; it joins
`pkyFullWidth(height:)` in PockyFoundation's existing file of that name. Tests:
`UIKitExtensions/UISheetPresentationControllerTests.swift` and any PockyTests case that only
exercises these files.

- **S4-01** `UILabel`, `UITextField`, `UITextView` `.pkyTypography`, `UIButton.pkyTitleTypography`,
  `UILabel`/`UITextView` `.pkyAttributedText(observing:_:)`, `pkyApplyStandardStyle` and
  `pkyUsePaperBackground` move iOS-only with C-03 behaviour, including selection clamping and the
  iOS 26.1 paper background guard. `pkyInsetGroupedList(_:)` keeps its clear background and
  standard separator color.
- **S4-02** `pkyTypographyRegistration`, `pkyTitleTypographyRegistration` and
  `pkyAttributedTextRegistration` follow section 6.
- **S4-03** After the Pocky PR, `Sources/Pocky` contains no Color, Typography or Theme directory,
  and no file or declaration in this inventory.

## 5. Verification

| Evidence | Applies to | Pass condition |
| --- | --- | --- |
| `./scripts/lint.sh` | every PockyFoundation PR | passes, including public-content check |
| `./scripts/test.sh macos`, `./scripts/test.sh ios` | every PockyFoundation PR | pass locally and in CI (Xcode 26.6) |
| `./scripts/build.sh macos`, `./scripts/build.sh ios` | every PockyFoundation PR | release builds pass |
| Pocky pre-commit lint and pre-push `Pocky-Package` tests | every Pocky PR | pass; Pocky Actions do not run, local hooks are the gate |
| GalleryX CI build and unit tests | every GalleryX pin PR | pass with lockfile-only diff |
| Lumi build and tests through its declared entry points | every Lumi pin PR | pass with lockfile-only diff |
| Inspection | C-01, C-03 | reviewer compares each moved public declaration and body with SRC-3 |

Required new macOS relationship checks (no exact values):

- S1: content primary, secondary and tertiary resolve to distinct colors; standard and grouped
  return the same color per level; background and inverse colors differ between `.aqua` and
  `.darkAqua`; the accent getters return the supplied accent.
- S2: system point sizes do not increase from `display` to `caption`; `bold` has a heavier weight
  trait than `regular`; `italic` and `rounded` change the descriptor; `monospacedDigits` adds the
  number-spacing feature; a reference size is used as given; an unloadable custom face falls back
  to the system font.
- S3: the macOS default accent is the current `controlAccentColor`; each `NSColor.pky*` getter
  equals the matching default-theme role.

Package tests do not prove on-screen rendering. AnyDock visual acceptance and GalleryX/Lumi UI
acceptance are outside this delivery.

## 6. Access changes across the package boundary

No member needs to become public temporarily: each step moves an internal member together with
every caller that uses it, and Pocky code left behind uses only public API. The following former
`package` members are used by PockyComponents or its tests, which live in another package after
step 3, so they need permanent cross-package access (form per decision D-1):

| Step | Member | Used by |
| --- | --- | --- |
| 3 | `PKYThemeBinding`: `init(owner:traits:resolvesTheme:)`, `onUpdate`, `registration`, `mountLink`, `resolvesTheme`, `observes(_:)`, `refresh(fromTraitChange:)`, `stop()`, `performVisibleUpdate()` | BottomPanel, ExpandableSheet, DualActionExpandableHeader, CapsuleButton, WelcomePage; Support tests |
| 3 | `pkyInstallThemeUpdate(on:key:observing:update:)` | ToastBanner surface |
| 3 | `pkyThemeUpdateRegistration`, `pkyThemeChangeRegistration`, `pkyLayerColorRegistration` | Support tests |
| 3 | `PKYThemeDiagnostics.reportCount`, `reportMissingInjection()` | Support tests |
| 4 | `pkyTypographyRegistration`, `pkyTitleTypographyRegistration`, `pkyAttributedTextRegistration` | Support tests |

Members only used inside the moved files (`PKYFontWeight`, `PKYFontFaceKey`,
`PKYResolvedFontFace`, `PKYTextStyle.Role`, resolve helpers) stay internal.

## 7. Risks and pitfalls

- **Availability cascade.** `PKYThemeContext` uses `NotificationCenter.MainActorMessage`
  (iOS 26), `PKYThemeBinding` uses `UIUpdateLink` (iOS 18), diagnostics use `Mutex` (iOS 18,
  macOS 15). Annotations spread to every dependent extension; a missing one fails only on the
  iOS 17 deployment build. Decision D-2.
- **macOS 14 floor.** `Mutex` is macOS 15, so any macOS diagnostics in step 3 need another lock or
  none. `underPageBackgroundColor` is documented by AppKit as not meant for drawing; the mapping
  is the owner's settled choice and is recorded, not reopened.
- **Duplicate definitions.** Pocky must delete moved files in the same PR as the bump; otherwise
  duplicate extension members (for example `UIColor.pkyContent(_:)`) make calls ambiguous.
- **Implicit transitive import.** PockyComponents depends only on Pocky; importing PockyFoundation
  SPI there needs an explicit product dependency in Pocky's manifest, which belongs in the step 3
  Pocky Setup PR.
- **Stale Lumi pin.** Lumi pins Pocky `main` at `01f55c0` and has no PockyFoundation pin, so its
  first pin PR also takes every earlier Pocky change. Run Lumi's full gate on that PR.
- **GalleryX lockfiles.** GalleryX has more than one `Package.resolved` that names Pocky; update
  each one its CI resolves.
- **Toolchain drift.** Local Xcode is newer than CI (#4 showed bundle naming differences); CI is
  the gate for C-07.
- **Theme contract lint.** Pocky's `check-theme-contract.py` only covers PockyComponents; moving
  Theme files does not change its baseline, but a renamed symbol in its pattern list would.

## 8. Exclusions and change protocol

- **X-1** Accessibility, Haptics, Layout and the other `UIKitExtensions` belong to #7. Removing
  the then-empty Pocky target and pointing PockyComponents at PockyFoundation directly is a later
  delivery.
- **X-2** No macOS theme switching, trait propagation, `NSView` bindings or `NSTextField`
  typography conveniences in this delivery (see D-6).
- **X-3** No AnyDock adoption; no new roles, values or API renames.
- Changing a clause's observable behaviour, the step order, or the access approach returns to Plan.
  Splitting a step into smaller PRs without changing behaviour does not.

## 9. Source record (SRC-1, SRC-2 normative excerpts)

SRC-1: "End state: PockyFoundation holds all foundation; iOS code under `#if os(iOS)`; macOS gets
native mappings for the shared roles; the Pocky package ends with only the iOS-only
PockyComponents; GalleryX and Lumi compile unchanged or with mechanical replacements only."
Settled: "AppKit/UIKit allowed only under `#if os(...)`; shared role types are
platform-neutral." "Public API stays source-compatible for GalleryX/Lumi via Pocky's
`@_exported import PockyFoundation`; Alex accepts dropping redundant forwarders when direct calls
stay compatible." "macOS backgrounds: `.grouped(level)` maps like `.standard(level)`: primary
windowBackgroundColor, secondary controlBackgroundColor, tertiary underPageBackgroundColor."
"Localized strings: `.lproj/Localizable.strings`; tests match `.lproj` names
case-insensitively." "Tests assert relationships, never exact visual values." "Alex
pre-authorized Pocky manual merges and PockyFoundation releases." Required content: "Slice order
(smallest safe steps, each a PockyFoundation PR + Pocky PR + GalleryX/Lumi pin PR), criterion IDs
and acceptance per step, verification (both platforms; CI is Xcode 26.6 so do not rely on
newer-toolchain behaviour), which internal members must become public temporarily, and risks."
Open: macOS theme propagation; opaque separator, systemGray2..6, Dynamic Type on macOS,
`PKYTypographyRole` macOS sizes.

SRC-2 (owner-confirmed): the macOS accent is a theme parameter, isomorphic with iOS
`PKYColorTheme.system(accent:)`; the macOS default theme's accent is `NSColor.controlAccentColor`
and follows the system setting; a custom app theme passes a brand color later, and `.pkyAccent`
call sites do not change.

SRC-6 (architect): PockyFoundation 0.4.0 is taken by #7 (Haptics, Accessibility, Layout,
UIKitExtensions); the four steps become 0.5.0, 0.6.0, 0.7.0 and 0.8.0, and
`pkyInsetGroupedList` (Pocky `Layout/NSCollectionLayoutSection+PKY.swift`, which depends on
`UIColor.pkySeparator`) joins step 3 or 4.

## 10. Pending owner decisions

Each has a recommendation; the contract text above assumes it until the owner answers.

- **D-1 Cross-package access form.** Recommended: `@_spi(PockyComponents) public`, imported by
  PockyComponents and its tests with `@_spi(PockyComponents) import PockyFoundation`, so GalleryX
  and Lumi do not see binding internals. Alternative: plain `public`.
- **D-2 iOS availability.** Recommended: keep iOS 17 and annotate the step 3 and 4 iOS layer
  `@available(iOS 26.0, *)` as a unit, matching #6. Alternative: raise the package iOS target to
  26 through a separate Setup PR, which removes the annotations but drops iOS 17 to 25 support.
- **D-3 macOS colors without an AppKit equivalent.** Recommended: opaque separator `gridColor`;
  prominent secondary `secondaryLabelColor`; media placeholder `quaternarySystemFillColor`.
  AppKit has no `systemGray2` ... `systemGray6`, so no gray ramp is added.
- **D-4 macOS sizes and Dynamic Type.** Recommended: without a reference size, use
  `NSFont.preferredFont(forTextStyle:)` point sizes for the same text style mapping as iOS, for
  both system and custom families; `Scaling` is ignored on macOS because it has no Dynamic Type.
- **D-5 Platform color alias name.** Recommended: `PKYPlatformColor`.
- **D-6 macOS theme propagation.** Recommended: static mapping only in this delivery; the
  `NSColor.pky*` getters resolve from the macOS default theme. A later delivery can add an
  app-supplied macOS theme (for example a settable current theme read by those getters) without
  changing call sites, which SRC-2 requires.
