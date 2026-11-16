import CoreGraphics

public extension PKYLayout {
    /// Minimum visual sizes for app-owned content; native controls keep their system sizing.
    enum Size {
        /// Minimum visual height for a small auxiliary button.
        public static let auxiliaryButton: CGFloat = 32

        /// Returns the minimum visual height of an app-owned button.
        public static func button(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: 36
            case .standard: 44
            case .wide: 52
            }
        }

        /// Returns the diameter of a small status dot.
        public static func dot(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: 6
            case .standard: 7
            case .wide: 8
            }
        }

        /// Returns the minimum height of an app-owned content row.
        public static func row(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: 44
            case .standard: 52
            case .wide: 64
            }
        }
    }
}
