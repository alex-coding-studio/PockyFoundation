import CoreGraphics
import PockyFoundation
import Testing

struct PKYAffineTransformTests {
    @Test(
        "Uniform scale transforms keep zero and negative factors",
        arguments: [CGFloat(1.5), -2, 0]
    )
    func uniformScalePreservesFactor(_ scale: CGFloat) {
        let point = CGPoint(x: 3, y: -5)
        #expect(point.applying(.pkyScale(scale)) == CGPoint(x: 3 * scale, y: -5 * scale))
    }

    @Test("Uniform scaling composes in native scaledBy order and keeps translation")
    func concatenationPreservesNativeOrder() {
        let transform = CGAffineTransform(translationX: 13, y: -7).rotated(by: 0.3)
        let scaled = transform.pkyScaled(by: -1.5)
        #expect(scaled == transform.scaledBy(x: -1.5, y: -1.5))
        #expect(scaled.tx == 13)
        #expect(scaled.ty == -7)
    }
}
