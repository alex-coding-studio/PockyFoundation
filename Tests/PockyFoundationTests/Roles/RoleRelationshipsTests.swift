import CoreGraphics
import PockyFoundation
import SwiftUI
import Testing

struct RoleRelationshipsTests {
    @Test("Semantic roles preserve relative emphasis")
    func rolesPreserveRelationships() {
        let durations = [
            PKYMotion.Duration.quick,
            .init(PKYMotion.Duration.standard),
            PKYMotion.Duration.slow,
            PKYMotion.Duration.long,
            PKYMotion.Duration.extended,
        ]
        #expect(zip(durations, durations.dropFirst()).allSatisfy { $0 < $1 })
        let springs = [PKYMotion.Spring.smooth, .snappy, .bouncy, .pop]
        #expect(zip(springs, springs.dropFirst()).allSatisfy { $0.bounce < $1.bounce })
        for spring in springs {
            let native = SwiftUI.Spring(
                duration: PKYMotion.Duration.standard,
                bounce: spring.bounce
            )
            #expect(abs(native.dampingRatio - spring.dampingRatio) < 0.000_1)
        }
        #expect(PKYOpacity.tint < PKYOpacity.dimmed)
        #expect(PKYOpacity.dimmed < PKYOpacity.glassTint)
        #expect(PKYShape.Stroke.standard < PKYShape.Stroke.strong)
        #expect(PKYShape.Stroke.strong < PKYShape.Stroke.heavy)
        #expect(PKYShape.Stroke.heavy < PKYShape.Stroke.display)
        #expect(PKYShape.Radius.content <= PKYShape.Radius.card)
        #expect(PKYShape.Radius.card < PKYShape.Radius.panel)
        let icons = PKYIcon.Size.allCases.map(\.pointSize)
        #expect(zip(icons, icons.dropFirst()).allSatisfy { $0 < $1 })
        for variant in [PKYLayout.Variant.compact, .standard, .wide] {
            #expect(PKYLayout.Gap.content(variant) < PKYLayout.Gap.group(variant))
            #expect(PKYLayout.Gap.group(variant) <= PKYLayout.Gap.section(variant))
            #expect(
                PKYLayout.Inset.control.vertical(variant) <= PKYLayout.Inset.control.horizontal(
                    variant
                )
            )
            #expect(PKYLayout.Inset.row.vertical(variant) < PKYLayout.Inset.row.horizontal(variant))
            #expect(PKYLayout.Size.button(variant) <= PKYLayout.Size.row(variant))
        }
        #expect(PKYLayout.Size.auxiliaryButton < PKYLayout.Size.button(.compact))
        #expect(PKYLayout.Target.minimum >= PKYLayout.Size.button(.compact))
    }

    @Test("Desktop grids use the accepted tray density without a device lookup")
    func desktopGridUsesWindowGeometry() {
        #if os(macOS)
            let role = PKYGridPlacementRole.tile(captioned: false)
            let output = role.resolve(width: 480, device: .unknown)
            #expect(output.columns == 4)
            #expect(output.width(spanning: output.columns) == output.contentWidth)
            #expect(role.rowSpacing == role.columnSpacing)
            #expect(PKYShape.Radius.content < PKYShape.Radius.card)
        #endif
    }
}
