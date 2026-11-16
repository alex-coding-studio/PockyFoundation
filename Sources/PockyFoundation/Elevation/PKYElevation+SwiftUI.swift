#if os(iOS)
    import SwiftUI

    public extension View {
        /// Applies a shared elevation shadow to a SwiftUI view, resolving dynamic colors against
        /// the environment.
        ///
        /// Preserves layout size and shape; clipping and state behavior remain component-owned.
        ///
        /// - Parameters:
        ///   - style: The shadow role chosen for the surface relationship or media legibility.
        ///   - color: The shadow color provided by the theme or component.
        /// - Returns: A view with the specified elevation shadow.
        func pkyElevation(_ style: PKYElevation.Style, color: Color) -> some View {
            let recipe = style.recipe
            return shadow(
                color: color.opacity(recipe.opacity),
                radius: recipe.radius,
                x: recipe.offset.width,
                y: recipe.offset.height
            )
        }
    }
#endif
