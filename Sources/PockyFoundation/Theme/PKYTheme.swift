public struct PKYTheme: Sendable {
    public let color: PKYColorTheme

    public let typography: PKYTypographyTheme

    public init(color: PKYColorTheme, typography: PKYTypographyTheme) {
        self.color = color
        self.typography = typography
    }
}
