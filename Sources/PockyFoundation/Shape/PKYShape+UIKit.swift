#if os(iOS)
    import UIKit

    public extension UIView {
        func pkyApplyCapsuleCorners() {
            cornerConfiguration = .capsule()
        }

        func pkyApplyConcentricCorners() {
            cornerConfiguration = .corners(radius: .containerConcentric(minimum: nil))
        }

        func pkyApplyConcentricCorners(minimum: CGFloat) {
            cornerConfiguration = .corners(radius: .containerConcentric(minimum: minimum))
        }

        func pkyApplyFixedCorners(radius: CGFloat) {
            cornerConfiguration = .corners(radius: .fixed(radius))
        }
    }
#endif
