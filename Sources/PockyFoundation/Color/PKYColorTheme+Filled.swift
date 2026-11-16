public extension PKYColorTheme {
    /// Neutral fills for controls and small elements, grouped into quiet translucent and prominent solid surfaces.
    ///
    /// Use Background for pages and containers, and Accent for brand emphasis. Quiet fills use ordinary
    /// Content; prominent fills require their matching on-prominent foreground.
    struct Filled: Sendable {
        private let quietValues: Quiet
        private let prominentValues: Prominent

        /// Combines quiet and prominent fill palettes.
        ///
        /// - Parameters:
        ///   - quiet: Four levels of translucent control backgrounds.
        ///   - prominent: Two solid neutral fills and their paired foregrounds.
        public init(quiet: Quiet, prominent: Prominent) {
            quietValues = quiet
            prominentValues = prominent
        }

        /// Resolves a quiet control background by shape size; pair it with ordinary Content.
        ///
        /// - Parameter level: The level matching the filled shape.
        /// - Returns: A translucent dynamic fill color.
        public func quiet(_ level: QuietLevel) -> PKYColor {
            quietValues.resolve(level)
        }

        /// Resolves a prominent neutral fill; pair it with ``onProminent(_:)`` at the same level.
        ///
        /// - Parameter level: The required emphasis.
        /// - Returns: An opaque neutral fill color.
        public func prominent(_ level: ProminentLevel) -> PKYColor {
            prominentValues.resolveFill(level)
        }

        /// Resolves text and symbols on a prominent fill of the same level.
        ///
        /// - Parameter level: The level matching the fill.
        /// - Returns: The foreground paired with that solid fill.
        public func onProminent(_ level: ProminentLevel) -> PKYColor {
            prominentValues.resolveContent(level)
        }
    }
}

public extension PKYColorTheme.Filled {
    /// A quiet fill level selected by shape size, following system fill semantics.
    enum QuietLevel: Sendable {
        /// Small shapes such as slider tracks.
        case primary

        /// Medium shapes such as switch backgrounds.
        case secondary

        /// Larger shapes such as fields, search bars, buttons, and selected or pressed states.
        case tertiary

        /// The faintest fill for large areas containing complex content.
        case quaternary
    }

    /// A shared level for prominent solid fills and their paired foregrounds.
    enum ProminentLevel: Sendable {
        /// The strongest neutral fill for primary neutral buttons, media badges, or strong selection marks.
        case primary

        /// A supporting fill for marks or toggle states that should not become the primary action.
        case secondary
    }

    /// Translucent control backgrounds that adapt to their surface, like system fills.
    ///
    /// Use ordinary Content for the foreground; quiet fills have no separate foreground roles.
    struct Quiet: Sendable {
        private let primary: PKYColor
        private let secondary: PKYColor
        private let tertiary: PKYColor
        private let quaternary: PKYColor

        /// Configures four levels of quiet dynamic fill.
        ///
        /// - Parameters:
        ///   - primary: Translucent fill for small shapes.
        ///   - secondary: Translucent fill for medium shapes.
        ///   - tertiary: Translucent fill for larger shapes.
        ///   - quaternary: Faint fill for large areas containing complex content.
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

    /// Solid neutral fills with explicit contrast and a paired foreground at each level.
    ///
    /// Use Accent when brand emphasis is needed.
    struct Prominent: Sendable {
        private let primary: PKYColor
        private let onPrimary: PKYColor
        private let secondary: PKYColor
        private let onSecondary: PKYColor

        /// Configures two prominent fills and their paired foregrounds.
        ///
        /// - Parameters:
        ///   - primary: The strongest solid neutral fill.
        ///   - onPrimary: Text and symbols on the primary fill, with at least 4.5:1 contrast.
        ///   - secondary: A solid neutral fill with lower emphasis.
        ///   - onSecondary: Text and symbols on the secondary fill, with at least 4.5:1 contrast.
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
