import SwiftUI

public extension View {
    /// Applies a shared elevation shadow to a SwiftUI view, resolving the appearance recipe and
    /// dynamic colors against the environment.
    ///
    /// Preserves layout size and shape; clipping and state behavior remain component-owned. SwiftUI
    /// offsets are visually downward on both iOS and macOS, so recipes apply without conversion.
    ///
    /// - Parameters:
    ///   - style: The shadow role chosen for the surface relationship or media legibility.
    ///   - color: The shadow color provided by the theme or component.
    /// - Returns: A view with the specified elevation shadow.
    func pkyElevation(_ style: PKYElevation.Style, color: Color) -> some View {
        modifier(PKYElevationModifier(style: style, color: color))
    }
}

private struct PKYElevationModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let style: PKYElevation.Style
    let color: Color

    func body(content: Content) -> some View {
        let appearance: PKYElevation.Appearance = colorScheme == .dark ? .dark : .light
        let recipe = style.recipe(for: appearance)
        content.shadow(
            color: color.opacity(recipe.opacity),
            radius: recipe.radius,
            x: recipe.offset.width,
            y: recipe.offset.height
        )
    }
}
