public extension PKYColorTheme {
    /// Background levels for ordinary and grouped content, used by pages, containers, and cards.
    struct Background: Sendable {
        private let standardValues: Hierarchy
        private let groupedValues: Hierarchy

        /// Configures separate background hierarchies for ordinary and grouped interfaces.
        ///
        /// Keep both semantic mappings even when their colors match in an appearance.
        ///
        /// - Parameters:
        ///   - standard: Backgrounds for ordinary, ungrouped content.
        ///   - grouped: Backgrounds for grouped lists, forms, and similar content.
        public init(standard: Hierarchy, grouped: Hierarchy) {
            standardValues = standard
            groupedValues = grouped
        }

        /// Resolves an ordinary, ungrouped background.
        ///
        /// - Parameter level: The content's nesting level.
        /// - Returns: The dynamic color for that level.
        public func standard(_ level: Level) -> PKYColor {
            standardValues.resolve(level)
        }

        /// Resolves the background of a grouped list, form, or similar content.
        ///
        /// - Parameter level: The grouped content's nesting level.
        /// - Returns: The dynamic color for that level.
        public func grouped(_ level: Level) -> PKYColor {
            groupedValues.resolve(level)
        }
    }
}

public extension PKYColorTheme.Background {
    /// The nesting level within one background context.
    enum Level: Sendable {
        /// The bottommost background of the interface.
        case primary

        /// Grouped content within the primary background.
        case secondary

        /// Further grouping within secondary content.
        case tertiary
    }

    /// The three colors of a single background context.
    struct Hierarchy: Sendable {
        private let primary: PKYColor
        private let secondary: PKYColor
        private let tertiary: PKYColor

        /// Creates a complete hierarchy of nested backgrounds.
        ///
        /// - Parameters:
        ///   - primary: The background of the interface.
        ///   - secondary: Content groups within the primary background.
        ///   - tertiary: Content groups within secondary content.
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
