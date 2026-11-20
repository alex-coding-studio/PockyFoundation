import CoreGraphics
import PockyFoundation
import SwiftUI
import Testing

struct RoleRelationshipsTests {
    @Test("Motion durations increase from quick to extended")
    func durationsIncrease() {
        let durations = [
            PKYMotion.Duration.quick,
            PKYMotion.Duration.standard,
            PKYMotion.Duration.slow,
            PKYMotion.Duration.long,
            PKYMotion.Duration.extended,
        ]
        #expect(zip(durations, durations.dropFirst()).allSatisfy { $0 < $1 })
    }

    @Test("Spring bounce increases and damping matches SwiftUI springs")
    func springsIncreaseAndMatchSwiftUI() {
        let springs = [PKYMotion.Spring.smooth, .snappy, .bouncy, .pop]
        #expect(zip(springs, springs.dropFirst()).allSatisfy { $0.bounce < $1.bounce })
        for spring in springs {
            let native = SwiftUI.Spring(
                duration: PKYMotion.Duration.standard,
                bounce: spring.bounce
            )
            #expect(abs(native.dampingRatio - spring.dampingRatio) < 0.000_1)
        }
    }

    @Test("Opacity roles increase from tint to glass tint and the focus scrim stays translucent")
    func opacityRolesIncrease() {
        #expect(PKYOpacity.focusScrim > 0)
        #expect(PKYOpacity.focusScrim < 1)
        #expect(PKYOpacity.tint < PKYOpacity.focusScrim)
        #expect(PKYOpacity.focusScrim < PKYOpacity.dimmed)
        #expect(PKYOpacity.dimmed < PKYOpacity.glassTint)
    }

    @Test("Stroke widths and surface radii increase with emphasis")
    func shapeRolesIncrease() {
        #expect(PKYShape.Stroke.standard < PKYShape.Stroke.strong)
        #expect(PKYShape.Stroke.strong < PKYShape.Stroke.heavy)
        #expect(PKYShape.Stroke.heavy < PKYShape.Stroke.display)
        #expect(PKYShape.Radius.content <= PKYShape.Radius.card)
        #expect(PKYShape.Radius.card < PKYShape.Radius.panel)
    }

    @Test("Icon sizes increase from accessory to feature")
    func iconSizesIncrease() {
        let icons = PKYIcon.Size.allCases.map(\.pointSize)
        #expect(zip(icons, icons.dropFirst()).allSatisfy { $0 < $1 })
    }

    @Test(
        "Layout gaps, insets, and sizes keep their ordering within each variant",
        arguments: [PKYLayout.Variant.compact, .standard, .wide]
    )
    func layoutRolesKeepOrdering(variant: PKYLayout.Variant) {
        #expect(PKYLayout.Gap.content(variant) < PKYLayout.Gap.group(variant))
        #expect(PKYLayout.Gap.group(variant) <= PKYLayout.Gap.section(variant))
        #expect(
            PKYLayout.Inset.control.vertical(variant) <= PKYLayout.Inset.control.horizontal(variant)
        )
        #expect(PKYLayout.Inset.row.vertical(variant) < PKYLayout.Inset.row.horizontal(variant))
        #expect(PKYLayout.Size.button(variant) <= PKYLayout.Size.row(variant))
    }

    @Test("The minimum target covers compact buttons and auxiliary buttons stay smaller")
    func targetsCoverCompactButtons() {
        #expect(PKYLayout.Size.auxiliaryButton < PKYLayout.Size.button(.compact))
        #expect(PKYLayout.Target.minimum >= PKYLayout.Size.button(.compact))
    }
}
