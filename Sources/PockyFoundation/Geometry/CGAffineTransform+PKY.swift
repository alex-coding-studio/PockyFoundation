import CoreGraphics

public extension CGAffineTransform {
    static func pkyScale(_ scale: CGFloat) -> CGAffineTransform {
        CGAffineTransform(scaleX: scale, y: scale)
    }

    func pkyScaled(by scale: CGFloat) -> CGAffineTransform {
        scaledBy(x: scale, y: scale)
    }
}
