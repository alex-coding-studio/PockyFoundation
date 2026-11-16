/// Maps app-supplied dynamic colors to a complete set of semantic roles for components.
///
/// Each role remains independent even when colors match. The theme implementation owns appearance
/// variants and asset names.
public struct PKYColorTheme: Sendable {
    /// Three nested background levels for ordinary and grouped content.
    public let background: Background

    /// Quiet translucent control fills and prominent solid fills with paired foregrounds.
    public let filled: Filled

    /// The foreground paired with the solid primary brand surface.
    public let onAccent: PKYColor

    /// A high-contrast solid surface independent of theme tint, such as a black capsule; pair with ``onInverse``.
    public let inverse: PKYColor

    /// Text and symbols on the ``inverse`` surface.
    public let onInverse: PKYColor

    /// Media-relative colors for placeholders, direct overlays, and scrims.
    public let media: Media

    /// The shadow color for app-owned surfaces, supplied explicitly to elevation adapters.
    ///
    /// May follow theme tint; elevation never reads a theme automatically.
    public let shadow: PKYColor

    private let contentValues: Content
    private let separatorValues: Separator
    private let accentValues: Accent
    private let statusValues: Status

    /// Creates a complete theme from semantic color families.
    ///
    /// - Parameters:
    ///   - background: Page and container backgrounds for ordinary and grouped contexts.
    ///   - content: Text and symbols on ordinary backgrounds and quiet fills.
    ///   - filled: Quiet and prominent fills with paired foregrounds.
    ///   - separator: Ordinary and opaque separators.
    ///   - accent: App brand accents and their paired foreground.
    ///   - status: Destructive, warning, and success colors and foregrounds, independent of branding.
    ///   - media: Colors relative to media rather than interface appearance.
    ///   - shadow: The shadow color supplied to elevation adapters.
    ///   - inverse: A theme-independent high-contrast fill with at least 7:1 contrast against `onInverse`.
    ///   - onInverse: Text and symbols on the inverse fill.
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

    /// Resolves ordinary text and symbols by purpose and importance.
    ///
    /// Use on ordinary backgrounds or quiet fills. Prominent, solid accent, and status fills each
    /// have their own paired foregrounds.
    ///
    /// - Parameter role: Information importance or input placeholder purpose.
    /// - Returns: The role's dynamic foreground color.
    public func content(_ role: Content.Role) -> PKYColor {
        contentValues.resolve(role)
    }

    /// Resolves a separator by whether underlying content may show through.
    ///
    /// - Parameter style: Ordinary or opaque compositing.
    /// - Returns: The corresponding separator color.
    public func separator(_ style: Separator.Style) -> PKYColor {
        separatorValues.resolve(style)
    }

    /// Resolves brand colors by emphasis; components own highlighted, selected, and disabled states.
    ///
    /// - Parameter level: Primary brand tint or a supporting brand surface.
    /// - Returns: The level's dynamic brand color.
    public func accent(_ level: Accent.Level) -> PKYColor {
        accentValues.resolve(level)
    }

    /// Resolves a status color for text, symbols, or solid fills.
    ///
    /// - Parameter role: Destructive, warning, or success.
    /// - Returns: The solid status color; pair with ``onStatus(_:)`` at the same role.
    public func status(_ role: Status.Role) -> PKYColor {
        statusValues.resolve(role)
    }

    /// Resolves a foreground for a solid status fill of the same role.
    ///
    /// - Parameter role: The role matching the status fill.
    /// - Returns: Text and symbols on that status fill.
    public func onStatus(_ role: Status.Role) -> PKYColor {
        statusValues.resolveContent(role)
    }
}
