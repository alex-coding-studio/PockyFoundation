import CoreGraphics
import PockyFoundation
import Testing

struct CGSizeArithmeticTests {
    @Test("Core Graphics arithmetic preserves native semantics", arguments: [CGFloat(0), 12.5, 44])
    func squareConstruction(side: CGFloat) {
        #expect(CGSize.pkySquare(side) == CGSize(width: side, height: side))
    }

    @Test(
        "只有宽高都大于零才算有面积",
        arguments: [
            (CGSize(width: 0.5, height: 44), true),
            (CGSize(width: 0, height: 44), false),
            (CGSize(width: 44, height: 0), false),
            (CGSize(width: -1, height: 44), false),
            (CGSize(width: 44, height: CGFloat.nan), false),
        ]
    )
    func hasAreaRequiresBothDimensionsPositive(size: CGSize, expected: Bool) {
        #expect(size.pkyHasArea == expected)
    }

    @Test("Core Graphics arithmetic preserves native semantics")
    func componentwiseAdditionAndSubtraction() {
        let content = CGSize(width: 120.5, height: 80)
        let padding = CGSize(width: 24, height: 16.5)

        #expect(content + padding == CGSize(width: 144.5, height: 96.5))
        #expect(content - padding == CGSize(width: 96.5, height: 63.5))
        #expect(padding - content == CGSize(width: -96.5, height: -63.5))
    }

    @Test("Core Graphics arithmetic preserves native semantics", arguments: [CGFloat(0.5), 2, -2])
    func scalarMultiplicationAndDivision(factor: CGFloat) {
        let size = CGSize(width: 120.5, height: 80)
        let scaled = size * factor

        #expect(scaled.width == size.width * factor)
        #expect(scaled.height == size.height * factor)
        #expect(factor * size == scaled)
        #expect(scaled / factor == size)
        #expect(size * 0 == .zero)
    }

    @Test("Core Graphics arithmetic preserves native semantics")
    func divisionPreservesFloatingPointBehavior() {
        let result = CGSize(width: 10, height: 0) / CGFloat(0)

        #expect(result.width == .infinity)
        #expect(result.height.isNaN)
    }
}
