import CoreGraphics

/// Directional padding independent of AppKit and UIKit; callers resolve layout direction.
public struct PKYEdgeInsets: Equatable, Sendable {
    /// Padding without any inset.
    public static let zero = PKYEdgeInsets()

    /// Padding before the top edge.
    public var top: CGFloat
    /// Padding before the leading edge in the caller's layout direction.
    public var leading: CGFloat
    /// Padding after the bottom edge.
    public var bottom: CGFloat
    /// Padding after the trailing edge in the caller's layout direction.
    public var trailing: CGFloat

    /// Creates directional padding; negative values represent outsets.
    public init(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
}
