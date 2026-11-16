import CoreGraphics
import PockyFoundation
import QuartzCore
import Testing

@MainActor
struct PKYElevationTests {
    @Test(
        "Layer adaptation preserves geometry and resolves downward offsets in both coordinate directions"
    )
    func layerAdaptationAndRemoval() {
        let layer = CALayer()
        let path = CGPath(rect: CGRect(x: 1, y: 2, width: 30, height: 40), transform: nil)
        layer.masksToBounds = true
        layer.cornerRadius = PKYShape.Radius.card
        layer.shadowPath = path
        let originalRadius = layer.cornerRadius
        let originalBounds = layer.bounds
        let color = CGColor(gray: 0, alpha: 1)
        layer.pkyApplyElevation(.subtle, color: color, positiveYIsDown: true)
        let downward = layer.shadowOffset
        #expect(layer.shadowColor == color)
        #expect(layer.shadowOpacity > 0)
        layer.pkyApplyElevation(.subtle, color: color, positiveYIsDown: false)
        #expect(layer.shadowOffset.height == -downward.height)
        layer.pkyApplyElevation(.subtle, color: color)
        #if os(macOS)
            #expect(layer.shadowOffset.height < 0)
        #else
            #expect(layer.shadowOffset.height > 0)
        #endif
        #expect(layer.masksToBounds)
        #expect(layer.cornerRadius == originalRadius)
        #expect(layer.bounds == originalBounds)
        #expect(layer.shadowPath?.boundingBox == path.boundingBox)
        layer.pkyRemoveElevation()
        #expect(layer.shadowColor == nil)
        #expect(layer.shadowOpacity == 0)
        #expect(layer.shadowRadius == 0)
        #expect(layer.shadowOffset == .zero)
        #expect(layer.shadowPath?.boundingBox == path.boundingBox)
        #expect(layer.cornerRadius == originalRadius)
    }

    @Test("Appearance selects the shadow recipe on every platform")
    func appearanceResolvesRecipes() {
        let light = PKYElevation.Style.subtle.recipe(for: .light)
        let dark = PKYElevation.Style.subtle.recipe(for: .dark)
        #expect(light.radius == dark.radius)
        #expect(light.offset == dark.offset)
        #expect(light.opacity < dark.opacity)
        #expect(PKYElevation.Style.insetIndicator.recipe(for: .light).opacity > 0)
        #expect(PKYElevation.Style.insetIndicator.recipe(for: .dark).opacity == 0)
        for style in [PKYElevation.Style.floating, .mediaContent, .mediaHalo] {
            let layer = CALayer()
            layer.pkyApplyElevation(style, color: CGColor(gray: 0, alpha: 1))
            #expect(layer.shadowRadius > 0)
            #expect(layer.shadowOpacity > 0 && layer.shadowOpacity <= 1)
        }
    }
}
