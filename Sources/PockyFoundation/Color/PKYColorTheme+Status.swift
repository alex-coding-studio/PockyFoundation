public extension PKYColorTheme {
    /// Destructive, warning, and success colors with stable meanings for text, symbols, or solid fills.
    ///
    /// Status meaning is independent of brand colors. Use `onStatus(_:)` at the same role for content
    /// on a solid status surface.
    struct Status: Sendable {
        private let destructive: PKYColor
        private let onDestructive: PKYColor
        private let warning: PKYColor
        private let onWarning: PKYColor
        private let success: PKYColor
        private let onSuccess: PKYColor

        /// Configures each status color and its paired foreground.
        ///
        /// - Parameters:
        ///   - destructive: The solid color for destructive actions.
        ///   - onDestructive: Text and symbols on a destructive fill.
        ///   - warning: The solid color for warnings.
        ///   - onWarning: Text and symbols on a warning fill.
        ///   - success: The solid color for successful or completed states.
        ///   - onSuccess: Text and symbols on a success fill.
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
    /// The meaning conveyed by a status color.
    enum Role: Sendable {
        /// A destructive action such as deletion or irreversible removal.
        case destructive

        /// A condition requiring attention before continuing, such as limited photo access.
        case warning

        /// A completed task or successful outcome.
        case success
    }
}
