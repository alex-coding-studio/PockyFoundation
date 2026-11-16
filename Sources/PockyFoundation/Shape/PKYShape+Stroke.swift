import CoreGraphics

public extension PKYShape {
    /// Stroke widths for boundaries, emphasis, and display graphics.
    enum Stroke {
        /// An ordinary boundary.
        public static let standard: CGFloat = 0.5
        /// An emphasized boundary, such as selection.
        public static let strong: CGFloat = 2
        /// A substantial custom graphic stroke.
        public static let heavy: CGFloat = 3
        /// A large display graphic, such as a full-page progress ring.
        public static let display: CGFloat = 12
    }
}
