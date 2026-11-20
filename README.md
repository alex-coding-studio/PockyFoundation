# PockyFoundation

Semantic design values and pure layout geometry for **iOS 26+ and macOS 14+**.
Built with Swift 6 and Swift Package Manager, with no package dependencies.

Use shared role names and values on every platform.
Platform mappings use UIKit on iOS and AppKit on macOS under conditional compilation.
The package contains no views or device queries. A thin QuartzCore adapter applies
caller-colored elevation to CALayer.

## Installation

Add `https://github.com/alex-coding-studio/PockyFoundation` as a Swift package dependency
and link the `PockyFoundation` product. The initial version is not tagged yet.
Use released semantic versions rather than a moving branch once releases are available.

```swift
import PockyFoundation

let placement = PKYMasonryPlacement.frames(
    aspectRatios: [1, 0.75, 1.5],
    width: 432,
    columns: 4,
    spacing: PKYLayout.Gap.group(.compact),
    rounding: nil,
    maximumHeightRatio: 2.5
)
```

## Roles and geometry

| Domain | Public API |
| --- | --- |
| Layout | `PKYLayout.Space`, `Gap`, `Inset`, `Size`, `Split`, `Target`, `Variant`, `WidthClass`, `ContentWidth.maximum`; iOS content-width guides, `pin`/`lane`, full-width collection sections, and arranged stack initialization |
| Shape | `PKYShape.Radius`, `RadiusRole`, `Stroke`, `StrokeRole`; SwiftUI `View` clipping adapters (concentric clipping needs macOS 26); iOS `UIView` corner adapters |
| Motion | `PKYMotion.Duration`, `Spring` |
| Opacity | `PKYOpacity.tint`, `focusScrim`, `dimmed`, `glassTint` |
| Symbols | `PKYIcon.Size.pointSize`; SwiftUI `font`; iOS `symbolConfiguration` and `image` adapters |
| Geometry | `CGSize`, `CGPoint`, `CGRect`, `CGAffineTransform` arithmetic and `pky` helpers; `NSDirectionalEdgeInsets.pky` (iOS and macOS) and `UIEdgeInsets.pky` (iOS) |
| Grid | `PKYGridPlacementInput`, `PKYGridPlacementOutput`, `PKYGridPlacementRole`, `PKYEdgeInsets` |
| Masonry | `PKYMasonryPlacement.frames` and `.columns` |
| Elevation | `PKYElevation.Style`, `.Appearance`, `.Recipe`, `CALayer.pkyApplyElevation`; SwiftUI `View` elevation adapter; iOS `UIView` elevation adapter |
| Accessibility | `PKYAccessibilityIdentifier`; iOS `PKYAccessibility`, `PKYAccessibilityDescription`, `pkyA11y`, and `pkyA11yID` adapters |
| Haptics | iOS `PKYHaptics` interaction feedback with reused generators, `prepare(_:)`, and `PKYHaptics.Event.sensoryFeedback` for SwiftUI |
| UIKit helpers | iOS monospaced-digit fonts, multiline labels, minimum interaction-target bounds, standard sheet style and paper background, `NSCollectionLayoutSection.pkyFullWidth` and `pkyInsetGroupedList` |
| Typography | `PKYFontFamily`, `PKYTypographyRole`, `PKYSectionHeaderRole`, `PKYTypographyTheme`; iOS `uiFont(in:compatibleWith:)`, macOS `nsFont(in:)`, SwiftUI `View.pkyFont(_:)`, and monospaced digits; iOS `pkyTypography` on labels, text fields and text views, `UIButton.pkyTitleTypography`, and theme-driven `pkyAttributedText` |
| Theme | `PKYTheme`, shared `PKYThemeFallback.system`; iOS Context, traits, SwiftUI environment and view/layer update bindings; macOS default-theme `NSColor.pky*` getters |
| Color | `PKYColor` (`UIColor` on iOS, `NSColor` on macOS), `PKYBackgroundRole`, `PKYColorTheme`, `PKYStandardInverse` |
| Appearance | `PKYAppearance` storage, `.Mode`; `userInterfaceStyle` on iOS, `nsAppearance` on macOS |

### Platform values

Measurements are in points, durations in seconds. These values are shared by iOS and macOS;
only native API mappings and coordinate conversion differ by platform.
App-owned roles do not override native control sizing or system presentation corners.

| Role | Value |
| --- | --- |
| Space | 4 / 8 / 12 / 16 / 24 / 32 |
| Gap content; group; section (compact / standard / wide) | 4/8/12; 12/16/24; 16/24/32 |
| Inset page/container; control vertical/horizontal; row vertical/horizontal | 8/16/24; 4/8/12 + 8/12/16; 4/8/12 + 12/16/24 |
| Size button; row; dot; auxiliary; minimum target | 36/44/52; 44/52/64; 6/7/8; 32; 44; native controls keep system sizing |
| Radius tile / compact / content / card / panel | 10 / 14 / 16 / 22 / 30 |
| Stroke standard / strong / heavy / display | 0.5 / 2 / 3 / 12 |
| Duration quick / standard / slow / long / extended | .15 / .25 / .35 / .45 / .6 |
| Spring smooth / snappy / bouncy / pop (bounce) | 0 / .15 / .3 / .45 |
| Opacity tint / focusScrim / dimmed / glassTint | .16 / .28 / .5 / .85 |
| Icon accessory / badge / control / item / feature | 12 / 16 / 18 / 20 / 24 |
| Grid tile reference columns (ordinary / large) | 3 / 5 |
| Grid page margin; card minimum width | 16; 300 |
| Grid tile gaps without / with caption | 8 / 12 horizontal, 8 / 16 vertical |
| Elevation subtle light / dark (opacity, radius, visual y) | (.12, 3, 1) / (.35, 3, 1) |
| Elevation insetIndicator light / dark | (.08, 2, 0) / none |
| Elevation floating; mediaContent; mediaHalo | (.16,18,8); (.45,1,1); (.25,12,2) |

Elevation recipes depend on the caller's resolved appearance; UIKit and SwiftUI adapters derive it
from traits and `colorScheme`. Grid column policy depends on the caller-supplied window geometry, and callers can
supply an explicit column policy instead. Products that need denser surfaces choose a smaller role
or keep a product-owned metric rather than adding a platform branch.

### Color mappings

`PKYColorTheme.system(accent:)` keeps app-provided primary, secondary, and on-accent colors.
Color families store and return `PKYColor`, a native platform alias, preserving iOS signatures.

| Role | iOS | macOS |
| --- | --- | --- |
| Standard background primary / secondary / tertiary | `systemBackground` / `secondarySystemBackground` / `tertiarySystemBackground` | `windowBackgroundColor` / `controlBackgroundColor` / `underPageBackgroundColor` |
| Grouped background primary / secondary / tertiary | `systemGroupedBackground` / `secondarySystemGroupedBackground` / `tertiarySystemGroupedBackground` | Same as standard backgrounds |
| Content primary / secondary / tertiary / quaternary / placeholder | `label` / `secondaryLabel` / `tertiaryLabel` / `quaternaryLabel` / `placeholderText` | `labelColor` / `secondaryLabelColor` / `tertiaryLabelColor` / `quaternaryLabelColor` / `placeholderTextColor` |
| Quiet fills primary through quaternary | UIKit `systemFill` through `quaternarySystemFill` | AppKit `systemFill` through `quaternarySystemFill` |
| Prominent primary / paired foreground | `label` / `systemBackground` | `labelColor` / `windowBackgroundColor` |
| Prominent secondary / paired foreground | Opposite-appearance `systemGray3` / `systemBackground` | `secondaryLabelColor` / `windowBackgroundColor` |
| Separator standard / opaque | `separator` / `opaqueSeparator` | `separatorColor` / `gridColor` |
| Accent primary / secondary / paired foreground | Supplied `accent` palette | Supplied `accent` palette |
| Status destructive / warning / success; paired foreground | `systemRed` / `systemOrange` / `systemGreen`; white | Same native AppKit colors |
| Media placeholder | `systemGray5` | `quaternarySystemFill` |
| Media content / content shadow / scrim / focus scrim; shadow | White / black / black / black at `PKYOpacity.focusScrim`; black | Same |
| Inverse / on inverse | Black / white in light appearance, reversed in dark | Black / white in aqua, reversed in darkAqua |

AppKit has no `systemGray2` through `systemGray6` ramp, so none is introduced.
`underPageBackgroundColor` is retained as the selected tertiary mapping, although AppKit does
not recommend it for drawing. Both inverse colors use custom dynamic providers. The focus
scrim opacity is shared across platforms; adopting its semantic role preserves the iOS value.
iOS propagates injected themes through traits; macOS `NSColor.pky*` conveniences use the static default theme described below.

### Typography mappings

`PKYTypographyRole` is the only typography descriptor: eight roles composed with weight, italic,
rounded and monospaced design, monospaced digits, and optional reference sizes, independent of
any theme. `PKYTypographyTheme` supplies the system or custom PostScript font family and the
Dynamic Type policy that resolve every role. `PKYTheme` combines complete color and typography values.
UIKit resolves roles with `uiFont(in:compatibleWith:)`, AppKit with `nsFont(in:)`, and SwiftUI
with `View.pkyFont(_:)`.

| Role | Native text style | Standard weight |
| --- | --- | --- |
| display | largeTitle | bold |
| pageTitle | title1 | bold |
| title | title2 | semibold |
| heading | headline | semibold |
| body | body | regular |
| supporting | subheadline | regular |
| caption | footnote | regular |
| action | body | semibold |

On iOS, fixed system fonts use the large content-size category; custom families use their
existing reference sizes. Dynamic scaling follows UIKit metrics up to the supplied maximum.
When the UIKit legibility weight is bold, both families request one heavier role weight
(regular → medium → semibold → bold), capped at bold, without changing the scaling policy.
UIKit typography bindings reapply fonts when the legibility weight changes. In SwiftUI,
`View.pkyFont(_:)` builds traits from the injected theme, Dynamic Type size, and legibility
weight environment and uses the same UIKit resolution, so both frameworks render identical fonts.

On macOS, both families use `NSFont.preferredFont(forTextStyle:options:)` sizes by default and
ignore `Scaling`. Explicit reference sizes override those defaults on both platforms. macOS
`View.pkyFont(_:)` resolves against the default theme; use `Font(role.nsFont(in:))` for another theme.

Custom lookup tries the requested face, then the same-weight upright face for missing italics,
then the nearest loadable upright weight, and finally the equivalent system font. Bold Text
prefers an available upright weight at or above the request before considering lighter weights.
Rounded and monospaced designs change system faces only (monospaced overrides rounded if both are set). The native monospaced-digit
adapters preserve family, size, and existing traits while adding the number-spacing feature.

### Theme runtime and platform boundary

On iOS, the app owns `PKYThemeContext`. Theme activation replaces an immutable identity snapshot,
notifies UIKit observers through `.pkyThemeDidChange`, and invalidates Swift Observation readers.
Appearance selection is stored through `PKYAppearance`, applied to connected scenes as a
user-interface-style trait override that every window in the scene follows, and notified
separately through `.pkyAppearanceDidChange`. UIKit apps call `apply(to:)` from
`scene(_:willConnectTo:options:)` to install the current theme and appearance on each new scene.
App extensions cannot use the scene-free `activate` calls; they pass their own scenes to
`activate(theme:in:)` and `activate(appearance:in:)`.
`View.pkyTheme(_:)` shares the context and snapshot with SwiftUI and bridges that snapshot to
UIKit traits. Local trait or environment overrides keep the root selection unchanged.

`UIColor.pkyTheme` and semantic color getters resolve at use time from the requesting traits.
Missing injection remains nil: Debug diagnoses direct theme resolution and returns magenta for
dynamic colors; Release reports a fault once and uses the explicit emergency recipe. That iOS
recipe uses system blue accents, white on-accent, native system colors, and fixed typography.
Direct resolution, including UIKit typography bindings and SwiftUI `View.pkyFont(_:)`, traps in
Debug because its stack points at the uninjected hierarchy; dynamic colors resolve later during
rendering, so they signal with magenta instead. Previews and tests inject a theme like the app:
SwiftUI uses `MyView().pkyTheme(PKYThemeContext(theme: theme))`, and UIKit sets
`traitOverrides.pkyTheme = PKYThemeTraitValue(theme: theme)` on a window or view.
View and layer update bindings reuse registrations, hold owners weakly, and defer detached or
not-yet-inherited theme work to a visible UI update. Cancelling preserves the last rendering.

macOS has no Context, trait propagation, diagnostic machinery, or NSView binding in this step.
`PKYThemeFallback.system` is its default recipe: both accent levels are `NSColor.controlAccentColor`,
on-accent is white, and typography is `.system(scaling: .fixed)`. `NSColor.pkyContent`,
`pkyBackground`, `pkyAccent`, `pkySeparator`, `pkyOnAccent`, `pkyStatus`, and `pkyOnStatus` return
roles from that default theme. The native colors retain system appearance behavior; app-supplied
macOS theme switching is deferred.

Binding and diagnostic implementation access for the iOS Pocky component library is exposed only through
`@_spi(Pocky) import PockyFoundation`. It is not part of the ordinary consumer API.

### Placement behavior

Masonry ratios are **width / height**. Items enter the shortest column, breaking ties toward
the leading column. The default rounds item heights to whole points; pass `rounding: nil`
to preserve fractional heights. `maximumHeightRatio: 2.5` caps height / width after rounding.
Invalid ratios use squares. Negative spacing intentionally supports overlapping content.
Grid padding uses `PKYEdgeInsets`; native adapters must bridge their own directional-inset types.

### Elevation and appearance

Recipe offsets use visual downward-positive y. The CALayer adapter defaults to positive y
on iOS and negative y on macOS. Pass `positiveYIsDown` for custom or flipped coordinate
hierarchies; the adapter does not infer ancestor transforms. Pass resolved CGColor and
`appearance: .dark` when appropriate, and reapply after appearance or color changes.
It changes only shadow color, opacity, radius, and offset. Clipping, corners, z-order,
layout, and shadowPath remain caller-owned. `pkyRemoveElevation()` clears those four properties.
The iOS `UIView` adapter keeps its recipe and color current as the view mounts and as the theme
or color-appearance traits change, without requiring theme injection; its `pkyRemoveElevation()`
also stops those updates. SwiftUI adapters follow `colorScheme` directly.

## Development

Read [ProjectContext.md](ProjectContext.md) and [the engineering guide](docs/PROJECT.md).
Run `./scripts/lint.sh`, `./scripts/test.sh macos`, `./scripts/test.sh ios`, and
`./scripts/build.sh macos|ios`. Use Xcode 26 or later with an available iOS Simulator runtime;
CI verifies with the newest installed Xcode. The iOS 26.1 sheet paper background is compiled
only with Xcode 26.1 or later; earlier toolchains keep the system sheet background.
Formatter/linter versions and binary checksums are pinned in CI. No private tooling is needed.

Personally maintained; external issues and pull requests are not accepted; forks are welcome.
MIT License. Copyright (c) 2026 Cunqi.
