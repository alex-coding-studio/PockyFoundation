import CoreGraphics

public extension PKYShape {
    enum RadiusRole: Hashable, Sendable {
        case tile
        case compact
        case content
        case card
        case panel

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

    enum StrokeRole: Hashable, Sendable {
        case standard
        case strong
        case heavy

        public var value: CGFloat {
            switch self {
            case .standard: Stroke.standard
            case .strong: Stroke.strong
            case .heavy: Stroke.heavy
            }
        }
    }
}
