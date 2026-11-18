#if os(iOS)
    import UIKit

    public extension UILabel {
        /// Creates a label with unlimited lines, centered by default for short multiline text.
        static func pkyMultiline(alignment: NSTextAlignment = .center) -> UILabel {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = alignment
            return label
        }
    }
#endif
