#if os(iOS)
    import PockyFoundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor
    struct PKYShapeUtilitiesTests {
        @Test("SHAPE-01/T01 UIKit capsule corners track the view's shortest dimension")
        func uiKitCapsuleTracksViewGeometry() {
            guard #available(iOS 26.0, *) else {
                return
            }
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

            view.pkyApplyCapsuleCorners()
            view.layoutIfNeeded()

            #expect(view.effectiveRadius(corner: .topLeft) == 20)

            view.bounds.size.height = 60
            view.layoutIfNeeded()

            #expect(view.effectiveRadius(corner: .topLeft) == 30)
        }

        @Test("SHAPE-02/T01 UIKit concentric corners resolve from container radius and inset")
        func uiKitConcentricTracksContainerGeometry() {
            guard #available(iOS 26.0, *) else {
                return
            }
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            container.cornerConfiguration = .corners(radius: .fixed(30))
            let child = UIView(frame: CGRect(x: 8, y: 8, width: 84, height: 84))
            container.addSubview(child)
            let window = hostingWindow(for: container)
            defer { window.isHidden = true }

            child.pkyApplyConcentricCorners()
            window.layoutIfNeeded()

            #expect(child.effectiveRadius(corner: .topLeft) == 22)
        }

        @Test(
            "SHAPE-02/T02 UIKit concentric minimum preserves minimum radius without a rounded container"
        )
        func uiKitConcentricMinimumPreventsSquareCorner() {
            guard #available(iOS 26.0, *) else {
                return
            }
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            let child = UIView(frame: CGRect(x: 8, y: 8, width: 84, height: 84))
            container.addSubview(child)
            let window = hostingWindow(for: container)
            defer { window.isHidden = true }

            child.pkyApplyConcentricCorners(minimum: 12)
            window.layoutIfNeeded()

            #expect(child.effectiveRadius(corner: .topLeft) == 12)
        }

        @Test("SHAPE-03/T01 SwiftUI shape utilities clip content without changing layout size")
        func swiftUIUtilitiesPreserveLayoutSize() {
            guard #available(iOS 26.0, *) else {
                return
            }
            let content = Color.red.frame(width: 100, height: 40)
            let expected = CGSize(width: 100, height: 40)

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
            guard #available(iOS 26.0, *) else {
                return
            }
            let cases: [(radius: CGFloat, expected: CGFloat)] = [
                (PKYShape.Radius.compact, 14),
                (PKYShape.Radius.content, 16),
                (PKYShape.Radius.card, 22),
            ]

            for item in cases {
                let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                let child = UIView(frame: CGRect(x: 8, y: 8, width: 84, height: 84))
                container.addSubview(child)
                let window = hostingWindow(for: container)
                defer { window.isHidden = true }

                child.pkyApplyConcentricCorners(minimum: item.radius)
                window.layoutIfNeeded()

                #expect(child.effectiveRadius(corner: .topLeft) == item.expected)
            }
        }

        @Test("SHAPE-07/T01 Tile radius is 10 pt and smaller than compact")
        func tileRadiusIsSmallerThanCompact() {
            #expect(PKYShape.Radius.tile == 10)
            #expect(PKYShape.Radius.tile < PKYShape.Radius.compact)
        }

        @Test("SHAPE-07/T02 Tile radius works directly as concentric minimum and fixed radius")
        func tileRadiusWorksWithShapeUtilities() {
            guard #available(iOS 26.0, *) else {
                return
            }
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            let concentric = UIView(frame: CGRect(x: 8, y: 8, width: 36, height: 36))
            let fixed = UIView(frame: CGRect(x: 52, y: 8, width: 36, height: 36))
            container.addSubview(concentric)
            container.addSubview(fixed)
            let window = hostingWindow(for: container)
            defer { window.isHidden = true }

            concentric.pkyApplyConcentricCorners(minimum: PKYShape.Radius.tile)
            fixed.pkyApplyFixedCorners(radius: PKYShape.Radius.tile)
            window.layoutIfNeeded()

            #expect(concentric.effectiveRadius(corner: .topLeft) == 10)
            #expect(fixed.effectiveRadius(corner: .bottomRight) == 10)
        }

        @Test("SHAPE-08/T01 Floating panel radius is 30 pt and larger than card")
        func panelRadiusIsLargerThanCard() {
            #expect(PKYShape.Radius.panel == 30)
            #expect(PKYShape.Radius.panel > PKYShape.Radius.card)
        }

        @Test("SHAPE-08/T02 Panel radius works directly as concentric minimum and fixed radius")
        func panelRadiusWorksWithShapeUtilities() {
            guard #available(iOS 26.0, *) else {
                return
            }
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
            let concentric = UIView(frame: CGRect(x: 8, y: 8, width: 180, height: 180))
            let fixed = UIView(frame: CGRect(x: 212, y: 8, width: 180, height: 180))
            container.addSubview(concentric)
            container.addSubview(fixed)
            let window = hostingWindow(for: container)
            defer { window.isHidden = true }

            concentric.pkyApplyConcentricCorners(minimum: PKYShape.Radius.panel)
            fixed.pkyApplyFixedCorners(radius: PKYShape.Radius.panel)
            window.layoutIfNeeded()

            #expect(concentric.effectiveRadius(corner: .topLeft) == 30)
            #expect(fixed.effectiveRadius(corner: .bottomRight) == 30)
        }

        @Test("SHAPE-06/T01 UIKit fixed corners ignore container concentric geometry")
        func uiKitFixedCornersIgnoreContainerGeometry() {
            guard #available(iOS 26.0, *) else {
                return
            }
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            container.cornerConfiguration = .corners(radius: .fixed(60))
            let child = UIView(frame: CGRect(x: 8, y: 8, width: 184, height: 184))
            container.addSubview(child)
            let window = hostingWindow(for: container)
            defer { window.isHidden = true }

            child.pkyApplyFixedCorners(radius: PKYShape.Radius.card)
            window.layoutIfNeeded()

            #expect(child.effectiveRadius(corner: .topLeft) == 22)
            #expect(child.effectiveRadius(corner: .bottomRight) == 22)
            #expect(child.clipsToBounds == false)
        }

        @Test(
            "SHAPE-05/T01 Semantic stroke widths work directly with UIKit and Core Animation line widths"
        )
        func semanticStrokeWidthsWorkWithNativeDrawingAPIs() {
            let borderLayer = CALayer()
            borderLayer.borderWidth = PKYShape.Stroke.standard
            let shapeLayer = CAShapeLayer()
            shapeLayer.lineWidth = PKYShape.Stroke.strong

            #expect(borderLayer.borderWidth == 0.5)
            #expect(shapeLayer.lineWidth == 2)
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
