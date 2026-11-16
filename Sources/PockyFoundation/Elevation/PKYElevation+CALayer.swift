import QuartzCore

public extension CALayer {
    /// Applies a semantic shadow without changing geometry, clipping, z-order, or shadowPath.
    ///
    /// The default converts visual downward offsets to negative y on macOS and positive y on iOS.
    /// For a custom coordinate hierarchy, pass whether positive y is visually downward explicitly;
    /// isGeometryFlipped alone does not describe every transformed ancestor hierarchy.
    /// Reapply when the caller's effective appearance or resolved shadow color changes.
    /// - Parameters:
    ///   - style: The surface relationship to express.
    ///   - color: The caller's already-resolved shadow color.
    ///   - appearance: The caller's current effective appearance, defaulting to light.
    ///   - positiveYIsDown: Overrides the platform coordinate default when supplied.
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

    /// Clears only the four owned shadow properties, preserving clipping, geometry, and shadowPath.
    func pkyRemoveElevation() {
        shadowColor = nil
        shadowOpacity = 0
        shadowRadius = 0
        shadowOffset = .zero
    }
}
