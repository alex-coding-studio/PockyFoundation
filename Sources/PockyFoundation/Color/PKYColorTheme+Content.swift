public extension PKYColorTheme {
    struct Content: Sendable {
        private let primary: PKYColor
        private let secondary: PKYColor
        private let tertiary: PKYColor
        private let quaternary: PKYColor
        private let placeholder: PKYColor

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
    enum Role: Sendable {
        case primary

        case secondary

        case tertiary

        case quaternary

        case placeholder
    }
}
