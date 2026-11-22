public extension PKYColorTheme {
    struct Separator: Sendable {
        private let standard: PKYColor
        private let opaque: PKYColor

        public init(standard: PKYColor, opaque: PKYColor) {
            self.standard = standard
            self.opaque = opaque
        }

        func resolve(_ style: Style) -> PKYColor {
            switch style {
            case .standard: standard
            case .opaque: opaque
            }
        }
    }
}

public extension PKYColorTheme.Separator {
    enum Style: Sendable {
        case standard

        case opaque
    }
}
