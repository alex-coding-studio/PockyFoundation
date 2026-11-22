import CoreGraphics

public extension CGRect {
    static func pky(size: CGSize) -> CGRect {
        CGRect(origin: .zero, size: size)
    }

    static func pky(center: CGPoint, size: CGSize) -> CGRect {
        CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    var pkyCenter: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    var pkyArea: CGFloat {
        isEmpty ? 0 : width * height
    }
}
