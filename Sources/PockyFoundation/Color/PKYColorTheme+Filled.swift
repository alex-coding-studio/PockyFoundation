public extension PKYColorTheme {
    struct Filled: Sendable {
        private let quietValues: Quiet
        private let prominentValues: Prominent

        public init(quiet: Quiet, prominent: Prominent) {
            quietValues = quiet
            prominentValues = prominent
        }

        public func quiet(_ level: QuietLevel) -> PKYColor {
            quietValues.resolve(level)
        }

        public func prominent(_ level: ProminentLevel) -> PKYColor {
            prominentValues.resolveFill(level)
        }

        public func onProminent(_ level: ProminentLevel) -> PKYColor {
            prominentValues.resolveContent(level)
        }
    }
}

public extension PKYColorTheme.Filled {
    enum QuietLevel: Sendable {
        case primary

        case secondary

        case tertiary

        case quaternary
    }

    enum ProminentLevel: Sendable {
        case primary

        case secondary
    }

    struct Quiet: Sendable {
        private let primary: PKYColor
        private let secondary: PKYColor
        private let tertiary: PKYColor
        private let quaternary: PKYColor

        public init(
            primary: PKYColor,
            secondary: PKYColor,
            tertiary: PKYColor,
            quaternary: PKYColor
        ) {
            self.primary = primary
            self.secondary = secondary
            self.tertiary = tertiary
            self.quaternary = quaternary
        }

        func resolve(_ level: QuietLevel) -> PKYColor {
            switch level {
            case .primary: primary
            case .secondary: secondary
            case .tertiary: tertiary
            case .quaternary: quaternary
            }
        }
    }

    struct Prominent: Sendable {
        private let primary: PKYColor
        private let onPrimary: PKYColor
        private let secondary: PKYColor
        private let onSecondary: PKYColor

        public init(
            primary: PKYColor,
            onPrimary: PKYColor,
            secondary: PKYColor,
            onSecondary: PKYColor
        ) {
            self.primary = primary
            self.onPrimary = onPrimary
            self.secondary = secondary
            self.onSecondary = onSecondary
        }

        func resolveFill(_ level: ProminentLevel) -> PKYColor {
            switch level {
            case .primary: primary
            case .secondary: secondary
            }
        }

        func resolveContent(_ level: ProminentLevel) -> PKYColor {
            switch level {
            case .primary: onPrimary
            case .secondary: onSecondary
            }
        }
    }
}
