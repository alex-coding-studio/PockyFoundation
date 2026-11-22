import CoreGraphics

public extension PKYLayout {
    enum Gap {
        public static func content(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s4
            case .standard: Space.s8
            case .wide: Space.s12
            }
        }

        public static func group(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s12
            case .standard: Space.s16
            case .wide: Space.s24
            }
        }

        public static func section(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s16
            case .standard: Space.s24
            case .wide: Space.s32
            }
        }
    }
}
