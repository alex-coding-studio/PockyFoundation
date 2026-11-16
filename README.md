# PockyFoundation

Semantic design values and pure layout geometry for **iOS 17+ and macOS 14+**.
Built with Swift 6 and Swift Package Manager, with no package dependencies.

Use shared role names while allowing desktop and touch interfaces to use appropriate values.
The package contains no colors, themes, typography, haptics, views, UIKit/AppKit extensions,
or device queries. A thin QuartzCore adapter applies caller-colored elevation to CALayer.

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
| Layout | `PKYLayout.Space`, `Gap`, `Inset`, `Size`, `Split`, `Target`, `Variant`, `WidthClass` |
| Shape | `PKYShape.Radius`, `RadiusRole`, `Stroke`, `StrokeRole` |
| Motion | `PKYMotion.Duration`, `Spring` |
| Opacity | `PKYOpacity.tint`, `dimmed`, `glassTint` |
| Symbols | `PKYIcon.Size.pointSize`; native symbol configuration belongs to the caller |
| Geometry | `CGSize`, `CGPoint`, `CGRect`, `CGAffineTransform` arithmetic and `pky` helpers |
| Grid | `PKYGridPlacementInput`, `PKYGridPlacementOutput`, `PKYGridPlacementRole`, `PKYEdgeInsets` |
| Masonry | `PKYMasonryPlacement.frames` and `.columns` |
| Elevation | `PKYElevation.Style`, `.Appearance`, `.Recipe`, `CALayer.pkyApplyElevation` |

### Platform values

Measurements are in points, durations in seconds. Values not listed as different are shared.
App-owned roles do not override native control sizing or system presentation corners.

| Role | iOS | macOS |
| --- | --- | --- |
| Space | 4 / 8 / 12 / 16 / 24 / 32 | Same |
| Gap content; group; section (compact / standard / wide) | 4/8/12; 12/16/24; 16/24/32 | Same |
| Inset page/container; control vertical/horizontal; row vertical/horizontal | 8/16/24; 4/8/12 + 8/12/16; 4/8/12 + 12/16/24 | Same |
| Size button; row; dot; auxiliary; minimum target | 36/44/52; 44/52/64; 6/7/8; 32; 44 | Same; native controls keep system sizing |
| Radius tile / compact / content / card / panel | 10 / 14 / 16 / 22 / 30 | 4 / 6 / 4 / 6 / 30 |
| Stroke standard / strong / heavy / display | 0.5 / 2 / 3 / 12 | Same |
| Duration quick / standard / slow / long / extended | .15 / .25 / .35 / .45 / .6 | Same |
| Spring smooth / snappy / bouncy / pop (bounce) | 0 / .15 / .3 / .45 | Same |
| Opacity tint / dimmed / glassTint | .16 / .5 / .85 | Same |
| Icon accessory / badge / control / item / feature | 12 / 16 / 18 / 20 / 24 | Same |
| Grid tile reference columns (ordinary / large) | 3 / 5 | 4 / 4 |
| Grid page margin; card minimum width | 16; 300 | 24; 96 |
| Grid tile gaps without / with caption | 8 / 12 horizontal, 8 / 16 vertical | 12 / 12 on both axes |
| Elevation subtle light/dark (opacity, radius, visual y) | (.12, 3, 1) / same | (.14, 4, 1) / (.35, 4, 1) |
| Elevation insetIndicator light/dark | (.08, 2, 0) / same | (.08, 2, 0) / none |
| Elevation floating; mediaContent; mediaHalo | (.16,18,8); (.45,1,1); (.25,12,2) | Same |

Desktop card and nested radii, grid density, and light/dark separation follow AnyDock's
accepted tray geometry. Roles without a distinct desktop use retain their existing shared values.
The desktop grid is a window-based policy; callers can supply an explicit column policy instead.

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
