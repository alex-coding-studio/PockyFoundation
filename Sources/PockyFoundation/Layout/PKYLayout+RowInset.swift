import CoreGraphics

public extension PKYLayout.Inset {
    /// Vertical and horizontal padding for content within rows.
    static let row = Row()

    /// Padding for content within rows.
    struct Row: Sendable {
        /// Returns vertical padding for the selected variant.
        public func vertical(_ variant: PKYLayout.Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: PKYLayout.Space.s4
            case .standard: PKYLayout.Space.s8
            case .wide: PKYLayout.Space.s12
            }
        }

        /// Returns horizontal padding for the selected variant.
        public func horizontal(_ variant: PKYLayout.Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: PKYLayout.Space.s12
            case .standard: PKYLayout.Space.s16
            case .wide: PKYLayout.Space.s24
            }
        }
    }
}
