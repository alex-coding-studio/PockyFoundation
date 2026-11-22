import SwiftUI

public extension View {
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
