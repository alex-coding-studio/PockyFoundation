import CoreGraphics

public extension CGRect {
    /// Creates a zero-origin rectangle with the supplied size.
    static func pky(size: CGSize) -> CGRect {
        CGRect(origin: .zero, size: size)
    }

    /// Creates a rectangle centered on the supplied point without standardizing its size.
    static func pky(center: CGPoint, size: CGSize) -> CGRect {
        CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    /// The rectangle midpoint in its existing coordinate space.
    var pkyCenter: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    /// Returns area using native Core Graphics and floating-point semantics.
    var pkyArea: CGFloat {
        isEmpty ? 0 : width * height
    }
}
