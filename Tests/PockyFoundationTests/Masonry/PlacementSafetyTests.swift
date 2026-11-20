import CoreGraphics
import PockyFoundation
import Testing

struct PlacementSafetyTests {
    @Test("Fractional masonry heights, height caps, invalid ratios, and ties remain deterministic")
    func capsAndInvalidRatios() {
        let ratios: [CGFloat] = [0.25, .nan, .infinity, 0, -1, 2]
        let result = PKYMasonryPlacement.frames(
            aspectRatios: ratios,
            width: 213,
            columns: 2,
            spacing: 10,
            rounding: nil,
            maximumHeightRatio: 2.5
        )
        let columnWidth = (CGFloat(213) - 10) / 2
        #expect(result.frames.count == ratios.count)
        #expect(result.frames[0].height == columnWidth * 2.5)
        #expect(result.frames[1].minX > result.frames[0].minX)
        #expect(result.frames[1].height == columnWidth)
        #expect(result.frames[2].height == columnWidth)
        #expect(result.frames[3].height == columnWidth)
        #expect(result.frames[4].height == columnWidth)
        #expect(result.frames.allSatisfy { $0.height.isFinite && $0.height <= $0.width * 2.5 })
        #expect(result.height == result.frames.map(\.maxY).max())
        let fractional = PKYMasonryPlacement.frames(
            aspectRatios: [1.5],
            width: 101,
            columns: 1,
            spacing: 0,
            rounding: nil
        )
        #expect(fractional.frames[0].height == CGFloat(101) / 1.5)
        #expect(fractional.frames[0].height != fractional.frames[0].height.rounded())
    }

    @Test("Negative masonry spacing reports the lowest frame edge as content height")
    func negativeSpacingHeight() {
        let sparse = PKYMasonryPlacement.frames(
            aspectRatios: [10],
            width: 100,
            columns: 2,
            spacing: -20
        )
        #expect(sparse.frames.count == 1)
        #expect(sparse.height == sparse.frames.map(\.maxY).max())
        let overlapping = PKYMasonryPlacement.frames(
            aspectRatios: [2, 12],
            width: 60,
            columns: 1,
            spacing: -20
        )
        #expect(overlapping.frames[1].maxY < overlapping.frames[0].maxY)
        #expect(overlapping.height == overlapping.frames.map(\.maxY).max())
    }

    @Test("Empty and nonfinite layout inputs do not trap or allocate by an unbounded column count")
    func invalidContainerGeometry() {
        #expect(PKYMasonryPlacement.frames(
            aspectRatios: [],
            width: 300,
            columns: 0,
            spacing: 8
        ).height == 0)
        #expect(PKYMasonryPlacement.frames(
            aspectRatios: [1],
            width: .nan,
            columns: 1,
            spacing: 8
        ).frames.isEmpty)
        let many = PKYMasonryPlacement.frames(
            aspectRatios: [1],
            width: 300,
            columns: .max,
            spacing: 0
        )
        #expect(many.frames.count == 1)
        let grid = PKYGridPlacementInput(
            width: .nan,
            columns: .fitting(minimumWidth: .nan, range: 1 ... 8),
            spacing: .infinity
        ).resolve()
        #expect(grid.itemWidth.isFinite)
        #expect(grid.columns >= 1)
    }
}
