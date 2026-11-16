#if os(iOS)
    import PockyFoundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor
    struct PKYShapeUtilitiesTests {
        @Test("SHAPE-01/T01 UIKit capsule corners track the view's shortest dimension")
        func uiKitCapsuleTracksViewGeometry() {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

            view.pkyApplyCapsuleCorners()
            view.layoutIfNeeded()

            #expect(view.effectiveRadius(corner: .topLeft) == view.bounds.height / 2)

            view.bounds.size.height = 60
            view.layoutIfNeeded()

            #expect(view.effectiveRadius(corner: .topLeft) == view.bounds.height / 2)
        }

        @Test("SHAPE-02/T01 UIKit concentric corners resolve from container radius and inset")
        func uiKitConcentricTracksContainerGeometry() {
            let containerRadius = PKYShape.Radius.panel
            let inset: CGFloat = 8
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            container.cornerConfiguration = .corners(radius: .fixed(containerRadius))
            let child = UIView(
                frame: CGRect(
                    x: inset,
                    y: inset,
                    width: container.bounds.width - inset * 2,
                    height: container.bounds.height - inset * 2
                )
            )
            container.addSubview(child)
            let window = hostingWindow(for: container)
            defer { window.isHidden = true }

            child.pkyApplyConcentricCorners()
            window.layoutIfNeeded()

            #expect(child.effectiveRadius(corner: .topLeft) == containerRadius - inset)
        }

        @Test("SHAPE-03/T01 SwiftUI shape utilities clip content without changing layout size")
        func swiftUIUtilitiesPreserveLayoutSize() {
            let content = Color.red.frame(width: 100, height: 40)
            let expected = renderedSize(content)

            #expect(expected != .zero)
            #expect(renderedSize(content.pkyClipCapsule()) == expected)
            #expect(renderedSize(content.pkyClipConcentric()) == expected)
            #expect(
                renderedSize(
                    content.pkyClipConcentric(minimum: PKYShape.Radius.content)
                ) == expected
            )
        }

        @Test(
            "SHAPE-04/T01 Semantic Radius roles act as concentric minimums without a rounded container"
        )
        func semanticRadiiPreventConcentricSquareCorners() {
            let roles = [
                PKYShape.Radius.tile,
                PKYShape.Radius.compact,
                PKYShape.Radius.content,
                PKYShape.Radius.card,
                PKYShape.Radius.panel,
            ]

            for radius in roles {
                let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
                let child = UIView(frame: CGRect(x: 8, y: 8, width: 180, height: 180))
                container.addSubview(child)
                let window = hostingWindow(for: container)
                defer { window.isHidden = true }

                child.pkyApplyConcentricCorners(minimum: radius)
                window.layoutIfNeeded()

                #expect(child.effectiveRadius(corner: .topLeft) == radius)
            }
        }

        @Test("SHAPE-06/T01 UIKit fixed corners ignore container concentric geometry")
        func uiKitFixedCornersIgnoreContainerGeometry() {
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            container.cornerConfiguration = .corners(radius: .fixed(PKYShape.Radius.panel * 2))
            let child = UIView(frame: CGRect(x: 8, y: 8, width: 184, height: 184))
            container.addSubview(child)
            let window = hostingWindow(for: container)
            defer { window.isHidden = true }

            child.pkyApplyFixedCorners(radius: PKYShape.Radius.card)
            window.layoutIfNeeded()

            #expect(child.effectiveRadius(corner: .topLeft) == PKYShape.Radius.card)
            #expect(child.effectiveRadius(corner: .bottomRight) == PKYShape.Radius.card)
            #expect(child.clipsToBounds == false)
        }

        private func renderedSize(_ view: some View) -> CGSize {
            let renderer = ImageRenderer(content: view)
            renderer.scale = 1
            return renderer.uiImage?.size ?? .zero
        }

        /// Hosts `view` at the center of a window, away from every window corner.
        ///
        /// Since iOS 27, `containerConcentric` also resolves against the display's rounded corners
        /// when a view sits near a corner of its root hierarchy. Centering keeps the display corners
        /// out of range, so the container under test is the only candidate ancestor geometry.
        private func hostingWindow(for view: UIView) -> UIWindow {
            let controller = UIViewController()
            controller.view.addSubview(view)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            window.rootViewController = controller
            window.isHidden = false
            view.center = CGPoint(x: controller.view.bounds.midX, y: controller.view.bounds.midY)
            return window
        }
    }
#endif
