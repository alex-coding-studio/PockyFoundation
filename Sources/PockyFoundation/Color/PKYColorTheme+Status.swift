public extension PKYColorTheme {
    struct Status: Sendable {
        private let destructive: PKYColor
        private let onDestructive: PKYColor
        private let warning: PKYColor
        private let onWarning: PKYColor
        private let success: PKYColor
        private let onSuccess: PKYColor

        public init(
            destructive: PKYColor,
            onDestructive: PKYColor,
            warning: PKYColor,
            onWarning: PKYColor,
            success: PKYColor,
            onSuccess: PKYColor
        ) {
            self.destructive = destructive
            self.onDestructive = onDestructive
            self.warning = warning
            self.onWarning = onWarning
            self.success = success
            self.onSuccess = onSuccess
        }

        func resolve(_ role: Role) -> PKYColor {
            switch role {
            case .destructive: destructive
            case .warning: warning
            case .success: success
            }
        }

        func resolveContent(_ role: Role) -> PKYColor {
            switch role {
            case .destructive: onDestructive
            case .warning: onWarning
            case .success: onSuccess
            }
        }
    }
}

public extension PKYColorTheme.Status {
    enum Role: Sendable {
        case destructive

        case warning

        case success
    }
}
