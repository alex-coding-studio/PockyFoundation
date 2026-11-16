/// An immutable product theme combining color and typography.
///
/// Apps construct a complete theme; components read the semantic roles they need from that value.
public struct PKYTheme: Sendable {
    /// The theme's semantic color palette.
    public let color: PKYColorTheme

    /// The theme's typography roles and shared scaling policy.
    public let typography: PKYTypographyTheme

    /// Combines complete color and typography palettes.
    ///
    /// - Parameters:
    ///   - color: The product's semantic color mapping.
    ///   - typography: The product's typography roles and scaling policy.
    public init(color: PKYColorTheme, typography: PKYTypographyTheme) {
        self.color = color
        self.typography = typography
    }
}
