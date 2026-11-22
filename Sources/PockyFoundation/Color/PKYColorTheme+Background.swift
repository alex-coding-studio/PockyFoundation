public extension PKYColorTheme {
    struct Background: Sendable {
        private let standardValues: Hierarchy
        private let groupedValues: Hierarchy

        public init(standard: Hierarchy, grouped: Hierarchy) {
            standardValues = standard
            groupedValues = grouped
        }

        public func standard(_ level: Level) -> PKYColor {
            standardValues.resolve(level)
        }

        public func grouped(_ level: Level) -> PKYColor {
            groupedValues.resolve(level)
        }
    }
}

public extension PKYColorTheme.Background {
    enum Level: Sendable {
        case primary

        case secondary

        case tertiary
    }

    struct Hierarchy: Sendable {
        private let primary: PKYColor
        private let secondary: PKYColor
        private let tertiary: PKYColor

        public init(primary: PKYColor, secondary: PKYColor, tertiary: PKYColor) {
            self.primary = primary
            self.secondary = secondary
            self.tertiary = tertiary
        }

        func resolve(_ level: Level) -> PKYColor {
            switch level {
            case .primary: primary
            case .secondary: secondary
            case .tertiary: tertiary
            }
        }
    }
}
