import CoreGraphics
import PockyFoundation
import Testing

struct PKYPointTests {
    @Test("Core Graphics arithmetic preserves native semantics")
    func pointArithmeticPreservesCoordinates() {
        let point = CGPoint(x: 11, y: -7)
        let offset = CGPoint(x: -3, y: 2)
        #expect(point + offset == CGPoint(x: 8, y: -5))
        #expect(point - offset == CGPoint(x: 14, y: -9))
        #expect(point + .zero == point)
    }

    @Test("Core Graphics arithmetic preserves native semantics")
    func scalarArithmeticPreservesFractions() {
        let point = CGPoint(x: 11, y: -7)
        #expect(point * CGFloat(-0.5) == CGPoint(x: -5.5, y: 3.5))
        #expect(CGFloat(-0.5) * point == point * CGFloat(-0.5))
        #expect(point / CGFloat(2) == CGPoint(x: 5.5, y: -3.5))
        #expect(point * CGFloat(0) == .zero)
    }

    @Test("Core Graphics arithmetic preserves native semantics")
    func divisionByZeroPreservesFloatingPointBehavior() {
        let result = CGPoint(x: 3, y: 0) / CGFloat(0)
        #expect(result.x.isInfinite)
        #expect(result.y.isNaN)
    }
}
