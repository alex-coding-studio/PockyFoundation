#if os(iOS)
    import UIKit

    public extension UIView {
        /// The effective interaction bounds expanded to ``PKYLayout/Target/minimum`` in the view's coordinates.
        ///
        /// Use this in `point(inside:with:)` for controls smaller than the minimum target, and convert it
        /// to `accessibilityFrame` when the VoiceOver target should match. Only hit and accessibility
        /// areas grow; layout and visible size stay unchanged. Axes already meeting the minimum retain
        /// their original bounds.
        var pkyMinimumTargetBounds: CGRect {
            bounds.insetBy(
                dx: -max(0, PKYLayout.Target.minimum - bounds.width) / 2,
                dy: -max(0, PKYLayout.Target.minimum - bounds.height) / 2
            )
        }
    }
#endif
