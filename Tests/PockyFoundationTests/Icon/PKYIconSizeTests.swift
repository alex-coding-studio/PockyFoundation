#if os(iOS)
    import PockyFoundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor
    struct PKYIconSizeTests {
        @Test(
            "ICON-01/T01 Five icon size roles resolve to 12, 16, 18, 20, and 24 pt in ascending order"
        )
        func sizeRolesResolveToAcceptedPointSizes() {
            #expect(PKYIcon.Size.accessory.pointSize == 12)
            #expect(PKYIcon.Size.badge.pointSize == 16)
            #expect(PKYIcon.Size.control.pointSize == 18)
            #expect(PKYIcon.Size.item.pointSize == 20)
            #expect(PKYIcon.Size.feature.pointSize == 24)

            let ladder = PKYIcon.Size.allCases.map(\.pointSize)
            #expect(ladder == [12, 16, 18, 20, 24])
        }

        @Test("ICON-01/T02 UIKit symbol configuration and image use the role point size and weight")
        func uiKitSymbolUsesPointSizeAndWeight() {
            let configuration = PKYIcon.Size.control.symbolConfiguration(weight: .semibold)
            #expect(configuration == UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
            #expect(
                PKYIcon.Size.accessory.symbolConfiguration()
                    == UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
            )

            let image = PKYIcon.Size.item.image(systemName: "checkmark", weight: .bold)
            let reference = UIImage(
                systemName: "checkmark",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            )
            let smaller = PKYIcon.Size.accessory.image(systemName: "checkmark", weight: .bold)
            #expect(image != nil)
            #expect(image?.size == reference?.size)
            #expect((smaller?.size.width ?? 0) < (image?.size.width ?? 0))
            #expect(PKYIcon.Size.item.image(systemName: "pocky.missing.symbol") == nil)
        }

        @Test(
            "ICON-01/T03 SwiftUI font resolves to a system font with the same point size and weight"
        )
        func swiftUIFontUsesPointSizeAndWeight() {
            let featureSize: CGFloat = 24
            let badgeSize: CGFloat = 16
            #expect(
                PKYIcon.Size.feature.font(weight: .semibold)
                    == Font.system(size: featureSize, weight: .semibold)
            )
            #expect(PKYIcon.Size.badge.font() == Font.system(size: badgeSize, weight: .regular))
        }
    }
#endif
