#if os(iOS)
    import UIKit

    public extension UIView {
        /// Resolves the color against the view's current traits and applies the shared elevation.
        ///
        /// The layer stores the resolved `CGColor`; reapply after appearance, contrast, or theme
        /// changes. Preserves the view's clipping, corners, layout, and `shadowPath`.
        ///
        /// - Parameters:
        ///   - style: The shadow role chosen for the surface relationship or media legibility.
        ///   - color: The shadow color provided by the theme or component.
        func pkyApplyElevation(_ style: PKYElevation.Style, color: UIColor) {
            layer.pkyApplyElevation(
                style,
                color: color.resolvedColor(with: traitCollection).cgColor
            )
        }

        /// Clears the managed elevation properties while preserving the component's clipping,
        /// corners, layout, and `shadowPath`.
        func pkyRemoveElevation() {
            layer.pkyRemoveElevation()
        }
    }
#endif
