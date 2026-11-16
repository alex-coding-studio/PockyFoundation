#if os(iOS)
    import PockyFoundation
    import Testing
    import UIKit

    @MainActor
    struct PKYLayoutContentWidthTests {
        private static let inset: CGFloat = 4

        @Test(
            "CONTENT-WIDTH-01/T01 Wide content shrinks relative to its host while remaining centered"
        )
        func pinnedViewKeepsFullLaneUntilMaximum() {
            let narrow = layout(width: 393)
            let wide = layout(width: 1180)

            #expect(
                narrow.view.bounds.width / narrow.host.bounds.width > wide.view.bounds.width / wide.host.bounds.width
            )
            for result in [narrow, wide] {
                #expect(result.view.frame.minX >= result.host.bounds.minX)
                #expect(result.view.frame.maxX <= result.host.bounds.maxX)
                #expect(abs(result.view.center.x - result.host.bounds.midX) < 0.5)
            }
        }

        @Test("CONTENT-WIDTH-01/T02 Each host reuses one content guide centered within its margins")
        func contentWidthGuideIsSharedAndCentered() {
            let host = UIView(frame: CGRect(x: 0, y: 0, width: 1180, height: 600))
            let guide = host.pkyContentWidthGuide
            host.layoutIfNeeded()

            #expect(host.pkyContentWidthGuide === guide)
            #expect(host.layoutGuides.count { $0.identifier == guide.identifier } == 1)
            #expect(guide.layoutFrame.minX >= host.layoutMarginsGuide.layoutFrame.minX)
            #expect(guide.layoutFrame.maxX <= host.layoutMarginsGuide.layoutFrame.maxX)
            #expect(guide.layoutFrame.width < host.layoutMarginsGuide.layoutFrame.width)
            #expect(abs(guide.layoutFrame.midX - host.layoutMarginsGuide.layoutFrame.midX) < 0.5)
        }

        private func layout(width: CGFloat) -> (host: UIView, view: UIView) {
            let host = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 600))
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            host.addSubview(view)
            view.topAnchor.constraint(equalTo: host.topAnchor).isActive = true
            view.heightAnchor.constraint(equalToConstant: 40).isActive = true
            PKYLayout.ContentWidth.pin(
                view,
                in: host,
                leading: host.leadingAnchor,
                trailing: host.trailingAnchor,
                inset: Self.inset
            )
            host.layoutIfNeeded()
            return (host, view)
        }
    }
#endif
