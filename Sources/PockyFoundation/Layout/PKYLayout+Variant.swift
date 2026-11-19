public extension PKYLayout {
    /// Compact, standard, and wide variants of a semantic layout role.
    enum Variant: Sendable {
        /// A denser value for constrained space or secondary content.
        case compact

        /// The default value for ordinary content.
        case standard

        /// A roomier value for prominent content or wide regions.
        case wide
    }
}
