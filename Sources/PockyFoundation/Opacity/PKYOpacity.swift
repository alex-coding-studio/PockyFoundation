import CoreGraphics

/// Opacity roles for tinting, dimming, and glass overlays; colors remain caller-owned.
public enum PKYOpacity {
    /// A translucent tint over existing content.
    public static let tint: CGFloat = 0.16

    /// A complete scrim behind focused content, shared by both platforms.
    public static let focusScrim: CGFloat = 0.28

    /// Reduced emphasis while content remains recognizable.
    public static let dimmed: CGFloat = 0.5

    /// A tint for caller-owned glass presentations.
    public static let glassTint: CGFloat = 0.85
}
