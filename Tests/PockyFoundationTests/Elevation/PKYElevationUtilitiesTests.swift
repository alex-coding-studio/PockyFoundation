#if os(iOS)
    import PockyFoundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor
    struct PKYElevationUtilitiesTests {
        @Test("ELEV-01/T01 UIView applies recipe and preserves component geometry")
        func viewAppliesRecipeAndPreservesGeometry() {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 24))
            let originalFrame = view.frame
            let originalCornerRadius = PKYShape.Radius.tile
            view.clipsToBounds = false
            view.layer.cornerRadius = originalCornerRadius

            view.pkyApplyElevation(.floating, color: .black)

            let recipe = PKYElevation.Style.floating.recipe
            #expect(view.layer.shadowOpacity == Float(recipe.opacity))
            #expect(view.layer.shadowRadius == recipe.radius)
            #expect(view.layer.shadowOffset == recipe.offset)
            #expect(view.clipsToBounds == false)
            #expect(view.layer.cornerRadius == originalCornerRadius)
            #expect(view.frame == originalFrame)
        }

        @Test(
            "ELEV-03/T01 UIView resolves dynamic shadow color and recipe using current traits"
        )
        func viewResolvesDynamicColorUsingCurrentTraits() {
            let view = UIView()
            let window = hostingWindow(for: view, interfaceStyle: .dark)
            defer { window.isHidden = true }
            let color = UIColor { traits in
                traits.userInterfaceStyle == .dark ? .blue : .red
            }

            #expect(view.traitCollection.userInterfaceStyle == .dark)
            view.pkyApplyElevation(.subtle, color: color)

            let darkSubtle = PKYElevation.Style.subtle.recipe(for: .dark)
            let lightSubtle = PKYElevation.Style.subtle.recipe(for: .light)
            #expect(view.layer.shadowColor == UIColor.blue.cgColor)
            #expect(view.layer.shadowOpacity == Float(darkSubtle.opacity))
            #expect(view.layer.shadowOpacity > Float(lightSubtle.opacity))

            view.pkyApplyElevation(.insetIndicator, color: color)
            #expect(view.layer.shadowOpacity == 0)
            #expect(view.layer.shadowRadius == 0)

            let lightView = UIView()
            let lightWindow = hostingWindow(for: lightView, interfaceStyle: .light)
            defer { lightWindow.isHidden = true }
            #expect(lightView.traitCollection.userInterfaceStyle == .light)

            lightView.pkyApplyElevation(.subtle, color: color)
            #expect(lightView.layer.shadowColor == UIColor.red.cgColor)
            #expect(lightView.layer.shadowOpacity == Float(lightSubtle.opacity))

            lightView.pkyApplyElevation(.insetIndicator, color: color)
            let lightInset = PKYElevation.Style.insetIndicator.recipe(for: .light)
            #expect(lightView.layer.shadowOpacity == Float(lightInset.opacity))
            #expect(lightView.layer.shadowOpacity > 0)
            #expect(lightView.layer.shadowRadius == lightInset.radius)
        }

        @Test(
            "ELEV-03/T02 UIView preserves component geometry and clipping across apply and remove"
        )
        func viewApplicationAndRemovalPreserveComponentGeometry() {
            let view = UIView()
            let path = CGPath(rect: CGRect(x: 1, y: 2, width: 30, height: 40), transform: nil)
            view.clipsToBounds = true
            view.cornerConfiguration = .capsule()
            view.layer.zPosition = 4
            view.layer.shadowPath = path

            view.pkyApplyElevation(.subtle, color: .black)
            view.pkyRemoveElevation()

            #expect(view.layer.shadowColor == nil)
            #expect(view.layer.shadowOpacity == 0)
            #expect(view.layer.shadowRadius == 0)
            #expect(view.layer.shadowOffset == .zero)
            #expect(view.clipsToBounds)
            #expect(view.cornerConfiguration == .capsule())
            #expect(view.layer.zPosition == 4)
            #expect(view.layer.shadowPath?.boundingBox == path.boundingBox)
        }

        @Test("ELEV-04/T01 SwiftUI elevation preserves layout size")
        func swiftUIElevationPreservesLayoutSize() {
            let content = Color.red.frame(width: 100, height: 40)

            let baseline = ImageRenderer(content: content)
            baseline.scale = 1
            let elevated = ImageRenderer(
                content: content.pkyElevation(.floating, color: .black)
            )
            elevated.scale = 1

            #expect(elevated.uiImage?.size != nil)
            #expect(elevated.uiImage?.size == baseline.uiImage?.size)
        }

        @Test("ELEV-04/T02 SwiftUI elevation resolves appearance recipe from colorScheme")
        func swiftUIElevationResolvesAppearanceFromColorScheme() {
            let lightSubtleShadow = outerShadowAlphaSum(style: .subtle, colorScheme: .light)
            let darkSubtleShadow = outerShadowAlphaSum(style: .subtle, colorScheme: .dark)
            #expect(lightSubtleShadow > 0)
            #expect(darkSubtleShadow > lightSubtleShadow)

            let lightInsetShadow = outerShadowAlphaSum(
                style: .insetIndicator,
                colorScheme: .light
            )
            let darkInsetShadow = outerShadowAlphaSum(
                style: .insetIndicator,
                colorScheme: .dark
            )
            #expect(lightInsetShadow > 0)
            #expect(darkInsetShadow == 0)
        }

        private func outerShadowAlphaSum(
            style: PKYElevation.Style,
            colorScheme: ColorScheme
        ) -> Int {
            let content = Color.white
                .frame(width: 40, height: 40)
                .pkyElevation(style, color: .black)
                .frame(width: 80, height: 80)
                .environment(\.colorScheme, colorScheme)
            let renderer = ImageRenderer(content: content)
            renderer.scale = 1
            renderer.isOpaque = false
            guard let cgImage = renderer.cgImage else {
                Issue.record("Failed to render SwiftUI elevation view")
                return -1
            }
            let width = cgImage.width
            let height = cgImage.height
            var pixels = [UInt8](repeating: 0, count: width * height * 4)
            guard
                let context = CGContext(
                    data: &pixels,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width * 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            else {
                Issue.record("Failed to create CGContext for shadow alpha inspection")
                return -1
            }
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            var alphaSum = 0
            for y in 0 ..< height {
                for x in 0 ..< width {
                    let insideInnerBox = x >= 20 && x < 60 && y >= 20 && y < 60
                    if !insideInnerBox {
                        alphaSum += Int(pixels[(y * width + x) * 4 + 3])
                    }
                }
            }
            return alphaSum
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
