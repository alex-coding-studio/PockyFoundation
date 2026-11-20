import CoreGraphics
import PockyFoundation
import Testing

struct PKYMasonryPlacementTests {
    @Test("Each masonry item enters the currently shortest column")
    func eachItemGoesToTheShortestColumn() {
        let result = PKYMasonryPlacement.frames(
            aspectRatios: [0.75, 1.5, 1.5, 1],
            width: 206,
            columns: 2,
            spacing: 6
        )

        #expect(result.frames.map(\.minX) == [0, 106, 106, 0])
        #expect(result.frames.map(\.height) == [133, 67, 67, 100])
        #expect(result.frames[2].minY == 73)
        #expect(result.frames[3].minY == 139)
        #expect(result.height == 239)
    }

    @Test("Masonry column count fits the minimum column width within its range")
    func columnsFollowTheMinimumColumnWidth() {
        #expect(PKYMasonryPlacement.columns(
            width: 734,
            minimumColumnWidth: 135,
            spacing: 8,
            range: 2 ... 99
        ) == 5)
        #expect(PKYMasonryPlacement.columns(
            width: 450,
            minimumColumnWidth: 135,
            spacing: 8,
            range: 2 ... 99
        ) == 3)
        #expect(PKYMasonryPlacement.columns(
            width: 200,
            minimumColumnWidth: 135,
            spacing: 8,
            range: 2 ... 99
        ) == 2)
        #expect(PKYMasonryPlacement.columns(
            width: 1350,
            minimumColumnWidth: 208,
            spacing: 8,
            range: 2 ... 4
        ) == 4)
        #expect(PKYMasonryPlacement.columns(
            width: 300,
            minimumColumnWidth: 0,
            spacing: 8,
            range: 2 ... 4
        ) == 2)
    }

    @Test("Negative masonry spacing overlaps items and still fits columns")
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
}
