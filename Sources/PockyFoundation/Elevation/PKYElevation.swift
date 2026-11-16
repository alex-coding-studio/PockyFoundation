import CoreGraphics

/// Shadow styles expressed as surface relationships, without owning colors or appearance observation.
public enum PKYElevation {
    /// The caller's resolved appearance; reapply after effective appearance changes.
    public enum Appearance: Sendable {
        /// A light interface.
        case light
        /// A dark interface.
        case dark
    }

    /// A semantic shadow relationship. Recipes depend on appearance, not platform.
    public enum Style: Sendable {
        /// No separation shadow.
        case none
        /// Slight separation near a container, with a stronger dark recipe.
        case subtle
        /// A small inset selection indicator; dark indicators have no shadow.
        case insetIndicator
        /// Detached overlays, floating controls, and previews.
        case floating
        /// A tight legibility shadow for a glyph directly on media.
        case mediaContent
        /// A soft halo for a group of content directly on media.
        case mediaHalo

        /// The light-appearance recipe, with positive y meaning visually downward.
        public var recipe: Recipe {
            recipe(for: .light)
        }

        /// Resolves numeric shadow properties; color remains a separate caller-owned value.
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

    /// Immutable shadow numbers; offset y is positive visually downward, before layer conversion.
    public struct Recipe: Sendable {
        /// Shadow opacity, independent of the supplied color's alpha.
        public let opacity: Double
        /// Shadow blur radius in points.
        public let radius: CGFloat
        /// Offset in a visual, downward-positive coordinate space.
        public let offset: CGSize
    }
}
