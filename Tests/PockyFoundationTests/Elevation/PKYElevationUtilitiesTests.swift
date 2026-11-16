#if os(iOS)
    import PockyFoundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor
    struct PKYElevationUtilitiesTests {
        @Test("ELEV-01/T01 Subtle uses the slight-separation recipe")
        func subtleUsesSlightSeparationRecipe() {
            let layer = CALayer()
            let color = UIColor.red.cgColor

            layer.pkyApplyElevation(.subtle, color: color)

            #expect(layer.shadowColor == color)
            #expect(layer.shadowOpacity == 0.12)
            #expect(layer.shadowRadius == 3)
            #expect(layer.shadowOffset == CGSize(width: 0, height: 1))
        }

        @Test("ELEV-01/T02 Floating uses the clear-detachment recipe")
        func floatingUsesClearDetachmentRecipe() {
            let layer = CALayer()
            let color = UIColor.blue.cgColor

            layer.pkyApplyElevation(.floating, color: color)

            #expect(layer.shadowColor == color)
            #expect(layer.shadowOpacity == 0.16)
            #expect(layer.shadowRadius == 18)
            #expect(layer.shadowOffset == CGSize(width: 0, height: 8))
        }

        @Test("ELEV-05/T01 mediaContent uses the tight legibility shadow recipe over media")
        func mediaContentUsesTightLegibilityRecipe() {
            let layer = CALayer()
            let color = UIColor.black.cgColor

            layer.pkyApplyElevation(.mediaContent, color: color)

            #expect(layer.shadowColor == color)
            #expect(layer.shadowOpacity == 0.45)
            #expect(layer.shadowRadius == 1)
            #expect(layer.shadowOffset == CGSize(width: 0, height: 1))
        }

        @Test("ELEV-05/T02 mediaHalo uses the wide halo recipe for grouped content over media")
        func mediaHaloUsesWideHaloRecipe() {
            let layer = CALayer()
            let color = UIColor.black.cgColor

            layer.pkyApplyElevation(.mediaHalo, color: color)

            #expect(layer.shadowColor == color)
            #expect(layer.shadowOpacity == 0.25)
            #expect(layer.shadowRadius == 12)
            #expect(layer.shadowOffset == CGSize(width: 0, height: 2))
        }

        @Test("ELEV-05/T03 UIView preserves clipping and geometry when applying media elevation")
        func mediaStylesPreserveViewGeometry() {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 24))
            view.clipsToBounds = false
            view.layer.cornerRadius = PKYShape.Radius.tile

            view.pkyApplyElevation(.mediaContent, color: .black)

            #expect(view.layer.shadowOpacity == 0.45)
            #expect(view.clipsToBounds == false)
            #expect(view.layer.cornerRadius == PKYShape.Radius.tile)
            #expect(view.frame == CGRect(x: 0, y: 0, width: 80, height: 24))
        }

        @Test(
            "ELEV-02/T01 CALayer preserves component geometry and clipping when applying elevation"
        )
        func layerApplicationPreservesComponentGeometry() {
            let layer = CALayer()
            let path = CGPath(rect: CGRect(x: 1, y: 2, width: 30, height: 40), transform: nil)
            layer.masksToBounds = true
            layer.cornerRadius = PKYShape.Radius.tile
            layer.zPosition = 4
            layer.shadowPath = path

            layer.pkyApplyElevation(.floating, color: UIColor.black.cgColor)

            #expect(layer.masksToBounds)
            #expect(layer.cornerRadius == PKYShape.Radius.tile)
            #expect(layer.zPosition == 4)
            #expect(layer.shadowPath?.boundingBox == path.boundingBox)
        }

        @Test("ELEV-02/T02 CALayer clears only owned shadow properties when removing elevation")
        func layerRemovalClearsOnlyOwnedShadowProperties() {
            let layer = CALayer()
            let path = CGPath(rect: CGRect(x: 1, y: 2, width: 30, height: 40), transform: nil)
            layer.masksToBounds = true
            layer.cornerRadius = PKYShape.Radius.tile
            layer.zPosition = 4
            layer.shadowPath = path
            layer.pkyApplyElevation(.floating, color: UIColor.black.cgColor)

            layer.pkyRemoveElevation()

            #expect(layer.shadowColor == nil)
            #expect(layer.shadowOpacity == 0)
            #expect(layer.shadowRadius == 0)
            #expect(layer.shadowOffset == .zero)
            #expect(layer.masksToBounds)
            #expect(layer.cornerRadius == PKYShape.Radius.tile)
            #expect(layer.zPosition == 4)
            #expect(layer.shadowPath?.boundingBox == path.boundingBox)
        }

        @Test("ELEV-03/T01 UIView resolves dynamic shadow color using current traits")
        func viewResolvesDynamicColorUsingCurrentTraits() {
            let view = UIView()
            let window = hostingWindow(for: view, interfaceStyle: .dark)
            defer { window.isHidden = true }
            let color = UIColor { traits in
                traits.userInterfaceStyle == .dark ? .blue : .red
            }

            #expect(view.traitCollection.userInterfaceStyle == .dark)
            view.pkyApplyElevation(.subtle, color: color)

            #expect(view.layer.shadowColor == UIColor.blue.cgColor)
        }

        @Test(
            "ELEV-03/T02 UIView preserves component geometry and clipping across apply and remove"
        )
        func viewApplicationAndRemovalPreserveComponentGeometry() {
            guard #available(iOS 26.0, *) else {
                return
            }
            let view = UIView()
            let path = CGPath(rect: CGRect(x: 1, y: 2, width: 30, height: 40), transform: nil)
            view.clipsToBounds = true
            view.cornerConfiguration = .capsule()
            view.layer.zPosition = 4
            view.layer.shadowPath = path

            view.pkyApplyElevation(.subtle, color: .black)
            view.pkyRemoveElevation()

            #expect(view.clipsToBounds)
            #expect(view.cornerConfiguration == .capsule())
            #expect(view.layer.zPosition == 4)
            #expect(view.layer.shadowPath?.boundingBox == path.boundingBox)
        }

        @Test("ELEV-04/T01 SwiftUI elevation preserves layout size")
        func swiftUIElevationPreservesLayoutSize() {
            let content = Color.red.frame(width: 100, height: 40)

            let renderer = ImageRenderer(
                content: content.pkyElevation(.floating, color: .black)
            )
            renderer.scale = 1

            #expect(renderer.uiImage?.size == CGSize(width: 100, height: 40))
        }

        private func hostingWindow(
            for view: UIView,
            interfaceStyle: UIUserInterfaceStyle
        ) -> UIWindow {
            let controller = UIViewController()
            controller.view.addSubview(view)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            window.overrideUserInterfaceStyle = interfaceStyle
            window.rootViewController = controller
            window.isHidden = false
            window.layoutIfNeeded()
            return window
        }
    }
#endif
