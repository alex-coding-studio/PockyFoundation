public extension PKYColorTheme {
    /// App identity colors for theme tint, primary actions, and secondary branded surfaces.
    ///
    /// Use the paired `onAccent` for content on a solid primary accent. Components own highlighting,
    /// disabled states, and opacity changes.
    struct Accent: Sendable {
        let onAccent: PKYColor

        private let primary: PKYColor
        private let secondary: PKYColor

        /// Provides a brand palette for the color theme to resolve by emphasis level.
        ///
        /// - Parameters:
        ///   - primary: The main brand color for tint and prominent fills.
        ///   - secondary: A brand surface with lower emphasis.
        ///   - onAccent: Text and symbols on the solid primary accent, with readable contrast.
        public init(primary: PKYColor, secondary: PKYColor, onAccent: PKYColor) {
            self.primary = primary
            self.secondary = secondary
            self.onAccent = onAccent
        }

        func resolve(_ level: Level) -> PKYColor {
            switch level {
            case .primary: primary
            case .secondary: secondary
            }
        }
    }
}

public extension PKYColorTheme.Accent {
    /// The two levels of brand emphasis.
    enum Level: Sendable {
        /// The main app tint, prominent actions, selection marks, and strong emphasis.
        case primary

        /// A supporting brand surface for secondary actions or selected content.
        case secondary
    }
}
