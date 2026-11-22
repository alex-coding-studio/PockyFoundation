import CoreGraphics

public extension PKYLayout.Inset {
    static let row = Row()

    struct Row: Sendable {
        public func vertical(_ variant: PKYLayout.Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: PKYLayout.Space.s4
            case .standard: PKYLayout.Space.s8
            case .wide: PKYLayout.Space.s12
            }
        }

        public func horizontal(_ variant: PKYLayout.Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: PKYLayout.Space.s12
            case .standard: PKYLayout.Space.s16
            case .wide: PKYLayout.Space.s24
            }
        }
    }
}
