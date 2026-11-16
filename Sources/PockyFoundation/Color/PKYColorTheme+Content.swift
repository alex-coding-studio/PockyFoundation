public extension PKYColorTheme {
    /// Foreground colors for text, symbols, and input placeholders on ordinary backgrounds or quiet fills.
    struct Content: Sendable {
        private let primary: PKYColor
        private let secondary: PKYColor
        private let tertiary: PKYColor
        private let quaternary: PKYColor
        private let placeholder: PKYColor

        /// Configures every ordinary foreground role.
        ///
        /// - Parameters:
        ///   - primary: Primary information.
        ///   - secondary: Supporting information.
        ///   - tertiary: Less prominent supplementary information.
        ///   - quaternary: The least prominent ordinary content.
        ///   - placeholder: Input placeholder text.
        public init(
            primary: PKYColor,
            secondary: PKYColor,
            tertiary: PKYColor,
            quaternary: PKYColor,
            placeholder: PKYColor
        ) {
            self.primary = primary
            self.secondary = secondary
            self.tertiary = tertiary
            self.quaternary = quaternary
            self.placeholder = placeholder
        }

        func resolve(_ role: Role) -> PKYColor {
            switch role {
            case .primary: primary
            case .secondary: secondary
            case .tertiary: tertiary
            case .quaternary: quaternary
            case .placeholder: placeholder
            }
        }
    }
}

public extension PKYColorTheme.Content {
    /// A foreground role selected by information importance or input purpose.
    enum Role: Sendable {
        /// The strongest emphasis for primary information and ordinary content.
        case primary

        /// Supporting information or subtitles.
        case secondary

        /// Supplementary information with less emphasis.
        case tertiary

        /// The least prominent ordinary content, such as watermarks.
        case quaternary

        /// Input placeholder text describing purpose rather than a fifth emphasis level.
        case placeholder
    }
}
