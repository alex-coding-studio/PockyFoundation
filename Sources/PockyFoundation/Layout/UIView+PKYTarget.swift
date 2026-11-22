#if os(iOS)
    import UIKit

    public extension UIView {
        var pkyMinimumTargetBounds: CGRect {
            bounds.insetBy(
                dx: -max(0, PKYLayout.Target.minimum - bounds.width) / 2,
                dy: -max(0, PKYLayout.Target.minimum - bounds.height) / 2
            )
        }
    }
#endif
