#if os(iOS)
    import UIKit

    public extension UIStackView {
        convenience init(
            pkyArranged arrangedSubviews: [UIView],
            axis: NSLayoutConstraint.Axis = .horizontal,
            spacing: CGFloat = 0,
            alignment: UIStackView.Alignment = .fill,
            distribution: UIStackView.Distribution = .fill
        ) {
            self.init(arrangedSubviews: arrangedSubviews)
            self.axis = axis
            self.spacing = spacing
            self.alignment = alignment
            self.distribution = distribution
        }
    }
#endif
