public extension PKYColorTheme {
    /// Separator colors distinguished by whether underlying content may show through.
    struct Separator: Sendable {
        private let standard: PKYColor
        private let opaque: PKYColor

        /// Configures ordinary and opaque separator colors.
        ///
        /// - Parameters:
        ///   - standard: An ordinary separator that allows underlying content to show through.
        ///   - opaque: A solid separator that obscures underlying content.
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
    /// The separator's compositing behavior.
    enum Style: Sendable {
        /// An ordinary separator that lets some underlying content show through.
        case standard

        /// A solid separator that fully obscures underlying content.
        case opaque
    }
}
