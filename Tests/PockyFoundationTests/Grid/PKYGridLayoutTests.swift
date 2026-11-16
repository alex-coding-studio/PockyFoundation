import CoreGraphics
import PockyFoundation
import Testing

struct PKYGridLayoutTests {
    @Test("Grid placement preserves its column and spacing policies")
    func negativeSpacingKeepsExistingMasonryGeometry() {
        let result = PKYMasonryPlacement.frames(
            aspectRatios: [1, 1],
            width: 206,
            columns: 2,
            spacing: -6
        )
        #expect(result.frames == [
            CGRect(x: 0, y: 0, width: 106, height: 106),
            CGRect(x: 100, y: 0, width: 106, height: 106),
        ])
        #expect(PKYMasonryPlacement.columns(
            width: 280,
            minimumColumnWidth: 100,
            spacing: -10,
            range: 1 ... 8
        ) == 3)
    }

    @Test("Grid placement preserves its column and spacing policies")
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

    @Test("Grid placement preserves its column and spacing policies")
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

    @Test("Grid placement preserves its column and spacing policies")
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

    @Test("Grid placement preserves its column and spacing policies")
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

    @Test("Grid placement preserves its column and spacing policies")
    func migrationMatchesExistingGeometry() {
        for width in stride(from: CGFloat(280), through: 1400, by: 0.5) {
            for target in [CGFloat(104), 130, 137, 300, 340] {
                let gap: CGFloat = 16
                let columns = max(2, Int(((width + gap) / (target + gap)).rounded(.down)))
                let output = PKYGridPlacementInput(
                    width: width,
                    columns: .fitting(minimumWidth: target, range: 2 ... Int.max),
                    spacing: gap
                ).resolve()
                #expect(output.columns == columns)
            }
        }
    }
}
