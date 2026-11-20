import CoreGraphics
import PockyFoundation
import Testing

struct PKYGridLayoutTests {
    @Test("Adaptive grids fit columns within the width remaining after padding")
    func adaptiveGridUsesThePaddedWidth() {
        let output = PKYGridPlacementInput(
            width: 378,
            padding: PKYEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 24),
            columns: .fitting(minimumWidth: 137, range: 2 ... 8),
            spacing: 16
        ).resolve()
        #expect(output.contentWidth == 338)
        #expect(output.columns == 2)
        #expect(output.width(spanning: 2) == 338)
    }

    @Test("Fixed item widths distribute the remaining space as spacing")
    func fixedWidthDistributesTheRemainingSpace() {
        let output = PKYGridPlacementInput(
            width: 380,
            columns: .fixed(3),
            spacing: 8,
            itemWidth: .fixed(100)
        ).resolve()
        #expect(output.spacing == 40)
        let single = PKYGridPlacementInput(
            width: 200,
            columns: .fixed(1),
            spacing: 8,
            itemWidth: .fixed(100)
        ).resolve()
        #expect(single.spacing == 8)
    }

    @Test("Fitting column counts change exactly at their width boundaries")
    func columnPoliciesKeepTheirBoundaryBehavior() {
        func columns(_ width: CGFloat) -> Int {
            PKYGridPlacementInput(
                width: width,
                columns: .fitting(minimumWidth: 100, range: 1 ... 8),
                spacing: 8
            ).resolve().columns
        }
        #expect(columns(315.99) == 2)
        #expect(columns(316) == 3)
        #expect(PKYMasonryPlacement.columns(
            width: 315.99,
            minimumColumnWidth: 100,
            spacing: 8,
            range: 1 ... 8
        ) == 2)
        #expect(PKYGridPlacementInput(
            width: 200,
            columns: .fitting(minimumWidth: (200 - 8 * 2) / 3, range: 1 ... 8),
            spacing: 8
        ).resolve().columns == 3)
    }

    @Test("Rounded and over-padded grids keep usable nonnegative geometry")
    func narrowAndRoundedGridsHaveUsableGeometry() {
        let output = PKYGridPlacementInput(
            width: 350,
            columns: .fixed(3),
            spacing: 8,
            itemWidth: .fill(rounding: .down)
        ).resolve()
        #expect(output.itemWidth == output.itemWidth.rounded(.down))
        let empty = PKYGridPlacementInput(
            width: 8,
            padding: PKYEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16),
            columns: .fixed(0),
            spacing: 16
        ).resolve()
        #expect(empty.columns == 1)
        #expect(empty.contentWidth == 0)
        #expect(empty.itemWidth.isFinite && empty.itemWidth >= 0)
    }

    @Test(
        "Fitting columns change where another column and its gap fill the width",
        arguments: [CGFloat(104), 130, 137, 300, 340]
    )
    func fittingColumnsChangeAtFillWidths(target: CGFloat) {
        let gap: CGFloat = 16
        func columns(_ width: CGFloat) -> Int {
            PKYGridPlacementInput(
                width: width,
                columns: .fitting(minimumWidth: target, range: 2 ... Int.max),
                spacing: gap
            ).resolve().columns
        }
        for count in 3 ... 8 {
            let fill = CGFloat(count) * target + CGFloat(count - 1) * gap
            #expect(columns(fill) == count)
            #expect(columns(fill - 0.5) == count - 1)
        }
        #expect(columns(target) == 2)
    }
}
