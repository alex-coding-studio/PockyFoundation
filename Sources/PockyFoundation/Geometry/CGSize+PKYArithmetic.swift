import CoreGraphics

public extension CGSize {
    /// Creates a square size without rounding or clamping the side length.
    static func pkySquare(_ side: CGFloat) -> CGSize {
        CGSize(width: side, height: side)
    }

    /// Returns area using native Core Graphics and floating-point semantics.
    var pkyArea: CGFloat {
        width * height
    }

    /// Whether both dimensions are positive; zero, negative, and NaN dimensions fail.
    var pkyHasArea: Bool {
        width > 0 && height > 0
    }

    /// Adds coordinates or dimensions component by component.
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    /// Subtracts coordinates or dimensions, preserving negative results.
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    /// Scales both coordinates or dimensions without rounding.
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    /// Scales both coordinates or dimensions without rounding.
    static func * (lhs: CGFloat, rhs: CGSize) -> CGSize {
        rhs * lhs
    }

    /// Divides both coordinates or dimensions, preserving floating-point division by zero.
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}
