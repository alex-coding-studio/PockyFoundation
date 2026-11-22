public struct PKYColorTheme: Sendable {
    public let background: Background

    public let filled: Filled

    public let onAccent: PKYColor

    public let inverse: PKYColor

    public let onInverse: PKYColor

    public let media: Media

    public let shadow: PKYColor

    private let contentValues: Content
    private let separatorValues: Separator
    private let accentValues: Accent
    private let statusValues: Status

    public init(
        background: Background,
        content: Content,
        filled: Filled,
        separator: Separator,
        accent: Accent,
        status: Status,
        media: Media,
        shadow: PKYColor,
        inverse: PKYColor = PKYStandardInverse.inverse,
        onInverse: PKYColor = PKYStandardInverse.onInverse
    ) {
        self.background = background
        self.filled = filled
        onAccent = accent.onAccent
        self.media = media
        self.shadow = shadow
        self.inverse = inverse
        self.onInverse = onInverse
        statusValues = status
        contentValues = content
        separatorValues = separator
        accentValues = accent
    }

    public func content(_ role: Content.Role) -> PKYColor {
        contentValues.resolve(role)
    }

    public func separator(_ style: Separator.Style) -> PKYColor {
        separatorValues.resolve(style)
    }

    public func accent(_ level: Accent.Level) -> PKYColor {
        accentValues.resolve(level)
    }

    public func status(_ role: Status.Role) -> PKYColor {
        statusValues.resolve(role)
    }

    public func onStatus(_ role: Status.Role) -> PKYColor {
        statusValues.resolveContent(role)
    }
}
