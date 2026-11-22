import CoreGraphics

public extension PKYLayout {
    enum Inset {
        public static func page(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s8
            case .standard: Space.s16
            case .wide: Space.s24
            }
        }

        public static func container(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s8
            case .standard: Space.s16
            case .wide: Space.s24
            }
        }
    }
}
