import CoreGraphics

public extension CGAffineTransform {
    /// Creates a uniform scale, preserving zero and negative factors.
    static func pkyScale(_ scale: CGFloat) -> CGAffineTransform {
        CGAffineTransform(scaleX: scale, y: scale)
    }

    /// Composes a uniform scale using the native scaledBy order, preserving translation.
    func pkyScaled(by scale: CGFloat) -> CGAffineTransform {
        scaledBy(x: scale, y: scale)
    }
}
