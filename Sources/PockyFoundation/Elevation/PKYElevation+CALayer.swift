import QuartzCore

public extension CALayer {
    func pkyApplyElevation(
        _ style: PKYElevation.Style,
        color: CGColor,
        appearance: PKYElevation.Appearance = .light,
        positiveYIsDown: Bool? = nil
    ) {
        #if os(macOS)
            let downward = positiveYIsDown ?? false
        #else
            let downward = positiveYIsDown ?? true
        #endif
        let recipe = style.recipe(for: appearance)
        shadowColor = color
        shadowOpacity = Float(recipe.opacity)
        shadowRadius = recipe.radius
        shadowOffset = CGSize(
            width: recipe.offset.width,
            height: recipe.offset.height * (downward ? 1 : -1)
        )
    }

    func pkyRemoveElevation() {
        shadowColor = nil
        shadowOpacity = 0
        shadowRadius = 0
        shadowOffset = .zero
    }
}
