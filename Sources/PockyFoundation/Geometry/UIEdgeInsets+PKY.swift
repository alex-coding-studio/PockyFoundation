#if os(iOS)
    import UIKit

    public extension UIEdgeInsets {
        static func pky(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> UIEdgeInsets {
            UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        }
    }
#elseif os(macOS)
    import AppKit
#endif

public extension NSDirectionalEdgeInsets {
    static func pky(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }
}
