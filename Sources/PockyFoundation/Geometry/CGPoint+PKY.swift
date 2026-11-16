import CoreGraphics

public extension CGPoint {
    /// Adds coordinates or dimensions component by component.
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Subtracts coordinates or dimensions, preserving negative results.
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// Scales both coordinates or dimensions without rounding.
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    /// Scales both coordinates or dimensions without rounding.
    static func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        rhs * lhs
    }

    /// Divides both coordinates or dimensions, preserving floating-point division by zero.
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}
