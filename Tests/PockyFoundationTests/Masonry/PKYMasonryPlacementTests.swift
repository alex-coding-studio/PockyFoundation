import CoreGraphics
import PockyFoundation
import Testing

struct PKYMasonryPlacementTests {
    @Test("Masonry placement preserves shortest-column and adaptive-column behavior")
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

    @Test("Masonry placement preserves shortest-column and adaptive-column behavior")
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
}
