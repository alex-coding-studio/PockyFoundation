public extension PKYTypographyTheme {
    /// Creates eight semantic roles using Apple system fonts and native text styles.
    ///
    /// - Parameter scaling: The shared Dynamic Type policy on iOS; ignored on macOS.
    /// - Returns: A complete typography theme for ``PKYTheme``.
    static func system(scaling: Scaling) -> PKYTypographyTheme {
        PKYTypographyTheme(family: .system, scaling: scaling)
    }
}
