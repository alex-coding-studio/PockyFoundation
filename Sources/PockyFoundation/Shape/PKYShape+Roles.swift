import CoreGraphics

public extension PKYShape {
    /// A storable semantic corner role for component styles.
    enum RadiusRole: Hashable, Sendable {
        /// A small thumbnail or option surface.
        case tile
        /// A compact control or thumbnail surface.
        case compact
        /// Nested content within a larger surface.
        case content
        /// An app-owned content card.
        case card
        /// A detached custom panel.
        case panel

        /// Resolves the role to the current platform value.
        public var value: CGFloat {
            switch self {
            case .tile: Radius.tile
            case .compact: Radius.compact
            case .content: Radius.content
            case .card: Radius.card
            case .panel: Radius.panel
            }
        }
    }

    /// A storable semantic boundary role for component styles.
    ///
    /// ``PKYShape/Stroke/display`` sizes display graphics rather than boundaries, so it has no role.
    enum StrokeRole: Hashable, Sendable {
        /// An ordinary boundary.
        case standard
        /// An emphasized boundary, such as selection.
        case strong
        /// A substantial custom graphic stroke.
        case heavy

        /// Resolves the role to the current platform value.
        public var value: CGFloat {
            switch self {
            case .standard: Stroke.standard
            case .strong: Stroke.strong
            case .heavy: Stroke.heavy
            }
        }
    }
}
