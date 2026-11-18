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
| Shape | `PKYShape.Radius`, `RadiusRole`, `Stroke`, `StrokeRole`; iOS `UIView` and SwiftUI `View` corner/clipping adapters |
| Motion | `PKYMotion.Duration`, `Spring` |
| Opacity | `PKYOpacity.tint`, `focusScrim`, `dimmed`, `glassTint` |
| Symbols | `PKYIcon.Size.pointSize`; iOS `symbolConfiguration`, `image`, and `font` adapters |
| Geometry | `CGSize`, `CGPoint`, `CGRect`, `CGAffineTransform` arithmetic and `pky` helpers; `NSDirectionalEdgeInsets.pky` (iOS and macOS) and `UIEdgeInsets.pky` (iOS) |
| Grid | `PKYGridPlacementInput`, `PKYGridPlacementOutput`, `PKYGridPlacementRole`, `PKYEdgeInsets` |
| Masonry | `PKYMasonryPlacement.frames` and `.columns` |
| Elevation | `PKYElevation.Style`, `.Appearance`, `.Recipe`, `CALayer.pkyApplyElevation`; iOS `UIView` and SwiftUI `View` elevation adapters |
| Accessibility | `PKYAccessibilityIdentifier`; iOS `PKYAccessibility`, `pkyA11y`, and `pkyA11yID` adapters |
| Haptics | iOS `PKYHaptics` interaction feedback |
| UIKit helpers | iOS monospaced-digit fonts, multiline labels, minimum interaction-target bounds, standard sheet style and paper background, `NSCollectionLayoutSection.pkyFullWidth` and `pkyInsetGroupedList` |
| Typography | `PKYFontFamily`, `PKYTextStyle`, `PKYTypographyRole`, `PKYSectionHeaderRole`, `PKYTypographyTheme`; SwiftUI `font`, iOS `uiFont`, macOS `nsFont` and monospaced digits; iOS `pkyTypography` on labels, text fields and text views, `UIButton.pkyTitleTypography`, and theme-driven `pkyAttributedText` |
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

`PKYTypographyTheme` builds eight roles from a system or custom PostScript font family.
`PKYTextStyle` preserves role size and policy while composing weight, italic, rounded, and monospaced design.
`PKYTypographyRole` keeps those modifiers plus monospaced digits and optional reference sizes
independent of the selected theme. `PKYTheme` combines complete color and typography values.

| Role | Native text style | Standard weight |
| --- | --- | --- |
| display | largeTitle | bold |
| pageTitle | title1 (`title` in SwiftUI) | bold |
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
`View.pkyFont(_:)` reads the legibility environment and applies the same rule to custom faces.
SwiftUI system fonts respond to the environment through their native text styles.

On macOS, both families use `NSFont.preferredFont(forTextStyle:options:)` sizes by default and
ignore `Scaling`. Explicit reference sizes override those defaults on both platforms. SwiftUI
`font` uses the resolved native font on macOS; iOS keeps its original text-style behavior.

Custom lookup tries the requested face, then the same-weight upright face for missing italics,
then the nearest loadable upright weight, and finally the equivalent system font. Bold Text
prefers an available upright weight at or above the request before considering lighter weights.
Rounded and monospaced designs change system faces only (monospaced overrides rounded if both are set). The native monospaced-digit
adapters preserve family, size, and existing traits while adding the number-spacing feature.

### Theme runtime and platform boundary

On iOS, the app owns `PKYThemeContext`. Theme activation replaces an immutable identity snapshot,
notifies UIKit observers through `.pkyThemeDidChange`, and invalidates Swift Observation readers.
Appearance selection is stored through `PKYAppearance`, applied to connected scene windows, and
notified separately through `.pkyAppearanceDidChange`. `View.pkyTheme(_:)` shares the context and
snapshot with SwiftUI and bridges that snapshot to UIKit traits. Local trait or environment
overrides keep the root selection unchanged.

`UIColor.pkyTheme` and semantic color getters resolve at use time from the requesting traits.
Missing injection remains nil: Debug diagnoses direct theme resolution and returns magenta for
dynamic colors; Release reports a fault once and uses the explicit emergency recipe. That iOS
recipe uses system blue accents, white on-accent, native system colors, and fixed typography.
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
Typography control adapters, sheet styling, and the theme-dependent list section remain outside
this step.

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

## Development

Read [ProjectContext.md](ProjectContext.md) and [the engineering guide](docs/PROJECT.md).
Run `./scripts/lint.sh`, `./scripts/test.sh macos`, `./scripts/test.sh ios`, and
`./scripts/build.sh macos|ios`. Xcode must include an available iOS Simulator runtime.
Formatter/linter versions and binary checksums are pinned in CI. No private tooling is needed.

Personally maintained; external issues and pull requests are not accepted; forks are welcome.
MIT License. Copyright (c) 2026 Cunqi.
