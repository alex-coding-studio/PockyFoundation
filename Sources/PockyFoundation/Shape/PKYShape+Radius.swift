import CoreGraphics

public extension PKYShape {
    /// Corner radii for app-owned surfaces, with compact desktop values.
    enum Radius {
        #if os(macOS)
            /// A small thumbnail or option tile.
            public static let tile: CGFloat = 4
            /// A compact control or thumbnail surface.
            public static let compact: CGFloat = 6
            /// Nested content inside a card.
            public static let content: CGFloat = 4
            /// A card floating within a content region.
            public static let card: CGFloat = 6
        #else
            /// A small thumbnail or option tile.
            public static let tile: CGFloat = 10
            /// A compact control or thumbnail surface.
            public static let compact: CGFloat = 14
            /// Ordinary content and nested panels.
            public static let content: CGFloat = 16
            /// A prominent card or major content surface.
            public static let card: CGFloat = 22
        #endif
        /// A large detached custom panel; system presentations retain system corners.
        public static let panel: CGFloat = 30
    }
}
