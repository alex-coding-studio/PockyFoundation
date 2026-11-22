public extension PKYColorTheme {
    struct Media: Sendable {
        public let placeholder: PKYColor

        public let content: PKYColor

        public let contentShadow: PKYColor

        public let scrim: PKYColor

        public let focusScrim: PKYColor

        public init(
            placeholder: PKYColor,
            content: PKYColor,
            contentShadow: PKYColor,
            scrim: PKYColor,
            focusScrim: PKYColor
        ) {
            self.placeholder = placeholder
            self.content = content
            self.contentShadow = contentShadow
            self.scrim = scrim
            self.focusScrim = focusScrim
        }
    }
}
