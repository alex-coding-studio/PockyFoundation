import CoreGraphics

public extension PKYLayout {
    enum Size {
        public static let auxiliaryButton: CGFloat = 32

        public static func button(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: 36
            case .standard: 44
            case .wide: 52
            }
        }

        public static func dot(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: 6
            case .standard: 7
            case .wide: 8
            }
        }

        public static func row(_ variant: Variant = .standard) -> CGFloat {
            switch variant {
            case .compact: 44
            case .standard: 52
            case .wide: 64
            }
        }
    }
}
