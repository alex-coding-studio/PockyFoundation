#if os(iOS)
    import PockyFoundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor
    struct PKYIconSizeTests {
        @Test("ICON-01/T02 UIKit symbol configuration and image use the role point size and weight")
        func uiKitSymbolUsesPointSizeAndWeight() {
            let control = PKYIcon.Size.control
            let accessory = PKYIcon.Size.accessory
            let item = PKYIcon.Size.item

            #expect(
                control.symbolConfiguration(weight: .semibold)
                    == UIImage.SymbolConfiguration(pointSize: control.pointSize, weight: .semibold)
            )
            #expect(
                accessory.symbolConfiguration()
                    == UIImage.SymbolConfiguration(pointSize: accessory.pointSize, weight: .regular)
            )

            let image = item.image(systemName: "checkmark", weight: .bold)
            let reference = UIImage(
                systemName: "checkmark",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: item.pointSize,
                    weight: .bold
                )
            )
            let smaller = accessory.image(systemName: "checkmark", weight: .bold)
            #expect(image != nil)
            #expect(image?.size == reference?.size)
            #expect((smaller?.size.width ?? 0) < (image?.size.width ?? 0))
            #expect(item.image(systemName: "pocky.missing.symbol") == nil)
        }

        @Test(
            "ICON-01/T03 SwiftUI font resolves to a system font with the same point size and weight"
        )
        func swiftUIFontUsesPointSizeAndWeight() {
            let feature = PKYIcon.Size.feature
            let badge = PKYIcon.Size.badge
            #expect(
                feature.font(weight: .semibold)
                    == Font.system(size: feature.pointSize, weight: .semibold)
            )
            #expect(badge.font() == Font.system(size: badge.pointSize, weight: .regular))
        }
    }
#endif
