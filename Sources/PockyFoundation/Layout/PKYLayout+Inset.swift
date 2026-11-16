import CoreGraphics

public extension PKYLayout {
    /// Padding within pages, containers, controls, and rows.
    enum Inset {
        /// Returns page padding for the selected variant.
        public static func page(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s8
            case .standard: Space.s16
            case .wide: Space.s24
            }
        }

        /// Returns content-container padding for the selected variant.
        public static func container(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: Space.s8
            case .standard: Space.s16
            case .wide: Space.s24
            }
        }
    }
}
