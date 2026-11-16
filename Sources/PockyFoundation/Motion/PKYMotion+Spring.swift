import CoreGraphics

public extension PKYMotion {
    /// A spring role exposing native bounce and damping-ratio representations.
    struct Spring: Sendable {
        /// A spring without bounce.
        public static let smooth = Spring(bounce: 0)

        /// A spring with restrained bounce for responsive feedback.
        public static let snappy = Spring(bounce: 0.15)

        /// A spring with visible bounce for expressive changes.
        public static let bouncy = Spring(bounce: 0.3)

        /// The most expressive bounce role, for brief emphasis.
        public static let pop = Spring(bounce: 0.45)

        /// The native spring bounce amount.
        public let bounce: CGFloat

        /// The damping ratio corresponding to the role, for native timing APIs.
        public var dampingRatio: CGFloat {
            1 - bounce
        }

        private init(bounce: CGFloat) {
            self.bounce = bounce
        }
    }
}
