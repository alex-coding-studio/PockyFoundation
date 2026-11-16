#if os(iOS)
    import UIKit

    public extension UIStackView {
        /// Creates a stack with its arranged subviews and common configuration in one call.
        ///
        /// Defaults match UIKit; specify only settings that differ. Spacing usually comes from layout
        /// roles such as `PKYLayout.Gap`. This initializer preserves
        /// `translatesAutoresizingMaskIntoConstraints`: callers placing the stack with Auto Layout
        /// disable it themselves. Use native UIStackView APIs for custom spacing, margins, and visibility.
        ///
        /// - Parameters:
        ///   - arrangedSubviews: The subviews in arrangement order.
        ///   - axis: The arrangement axis; horizontal by default.
        ///   - spacing: The spacing between adjacent subviews; zero by default.
        ///   - alignment: Alignment perpendicular to the axis; fill by default.
        ///   - distribution: Distribution along the axis; fill by default.
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
