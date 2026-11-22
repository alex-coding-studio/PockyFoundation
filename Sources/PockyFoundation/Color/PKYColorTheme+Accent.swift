public extension PKYColorTheme {
    struct Accent: Sendable {
        let onAccent: PKYColor

        private let primary: PKYColor
        private let secondary: PKYColor

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
    enum Level: Sendable {
        case primary

        case secondary
    }
}
