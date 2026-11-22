import Foundation

#if os(iOS)
    import UIKit
#endif

public extension PKYLayout {
    enum ContentWidth {
        public static let maximum: CGFloat = 560

        #if os(iOS)
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
