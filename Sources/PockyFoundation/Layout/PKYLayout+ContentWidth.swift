import Foundation

#if os(iOS)
    import UIKit
#endif

public extension PKYLayout {
    /// A maximum width and centering tools for content that should not stretch indefinitely.
    ///
    /// Narrow regions use the available inset width; wide regions expand up to ``maximum``.
    /// Callers choose the content or components to constrain; backgrounds and full-width media
    /// retain their own layout.
    enum ContentWidth {
        /// The maximum width, in points, allowed for the selected content.
        public static let maximum: CGFloat = 560

        #if os(iOS)
            /// Centers a view horizontally in a content lane and prefers filling that lane.
            ///
            /// The lane adds insets to the supplied boundaries and subtracts the excess on either side of
            /// the host's content-width guide. Callers supply vertical constraints.
            ///
            /// - Parameters:
            ///   - view: The view to constrain horizontally.
            ///   - host: The host containing the layout guides.
            ///   - leading: The original leading boundary of the lane.
            ///   - trailing: The original trailing boundary of the lane.
            ///   - inset: The additional inset inside each original boundary.
            @MainActor
            public static func pin(
                _ view: UIView,
                in host: UIView,
                leading: NSLayoutXAxisAnchor,
                trailing: NSLayoutXAxisAnchor,
                inset: CGFloat
            ) {
                let lane = lane(in: host, leading: leading, trailing: trailing, inset: inset)
                let fills = view.widthAnchor.constraint(equalTo: lane.widthAnchor)
                fills.priority = .defaultHigh
                NSLayoutConstraint.activate([
                    view.centerXAnchor.constraint(equalTo: lane.centerXAnchor),
                    view.widthAnchor.constraint(lessThanOrEqualTo: lane.widthAnchor),
                    fills,
                ])
            }

            /// Creates a constrained content lane for views that share boundaries or align to either side.
            ///
            /// Each call creates a guide; retain and reuse the returned guide for a shared lane.
            ///
            /// - Parameters:
            ///   - host: The host containing the guide.
            ///   - leading: The original leading boundary of the lane.
            ///   - trailing: The original trailing boundary of the lane.
            ///   - inset: The additional inset on each side.
            /// - Returns: A lane guide with horizontal constraints already installed.
            @MainActor
            public static func lane(
                in host: UIView,
                leading: NSLayoutXAxisAnchor,
                trailing: NSLayoutXAxisAnchor,
                inset: CGFloat
            ) -> UILayoutGuide {
                let margins = host.layoutMarginsGuide
                let content = host.pkyContentWidthGuide
                let leadingExcess = UILayoutGuide()
                let trailingExcess = UILayoutGuide()
                let leadingShift = UILayoutGuide()
                let trailingShift = UILayoutGuide()
                let lane = UILayoutGuide()
                for guide in [leadingExcess, trailingExcess, leadingShift, trailingShift, lane] {
                    host.addLayoutGuide(guide)
                }
                NSLayoutConstraint.activate([
                    leadingExcess.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                    leadingExcess.trailingAnchor.constraint(equalTo: content.leadingAnchor),
                    trailingExcess.leadingAnchor.constraint(equalTo: content.trailingAnchor),
                    trailingExcess.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                    leadingShift.leadingAnchor.constraint(equalTo: leading, constant: inset),
                    leadingShift.widthAnchor.constraint(equalTo: leadingExcess.widthAnchor),
                    trailingShift.trailingAnchor.constraint(equalTo: trailing, constant: -inset),
                    trailingShift.widthAnchor.constraint(equalTo: trailingExcess.widthAnchor),
                    lane.leadingAnchor.constraint(equalTo: leadingShift.trailingAnchor),
                    lane.trailingAnchor.constraint(equalTo: trailingShift.leadingAnchor),
                ])
                return lane
            }
        #endif
    }
}

#if os(iOS)
    public extension UIView {
        private static let pkyContentWidthGuideID = "pky.contentWidth"

        /// A guide centered inside the view's layout margins and bounded by the content-width maximum.
        ///
        /// Created on first access and reused thereafter. Its vertical extent matches the margins;
        /// its horizontal extent shrinks with the available space.
        var pkyContentWidthGuide: UILayoutGuide {
            if let guide = layoutGuides.first(
                where: { $0.identifier == Self.pkyContentWidthGuideID }
            ) {
                return guide
            }
            let guide = UILayoutGuide()
            guide.identifier = Self.pkyContentWidthGuideID
            addLayoutGuide(guide)
            let margins = layoutMarginsGuide
            let fills = guide.widthAnchor.constraint(equalTo: margins.widthAnchor)
            fills.priority = .defaultHigh
            NSLayoutConstraint.activate([
                guide.topAnchor.constraint(equalTo: margins.topAnchor),
                guide.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
                guide.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
                guide.widthAnchor.constraint(lessThanOrEqualTo: margins.widthAnchor),
                guide.widthAnchor.constraint(
                    lessThanOrEqualToConstant: PKYLayout.ContentWidth.maximum
                ),
                fills,
            ])
            return guide
        }
    }
#endif
