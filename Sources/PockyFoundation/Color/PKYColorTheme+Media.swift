public extension PKYColorTheme {
    /// Placeholder, overlaid content, and scrim colors for photos and videos.
    ///
    /// Media itself does not change with interface appearance. Direct overlays use media-relative
    /// foregrounds; media controls with a solid surface use prominent fills and their paired foregrounds.
    struct Media: Sendable {
        /// An opaque background for unloaded media, preventing stacked or fading thumbnails from revealing content behind them.
        public let placeholder: PKYColor

        /// Text and symbols drawn directly on media without a separate solid surface.
        public let content: PKYColor

        /// A shadow that keeps media foregrounds readable on bright or complex imagery.
        public let contentShadow: PKYColor

        /// The base color for dimming media; components supply opacity or gradients.
        public let scrim: PKYColor

        /// A complete scrim including opacity, used to dim content behind a focused element.
        public let focusScrim: PKYColor

        /// Configures a complete media-relative palette.
        ///
        /// - Parameters:
        ///   - placeholder: An opaque background for unloaded media.
        ///   - content: Text and symbols directly over media.
        ///   - contentShadow: The shadow keeping media foregrounds readable.
        ///   - scrim: A dimming base whose opacity or gradient belongs to the component.
        ///   - focusScrim: A focus background scrim with opacity already included.
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
