#if os(iOS)
    import UIKit

    public extension UILabel {
        static func pkyMultiline(alignment: NSTextAlignment = .center) -> UILabel {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = alignment
            return label
        }
    }
#endif
