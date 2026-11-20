import CoreGraphics
import PockyFoundation
import SwiftUI
import Testing

@MainActor
struct PKYElevationSwiftUITests {
    private struct ShadowAlpha {
        var outside = 0
        var above = 0
        var below = 0
    }

    @Test("SwiftUI elevation preserves layout size")
    func swiftUIElevationPreservesLayoutSize() {
        let content = Color.red.frame(width: 100, height: 40)

        let baseline = ImageRenderer(content: content)
        baseline.scale = 1
        let elevated = ImageRenderer(
            content: content.pkyElevation(.floating, color: .black)
        )
        elevated.scale = 1

        #expect(elevated.cgImage != nil)
        #expect(elevated.cgImage?.width == baseline.cgImage?.width)
        #expect(elevated.cgImage?.height == baseline.cgImage?.height)
    }

    @Test("SwiftUI elevation resolves appearance recipe from colorScheme")
    func swiftUIElevationResolvesAppearanceFromColorScheme() {
        let lightSubtleShadow = shadowAlpha(style: .subtle, colorScheme: .light).outside
        let darkSubtleShadow = shadowAlpha(style: .subtle, colorScheme: .dark).outside
        #expect(lightSubtleShadow > 0)
        #expect(darkSubtleShadow > lightSubtleShadow)

        let lightInsetShadow = shadowAlpha(style: .insetIndicator, colorScheme: .light).outside
        let darkInsetShadow = shadowAlpha(style: .insetIndicator, colorScheme: .dark).outside
        #expect(lightInsetShadow > 0)
        #expect(darkInsetShadow == 0)
    }

    @Test("SwiftUI elevation casts downward recipe offsets below the content on every platform")
    func swiftUIElevationCastsShadowDownward() {
        let floating = shadowAlpha(style: .floating, colorScheme: .light)
        #expect(floating.below > floating.above)
    }

    private func shadowAlpha(style: PKYElevation.Style, colorScheme: ColorScheme) -> ShadowAlpha {
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
            return ShadowAlpha()
        }
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let createdContext = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard
                let baseAddress = buffer.baseAddress,
                let context = CGContext(
                    data: baseAddress,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width * 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            else {
                return false
            }
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard createdContext else {
            Issue.record("Failed to create CGContext for shadow alpha inspection")
            return ShadowAlpha()
        }
        var alpha = ShadowAlpha()
        for y in 0 ..< height {
            for x in 0 ..< width {
                let value = Int(pixels[(y * width + x) * 4 + 3])
                let insideInnerBox = x >= 20 && x < 60 && y >= 20 && y < 60
                if !insideInnerBox {
                    alpha.outside += value
                }
                if y < 20 {
                    alpha.above += value
                } else if y >= 60 {
                    alpha.below += value
                }
            }
        }
        return alpha
    }
}
