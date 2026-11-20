import CoreGraphics
import PockyFoundation
import Testing

struct PKYRectTests {
    @Test("Zero-origin rectangles keep the supplied size")
    func zeroOriginPreservesSize() {
        let size = CGSize(width: 37.5, height: 21)
        #expect(CGRect.pky(size: size) == CGRect(origin: .zero, size: size))
        #expect(CGRect.pky(size: .zero) == .zero)
    }

    @Test("Centered rectangles keep their center and size")
    func centeredRectPreservesCenterAndSize() {
        let rect = CGRect.pky(center: CGPoint(x: -11, y: 25), size: CGSize(width: 37.5, height: 12))
        #expect(rect.origin == CGPoint(x: -29.75, y: 19))
        #expect(rect.size == CGSize(width: 37.5, height: 12))
        #expect(rect.pkyCenter == CGPoint(x: -11, y: 25))
        #expect(CGRect.pky(center: CGPoint(
            x: 7,
            y: -3
        ), size: .zero).pkyCenter == CGPoint(x: 7, y: -3))
    }

    @Test("Rectangle centers use native midpoints for negative sizes")
    func centerUsesNativeMidpoints() {
        let rect = CGRect(x: 20, y: -8, width: -12, height: 6)
        #expect(rect.pkyCenter == CGPoint(x: rect.midX, y: rect.midY))
    }

    @Test("Rectangle area is zero when empty and follows native standardized dimensions")
    func emptyRectAreaIsZero() {
        #expect(CGRect(x: 0, y: 0, width: 0, height: CGFloat.infinity).pkyArea == 0)
        #expect(CGRect.null.pkyArea == 0)
        #expect(CGRect(x: 4, y: 4, width: -3, height: 2).pkyArea == 6)
    }
}
