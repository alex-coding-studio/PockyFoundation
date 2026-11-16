import CoreGraphics

public extension PKYShape {
    /// Corner radii for app-owned surfaces, shared by every platform.
    enum Radius {
        /// A small thumbnail or option tile.
        public static let tile: CGFloat = 10
        /// A compact control or thumbnail surface.
        public static let compact: CGFloat = 14
        /// Ordinary content and nested panels.
        public static let content: CGFloat = 16
        /// A prominent card or major content surface.
        public static let card: CGFloat = 22
        /// A large detached custom panel; system presentations retain system corners.
        public static let panel: CGFloat = 30
    }
}
