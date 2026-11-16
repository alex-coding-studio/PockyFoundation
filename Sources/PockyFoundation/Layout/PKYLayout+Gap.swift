import CoreGraphics

public extension PKYLayout {
    /// Distances between related content, groups, and page sections.
    enum Gap {
        /// Returns spacing between closely related content.
        public static func content(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s4
            case .standard: Space.s8
            case .wide: Space.s12
            }
        }

        /// Returns spacing between content groups.
        public static func group(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s12
            case .standard: Space.s16
            case .wide: Space.s24
            }
        }

        /// Returns spacing between page sections.
        public static func section(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s16
            case .standard: Space.s24
            case .wide: Space.s32
            }
        }
    }
}
