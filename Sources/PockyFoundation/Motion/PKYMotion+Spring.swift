import CoreGraphics

public extension PKYMotion {
    struct Spring: Hashable, Sendable {
        public static let smooth = Spring(bounce: 0)

        public static let snappy = Spring(bounce: 0.15)

        public static let bouncy = Spring(bounce: 0.3)

        public static let pop = Spring(bounce: 0.45)

        public let bounce: CGFloat

        public var dampingRatio: CGFloat {
            1 - bounce
        }

        private init(bounce: CGFloat) {
            self.bounce = bounce
        }
    }
}
