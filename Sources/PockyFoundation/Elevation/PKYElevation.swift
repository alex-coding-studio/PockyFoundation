import CoreGraphics

public enum PKYElevation {
    public enum Appearance: Sendable {
        case light
        case dark
    }

    public enum Style: Sendable {
        case none
        case subtle
        case insetIndicator
        case floating
        case mediaContent
        case mediaHalo

        public var recipe: Recipe {
            recipe(for: .light)
        }

        public func recipe(for appearance: Appearance) -> Recipe {
            switch self {
            case .none:
                Recipe(opacity: 0, radius: 0, offset: .zero)
            case .subtle:
                Recipe(
                    opacity: appearance == .dark ? 0.35 : 0.12,
                    radius: 3,
                    offset: CGSize(width: 0, height: 1)
                )
            case .insetIndicator:
                Recipe(
                    opacity: appearance == .dark ? 0 : 0.08,
                    radius: appearance == .dark ? 0 : 2,
                    offset: .zero
                )
            case .floating:
                Recipe(opacity: 0.16, radius: 18, offset: CGSize(width: 0, height: 8))
            case .mediaContent:
                Recipe(opacity: 0.45, radius: 1, offset: CGSize(width: 0, height: 1))
            case .mediaHalo:
                Recipe(opacity: 0.25, radius: 12, offset: CGSize(width: 0, height: 2))
            }
        }
    }

    public struct Recipe: Equatable, Sendable {
        public let opacity: Double
        public let radius: CGFloat
        public let offset: CGSize
    }
}
