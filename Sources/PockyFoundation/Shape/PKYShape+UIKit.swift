#if os(iOS)
    import UIKit

    @available(iOS 26.0, *)
    public extension UIView {
        /// Applies native capsule corners that update with the view's size, suitable for elongated
        /// custom controls; resolves to a circle when width equals height.
        ///
        /// Sets corner geometry only; content clipping is owned by the component, and system
        /// controls retain their native configuration.
        func pkyApplyCapsuleCorners() {
            cornerConfiguration = .capsule()
        }

        /// Applies native concentric corners from container geometry; may resolve to square corners
        /// when no container corner is nearby.
        ///
        /// Sets corner geometry only; use the minimum-radius overload for surfaces that must stay
        /// rounded.
        func pkyApplyConcentricCorners() {
            cornerConfiguration = .corners(radius: .containerConcentric(minimum: nil))
        }

        /// Applies concentric corners with a minimum radius while letting the system update the
        /// final shape with view and container geometry.
        ///
        /// - Parameter minimum: A `PKYShape.Radius` role matching the surface purpose, or a local
        ///   minimum for a dedicated component.
        func pkyApplyConcentricCorners(minimum: CGFloat) {
            cornerConfiguration = .corners(radius: .containerConcentric(minimum: minimum))
        }

        /// Applies the same fixed continuous corner radius to all four corners, suitable for
        /// surfaces that must keep a stable shape during reuse or scrolling.
        ///
        /// Sets corner geometry only; content clipping is owned by the component.
        ///
        /// - Parameter radius: A `PKYShape.Radius` role matching the surface purpose, or a fixed
        ///   radius for a dedicated component.
        func pkyApplyFixedCorners(radius: CGFloat) {
            cornerConfiguration = .corners(radius: .fixed(radius))
        }
    }
#endif
