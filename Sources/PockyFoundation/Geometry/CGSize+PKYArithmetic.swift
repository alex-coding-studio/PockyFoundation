import CoreGraphics

public extension CGSize {
    static func pkySquare(_ side: CGFloat) -> CGSize {
        CGSize(width: side, height: side)
    }

    var pkyArea: CGFloat {
        width * height
    }

    var pkyHasArea: Bool {
        width > 0 && height > 0
    }

    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    static func * (lhs: CGFloat, rhs: CGSize) -> CGSize {
        rhs * lhs
    }

    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}
