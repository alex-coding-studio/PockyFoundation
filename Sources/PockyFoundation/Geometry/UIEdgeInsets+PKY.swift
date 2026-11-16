#if os(iOS)
    import UIKit

    public extension UIEdgeInsets {
        /// Creates symmetric insets along physical axes; negative values expand outward. Use
        /// `NSDirectionalEdgeInsets.pky` for directional layouts.
        ///
        /// - Parameters:
        ///   - horizontal: Left and right inset, defaulting to `0`.
        ///   - vertical: Top and bottom inset, defaulting to `0`.
        static func pky(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> UIEdgeInsets {
            UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        }
    }

    public extension NSDirectionalEdgeInsets {
        /// Creates symmetric insets along directional axes; use the native initializer when all
        /// four edges differ.
        ///
        /// - Parameters:
        ///   - horizontal: Leading and trailing inset, defaulting to `0`.
        ///   - vertical: Top and bottom inset, defaulting to `0`.
        static func pky(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> NSDirectionalEdgeInsets {
            NSDirectionalEdgeInsets(
                top: vertical,
                leading: horizontal,
                bottom: vertical,
                trailing: horizontal
            )
        }
    }
#endif
